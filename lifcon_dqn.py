import numpy as np
import mxnet as mx
from mxnet import gluon
from mxnet.gluon import nn

from lifcon import Move, Wait, next_int, prev_int, STATE_GOING_UP, STATE_GOING_DOWN, STATE_EMPTY


class Swish(gluon.HybridBlock):
    r"""
    Swish Activation function
        https://arxiv.org/pdf/1710.05941.pdf

    Parameters
    ----------
    beta : float
        swish(x) = x * sigmoid(beta*x)


    Inputs:
        - **data**: input tensor with arbitrary shape.

    Outputs:
        - **out**: output tensor with the same shape as `data`.
    """

    def __init__(self, beta=1.0, **kwargs):
        super(Swish, self).__init__(**kwargs)
        self._beta = beta

    def hybrid_forward(self, F, x):
        return x * F.sigmoid(self._beta * x, name='fwd')


class LiftControllerDQN(gluon.HybridBlock):
    def __init__(self, nlifts, nfloors, loc_denom, **kwargs):
        super(LiftControllerDQN, self).__init__(**kwargs)

        # nliftinfo = members + locations + move state (stop/up/down) + liftid
        self.nliftinfo = nfloors + nfloors*loc_denom + 3 + nlifts
        self.nsideinfo = nfloors*2 + 16  # nsideinfo = wait up/down flags + tick in 16 bits
        self.nactions = 6

        self.nlifts = nlifts
        self.nfloors = nfloors
        self.loc_denom = loc_denom

        with self.name_scope():
            self.feats = nn.HybridSequential()

            self.liftvec_embed = nn.Dense(512, flatten=False)
            self.sidevec_embed = nn.Dense(512, flatten=False)

            self.self_trans = nn.Dense(512, flatten=False)
            self.other_trans = nn.Dense(512, flatten=False)

            self.act_q = nn.Dense(self.nactions, flatten=False)

    def hybrid_forward(self, F, liftmat, sidevec):
        #sidevec: batchsize x nsideinfo
        #liftmat: batchsize x nlifts x nliftinfo

        swish = Swish()

        lift_emb = self.liftvec_embed(liftmat)
        side_emb = self.sidevec_embed(sidevec).reshape((-1, 1, 512)).tile(reps=(1, self.nlifts, 1))

        hs = swish(lift_emb + side_emb)  # First hidden layer
        # hs: batchsize x nlifts x 512

        selfvecs = self.self_trans(hs)  # selfvec: batchsize x nlifts x 512
        othervecs = self.other_trans(hs)  # compute max exclufing self row
        othervecs = othervecs.split(num_outputs=self.nlifts, axis=1)  # othervecs: [batchsize x 1 x 512; nlifts]

        l = []
        for lid in range(self.nlifts):
            all_other = [othervecs[i] for i in range(self.nlifts) if i != lid]
            v = F.concat(*all_other)
            v = v.max(axis=1)
            v = v.reshape((-1, 1, 512))
            l.append(v)

        othervecs = F.concat(*l, dim=1)  # othervecs: batchsize x nlifts x 512
        last_h = swish(selfvecs + othervecs)  # last_h: batchsize x nlifts x 512
        qs = self.act_q(last_h)  # qs =: batchsize x nlifts x nactions

        return qs

    def encode_state(self, status, tick):
        # sidevec
        side_wait_up = np.zeros((self.nfloors,))
        side_wait_down = np.zeros((self.nfloors,))
        side_tickvec = np.zeros((16,))

        for b in range(16):
            if tick % 2 > 0:
                side_tickvec[b] = 1.0
            tick //= 2

        for f in range(self.nfloors):
            if status.wait_up[f]:
                side_wait_up[f] = 1.0
            if status.wait_down[f]:
                side_wait_down[f] = 1.0

        sidevec = np.r_[side_wait_up, side_wait_down, side_tickvec]

        liftvecs = []  # liftvecs

        for lid in range(self.nlifts):
            members = np.zeros((self.nfloors,))
            for p in status.members[lid]:
                members[p.dest_floor] = 1.0

            locations = np.zeros((self.nfloors * self.loc_denom,))
            loc_id = round(status.locations[lid] * self.loc_denom)
            locations[loc_id] = 1.0

            move = np.zeros((3,))

            j = 0
            if status.status[lid] == STATE_EMPTY:
                j = 0
            elif status.status[lid] == STATE_GOING_UP:
                j = 1
            elif status.status[lid] == STATE_GOING_DOWN:
                j = 2
            else:
                assert False
            move[j] = 1.0

            liftid = np.zeros((self.nlifts,))
            liftid[lid] = 1.0

            liftvecs.append(np.r_[members, locations, move, liftid])

        liftmat = np.array(liftvecs)
        return liftmat, sidevec

    def make_action_selector(self, status, goals, accept_sts):
        act = np.zeros((self.nlifts, self.nactions))

        desc2aid = {
            ("WAIT", True): 0,
            ("UP", True): 1,
            ("DOWN", True): 2,
            ("WAIT", False): 3,
            ("UP", False): 4,
            ("DOWN", False): 5,
        }

        for lid in range(self.nlifts):
            dir = "WAIT"
            if goals[lid] == Wait():
                dir = "WAIT"
            else:
                dest = goals[lid].dest
                if dest > status.locations[lid]: # up
                    dir = "UP"
                elif dest < status.locations[lid]: # down
                    dir = "DOWN"
                else:
                    dir = "WAIT"

            desc = (dir, accept_sts[lid])
            act[lid, desc2aid[desc]] = 1.0

        return act

    def make_action(self, qs, status, epsilon):

        aid2dir = ["WAIT", "UP", "DOWN", "WAIT", "UP", "DOWN"]
        aid2accflag = [True, True, True, False, False, False]

        acts = []

        accept_sts = []
        goals = []

        for lid in range(self.nlifts):
            if epsilon > 0 and np.random.rand() < epsilon:
                maxaid = np.random.randint(0, len(aid2dir))
            else:
                maxaid = qs[lid, :].argmax()

            accept_sts.append(aid2accflag[maxaid])
            dir = aid2dir[maxaid]

            if dir == "WAIT":
                goals.append(Wait())
            elif dir == "UP": # up
                goals.append(Move(dest=self.nfloors - 1))
            elif dir == "DOWN": # down
                goals.append(Move(dest=0))
            else:
                assert False

        return goals, accept_sts


class DQNController:
    def __init__(self, world, paramfile, epsilon, ctx=None):
        self.world = world
        self.nlifts = self.world.nlifts
        self.nfloors = self.world.nfloors
        self.loc_denom = self.world.lift_inv_speed
        self.epsilon = epsilon

        self.dqn = LiftControllerDQN(self.nlifts, self.nfloors, self.loc_denom)
        if ctx is None:
            ctx = mx.cpu()

        self.dqn.load_params(paramfile, ctx=ctx)

    def tick(self, status, tick):
        liftmat, sidevec = self.dqn.encode_state(status, tick)
        qs = self.dqn(mx.nd.array(liftmat), mx.nd.array(sidevec))

        assert qs.shape[0] == 1
        assert qs.shape[1] == self.nlifts

        acts = self.dqn.make_action(qs.asnumpy()[0], status, self.epsilon)

        return acts

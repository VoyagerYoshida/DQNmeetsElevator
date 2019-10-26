import yaml
import argparse
import numpy as np

import mxnet as mx

from lifcon import World
from lifcon_dqn import LiftControllerDQN


parser = argparse.ArgumentParser()
parser.add_argument('--world', type=str, help='world configuration')
parser.add_argument('--saveparam', type=str, default=None, help='Write DQN parameter')
parser.add_argument('--seed', type=int, default=0, help='seed')

opt = parser.parse_args()

world_conf = yaml.load(open(opt.world).read())
world = World(world_conf)

mx.random.seed(opt.seed)

dqn = LiftControllerDQN(world.nlifts, world.nfloors, world.lift_inv_speed)
dqn.initialize(mx.init.MSRAPrelu())
liftvecs = mx.nd.array(np.zeros((1, world.nlifts, dqn.nliftinfo)))
sidevec = mx.nd.array(np.zeros((1, dqn.nsideinfo)))

_ = dqn(liftvecs, sidevec)

dqn.save_params(opt.saveparam)

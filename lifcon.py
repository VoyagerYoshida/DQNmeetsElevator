from collections import namedtuple
import numpy as np
import math

Move = namedtuple("Move", ["dest"])
Wait = namedtuple("Wait", [])

STATE_GOING_UP = "up"
STATE_GOING_DOWN = "down"
STATE_EMPTY = "both"

ControllerStatus = namedtuple("ControllerStatus",
                              ["wait_up", "wait_down",
                               "locations", "members",
                               "status"])

Person = namedtuple("Person",
                    ["dest_floor", "spawn_floor", "spawn_tick"])

def make_person_from_jsval(v):
    return Person(
        dest_floor=int(v['df']),
        spawn_floor=int(v['sf']),
        spawn_tick=int(v['st']))



class World:
    def __init__(self, conf):
        self.nfloors = conf['num_floors']
        self.nlifts = conf['num_lifts']
        self.ticks_per_day = conf['tick_per_day']
        self.max_people_per_lift = conf['max_people_per_lift']
        self.lift_inv_speed = conf['lift_inv_speed']

        self.lift_stop_duration = conf['lift_stop_duration']

        self.spawn_lambdas = np.zeros((self.ticks_per_day, self.nfloors))
        self.destination_probs = {}
        for dest_conf in conf['destinations']:
            key = dest_conf['type']
            val = np.array(dest_conf['matrix'])
            val = val / np.array([val.sum(axis=1)]).T # normalize
            self.destination_probs[key] = val

        self.destination_types = [None for _ in range(self.ticks_per_day)]
        for spawn_conf in conf['people_incoming']:
            beg, end = spawn_conf['range']
            lambdas = np.array(spawn_conf['incoming_lambda'])
            self.spawn_lambdas[beg:end, :] = lambdas
            for t in range(beg, end):
                self.destination_types[t] = spawn_conf['destination_type']


    def spawn_people(self, tick):
        people = np.random.poisson(self.spawn_lambdas[tick])

        ret = [[] for _ in range(self.nfloors)]
        probmat = self.destination_probs[self.destination_types[tick]]
        for i, (n, ps) in enumerate(zip(people, probmat)):
            if n == 0:
                continue

            for _ in range(n):
                d = np.random.choice(range(self.nfloors), p=ps)
                ret[i].append(Person(dest_floor=d, spawn_floor=i, spawn_tick=tick))
        return ret

def next_int(fr):
    if fr.denominator == 1:
        return fr.numerator + 1
    else:
        return math.ceil(fr)

def prev_int(fr):
    if fr.denominator == 1:
        return fr.numerator - 1
    else:
        return math.floor(fr)

# Import Necessary Libraries
import numpy as np
import itertools
import matplotlib.pyplot as plt
import tiles3 as tc
from rl_glue import RLGlue
from agent import BaseAgent
from utils import argmax
import mountaincar_env
import time
from cartile import MountainCarTileCoder
from sarsa_agent import SarsaAgent

# -----------
# Tested Cell
# -----------

def grader_1():
    # The contents of the cell will be tested by the autograder.
    # If they do not pass here, they will not pass there.

    # create a range of positions and velocities to test
    # then test every element in the cross-product between these lists
    pos_tests = np.linspace(-1.2, 0.5, num=5)
    vel_tests = np.linspace(-0.07, 0.07, num=5)
    tests = list(itertools.product(pos_tests, vel_tests))

    mctc = MountainCarTileCoder(iht_size=1024, num_tilings=8, num_tiles=2)

    t = []
    for test in tests:
        position, velocity = test
        tiles = mctc.get_tiles(position=position, velocity=velocity)
        t.append(tiles)

    expected = [
        [0, 1, 2, 3, 4, 5, 6, 7],
        [0, 1, 8, 3, 9, 10, 6, 11],
        [12, 13, 8, 14, 9, 10, 15, 11],
        [12, 13, 16, 14, 17, 18, 15, 19],
        [20, 21, 16, 22, 17, 18, 23, 19],
        [0, 1, 2, 3, 24, 25, 26, 27],
        [0, 1, 8, 3, 28, 29, 26, 30],
        [12, 13, 8, 14, 28, 29, 31, 30],
        [12, 13, 16, 14, 32, 33, 31, 34],
        [20, 21, 16, 22, 32, 33, 35, 34],
        [36, 37, 38, 39, 24, 25, 26, 27],
        [36, 37, 40, 39, 28, 29, 26, 30],
        [41, 42, 40, 43, 28, 29, 31, 30],
        [41, 42, 44, 43, 32, 33, 31, 34],
        [45, 46, 44, 47, 32, 33, 35, 34],
        [36, 37, 38, 39, 48, 49, 50, 51],
        [36, 37, 40, 39, 52, 53, 50, 54],
        [41, 42, 40, 43, 52, 53, 55, 54],
        [41, 42, 44, 43, 56, 57, 55, 58],
        [45, 46, 44, 47, 56, 57, 59, 58],
        [60, 61, 62, 63, 48, 49, 50, 51],
        [60, 61, 64, 63, 52, 53, 50, 54],
        [65, 66, 64, 67, 52, 53, 55, 54],
        [65, 66, 68, 67, 56, 57, 55, 58],
        [69, 70, 68, 71, 56, 57, 59, 58],
    ]

    assert np.all(expected == np.array(t))

# -----------
# Tested Cell
# -----------

def grader_2():
    # The contents of the cell will be tested by the autograder.
    # If they do not pass here, they will not pass there.

    np.random.seed(0)

    agent = SarsaAgent()
    agent.agent_init({"epsilon": 0.1})
    agent.w = np.array([np.array([1, 2, 3]), np.array([4, 5, 6]), np.array([7, 8, 9])])

    action_distribution = np.zeros(3)
    for i in range(1000):
        chosen_action, action_value = agent.select_action(np.array([0,1]))
        action_distribution[chosen_action] += 1
        
    print("action distribution:", action_distribution)
    # notice that the two non-greedy actions are roughly uniformly distributed
    assert np.all(action_distribution == [29, 35, 936])

    agent = SarsaAgent()
    agent.agent_init({"epsilon": 0.0})
    agent.w = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])

    chosen_action, action_value = agent.select_action([0, 1])
    assert chosen_action == 2
    assert action_value == 15

    # -----------
    # test update
    # -----------
    agent = SarsaAgent()
    agent.agent_init({"epsilon": 0.1})

    agent.agent_start((0.1, 0.3))
    agent.agent_step(1, (0.02, 0.1))

    assert np.all(agent.w[0,0:8] == 0.0625)
    assert np.all(agent.w[1:] == 0)

# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

def grader_3():
    np.random.seed(0)

    num_runs = 10
    num_episodes = 50
    env_info = {"num_tiles": 8, "num_tilings": 8}
    agent_info = {}
    all_steps = []

    agent = SarsaAgent
    env = mountaincar_env.Environment
    start = time.time()

    for run in range(num_runs):
        if run % 5 == 0:
            print("RUN: {}".format(run))

        rl_glue = RLGlue(env, agent)
        rl_glue.rl_init(agent_info, env_info)
        steps_per_episode = []

        for episode in range(num_episodes):
            rl_glue.rl_episode(15000)
            steps_per_episode.append(rl_glue.num_steps)

        all_steps.append(np.array(steps_per_episode))

    print("Run time: {}".format(time.time() - start))

    mean = np.mean(all_steps, axis=0)
    plt.plot(mean)

    # because we set the random seed, these values should be *exactly* the same
    assert np.allclose(mean, [1432.5, 837.9, 694.4, 571.4, 515.2, 380.6, 379.4, 369.6, 357.2, 316.5, 291.1, 305.3, 250.1, 264.9, 235.4, 242.1, 244.4, 245., 221.2, 229., 238.3, 211.2, 201.1, 208.3, 185.3, 207.1, 191.6, 204., 214.5, 207.9, 195.9, 206.4, 194.9, 191.1, 195., 186.6, 171., 177.8, 171.1, 174., 177.1, 174.5, 156.9, 174.3, 164.1, 179.3, 167.4, 156.1, 158.4, 154.4])


# This result was using 8 tilings with 8x8 tiles on each. Let's see if we can do better, and what different tilings look like. We will also text 2 tilings of 16x16 and 4 tilings of 32x32. These three choices produce the same number of features (512), but distributed quite differently. 

# ---------------
# Discussion Cell
# ---------------

def grader_4():

    np.random.seed(0)

    # Compare the three
    num_runs = 20
    num_episodes = 100
    env_info = {}

    agent_runs = []
    # alphas = [0.2, 0.4, 0.5, 1.0]
    alphas = [0.5]
    agent_info_options = [{"num_tiles": 16, "num_tilings": 2, "alpha": 0.5},
                        {"num_tiles": 4, "num_tilings": 32, "alpha": 0.5},
                        {"num_tiles": 8, "num_tilings": 8, "alpha": 0.5}]
    agent_info_options = [{"num_tiles" : agent["num_tiles"], 
                        "num_tilings": agent["num_tilings"],
                        "alpha" : alpha} for agent in agent_info_options for alpha in alphas]

    agent = SarsaAgent
    env = mountaincar_env.Environment
    for agent_info in agent_info_options:
        all_steps = []
        start = time.time()
        for run in range(num_runs):
            if run % 5 == 0:
                print("RUN: {}".format(run))
            env = mountaincar_env.Environment
            
            rl_glue = RLGlue(env, agent)
            rl_glue.rl_init(agent_info, env_info)
            steps_per_episode = []

            for episode in range(num_episodes):
                rl_glue.rl_episode(15000)
                steps_per_episode.append(rl_glue.num_steps)
            all_steps.append(np.array(steps_per_episode))
        
        agent_runs.append(np.mean(np.array(all_steps), axis=0))
        print("stepsize:", rl_glue.agent.alpha)
        print("Run Time: {}".format(time.time() - start))

    plt.figure(figsize=(15, 10), dpi= 80, facecolor='w', edgecolor='k')
    plt.plot(np.array(agent_runs).T)
    plt.xlabel("Episode")
    plt.ylabel("Steps Per Episode")
    plt.yscale("linear")
    plt.ylim(0, 1000)
    plt.legend(["num_tiles: {}, num_tilings: {}, alpha: {}".format(agent_info["num_tiles"], 
                                                                agent_info["num_tilings"],
                                                                agent_info["alpha"])
                for agent_info in agent_info_options])




if __name__ == "__main__":
    
    grader_1()
    grader_2()
    grader_3()
    grader_4()
    pass
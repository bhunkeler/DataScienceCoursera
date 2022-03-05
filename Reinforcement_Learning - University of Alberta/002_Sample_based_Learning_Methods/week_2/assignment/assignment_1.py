 
# # Assignment: Policy Evaluation in Cliff Walking Environment
# 


import numpy as np
from rl_glue import RLGlue
from src.cliff_walk_environment import Cliffwalk_Environment
from src.td_agent import TDAgent
from manager import Manager
from itertools import product
from tqdm import tqdm
# import jdc
 
    
# --------------
# Debugging Cell
# --------------
# Feel free to make any changes to this cell to debug your code

def cw_env_4_12_grid():
    env = Cliffwalk_Environment()
    env.env_init({ "grid_height": 4, "grid_width": 12 })

    coords = [(0, 0), (0, 11), (1, 5), (3, 0), (3, 9), (3, 11)]
    correct_outputs = [0, 11, 17, 36, 45, 47]

    got = [env.state(s) for s in coords]
    assert got == correct_outputs

 
# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

def cw_env_rand_grid():
    np.random.seed(0)

    env = Cliffwalk_Environment()
    for n in range(100):
        # make a gridworld of random size and shape
        height = np.random.randint(2, 100)
        width = np.random.randint(2, 100)
        print('Env. : {0} x {1}'.format(height, width))
        env.env_init({ "grid_height": height, "grid_width": width })
        
        # generate some random coordinates within the grid
        idx_h = np.random.randint(height)
        idx_w = np.random.randint(width)
        
        # check that the state index is correct
        state = env.state((idx_h, idx_w))
        correct_state = width * idx_h + idx_w
        
        assert state == correct_state

# --------------
# Debugging Cell
# --------------
# Feel free to make any changes to this cell to debug your code

def test_action_up():
    env = Cliffwalk_Environment()
    env.env_init({"grid_height": 4, "grid_width": 12})
    env.agent_loc = (0, 0)
    env.env_step(0)
    assert(env.agent_loc == (0, 0))
    
    env.agent_loc = (1, 0)
    env.env_step(0)
    assert(env.agent_loc == (0, 0))
    
def test_reward():
    env = Cliffwalk_Environment()
    env.env_init({"grid_height": 4, "grid_width": 12})
    env.agent_loc = (0, 0)
    reward_state_term = env.env_step(0)
    assert(reward_state_term[0] == -1 and reward_state_term[1] == env.state((0, 0)) and
           reward_state_term[2] == False)
    
    env.agent_loc = (3, 1)
    reward_state_term = env.env_step(2)
    assert(reward_state_term[0] == -100 and reward_state_term[1] == env.state((3, 0)) and
           reward_state_term[2] == False)
    
    env.agent_loc = (2, 11)
    reward_state_term = env.env_step(2)
    assert(reward_state_term[0] == -1 and reward_state_term[1] == env.state((3, 11)) and
           reward_state_term[2] == True)
    
# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

def grader_cw_env_0():
    np.random.seed(0)

    env = Cliffwalk_Environment()
    for n in range(100):
        # create a cliff world of random size
        height = np.random.randint(2, 100)
        width = np.random.randint(2, 100)
        env.env_init({"grid_height": height, "grid_width": width})
        
        # start the agent in a random location
        idx_h = 0 if np.random.random() < 0.5 else np.random.randint(height)
        idx_w = np.random.randint(width)
        env.agent_loc = (idx_h, idx_w)
        
        env.env_step(0)
        assert(env.agent_loc == (0 if idx_h == 0 else idx_h - 1, idx_w))

 
# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

def grader_cw_env_1():
    np.random.seed(0)

    env = Cliffwalk_Environment()
    for n in range(100):
        # create a cliff world of random size
        height = np.random.randint(4, 10)
        width = np.random.randint(4, 10)
        env.env_init({"grid_height": height, "grid_width": width})
        env.env_start()
        
        # start the agent near the cliff
        idx_h = height - 2
        idx_w = np.random.randint(1, width - 2)
        env.agent_loc = (idx_h, idx_w)
        
        r, sp, term = env.env_step(2)
        assert(r == -100 and sp == (height - 1) * width and term == False)

    for n in range(100):
        # create a cliff world of random size
        height = np.random.randint(4, 10)
        width = np.random.randint(4, 10)
        env.env_init({"grid_height": height, "grid_width": width})
        env.env_start()
        
        # start the agent near the goal
        idx_h = height - 2
        idx_w = width - 1
        env.agent_loc = (idx_h, idx_w)
        
        r, sp, term = env.env_step(2)
        assert(r == -1 and sp == (height - 1) * width + (width - 1) and term == True)

    for n in range(100):
        # create a cliff world of random size
        height = np.random.randint(4, 10)
        width = np.random.randint(4, 10)
        env.env_init({"grid_height": height, "grid_width": width})
        env.env_start()
        
        # start the agent in a random location
        idx_h = np.random.randint(0, height - 3)
        idx_w = np.random.randint(0, width - 1)
        env.agent_loc = (idx_h, idx_w)
        
        r, sp, term = env.env_step(2)
        assert(r == -1 and term == False)

 
# --------------
# Debugging Cell
# --------------
# Feel free to make any changes to this cell to debug your code

# The following test checks that the TD check works for a case where the transition 
# garners reward -1 and does not lead to a terminal state. This is in a simple two state setting 
# where there is only one action. The first state's current value estimate is 0 while the second is 1.
# Note the discount and step size if you are debugging this test.

def agent_check():
    agent = TDAgent()
    policy_list = np.array([[1.], [1.]])
    agent.agent_init({"policy": np.array(policy_list), "discount": 0.99, "step_size": 0.1})
    agent.values = np.array([0., 1.])
    agent.agent_start(0)

    reward = -1
    next_state = 1
    agent.agent_step(reward, next_state)

    assert(np.isclose(agent.values[0], -0.001) and np.isclose(agent.values[1], 1.))

# The following test checks that the TD check works for a case where the transition 
# garners reward -100 and lead to a terminal state. This is in a simple one state setting 
# where there is only one action. The state's current value estimate is 0.
# Note the discount and step size if you are debugging this test.

def agent_check_cliff():
    agent = TDAgent()
    policy_list = np.array([[1.]])
    agent.agent_init({"policy": np.array(policy_list), "discount": 0.99, "step_size": 0.1})
    agent.values = np.array([0.])
    agent.agent_start(0)

    reward = -100
    next_state = 0
    agent.agent_end(reward)

    assert(np.isclose(agent.values[0], -10))
 
# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

def agent_test_0():
    agent = TDAgent()
    policy_list = [np.random.dirichlet(np.ones(10), size=1).squeeze() for _ in range(100)]

    for n in range(100):
        gamma = np.random.random()
        alpha = np.random.random()
        agent.agent_init({"policy": np.array(policy_list), "discount": gamma, "step_size": alpha})
        agent.values = np.random.randn(*agent.values.shape)
        state = np.random.randint(100)
        agent.agent_start(state)
        
        for _ in range(100):
            prev_agent_vals = agent.values.copy()
            reward = np.random.random()
            if np.random.random() > 0.1:
                next_state = np.random.randint(100)
                agent.agent_step(reward, next_state)
                prev_agent_vals[state] = prev_agent_vals[state] + alpha * (reward + gamma * prev_agent_vals[next_state] - prev_agent_vals[state])
                assert(np.allclose(prev_agent_vals, agent.values))
                state = next_state
            else:
                agent.agent_end(reward)
                prev_agent_vals[state] = prev_agent_vals[state] + alpha * (reward - prev_agent_vals[state])
                assert(np.allclose(prev_agent_vals, agent.values))
                break

 
# ---------------
# Discussion Cell
# ---------------

def run_experiment(env_info, agent_info,num_episodes=5000, experiment_name=None, plot_freq=100, true_values_file=None, value_error_threshold=1e-8):
    env = Cliffwalk_Environment
    agent = TDAgent
    rl_glue = RLGlue(env, agent)

    rl_glue.rl_init(agent_info, env_info)

    manager = Manager(env_info, agent_info, true_values_file=true_values_file, experiment_name=experiment_name)
    for episode in range(1, num_episodes + 1):
        rl_glue.rl_episode(0) # no step limit
        if episode % plot_freq == 0:
            values = rl_glue.agent.agent_message("get_values")
            manager.visualize(values, episode)

    values = rl_glue.agent.agent_message("get_values")
    return values, env, agent

 
# The cell below just runs a policy evaluation experiment with the determinstic optimal policy that strides just above the cliff. 
# You should observe that the per state value error and RMSVE curve asymptotically go towards 0. The arrows in the four directions 
# denote the probabilities of taking each action. This experiment is ungraded but should serve as a good test for the later experiments. 
# The true values file provided for this experiment may help with debugging as well.

 
# ---------------
# Discussion Cell
# ---------------
def policy_policy_evaluation():

    env_info = {"grid_height": 4, "grid_width": 12, "seed": 0}
    agent_info = {"discount": 1, "step_size": 0.01, "seed": 0}

    # The Optimal Policy that strides just along the cliff
    policy = np.ones(shape=(env_info['grid_width'] * env_info['grid_height'], 4)) * 0.25
    policy[36] = [1, 0, 0, 0]
    for i in range(24, 35):
        policy[i] = [0, 0, 0, 1]
    policy[35] = [0, 0, 1, 0]

    agent_info.update({"policy": policy})

    true_values_file = "optimal_policy_value_fn.npy"
    values, env, agent = run_experiment(env_info, agent_info, num_episodes=5000, experiment_name="Policy Evaluation on Optimal Policy",
                                        plot_freq=500, true_values_file=true_values_file)

    return env, agent, policy, env_info, agent_info

 
# -----------
# Graded Cell
# -----------

# The Safe Policy
# Hint: Fill in the array below (as done in the previous cell) based on the safe policy illustration 
# in the environment diagram. This is the policy that strides as far as possible away from the cliff. 
# We call it a "safe" policy because if the environment has any stochasticity, this policy would do a good job in 
# keeping the agent from falling into the cliff (in contrast to the optimal policy shown before). 

def grader_policy_0(env_info):
    # build a uniform random policy
    policy = np.ones(shape=(env_info['grid_width'] * env_info['grid_height'], 4)) * 0.25

    # build an example environment
    env = Cliffwalk_Environment()
    env.env_init(env_info)

    # modify the uniform random policy
    policy[36] = [1, 0, 0, 0]
    policy[24] = [1, 0, 0, 0]

    for i in range(0, 35):
        policy[i] = [1, 0, 0, 0]

    for i in range(0, 11):
        policy[i] = [0, 0, 0, 1]

    policy[11] = [0, 0, 1, 0]
    policy[23] = [0, 0, 1, 0]
    policy[35] = [0, 0, 1, 0]
    
    return env, policy
    # your code here


 
# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

def policy_test_0(env, env_info):
    width = env_info['grid_width']
    height = env_info['grid_height']

    # left side of space
    for x in range(1, height):
        s = env.state((x, 0))
        print(s)
        
        # go up
        assert np.all(policy[s] == [1, 0, 0, 0])

    # top of space
    for y in range(width - 1):
        s = env.state((0, y))

        # go right
        assert np.all(policy[s] == [0, 0, 0, 1])
        
    # right side of space
    for x in range(height - 1):
        s = env.state((x, width - 1))
        
        # go down
        assert np.all(policy[s] == [0, 0, 1, 0])

    # ---------------
    # Discussion Cell
    # ---------------

    agent_info.update({"policy": policy})
    v, env, agent = run_experiment(env_info, agent_info, experiment_name="Policy Evaluation On Safe Policy", num_episodes=5000, plot_freq=500)

 
# ---------------
# Discussion Cell
# ---------------

# A Near Optimal Stochastic Policy
# Now, we try a stochastic policy that deviates a little from the optimal policy seen above. 
# This means we can get different results due to randomness.
# We will thus average the value function estimates we get over multiple runs. 
# This can take some time, upto about 5 minutes from previous testing. 
# NOTE: The autograder will compare . Re-run this cell upon making any changes.

def optimal_stochastic_policy(env_info):
    env_info = {"grid_height": 4, "grid_width": 12}
    agent_info = {"discount": 1, "step_size": 0.01}

    policy = np.ones(shape=(env_info['grid_width'] * env_info['grid_height'], 4)) * 0.25
    policy[36] = [0.9, 0.1/3., 0.1/3., 0.1/3.]
    for i in range(24, 35):
        policy[i] = [0.1/3., 0.1/3., 0.1/3., 0.9]
    policy[35] = [0.1/3., 0.1/3., 0.9, 0.1/3.]
    agent_info.update({"policy": policy})
    agent_info.update({"step_size": 0.01})

 
    # ---------------
    # Discussion Cell
    # ---------------
    env_info['seed'] = 0
    agent_info['seed'] = 0
    v, env, agent = run_experiment(env_info, agent_info,
                                   experiment_name="Policy Evaluation On Optimal Policy",
                                   num_episodes=5000, plot_freq=100)

 
# ## Wrapping Up
# Congratulations, you have completed assignment 2! In this assignment, we investigated a very useful concept for sample-based online learning: temporal difference. We particularly looked at the prediction problem where the goal is to find the value function corresponding to a given policy. In the next assignment, by learning the action-value function instead of the state-value function, you will get to see how temporal difference learning can be used in control as well.


if __name__ == '__main__':

    # Environment check 
    cw_env_4_12_grid()
    cw_env_rand_grid()

    # Action / Reward check 
    test_action_up()
    test_reward()

    # Grading 
    grader_cw_env_0()
    grader_cw_env_1()

    # Agent implementation
    agent_check()
    agent_check_cliff()

    agent_test_0()

    env, agent, policy, env_info, agent_info = policy_policy_evaluation()
    env, policy = grader_policy_0(env_info)
    
    policy_test_0(env, env_info)
    optimal_stochastic_policy(env_info)

    pass
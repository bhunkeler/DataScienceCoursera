
import numpy as np
import matplotlib.pyplot as plt

# import jdc
from tqdm import tqdm

from rl_glue import RLGlue
from environment import BaseEnvironment
from agent import BaseAgent
import plot_script

# ---------------
# Discussion Cell
# ---------------

class RandomWalkEnvironment(BaseEnvironment):
    def env_init(self, env_info={}):
        """
        Setup for the environment called when the experiment first starts.
        
        Set parameters needed to setup the 500-state random walk environment.
        
        Assume env_info dict contains:
        {
            num_states: 500 [int],
            start_state: 250 [int],
            left_terminal_state: 0 [int],
            right_terminal_state: 501 [int],
            seed: int
        }
        """
        
        # set random seed for each run
        self.rand_generator = np.random.RandomState(env_info.get("seed")) 
        
        # set each class attribute
        self.num_states = env_info["num_states"] 
        self.start_state = env_info["start_state"] 
        self.left_terminal_state = env_info["left_terminal_state"] 
        self.right_terminal_state = env_info["right_terminal_state"]

    def env_start(self):
        """
        The first method called when the experiment starts, called before the
        agent starts.

        Returns:
            The first state from the environment.
        """

        # set self.reward_state_term tuple
        reward = 0.0
        state = self.start_state
        is_terminal = False
                
        self.reward_state_term = (reward, state, is_terminal)
        
        # return first state from the environment
        return self.reward_state_term[1]
        
    def env_step(self, action):
        """A step taken by the environment.

        Args:
            action: The action taken by the agent

        Returns:
            (float, state, Boolean): a tuple of the reward, state,
                and boolean indicating if it's terminal.
        """
        
        last_state = self.reward_state_term[1]
        
        # set reward, current_state, and is_terminal
        #
        # action: specifies direction of movement - 0 (indicating left) or 1 (indicating right)  [int]
        # current state: next state after taking action from the last state [int]
        # reward: -1 if terminated left, 1 if terminated right, 0 otherwise [float]
        # is_terminal: indicates whether the episode terminated [boolean]
        #
        # Given action (direction of movement), determine how much to move in that direction from last_state
        # All transitions beyond the terminal state are absorbed into the terminal state.
        
        if action == 0: # left
            current_state = max(self.left_terminal_state, last_state + self.rand_generator.choice(range(-100,0)))
        elif action == 1: # right
            current_state = min(self.right_terminal_state, last_state + self.rand_generator.choice(range(1,101)))
        else: 
            raise ValueError("Wrong action value")
        
        # terminate left
        if current_state == self.left_terminal_state: 
            reward = -1.0
            is_terminal = True
        
        # terminate right
        elif current_state == self.right_terminal_state:
            reward = 1.0
            is_terminal = True
        
        else:
            reward = 0.0
            is_terminal = False
        
        self.reward_state_term = (reward, current_state, is_terminal)
        
        return self.reward_state_term
        
# ---------------
# Discussion Cell
# ---------------

def agent_policy(rand_generator, state):
    """
    Given random number generator and state, returns an action according to the agent's policy.
    
    Args:
        rand_generator: Random number generator

    Returns:
        chosen action [int]
    """
    
    # set chosen_action as 0 or 1 with equal probability
    # state is unnecessary for this agent policy
    chosen_action = rand_generator.choice([0,1])
    
    return chosen_action

# -----------
# Graded Cell
# -----------
import math

def get_state_feature(num_states_in_group, num_groups, state):
    """
    Given state, return the feature of that state
    
    Args:
        num_states_in_group [int]
        num_groups [int] 
        state [int] : 1~500

    Returns:
        one_hot_vector [numpy array]
    """
    
    ### Generate state feature (2~4 lines)
    # Create one_hot_vector with size of the num_groups, according to state
    # For simplicity, assume num_states is always perfectly divisible by num_groups
    # Note that states start from index 1, not 0!
    
    # Example:
    # If num_states = 100, num_states_in_group = 20, num_groups = 5,
    # one_hot_vector would be of size 5.
    # For states 1~20, one_hot_vector would be: [1, 0, 0, 0, 0]
    # 
    # one_hot_vector = ?
    
    # your code here
    one_hot_vector = np.zeros(num_groups)
    pos = math.ceil((state / num_states_in_group))
    one_hot_vector[pos - 1] = 1
    # --------------
    
    return one_hot_vector


# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

# Given that num_states = 10 and num_groups = 5, test get_state_feature()
# There are states 1~10, and the state feature vector would be of size 5.
# Only one element would be active for any state feature vector.

# get_state_feature() should support various values of num_states, num_groups, not just this example
# For simplicity, assume num_states will always be perfectly divisible by num_groups
num_states = 10
num_groups = 5
num_states_in_group = int(num_states / num_groups)

# Test 1st group, state = 1
state = 1
features = get_state_feature(num_states_in_group, num_groups, state)
print("1st group: {}".format(features))

assert np.all(features == [1, 0, 0, 0, 0])

# Test 2nd group, state = 3
state = 3
features = get_state_feature(num_states_in_group, num_groups, state)
print("2nd group: {}".format(features))

assert np.all(features == [0, 1, 0, 0, 0])

# Test 3rd group, state = 6
state = 6
features = get_state_feature(num_states_in_group, num_groups, state)
print("3rd group: {}".format(features))

assert np.all(features == [0, 0, 1, 0, 0])

# Test 4th group, state = 7
state = 7
features = get_state_feature(num_states_in_group, num_groups, state)
print("4th group: {}".format(features))

assert np.all(features == [0, 0, 0, 1, 0])

# Test 5th group, state = 10
state = 10
features = get_state_feature(num_states_in_group, num_groups, state)
print("5th group: {}".format(features))

assert np.all(features == [0, 0, 0, 0, 1])

# -----------
# Graded Cell
# -----------



# Create TDAgent
class TDAgent(BaseAgent):
    def __init__(self):
        self.num_states = None
        self.num_groups = None
        self.step_size = None
        self.discount_factor = None
        
    def agent_init(self, agent_info={}):
        """Setup for the agent called when the experiment first starts.

        Set parameters needed to setup the semi-gradient TD(0) state aggregation agent.

        Assume agent_info dict contains:
        {
            num_states: 500 [int],
            num_groups: int, 
            step_size: float, 
            discount_factor: float,
            seed: int
        }
        """

        # set random seed for each run
        self.rand_generator = np.random.RandomState(agent_info.get("seed")) 

        # set class attributes
        self.num_states = agent_info.get("num_states")
        self.num_groups = agent_info.get("num_groups")
        self.step_size = agent_info.get("step_size")
        self.discount_factor = agent_info.get("discount_factor")

        # pre-compute all observable features
        num_states_in_group = int(self.num_states / self.num_groups)
        self.all_state_features = np.array([get_state_feature(num_states_in_group, self.num_groups, state) for state in range(1, self.num_states + 1)])

        # ----------------
        # initialize all weights to zero using numpy array with correct size
        # self.weights = ?
        # your code here
        
        # self.weights = np.zeros((self.num_groups, self.num_states)) 
        self.weights = np.zeros(self.num_groups) 
        
        # ----------------

        self.last_state = None
        self.last_action = None

    def agent_start(self, state):
        """The first method called when the experiment starts, called after
        the environment starts.
        Args:
            state (Numpy array): the state from the
                environment's evn_start function.
        Returns:
            self.last_action [int] : The first action the agent takes.
        """

        # ----------------
        ### select action given state (using agent_policy), and save current state and action
        # Use self.rand_generator for agent_policy
        # 
        # self.last_state = ?
        # self.last_action = ?
        # your code here
        self.last_state = state
        self.last_action = agent_policy(self.rand_generator, state)
        # ----------------

        return self.last_action

    def agent_step(self, reward, state):
        """A step taken by the agent.
        Args:
            reward [float]: the reward received for taking the last action taken
            state [int]: the state from the environment's step, where the agent ended up after the last step
        Returns:
            self.last_action [int] : The action the agent is taking.
        """
        
        # get relevant feature
        current_state_feature = self.all_state_features[state-1] 
        last_state_feature = self.all_state_features[self.last_state-1] 
        
        ### update weights and select action
        # (Hint: np.dot method is useful!)
        #
        # Update weights:
        #     use self.weights, current_state_feature, and last_state_feature
        #
        # Select action:
        #     use self.rand_generator for agent_policy
        #
        # Current state and selected action should be saved to self.last_state and self.last_action at the end
        #
        # self.weights = ?
        # self.last_state = ?
        # self.last_action = ?

        # ----------------
        # your code here
        
        num_states_in_group = int(self.num_states/self.num_groups)
        pos = math.floor((self.last_state - 1) / num_states_in_group)

        self.weights[pos] += self.step_size * (reward + self.discount_factor * np.dot(self.weights, current_state_feature) - np.dot(self.weights, last_state_feature))
        
        self.last_state = state
        self.last_action = agent_policy(self.rand_generator, state)
        # ----------------
        return self.last_action

    def agent_end(self, reward):
        """Run when the agent terminates.
        Args:
            reward (float): the reward the agent received for entering the
                terminal state.
        """

        # get relevant feature
        last_state_feature = self.all_state_features[self.last_state-1]
        
        ### update weights
        # Update weights using self.weights and last_state_feature
        # (Hint: np.dot method is useful!)
        # 
        # Note that here you don't need to choose action since the agent has reached a terminal state
        # Therefore you should not update self.last_state and self.last_action
        # 
        # self.weights = ?
        
        # ----------------
        # your code here
        
        # ----------------
        return
        
    def agent_message(self, message):
        # We will implement this method later
        raise NotImplementedError


# %%
agent_info = {
    "num_states": 500,
    "num_groups": 10,
    "step_size": 0.1,
    "discount_factor": 1.0,
    "seed": 1,
}
num_states = agent_info.get("num_states")
num_groups = agent_info.get("num_groups")

weights = np.zeros((num_groups))
assert weights.shape == (10,)

# 
# Run the following code to verify `agent_init()`

# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

agent_info = {
    "num_states": 500,
    "num_groups": 10,
    "step_size": 0.1,
    "discount_factor": 1.0,
    "seed": 1,
}

agent = TDAgent()
agent.agent_init(agent_info)

assert np.all(agent.weights == 0)
assert agent.weights.shape == (10,)

# check attributes
print("num_states: {}".format(agent.num_states))
print("num_groups: {}".format(agent.num_groups))
print("step_size: {}".format(agent.step_size))
print("discount_factor: {}".format(agent.discount_factor))

print("weights shape: {}".format(agent.weights.shape))
print("weights init. value: {}".format(agent.weights))

# Run the following code to verify `agent_start()`.
# Although there is randomness due to `rand_generator.choice()` in `agent_policy()`, we control the seed so your output should match the expected output. 
# 
# Make sure `rand_generator.choice()` is called only once per `agent_policy()` call.
# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

agent_info = {
    "num_states": 500,
    "num_groups": 10,
    "step_size": 0.1,
    "discount_factor": 1.0,
    "seed": 1,
}

# Suppose state = 250
state = 250

agent = TDAgent()
agent.agent_init(agent_info)
action = agent.agent_start(state)

assert action == 1
assert agent.last_state == 250
assert agent.last_action == 1

print("Agent state: {}".format(agent.last_state))
print("Agent selected action: {}".format(agent.last_action))

# Run the following code to verify `agent_step()`
# 
# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

agent_info = {
    "num_states": 500,
    "num_groups": 10,
    "step_size": 0.1,
    "discount_factor": 0.9,
    "seed": 1,
}

agent = TDAgent()
agent.agent_init(agent_info)

# Initializing the weights to arbitrary values to verify the correctness of weight update
agent.weights = np.array([-1.5, 0.5, 1., -0.5, 1.5, -0.5, 1.5, 0.0, -0.5, -1.0])

# Assume the agent started at State 50
start_state = 50
action = agent.agent_start(start_state)

assert action == 1

# Assume the reward was 10.0 and the next state observed was State 120
reward = 10.0
next_state = 120
action = agent.agent_step(reward, next_state)

assert action == 1

print("Updated weights: {}".format(agent.weights))
assert np.allclose(agent.weights, [-0.26, 0.5, 1., -0.5, 1.5, -0.5, 1.5, 0., -0.5, -1.])

assert agent.last_state == 120
assert agent.last_action == 1

print("last state: {}".format(agent.last_state))
print("last action: {}".format(agent.last_action))

# let's do another
reward = -22
next_state = 222
action = agent.agent_step(reward, next_state)

assert action == 0

assert np.allclose(agent.weights, [-0.26, 0.5, -1.165, -0.5, 1.5, -0.5, 1.5, 0, -0.5, -1])
assert agent.last_state == 222
assert agent.last_action == 0

# Run the following code to verify `agent_end()`
# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

agent_info = {
    "num_states": 500,
    "num_groups": 10,
    "step_size": 0.1,
    "discount_factor": 0.9,
    "seed": 1,
}

agent = TDAgent()
agent.agent_init(agent_info)

# Initializing the weights to arbitrary values to verify the correctness of weight update
agent.weights = np.array([-1.5, 0.5, 1., -0.5, 1.5, -0.5, 1.5, 0.0, -0.5, -1.0])

# Assume the agent started at State 50
start_state = 50
action = agent.agent_start(start_state)

assert action == 1

# Assume the reward was 10.0 and reached the terminal state
agent.agent_end(10.0)
print("Updated weights: {}".format(agent.weights))

assert np.allclose(agent.weights, [-0.35, 0.5, 1., -0.5, 1.5, -0.5, 1.5, 0., -0.5, -1.])

# -----------
# Graded Cell
# -----------

def agent_message(self, message):
    if message == 'get state value':
        
        ### return state_value
        # Use self.all_state_features and self.weights to return the vector of all state values
        # Hint: Use np.dot()
        #
        # state_value = ?
        
        # your code here
        
        
        return state_value

# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

agent_info = {
    "num_states": 20,
    "num_groups": 5,
    "step_size": 0.1,
    "discount_factor": 1.0,
}

agent = TDAgent()
agent.agent_init(agent_info)
test_state_val = agent.agent_message('get state value')

assert test_state_val.shape == (20,)
assert np.all(test_state_val == 0)

print("State value shape: {}".format(test_state_val.shape))
print("Initial State value for all states: {}".format(test_state_val))

# ---------------
# Discussion Cell
# ---------------

# Here we provide you with the true state value and state distribution
true_state_val = np.load('data/true_V.npy')    
state_distribution = np.load('data/state_distribution.npy')

def calc_RMSVE(learned_state_val):
    assert(len(true_state_val) == len(learned_state_val) == len(state_distribution))
    MSVE = np.sum(np.multiply(state_distribution, np.square(true_state_val - learned_state_val)))
    RMSVE = np.sqrt(MSVE)
    return RMSVE

# ---------------
# Discussion Cell
# ---------------

import os

# Define function to run experiment
def run_experiment(environment, agent, environment_parameters, agent_parameters, experiment_parameters):

    rl_glue = RLGlue(environment, agent)
    
    # Sweep Agent parameters
    for num_agg_states in agent_parameters["num_groups"]:
        for step_size in agent_parameters["step_size"]:
            
            # save rmsve at the end of each evaluation episode
            # size: num_episode / episode_eval_frequency + 1 (includes evaluation at the beginning of training)
            agent_rmsve = np.zeros(int(experiment_parameters["num_episodes"]/experiment_parameters["episode_eval_frequency"]) + 1)
            
            # save learned state value at the end of each run
            agent_state_val = np.zeros(environment_parameters["num_states"])

            env_info = {"num_states": environment_parameters["num_states"],
                        "start_state": environment_parameters["start_state"],
                        "left_terminal_state": environment_parameters["left_terminal_state"],
                        "right_terminal_state": environment_parameters["right_terminal_state"]}

            agent_info = {"num_states": environment_parameters["num_states"],
                          "num_groups": num_agg_states,
                          "step_size": step_size,
                          "discount_factor": environment_parameters["discount_factor"]}

            print('Setting - num. agg. states: {}, step_size: {}'.format(num_agg_states, step_size))
            os.system('sleep 0.2')
            
            # one agent setting
            for run in tqdm(range(1, experiment_parameters["num_runs"]+1)):
                env_info["seed"] = run
                agent_info["seed"] = run
                rl_glue.rl_init(agent_info, env_info)
                
                # Compute initial RMSVE before training
                current_V = rl_glue.rl_agent_message("get state value")
                agent_rmsve[0] += calc_RMSVE(current_V)
                    
                for episode in range(1, experiment_parameters["num_episodes"]+1):
                    # run episode
                    rl_glue.rl_episode(0) # no step limit
                    
                    if episode % experiment_parameters["episode_eval_frequency"] == 0:
                        current_V = rl_glue.rl_agent_message("get state value")
                        agent_rmsve[int(episode/experiment_parameters["episode_eval_frequency"])] += calc_RMSVE(current_V)
                        
                # store only one run of state value
                if run == 50:
                    agent_state_val = rl_glue.rl_agent_message("get state value")
            
            # rmsve averaged over runs
            agent_rmsve /= experiment_parameters["num_runs"]
            
            save_name = "{}_agg_states_{}_step_size_{}".format('TD_agent', num_agg_states, step_size).replace('.','')
            
            if not os.path.exists('results'):
                os.makedirs('results')
    
            # save avg. state value
            np.save("results/V_{}".format(save_name), agent_state_val)

            # save avg. rmsve
            np.save("results/RMSVE_{}".format(save_name), agent_rmsve)

# ---------------
# Discussion Cell
# ---------------

#### Run Experiment

# Experiment parameters
experiment_parameters = {
    "num_runs" : 50,
    "num_episodes" : 2000,
    "episode_eval_frequency" : 10 # evaluate every 10 episodes
}

# Environment parameters
environment_parameters = {
    "num_states" : 500, 
    "start_state" : 250,
    "left_terminal_state" : 0,
    "right_terminal_state" : 501, 
    "discount_factor" : 1.0
}

# Agent parameters
# Each element is an array because we will be later sweeping over multiple values
agent_parameters = {
    "num_groups": [10],
    "step_size": [0.01, 0.05, 0.1]
}

current_env = RandomWalkEnvironment
current_agent = TDAgent

run_experiment(current_env, current_agent, environment_parameters, agent_parameters, experiment_parameters)
plot_script.plot_result(agent_parameters, 'results')

# -----------
# Graded Cell
# -----------

agent_parameters = {
    "num_groups": [10],
    "step_size": [0.01, 0.05, 0.1]
}

all_correct = True
for num_agg_states in agent_parameters["num_groups"]:
    for step_size in agent_parameters["step_size"]:
        filename = 'RMSVE_TD_agent_agg_states_{}_step_size_{}'.format(num_agg_states, step_size).replace('.','')
        agent_RMSVE = np.load('results/{}.npy'.format(filename))
        correct_RMSVE = np.load('correct_npy/{}.npy'.format(filename))

        if not np.allclose(agent_RMSVE, correct_RMSVE):
            all_correct=False

if all_correct:
    print("Your experiment results are correct!")
else:
    print("Your experiment results does not match with ours. Please check if you have implemented all methods correctly.")

# ---------------
# Discussion Cell
# ---------------

# Make sure to verify your experiment result with the test cell above.
# Otherwise the sweep results will not be displayed.

# Experiment parameters
experiment_parameters = {
    "num_runs" : 50,
    "num_episodes" : 2000,
    "episode_eval_frequency" : 10 # evaluate every 10 episodes
}

# Environment parameters
environment_parameters = {
    "num_states" : 500,
    "start_state" : 250,
    "left_terminal_state" : 0,
    "right_terminal_state" : 501,
    "discount_factor" : 1.0
}

# Agent parameters
# Each element is an array because we will be sweeping over multiple values
agent_parameters = {
    "num_groups": [10, 100, 500],
    "step_size": [0.01, 0.05, 0.1]
}

if all_correct:
    plot_script.plot_result(agent_parameters, 'correct_npy')
else:
    raise ValueError("Make sure your experiment result is correct! Otherwise the sweep results will not be displayed.")




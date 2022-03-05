 
# # Assignment: Dyna-Q and Dyna-Q+
 
import numpy as np
import matplotlib.pyplot as plt
# import jdc
import os
from tqdm import tqdm

from rl_glue import RLGlue
from agent import BaseAgent
from maze_env import ShortcutMazeEnvironment

from src.agent.dyna_q import DynaQAgent
from src.agent.dyna_q_plus import DynaQPlusAgent

from src.plot.plots import plot_steps_per_episode, plot_cumulative_reward, plot_state_visitations, plot_cumulative_reward_comparison
 
plt.rcParams.update({'font.size': 15})
plt.rcParams.update({'figure.figsize': [8,5]})
 
# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

def test_model_update_0():

    actions = []
    agent_info = {"num_actions": 4, 
                "num_states": 3, 
                "epsilon": 0.1, 
                "step_size": 0.1, 
                "discount": 1.0, 
                "random_seed": 0,
                "planning_random_seed": 0}

    agent = DynaQAgent()
    agent.agent_init(agent_info)

    # (past_state, past_action, state, reward)
    agent.update_model(0,2,0,1)
    agent.update_model(2,0,1,1)
    agent.update_model(0,3,1,2)

    expected_model = {
        # action 2 in state 0 leads back to state 0 with a reward of 1
        # or taking action 3 leads to state 1 with reward of 2
        0: {
            2: (0, 1), # action 2 - state 0 with a reward of 1
            3: (1, 2), # action 3 - state 1 with reward of 2
        },
        # taking action 0 in state 2 leads to state 1 with a reward of 1
        2: {
            0: (1, 1), # action 0 - state 1 with reward of 1
        },
    }

    assert agent.model == expected_model

# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

def test_planning_step_0():
    np.random.seed(0)

    actions = []
    agent_info = {"num_actions": 4, 
                "num_states": 3, 
                "epsilon": 0.1, 
                "step_size": 0.1, 
                "discount": 1.0, 
                "planning_steps": 4,
                "random_seed": 0,
                "planning_random_seed": 5}

    agent = DynaQAgent()
    agent.agent_init(agent_info)

    agent.update_model(0,2,1,1)
    agent.update_model(2,0,1,1)
    agent.update_model(0,3,0,1)
    agent.update_model(0,1,-1,1)

    expected_model = {
        0: {
            2: (1, 1),
            3: (0, 1),
            1: (-1, 1),
        },
        2: {
            0: (1, 1),
        },
    }

    assert agent.model == expected_model

    agent.planning_step()

    expected_values = np.array([
        [0, 0.1, 0, 0.2],
        [0, 0, 0, 0],
        [0.1, 0, 0, 0],
    ])
    assert np.all(np.isclose(agent.q_values, expected_values))
 
# Now before you move on to implement the rest of the agent methods, here are the helper functions that you've used in the previous assessments for choosing an action using an $\epsilon$-greedy policy.

# ---------------
# Discussion Cell
# ---------------

def argmax(self, q_values):
    """argmax with random tie-breaking
    Args:
        q_values (Numpy array): the array of action values
    Returns:
        action (int): an action with the highest value
    """
    top = float("-inf")
    ties = []

    for i in range(len(q_values)):
        if q_values[i] > top:
            top = q_values[i]
            ties = []

        if q_values[i] == top:
            ties.append(i)

    return self.rand_generator.choice(ties)

def choose_action_egreedy(self, state):
    """returns an action using an epsilon-greedy policy w.r.t. the current action-value function.

    Important: assume you have a random number generator 'rand_generator' as a part of the class
                which you can use as self.rand_generator.choice() or self.rand_generator.rand()

    Args:
        state (List): coordinates of the agent (two elements)
    Returns:
        The action taken w.r.t. the aforementioned epsilon-greedy policy
    """

    if self.rand_generator.rand() < self.epsilon:
        action = self.rand_generator.choice(self.actions)
    else:
        values = self.q_values[state]
        action = self.argmax(values)

    return action

 
# Next, you will implement the rest of the agent-related methods, namely `agent_start`, `agent_step`, and `agent_end`.

# -----------
# Graded Cell
# -----------

# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.

def test_agent_start_step_end_0():
    np.random.seed(0)

    agent_info = {"num_actions": 4, 
                "num_states": 3, 
                "epsilon": 0.1, 
                "step_size": 0.1, 
                "discount": 1.0, 
                "random_seed": 0,
                "planning_steps": 2,
                "planning_random_seed": 0}

    agent = DynaQAgent()
    agent.agent_init(agent_info)

    # ----------------
    # test agent start
    # ----------------

    action = agent.agent_start(0)

    assert action == 1
    assert agent.model == {}
    assert np.all(agent.q_values == 0)

    # ---------------
    # test agent step
    # ---------------

    action = agent.agent_step(1, 2)
    assert action == 3

    action = agent.agent_step(0, 1)
    assert action == 1

    expected_model = {
        0: {
            1: (2, 1),
        },
        2: {
            3: (1, 0),
        },
    }
    assert agent.model == expected_model

    expected_values = np.array([
        [0, 0.3439, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
    ])
    assert np.allclose(agent.q_values, expected_values)

    # --------------
    # test agent end
    # --------------

    agent.agent_end(1)

    expected_model = {
        0: {
            1: (2, 1),
        },
        2: {
            3: (1, 0),
        },
        1: {
            1: (-1, 1),
        },
    }
    assert agent.model == expected_model

    expected_values = np.array([
        [0, 0.41051, 0, 0],
        [0, 0.1, 0, 0],
        [0, 0, 0, 0.01],
    ])
    assert np.allclose(agent.q_values, expected_values)

# ---------------
# Discussion Cell
# ---------------

def run_experiment(env, agent, env_parameters, agent_parameters, exp_parameters):

    # Experiment settings
    num_runs = exp_parameters['num_runs']
    num_episodes = exp_parameters['num_episodes']
    planning_steps_all = agent_parameters['planning_steps']

    env_info = env_parameters                     
    agent_info = {"num_states" : agent_parameters["num_states"],  # We pass the agent the information it needs. 
                  "num_actions" : agent_parameters["num_actions"],
                  "epsilon": agent_parameters["epsilon"], 
                  "discount": env_parameters["discount"],
                  "step_size" : agent_parameters["step_size"]}

    all_averages = np.zeros((len(planning_steps_all), num_runs, num_episodes)) # for collecting metrics 
    log_data = {'planning_steps_all' : planning_steps_all}                     # that shall be plotted later

    for idx, planning_steps in enumerate(planning_steps_all):

        print('Planning steps : ', planning_steps)
        os.system('sleep 0.5')                    # to prevent tqdm printing out-of-order before the above print()
        agent_info["planning_steps"] = planning_steps  

        for i in tqdm(range(num_runs)):

            agent_info['random_seed'] = i
            agent_info['planning_random_seed'] = i

            rl_glue = RLGlue(env, agent)          # Creates a new RLGlue experiment with the env and agent we chose above
            rl_glue.rl_init(agent_info, env_info) # We pass RLGlue what it needs to initialize the agent and environment

            for j in range(num_episodes):

                rl_glue.rl_start()                # We start an episode. Here we aren't using rl_glue.rl_episode()
                                                  # like the other assessments because we'll be requiring some 
                is_terminal = False               # data from within the episodes in some of the experiments here 
                num_steps = 0
                while not is_terminal:
                    reward, _, action, is_terminal = rl_glue.rl_step()  # The environment and agent take a step 
                    num_steps += 1                                      # and return the reward and action taken.

                all_averages[idx][i][j] = num_steps

    log_data['all_averages'] = all_averages
    
    return log_data

# ---------------
# Discussion Cell
# ---------------

def disc_run_experiment_0():
    # Experiment parameters
    experiment_parameters = {
        "num_runs" : 30,                     # The number of times we run the experiment
        "num_episodes" : 40,                 # The number of episodes per experiment
    }

    # Environment parameters
    environment_parameters = { 
        "discount": 0.95,
    }

    # Agent parameters
    agent_parameters = {  
        "num_states" : 54,
        "num_actions" : 4, 
        "epsilon": 0.1, 
        "step_size" : 0.125,
        "planning_steps" : [0, 5, 50]       # The list of planning_steps we want to try
    }

    current_env = ShortcutMazeEnvironment   # The environment
    current_agent = DynaQAgent              # The agent

    dataq = run_experiment(current_env, current_agent, environment_parameters, agent_parameters, experiment_parameters)
    plot_steps_per_episode(dataq)   

 
# ---------------
# Discussion Cell
# ---------------

def run_experiment_with_state_visitations(env, agent, env_parameters, agent_parameters, exp_parameters, result_file_name):

    # Experiment settings
    num_runs = exp_parameters['num_runs']
    num_max_steps = exp_parameters['num_max_steps']
    planning_steps_all = agent_parameters['planning_steps']

    env_info = {"change_at_n" : env_parameters["change_at_n"]}                     
    agent_info = {"num_states" : agent_parameters["num_states"],  
                  "num_actions" : agent_parameters["num_actions"],
                  "epsilon": agent_parameters["epsilon"], 
                  "discount": env_parameters["discount"],
                  "step_size" : agent_parameters["step_size"]}

    state_visits_before_change = np.zeros((len(planning_steps_all), num_runs, 54))  # For saving the number of
    state_visits_after_change = np.zeros((len(planning_steps_all), num_runs, 54))   #     state-visitations 
    cum_reward_all = np.zeros((len(planning_steps_all), num_runs, num_max_steps))   # For saving the cumulative reward
    log_data = {'planning_steps_all' : planning_steps_all}

    for idx, planning_steps in enumerate(planning_steps_all):

        print('Planning steps : ', planning_steps)
        os.system('sleep 1')          # to prevent tqdm printing out-of-order before the above print()
        agent_info["planning_steps"] = planning_steps  # We pass the agent the information it needs. 

        for run in tqdm(range(num_runs)):

            agent_info['random_seed'] = run
            agent_info['planning_random_seed'] = run

            rl_glue = RLGlue(env, agent)  # Creates a new RLGlue experiment with the env and agent we chose above
            rl_glue.rl_init(agent_info, env_info) # We pass RLGlue what it needs to initialize the agent and environment

            num_steps = 0
            cum_reward = 0

            while num_steps < num_max_steps-1 :

                state, _ = rl_glue.rl_start()  # We start the experiment. We'll be collecting the 
                is_terminal = False            # state-visitation counts to visiualize the learned policy
                if num_steps < env_parameters["change_at_n"]: 
                    state_visits_before_change[idx][run][state] += 1
                else:
                    state_visits_after_change[idx][run][state] += 1

                while not is_terminal and num_steps < num_max_steps-1 :
                    reward, state, action, is_terminal = rl_glue.rl_step()  
                    num_steps += 1
                    cum_reward += reward
                    cum_reward_all[idx][run][num_steps] = cum_reward
                    if num_steps < env_parameters["change_at_n"]:
                        state_visits_before_change[idx][run][state] += 1
                    else:
                        state_visits_after_change[idx][run][state] += 1

    log_data['state_visits_before'] = state_visits_before_change
    log_data['state_visits_after'] = state_visits_after_change
    log_data['cum_reward_all'] = cum_reward_all
    
    return log_data

# ---------------
# Discussion Cell
# ---------------

def disc_run_experiment_with_state_visitations():
    # Experiment parameters
    experiment_parameters = {
        "num_runs" : 10,                     # The number of times we run the experiment
        "num_max_steps" : 6000,              # The number of steps per experiment
    }

    # Environment parameters
    environment_parameters = { 
        "discount": 0.95,
        "change_at_n": 3000
    }

    # Agent parameters
    agent_parameters = {  
        "num_states" : 54,
        "num_actions" : 4, 
        "epsilon": 0.1, 
        "step_size" : 0.125,
        "planning_steps" : [5, 10, 50]      # The list of planning_steps we want to try
    }

    current_env = ShortcutMazeEnvironment   # The environment
    current_agent = DynaQAgent              # The agent

    dataq = run_experiment_with_state_visitations(current_env, current_agent, environment_parameters, agent_parameters, experiment_parameters, "Dyna-Q_shortcut_steps")    
    plot_cumulative_reward(dataq, 'planning_steps_all', 'cum_reward_all', 'Cumulative\nreward', 'Planning steps = ', 'Dyna-Q : Varying planning_steps')

    # ---------------
    # Discussion Cell
    # ---------------

    
    # Do not modify this cell!

    plot_state_visitations(dataq, ['Dyna-Q : State visitations before the env changes', 'Dyna-Q : State visitations after the env changes'], 1)
    
    return dataq

# ---------------
# Discussion Cell
# ---------------

def run_experiment_only_cumulative_reward(env, agent, env_parameters, agent_parameters, exp_parameters):

    # Experiment settings
    num_runs = exp_parameters['num_runs']
    num_max_steps = exp_parameters['num_max_steps']
    epsilons = agent_parameters['epsilons']

    env_info = {"change_at_n" : env_parameters["change_at_n"]}                     
    agent_info = {"num_states" : agent_parameters["num_states"],  
                  "num_actions" : agent_parameters["num_actions"],
                  "planning_steps": agent_parameters["planning_steps"], 
                  "discount": env_parameters["discount"],
                  "step_size" : agent_parameters["step_size"]}

    log_data = {'epsilons' : epsilons} 
    cum_reward_all = np.zeros((len(epsilons), num_runs, num_max_steps))

    for eps_idx, epsilon in enumerate(epsilons):

        print('Agent : Dyna-Q, epsilon : %f' % epsilon)
        os.system('sleep 1')          # to prevent tqdm printing out-of-order before the above print()
        agent_info["epsilon"] = epsilon

        for run in tqdm(range(num_runs)):

            agent_info['random_seed'] = run
            agent_info['planning_random_seed'] = run

            rl_glue = RLGlue(env, agent)  # Creates a new RLGlue experiment with the env and agent we chose above
            rl_glue.rl_init(agent_info, env_info) # We pass RLGlue what it needs to initialize the agent and environment

            num_steps = 0
            cum_reward = 0

            while num_steps < num_max_steps-1 :

                rl_glue.rl_start()  # We start the experiment
                is_terminal = False

                while not is_terminal and num_steps < num_max_steps-1 :
                    reward, _, action, is_terminal = rl_glue.rl_step()  # The environment and agent take a step and return
                    # the reward, and action taken.
                    num_steps += 1
                    cum_reward += reward
                    cum_reward_all[eps_idx][run][num_steps] = cum_reward

    log_data['cum_reward_all'] = cum_reward_all
    return log_data
 
# ---------------
# Discussion Cell
# ---------------

def disc_run_experiment_only_cumulative_reward():

    # Experiment parameters
    experiment_parameters = {
        "num_runs" : 30,                     # The number of times we run the experiment
        "num_max_steps" : 6000,              # The number of steps per experiment
    }

    # Environment parameters
    environment_parameters = { 
        "discount": 0.95,
        "change_at_n": 3000
    }

    # Agent parameters
    agent_parameters = {  
        "num_states" : 54,
        "num_actions" : 4, 
        "step_size" : 0.125,
        "planning_steps" : 10,
        "epsilons": [0.1, 0.2, 0.4, 0.8]    # The list of epsilons we want to try
    }

    current_env = ShortcutMazeEnvironment   # The environment
    current_agent = DynaQAgent              # The agent

    data = run_experiment_only_cumulative_reward(current_env, current_agent, environment_parameters, agent_parameters, experiment_parameters)
    plot_cumulative_reward(data, 'epsilons', 'cum_reward_all', 'Cumulative\nreward', r'$\epsilon$ = ', r'Dyna-Q : Varying $\epsilon$')

# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.
def test_model_update_1():
    actions = []
    agent_info = {"num_actions": 4, 
                "num_states": 3, 
                "epsilon": 0.1, 
                "step_size": 0.1, 
                "discount": 1.0, 
                "random_seed": 0,
                "planning_random_seed": 0}

    agent = DynaQPlusAgent()
    agent.agent_init(agent_info)

    agent.update_model(0,2,0,1)
    agent.update_model(2,0,1,1)
    agent.update_model(0,3,1,2)
    agent.tau[0][0] += 1

    expected_model = {
        0: {
            0: (0, 0),
            1: (0, 0),
            2: (0, 1),
            3: (1, 2),
        },
        2: {
            0: (1, 1),
            1: (2, 0),
            2: (2, 0),
            3: (2, 0),
        },
    }
    assert agent.model == expected_model

# -----------
# Graded Cell
# -----------

## Test code for planning_step() ##
def test_planning_step_1():
    actions = []
    agent_info = {"num_actions": 4, 
                "num_states": 3, 
                "epsilon": 0.1, 
                "step_size": 0.1, 
                "discount": 1.0, 
                "kappa": 0.001,
                "planning_steps": 4,
                "random_seed": 0,
                "planning_random_seed": 1}

    agent = DynaQPlusAgent()
    agent.agent_init(agent_info)

    agent.update_model(0,1,-1,1)
    agent.tau += 1
    agent.tau[0][1] = 0

    agent.update_model(0,2,1,1)
    agent.tau += 1
    agent.tau[0][2] = 0

    agent.update_model(2,0,1,1)
    agent.tau += 1
    agent.tau[2][0] = 0

    agent.planning_step()

    expected_model = {
        0: {
            1: (-1, 1), 
            0: (0, 0), 
            2: (1, 1), 
            3: (0, 0),
        }, 
        2: {
            0: (1, 1), 
            1: (2, 0), 
            2: (2, 0), 
            3: (2, 0),
        },
    }
    assert agent.model == expected_model

    expected_values = np.array([
        [0, 0.10014142, 0, 0],
        [0, 0, 0, 0],
        [0, 0.00036373, 0, 0.00017321],
    ])
    assert np.allclose(agent.q_values, expected_values)

 
# Again, before you move on to implement the rest of the agent methods, here are the couple of helper functions that you've used in the previous assessments for choosing an action using an $\epsilon$-greedy policy.
 
# ---------------
# Discussion Cell
# ---------------


# ### Test `agent_start()`, `agent_step()`, and `agent_end()`

 
# -----------
# Tested Cell
# -----------
# The contents of the cell will be tested by the autograder.
# If they do not pass here, they will not pass there.
def test_agent_start_step_end_1():
    agent_info = {"num_actions": 4, 
                "num_states": 3, 
                "epsilon": 0.1, 
                "step_size": 0.1, 
                "discount": 1.0,
                "kappa": 0.001,
                "random_seed": 0,
                "planning_steps": 4,
                "planning_random_seed": 0}

    agent = DynaQPlusAgent()
    agent.agent_init(agent_info)

    action = agent.agent_start(0) # state
    assert action == 1

    assert np.allclose(agent.tau, 0)
    assert np.allclose(agent.q_values, 0)
    assert agent.model == {}

    # ---------------
    # test agent step
    # ---------------

    action = agent.agent_step(1, 2)
    assert action == 3

    action = agent.agent_step(0, 1)
    assert action == 1

    expected_tau = np.array([
        [2, 1, 2, 2],
        [2, 2, 2, 2],
        [2, 2, 2, 0],
    ])
    assert np.all(agent.tau == expected_tau)

    expected_values = np.array([
        [0.0191, 0.271, 0.0, 0.0191],
        [0, 0, 0, 0],
        [0, 0.000183847763, 0.000424264069, 0],
    ])
    assert np.allclose(agent.q_values, expected_values)

    expected_model = {
        0: {
            1: (2, 1), 
            0: (0, 0), 
            2: (0, 0), 
            3: (0, 0),
        }, 
        2: {
            3: (1, 0), 
            0: (2, 0), 
            1: (2, 0), 
            2: (2, 0),
        },
    }
    assert agent.model == expected_model

    # --------------
    # test agent end
    # --------------
    agent.agent_end(1)

    expected_tau = np.array([
        [3, 2, 3, 3],
        [3, 0, 3, 3],
        [3, 3, 3, 1],
    ])
    assert np.all(agent.tau == expected_tau)

    expected_values = np.array([
        [0.0191, 0.344083848, 0, 0.0444632051],
        [0.0191732051, 0.19, 0, 0],
        [0, 0.000183847763, 0.000424264069, 0],
    ])
    assert np.allclose(agent.q_values, expected_values)

    expected_model = {0: {1: (2, 1), 0: (0, 0), 2: (0, 0), 3: (0, 0)}, 2: {3: (1, 0), 0: (2, 0), 1: (2, 0), 2: (2, 0)}, 1: {1: (-1, 1), 0: (1, 0), 2: (1, 0), 3: (1, 0)}}
    assert agent.model == expected_model
 
# ---------------
# Discussion Cell
# ---------------

def disc_run_experiment_1(dataq):
    # Experiment parameters
    experiment_parameters = {
        "num_runs" : 30,                     # The number of times we run the experiment
        "num_max_steps" : 6000,              # The number of steps per experiment
    }

    # Environment parameters
    environment_parameters = { 
        "discount": 0.95,
        "change_at_n": 3000
    }

    # Agent parameters
    agent_parameters = {  
        "num_states" : 54,
        "num_actions" : 4, 
        "epsilon": 0.1, 
        "step_size" : 0.5,
        "planning_steps" : [50]      
    }

    current_env = ShortcutMazeEnvironment   # The environment
    current_agent = DynaQPlusAgent          # The agent

    data_qplus = run_experiment_with_state_visitations(current_env, current_agent, environment_parameters, agent_parameters, experiment_parameters, "Dyna-Q+")

    
    # Let's compare the Dyna-Q and Dyna-Q+ agents with `planning_steps=50` each.

    # ---------------
    # Discussion Cell
    # ---------------

    plot_cumulative_reward_comparison(dataq, data_qplus)

    # ---------------
    # Discussion Cell
    # ---------------

    plot_state_visitations(data_qplus, ['Dyna-Q+ : State visitations before the env changes', 'Dyna-Q+ : State visitations after the env changes'], 0)

if __name__ == '__main__':
    
    # Dyna-Q
    # test_model_update_0()
    # test_planning_step_0()
    # test_agent_start_step_end_0()
    
    # disc_run_experiment_0()
    # dataq = disc_run_experiment_with_state_visitations()
    # disc_run_experiment_only_cumulative_reward()

    # Dyna-QPlus
    test_model_update_1()
    test_planning_step_1()
    test_agent_start_step_end_1()

    disc_run_experiment_1(dataq)
    pass 

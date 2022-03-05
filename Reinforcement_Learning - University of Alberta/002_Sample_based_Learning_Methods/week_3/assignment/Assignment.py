#region imports  
import numpy as np
import matplotlib.pyplot as plt
from tqdm import tqdm
from scipy.stats import sem

from rl_glue import RLGlue
from agent import BaseAgent
from src.expected_sars_agent import ExpectedSarsaAgent 
from src.qlearning_agent import QLearningAgent
import cliffworld_env
#endregion imports
 

# ============================================================================================ 
# initialization
# ============================================================================================

plt.rcParams.update({'font.size': 15})
plt.rcParams.update({'figure.figsize': [10,5]})
 
# ===================================================================================
# Tested Cell - Q-learning
# ===================================================================================

def test_qlearning():

    np.random.seed(0)

    agent_info = {"num_actions": 4, "num_states": 3, "epsilon": 0.1, "step_size": 0.1, "discount": 1.0, "seed": 0}
    agent = QLearningAgent()
    agent.agent_init(agent_info)
    action = agent.agent_start(0)

    expected_values = np.array([
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
    ])

    assert np.all(agent.q == expected_values)
    assert action == 1

    # reset the agent
    agent.agent_init(agent_info)

    action = agent.agent_start(0)
    assert action == 1

    action = agent.agent_step(2, 1)
    assert action == 3

    action = agent.agent_step(0, 0)
    assert action == 1

    expected_values = np.array([
        [0.,  0.2,  0.,  0.  ],
        [0.,  0.,   0.,  0.02],
        [0.,  0.,   0.,  0.  ],
    ])
    assert np.all(np.isclose(agent.q, expected_values))

    # reset the agent
    agent.agent_init(agent_info)

    action = agent.agent_start(0)
    assert action == 1

    action = agent.agent_step(2, 1)
    assert action == 3

    agent.agent_end(1)

    expected_values = np.array([
        [0.,  0.2, 0.,  0. ],
        [0.,  0.,  0.,  0.1],
        [0.,  0.,  0.,  0. ],
    ])
    assert np.all(np.isclose(agent.q, expected_values))

# ===================================================================================
# Tested Cell - Expected Sarsa Agent
# ===================================================================================

def test_expected_sarsa_agent():

    agent_info = {"num_actions": 4, "num_states": 3, "epsilon": 0.1, "step_size": 0.1, "discount": 1.0, "seed": 0}
    agent = ExpectedSarsaAgent()
    agent.agent_init(agent_info)

    action = agent.agent_start(0)
    assert action == 1

    expected_values = np.array([
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
    ])
    assert np.all(agent.q == expected_values)

    # ---------------
    # test agent step
    # ---------------

    action = agent.agent_step(2, 1)
    assert action == 3

    action = agent.agent_step(0, 0)
    assert action == 1

    expected_values = np.array([
        [0, 0.2, 0, 0],
        [0, 0, 0, 0.0185],
        [0, 0, 0, 0],
    ])
    assert np.all(np.isclose(agent.q, expected_values))

    # --------------
    # test agent end
    # --------------

    agent.agent_end(1)

    expected_values = np.array([
        [0, 0.28, 0, 0],
        [0, 0, 0, 0.0185],
        [0, 0, 0, 0],
    ])
    assert np.all(np.isclose(agent.q, expected_values))
 
# ===================================================================================
# Discussion Cell - Solving the Cliff World
# ===================================================================================

def disc_cliff_world():

    np.random.seed(0)

    agents = {
        "Q-learning": QLearningAgent,
        "Expected Sarsa": ExpectedSarsaAgent
    }
    env = cliffworld_env.Environment
    all_reward_sums = {} # Contains sum of rewards during episode
    all_state_visits = {} # Contains state visit counts during the last 10 episodes
    agent_info = {"num_actions": 4, "num_states": 48, "epsilon": 0.1, "step_size": 0.5, "discount": 1.0}
    env_info = {}
    num_runs = 100 # The number of runs
    num_episodes = 100 # The number of episodes in each run

    for algorithm in ["Q-learning", "Expected Sarsa"]:
        all_reward_sums[algorithm] = []
        all_state_visits[algorithm] = []
        for run in tqdm(range(num_runs)):
            agent_info["seed"] = run
            rl_glue = RLGlue(env, agents[algorithm])
            rl_glue.rl_init(agent_info, env_info)

            reward_sums = []
            state_visits = np.zeros(48)
            last_episode_total_reward = 0
            for episode in range(num_episodes):
                if episode < num_episodes - 10:
                    # Runs an episode
                    rl_glue.rl_episode(10000) 
                else: 
                    # Runs an episode while keeping track of visited states
                    state, action = rl_glue.rl_start()
                    state_visits[state] += 1
                    is_terminal = False
                    while not is_terminal:
                        reward, state, action, is_terminal = rl_glue.rl_step()
                        state_visits[state] += 1
                    
                reward_sums.append(rl_glue.rl_return() - last_episode_total_reward)
                last_episode_total_reward = rl_glue.rl_return()
                
            all_reward_sums[algorithm].append(reward_sums)
            all_state_visits[algorithm].append(state_visits)

    # plot results
    for algorithm in ["Q-learning", "Expected Sarsa"]:
        plt.plot(np.mean(all_reward_sums[algorithm], axis=0), label=algorithm)
    
    plt.style.use('ggplot')
    plt.title("Q-learning, Expected Sarsa", loc='left', fontsize=14)
    plt.xlabel("Episodes", fontsize=10)
    plt.ylabel("Sum of\n rewards\n during\n episode",rotation=0, labelpad=40, fontsize=10)
    plt.xlim(0,100)
    plt.xticks(fontsize=10, rotation=0)
    plt.ylim(-30,0)
    plt.yticks(fontsize=10, rotation=0)
    plt.legend(fontsize=10, loc='lower left')
    plt.show()

    return all_state_visits
 
# ===================================================================================
# Discussion Cell - disc_qlearning
# ===================================================================================

def disc_qlearning(all_state_visits):
    for algorithm, position in [("Q-learning", 211), ("Expected Sarsa", 212)]:
        plt.subplot(position)
        average_state_visits = np.array(all_state_visits[algorithm]).mean(axis=0)
        grid_state_visits = average_state_visits.reshape((4,12))
        grid_state_visits[0,1:-1] = np.nan
        plt.pcolormesh(grid_state_visits, edgecolors='gray', linewidth=2)
        plt.title(algorithm)
        plt.axis('off')
        cm = plt.get_cmap()
        cm.set_bad('gray')

        plt.subplots_adjust(bottom=0.0, right=0.7, top=1.0)
        cax = plt.axes([0.85, 0.0, 0.075, 1.])
        
    cbar = plt.colorbar(cax=cax)
    cbar.ax.set_ylabel("Visits during\n the last 10\n episodes", rotation=0, labelpad=70)
    plt.show()
 
# ===================================================================================
# Discussion Cell - Solving the Cliff World environment
# ===================================================================================

def disc_cliff_world_env():
    from itertools import product

    agents = {
        "Q-learning": QLearningAgent,
        "Expected Sarsa": ExpectedSarsaAgent
    }
    env = cliffworld_env.Environment
    all_reward_sums = {}
    step_sizes = np.linspace(0.1,1.0,10)
    agent_info = {"num_actions": 4, "num_states": 48, "epsilon": 0.1, "discount": 1.0}
    env_info = {}
    num_runs = 30
    num_episodes = 100
    all_reward_sums = {}

    algorithms = ["Q-learning", "Expected Sarsa"]
    cross_product = list(product(algorithms, step_sizes, range(num_runs)))
    for algorithm, step_size, run in tqdm(cross_product):
        if (algorithm, step_size) not in all_reward_sums:
            all_reward_sums[(algorithm, step_size)] = []

        agent_info["step_size"] = step_size
        agent_info["seed"] = run
        rl_glue = RLGlue(env, agents[algorithm])
        rl_glue.rl_init(agent_info, env_info)

        last_episode_total_reward = 0
        for episode in range(num_episodes):
            rl_glue.rl_episode(0)
        all_reward_sums[(algorithm, step_size)].append(rl_glue.rl_return()/num_episodes)
            

    for algorithm in ["Q-learning", "Expected Sarsa"]:
        algorithm_means = np.array([np.mean(all_reward_sums[(algorithm, step_size)]) for step_size in step_sizes])
        algorithm_stds = np.array([sem(all_reward_sums[(algorithm, step_size)]) for step_size in step_sizes])
        plt.plot(step_sizes, algorithm_means, marker='o', linestyle='solid', label=algorithm)
        plt.fill_between(step_sizes, algorithm_means + algorithm_stds, algorithm_means - algorithm_stds, alpha=0.2)
    
    plt.style.use('ggplot')
    plt.legend(fontsize=10, loc='lower left')
    plt.xlabel("Step-size", fontsize=10)
    plt.ylabel("Sum of\n rewards\n per episode",rotation=0, labelpad=50, fontsize=10)
    plt.xticks(step_sizes, fontsize=10)
    plt.show()

 
if __name__ == '__main__':

    test_qlearning()
    test_expected_sarsa_agent()
    all_state_visits = disc_cliff_world()
    all_state_visits = disc_qlearning(all_state_visits)
    disc_cliff_world_env()
    pass

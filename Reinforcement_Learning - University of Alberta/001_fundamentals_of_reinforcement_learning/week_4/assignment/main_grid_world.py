from src.plot import Plot
from src.gridworld_environment import GridWorld_Environment
from src.td_agent import TDAgent
from src.rlglue.rl_glue import RLGlue
import numpy as np
import argparse
from src.policies import Policy

def parse_args():
    parser = argparse.ArgumentParser(
            description = 'gridworld')

    parser.add_argument('--random', default=False,
                            help='initialize random')

    parser.add_argument('--height', type=int, default=6,
                        help = 'initialize height')
    
    parser.add_argument('--width', type=int, default=6,
                        help='initialize width')
    
    parser.add_argument('--actions', type=int, default=4,
                        help='left, up, right, down') 

    parser.add_argument('--obstacles', default = True,
                            help='initialize random obstacles')
    
    parser.add_argument('--random_teminal_state', default = False,
                            help='initialize random terminal state')

    return parser.parse_args()

def list_policies(policies):

    for s, pi_s in enumerate(policies):
        for a, p in enumerate(pi_s):
            print(f'pi(A={a}|S={s}) = {p.round(2)}    ', end='')
        print()
    pass    

def env_sanity_check(env, height, width):
    '''
    perform a sanity check of the environment prior to start experiment
    '''
        
    # generate some random coordinates within the grid
    idx_h = np.random.randint(height)
    idx_w = np.random.randint(width)
        
    # check that the state index is correct
    state = env.state((idx_h, idx_w))
    correct_state = width * idx_h + idx_w

    if state == correct_state:
        passed = 'Environment: {}'.format('Ok')
    else:
        passed = 'Environment: {}'.format('Not Ok')
    
    return passed

def agent_sanity_check(agent):
    agent.values = np.array([0., 1.])
    agent.agent_start(0)

    # reward = -1
    # next_state = 1
    # agent.agent_step(reward, next_state)

    if (np.isclose(agent.values[0], -0.001) and np.isclose(agent.values[1], 1.)):
        passed = 'Agent: {}'.format('Ok')  
    else: 
        passed = 'Agent: {}'.format('Not Ok')
    
    return passed 

def round_and_reshape(env, V):
    for i, val in enumerate(V):
        V[i] = round(V[i], 2)

    V_reshape = np.reshape(V, (env.width, env.height))
    return V_reshape

def generate_data(height, width, terminal_state, obstacle_state):
    '''
    Generate the data for the gridworld visualization. Apply the following rewards to states:
    Reward for non terminal state:  -1 
    Reward for terminal state:       5
    Reward for obstacle state:      -10

    Arguments:
    ----------
    height          - (int) height of gridworld 
    width           - (int) width of gridworld  
    terminal_state  - (tuple) (x, y) terminal states 
    obstacle_state  - (tuple) (x, y) obstacle states 

    Return:
    -------
    data            - matrix containing rewards fir each state 
    '''
    data = np.full((height, width), -1)

    for i in terminal_state:
        data[i] = 5 

    if obstacle_state != None:
        for i in obstacle_state:
                data[i] = -10        

    return data

def evaluate_improve(env, V, policies, params):
    
    gamma = params.get('gamma')
    theta = params.get('theta')
    episodes = params.get('episodes')

    episode_cnt = threshold = 0
    initial_print = True
    
    while (episode_cnt < episodes): # not policy_converged:
        episode_cnt += 1
        
        # Perform policy evaluation
        V = policy.evaluate(env, V, policies, gamma, theta)
        if initial_print:
            V_reshaped = round_and_reshape(env, V)
            print(V_reshaped)
            initial_print = False

        # Perform policy improvement      
        pi, policy_converged = policy.improve(env, V, policies, gamma)

        if episode_cnt == threshold:
            print("\nPolicy Iteration {}".format(episode_cnt))
            threshold += 10
            V_reshaped = round_and_reshape(env, V)
            print(V_reshaped)   
    
    V_reshaped = round_and_reshape(env, V)    
    plot.dashboard(data, env, V_reshaped, pi)    
    pass

def evaluate(env, V, policies, params):

    gamma = params.get('gamma')
    theta = params.get('theta')
    episodes = params.get('episodes')

    episode_cnt = threshold = 0
    initial_print = True
    
    while (episode_cnt < episodes): # not policy_converged:
        episode_cnt += 1
        
        # Perform policy evaluation
        V = policy.evaluate(env, V, policies, gamma, theta)
        if initial_print:
            V_reshaped = round_and_reshape(env, V)
            print(V_reshaped)
            initial_print = False
    
    V_reshaped = round_and_reshape(env, V)    
    print(V_reshaped)    

def iteration(env, V, policy, params):

    gamma = params.get('gamma')
    theta = params.get('theta')
    episodes = params.get('episodes')

    episode_cnt = threshold = 0
    
    while (episode_cnt < episodes): # not policy_converged:
        episode_cnt += 1
        V, pi = policy.iteration(env, gamma, theta)

        if episode_cnt == threshold:
            print("\nPolicy Iteration {}".format(episode_cnt))
            threshold += 10
            V_reshaped = round_and_reshape(env, V)
            print(V_reshaped)          

    V_reshaped = round_and_reshape(env, V)
    plot.dashboard(data, env, V_reshaped, pi)
    pass

# ==========================================================
# Main
# ==========================================================

if __name__ == '__main__':

    args = parse_args()

    #region initialization
    if args.random:
        
        height = np.random.randint(4, 10)
        width = np.random.randint(4, 10)
    else:
        
        height = args.height
        width = args.width

    if args.random_teminal_state:
        terminal_state = [(np.random.randint(1, height), np.random.randint(1, width))]   
    else:    
        terminal_state = [(0, 0), (height - 1, width - 1)] # [(height - 1, width - 1)]
    
    if args.obstacles == False:
        obstacle_state = None   
        params = {'episodes': 200,
                'gamma': 1.0,
                'epsilon': 0.08,
                'theta': 0.00001
                } 

    else:    
        obstacle_state = [(1, 1), (1, 2), (3, 4)]
        # hyperparameters
        params = {'episodes': 200,
                'gamma': 0.9,
                'epsilon': 0.08,
                'theta': 0.00001
                } 

    # actions = args.actions # left, up, right, down
    s_directions = ['left', 'up', 'right', 'down']

    actions = {}
    for a in range(args.actions):
        actions[a] = {'action': s_directions[a]}
    #endregion initialization

    #region Environment setup
    # ==========================================================
    env = GridWorld_Environment()
    env.env_init({ "grid_height": height, "grid_width": width, "actions": actions, "terminal": terminal_state, "obstacle": obstacle_state })
    env.agent_loc = (0, 0)   

    print('Env. height x width: {0} x {1}'.format(height, width))
    print('Terminal_state: {}'.format(terminal_state))
    if args.obstacles:
        print('Obstacle_state: {}'.format(obstacle_state))
    print(env_sanity_check(env, height, width))
    #endregion Environment setup  

    #region Agent setup 
    # ==========================================================
    
    agent = TDAgent()
    agent.agent_init({"policy": Policy(env), "discount": 0.99, "step_size": 0.1})

    print('\nStates: {0} à Actions: {1}'.format(len(env.S), len(env.A)))
    #endregion Agent setup

    #region data_initialization 
    gamma = params.get('gamma')
    theta = params.get('theta')
    episode = params.get('episode')
    V = agent.values
    policies = agent.policies
    policy_converged = False
    
    policy = agent.get_policy()
    plot = Plot()
    
    # generate basic matrix data
    data = generate_data(height, width, terminal_state, obstacle_state) 
    # plot.grid(env, data)
    #endregion data_initialization 

    #region policy_evaluation_improve

    evaluate(env, V, policies, params)
    evaluate_improve(env, V, policies, params)
    iteration(env, V, policy, params)

    #endregion policy_iteration

   

    pass
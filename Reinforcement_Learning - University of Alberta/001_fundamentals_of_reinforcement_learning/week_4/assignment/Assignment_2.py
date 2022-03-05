
import numpy as np
import tools
import grader


# In the city council's parking MDP, states are nonnegative integers indicating how many parking spaces are occupied, actions are nonnegative integers designating 
# the price of street parking, the reward is a real value describing the city's preference for the situation, and time is discretized by hour. As might be expected, 
# charging a high price is likely to decrease occupancy over the hour, while charging a low price is likely to increase it.
# 
# For now, let's consider an environment with three parking spaces and three price points. Note that an environment with three parking spaces actually has four 
# states &mdash; zero, one, two, or three spaces could be occupied.


# ---------------
# Discussion Cell
# ---------------

def parking_MDP():
    num_spaces = 3
    num_prices = 3
    env = tools.ParkingWorld(num_spaces, num_prices)
    V = np.zeros(num_spaces + 1)
    pi = np.ones((num_spaces + 1, num_prices)) / num_prices

    # The value function is a one-dimensional array where the $i$-th entry gives the value of $i$ spaces being occupied.
    V
    # We can represent the policy as a two-dimensional array where the $(i, j)$-th entry gives the probability of taking action $j$ in state $i$.
    pi

    pi[0] = [0.75, 0.11, 0.14]

    for s, pi_s in enumerate(pi):
        for a, p in enumerate(pi_s):
            print(f'pi(A={a}|S={s}) = {p.round(2)}    ', end='')
        print()

    V[0] = 1

    tools.plot(V, pi)

    # We can visualize a value function and policy with the `plot` function in the `tools` module. On the left, the value function is displayed as a barplot. State zero has an expected return of ten, while the other states have an expected return of zero. On the right, the policy is displayed on a two-dimensional grid. Each vertical strip gives the policy at the labeled state. In state zero, action zero is the darkest because the agent's policy makes this choice with the highest probability. In the other states the agent has the equiprobable policy, so the vertical strips are colored uniformly.
    # You can access the state space and the action set as attributes of the environment.

    print('Env.S: {}'.format(env.S))
    print('Env.A: {}'.format(env.A))

    # You will need to use the environment's `transitions` method to complete this assignment. The method takes a state and an action 
    # and returns a 2-dimensional array, where the entry at $(i, 0)$ is the reward for transitioning to state $i$ from the current 
    # state and the entry at $(i, 1)$ is the conditional probability of transitioning to state $i$ given the current state and action.

    state = 3
    action = 1
    transitions = env.transitions(state, action)

    print(' ')
    print('transitions:')
    for sp, (r, p) in enumerate(transitions):
        print(f'p(S\'= {sp}, R= {r} | S= {state}, A= {action}) = {p.round(2)}')

def evaluate_policy(env, V, pi, gamma, theta):
    delta = float('inf')
    while delta > theta:
        delta = 0
        for s in env.S:
            v = V[s]
            V = bellman_update(env, V, pi, s, gamma)
            delta = max(delta, abs(v - V[s]))
            
    return V

# -----------
# Graded Cell
# -----------
def bellman_update(env, V, pi, s, gamma):
    """
    Mutate ``V`` according to the Bellman update equation.
    """
        
    v = 0
    for a in env.A:
        for s_prime, (reward, p) in enumerate(env.transitions(s, a)):
            v += pi[s, a] * (p * (reward + (gamma * V[s_prime])) )
    V[s] = v 
    
    return V

def policy_evaluation():

    # set up test environment
    num_spaces = 10
    num_prices = 4
    env = tools.ParkingWorld(num_spaces, num_prices)

    # build test policy
    city_policy = np.zeros((num_spaces + 1, num_prices))
    city_policy[:, 1] = 1

    gamma = 0.9
    theta = 0.1

    V = np.zeros(num_spaces + 1)
    V = evaluate_policy(env, V, city_policy, gamma, theta)

    print(V)

    # -----------
    # Tested Cell
    # -----------
    # The contents of the cell will be tested by the autograder.
    # If they do not pass here, they will not pass there.

    # set up test environment
    num_spaces = 10
    num_prices = 4
    env = tools.ParkingWorld(num_spaces, num_prices)

    # build test policy
    city_policy = np.zeros((num_spaces + 1, num_prices))
    city_policy[:, 1] = 1

    gamma = 0.9
    theta = 0.1

    V = np.zeros(num_spaces + 1)
    V = evaluate_policy(env, V, city_policy, gamma, theta)

    # test the value function
    answer = [80.04, 81.65, 83.37, 85.12, 86.87, 88.55, 90.14, 91.58, 92.81, 93.78, 87.77]

    # make sure the value function is within 2 decimal places of the correct answer
    assert grader.near(V, answer, 1e-2)

    # lock
    tools.plot(V, city_policy)

def improve_policy(env, V, pi, gamma):
    policy_stable = True
    for s in env.S:
        old = pi[s].copy()
        q_greedify_policy(env, V, pi, s, gamma)
        
        if not np.array_equal(pi[s], old):
            policy_stable = False
            
    return pi, policy_stable

def policy_iteration(env, gamma, theta):
    V = np.zeros(len(env.S))
    pi = np.ones((len(env.S), len(env.A))) / len(env.A)
    policy_stable = False
    
    while not policy_stable:
        V = evaluate_policy(env, V, pi, gamma, theta)
        pi, policy_stable = improve_policy(env, V, pi, gamma)
        
    return V, pi

# -----------
# Graded Cell
# -----------
def q_greedify_policy(env, V, pi, s, gamma):
    """
    Mutate ``pi`` to be greedy with respect to the q-values induced by ``V``.
    The method takes a state and an action and returns a 2-dimensional array, where the entry 
    at $(i, 0)$ is the reward for transitioning to state $i$ from the current 
    state and the entry at $(i, 1)$ is the conditional probability of transitioning to state $i$ 
    given the current state and action.
    """
    # YOUR CODE HERE

    best_value  = float('-inf')
    best_action = 0

    for a in env.A:
        transitions = env.transitions(s, a)
        v = 0
        
        for s_prime in env.S:
            reward = transitions[s_prime][0]
            p      = transitions[s_prime][1]
            
            v += p * (reward + (gamma * V[s_prime]))

        if best_value < v:
            best_value  = v
            best_action = a

    pi[s] = np.zeros_like(pi[s])
    pi[s][best_action] = 1
    return pi

# --------------
# Debugging Cell
# --------------
# Feel free to make any changes to this cell to debug your code

def policy_improvement():
    gamma = 0.9
    theta = 0.1
    env = tools.ParkingWorld(num_spaces=6, num_prices=4)

    V = np.array([7, 6, 5, 4, 3, 2, 1])
    pi = np.ones((7, 4)) / 4

    new_pi, stable = improve_policy(env, V, pi, gamma)

    # expect first call to greedify policy
    expected_pi = np.array([
        [0, 0, 0, 1],
        [0, 0, 0, 1],
        [0, 0, 0, 1],
        [0, 0, 0, 1],
        [0, 0, 0, 1],
        [0, 0, 0, 1],
        [0, 0, 0, 1],
    ])
    assert np.all(new_pi == expected_pi)
    assert stable == False

    # the value function has not changed, so the greedy policy should not change
    new_pi, stable = improve_policy(env, V, new_pi, gamma)

    assert np.all(new_pi == expected_pi)
    assert stable == True

    # -----------
    # Tested Cell
    # -----------
    # The contents of the cell will be tested by the autograder.
    # If they do not pass here, they will not pass there.
    gamma = 0.9
    theta = 0.1
    env = tools.ParkingWorld(num_spaces=10, num_prices=4)

    V, pi = policy_iteration(env, gamma, theta)

    V_answer = [81.60, 83.28, 85.03, 86.79, 88.51, 90.16, 91.70, 93.08, 94.25, 95.25, 89.45]
    pi_answer = [
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [0, 0, 0, 1],
        [0, 0, 0, 1],
    ]

    # make sure value function is within 2 decimal places of answer
    assert grader.near(V, V_answer, 1e-2)
    # make sure policy is exactly correct
    assert np.all(pi == pi_answer)

    # When you are ready to test the policy iteration algorithm, run the cell below.

    env = tools.ParkingWorld(num_spaces=10, num_prices=4)
    gamma = 0.9
    theta = 0.1
    V, pi = policy_iteration(env, gamma, theta)

    # You can use the ``plot`` function to visualize the final value function and policy.

    tools.plot(V, pi)

def value_iteration(env, gamma, theta):
    V = np.zeros(len(env.S))
    while True:
        delta = 0
        for s in env.S:
            v = V[s]
            bellman_optimality_update(env, V, s, gamma)
            delta = max(delta, abs(v - V[s]))
        if delta < theta:
            break
    pi = np.ones((len(env.S), len(env.A))) / len(env.A)
    for s in env.S:
        q_greedify_policy(env, V, pi, s, gamma)
    return V, pi

# -----------
# Graded Cell
# -----------
def bellman_optimality_update(env, V, s, gamma):
    """Mutate ``V`` according to the Bellman optimality update equation."""

    best_value = float('-inf')
    for a in env.A:
        v = 0
        transitions = env.transitions(s,a)
        
        for s_prime in env.S:
            reward = transitions[s_prime][0]
            p      = transitions[s_prime][1]
            
            v += p * (reward + (gamma * V[s_prime]))
            
        if best_value < v:
            best_value = v
    V[s] = best_value
    return V

# --------------
# Debugging Cell
# --------------
# Feel free to make any changes to this cell to debug your code
def bellmann_optimality_update():
    gamma = 0.9
    env = tools.ParkingWorld(num_spaces=6, num_prices=4)

    V = np.array([7, 6, 5, 4, 3, 2, 1])

    # only state 0 updated
    bellman_optimality_update(env, V, 0, gamma)
    assert list(V) == [5, 6, 5, 4, 3, 2, 1]

    # only state 2 updated
    bellman_optimality_update(env, V, 2, gamma)
    assert list(V) == [5, 6, 7, 4, 3, 2, 1]

    # -----------
    # Tested Cell
    # -----------
    # The contents of the cell will be tested by the autograder.
    # If they do not pass here, they will not pass there.
    gamma = 0.9
    env = tools.ParkingWorld(num_spaces=10, num_prices=4)

    V = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])

    for _ in range(10):
        for s in env.S:
            bellman_optimality_update(env, V, s, gamma)

    # make sure value function is exactly correct
    answer = [61, 63, 65, 67, 69, 71, 72, 74, 75, 76, 71]
    assert np.all(V == answer)

    # When you are ready to test the value iteration algorithm, run the cell below.

    env = tools.ParkingWorld(num_spaces=10, num_prices=4)
    gamma = 0.9
    theta = 0.1
    V, pi = value_iteration(env, gamma, theta)

    # You can use the ``plot`` function to visualize the final value function and policy.

    tools.plot(V, pi)


def value_iteration2(env, gamma, theta):
    V = np.zeros(len(env.S))
    pi = np.ones((len(env.S), len(env.A))) / len(env.A)
    while True:
        delta = 0
        for s in env.S:
            v = V[s]
            q_greedify_policy(env, V, pi, s, gamma)
            bellman_update(env, V, pi, s, gamma)
            delta = max(delta, abs(v - V[s]))
        if delta < theta:
            break
    return V, pi

if __name__ == '__main__':
    
    parking_MDP()
    policy_evaluation()
    policy_improvement()
    bellmann_optimality_update()
    
    # value iteration algorithm by running the cell below.
    env = tools.ParkingWorld(num_spaces=10, num_prices=4)
    gamma = 0.9
    theta = 0.1
    V, pi = value_iteration2(env, gamma, theta)
    tools.plot(V, pi)    
    pass 


# Do not modify this cell!

import os
import shutil

import matplotlib.pyplot as plt
# Import necessary libraries
# DO NOT IMPORT OTHER LIBRARIES - This will break the autograder.
import numpy as np
from tqdm import tqdm

import plot_script
from randomwalk_environment import RandomWalkEnvironment
from rl_glue import RLGlue
from agent import BaseAgent
from optimizer import BaseOptimizer
# from adam import Adam
# from sgd import SGD
# from td_agent import TDAgent


def my_matmul(x1, x2):
    """
    Given matrices x1 and x2, return the multiplication of them
    """
    
    result = np.zeros((x1.shape[0], x2.shape[1]))
    x1_non_zero_indices = x1.nonzero()
    if x1.shape[0] == 1 and len(x1_non_zero_indices[1]) == 1:
        result = x2[x1_non_zero_indices[1], :]
    elif x1.shape[1] == 1 and len(x1_non_zero_indices[0]) == 1:
        result[x1_non_zero_indices[0], :] = x2 * x1[x1_non_zero_indices[0], 0]
    else:
        result = np.matmul(x1, x2)
    return result

def ReLU(z):
    '''
    Rectified linear Unit function
    Returns a 0 value for each negative value, while positive values remain.
    '''
    return z * (z > 0)

def Step(z):
    '''
    Rectified linear Unit function
    Returns a 0 value for each negative value, while positive values are 1.
    '''
    I = (z > 0).astype(float)
    II = 1 * (z > 0)
    return 1 * (z > 0)

def one_hot(state, num_states):
    """
    Given num_state and a state, return the one-hot encoding of the state
    """
    # Create the one-hot encoding of state
    # one_hot_vector is a numpy array of shape (1, num_states)
    
    one_hot_vector = np.zeros((1, num_states))
    one_hot_vector[0, int((state - 1))] = 1
    
    return one_hot_vector

def get_gradient(s, weights):
    """
    Given inputs s and weights, return the gradient of v with respect to the weights
    """

    ### Compute the gradient of the value function with respect to W0, b0, W1, b1 for input s
    # grads[0]["W"] = ?
    # grads[0]["b"] = ?
    # grads[1]["W"] = ?
    # grads[1]["b"] = ?
    # Note that grads[0]["W"], grads[0]["b"], grads[1]["W"], and grads[1]["b"] should have the same shape as 
    # weights[0]["W"], weights[0]["b"], weights[1]["W"], and weights[1]["b"] respectively
    # Note that to compute the gradients, you need to compute the activation of the hidden layer (x)

    w0 = weights[0]["W"]
    b0 = weights[0]["b"]
    w1 = weights[1]["W"]
    b1 = weights[1]["b"]

    grads = [dict() for i in range(len(weights))]
    
    # psi = my_matmul(s, w0) + b0
    psi = np.dot(s, w0) + b0  
    x = Step(psi)
    
    # grads[0]["W"] = my_matmul(np.transpose(s), np.transpose(w1) * x) 
    grads[0]["W"] = np.dot(np.transpose(s), np.transpose(w1) * x) 
    grads[0]["b"] = np.transpose(w1) * x
    grads[1]["W"] = np.transpose(ReLU(psi)) 
    grads[1]["b"] = np.array([[1.0]])

    # ----------------

    return grads

def get_value(s, weights):
    """
    Compute value of input s given the weights of a neural network
    """
    ### Compute the ouput of the neural network, v, for input s
    
    # ----------------
    # your code here

    w0 = weights[0]["W"]
    b0 = weights[0]["b"]
    w1 = weights[1]["W"]
    b1 = weights[1]["b"]
    
    psi = my_matmul(s, w0) + b0
    x = ReLU(psi)
    v = my_matmul(x, w1) + b1

    # ----------------
    return v

class Adam(BaseOptimizer):
    def __init__(self):
        pass
    
    def optimizer_init(self, optimizer_info):
        """Setup for the optimizer.

        Set parameters needed to setup the Adam algorithm.

        Assume optimizer_info dict contains:
        {
            num_states: integer,
            num_hidden_layer: integer,
            num_hidden_units: integer,
            step_size: float, 
            self.beta_m: float
            self.beta_v: float
            self.epsilon: float
        }
        """
        
        self.num_states = optimizer_info.get("num_states")
        self.num_hidden_layer = optimizer_info.get("num_hidden_layer")
        self.num_hidden_units = optimizer_info.get("num_hidden_units")

        # Specify Adam algorithm's hyper parameters
        self.step_size = optimizer_info.get("step_size")
        self.beta_m = optimizer_info.get("beta_m")
        self.beta_v = optimizer_info.get("beta_v")
        self.epsilon = optimizer_info.get("epsilon")

        self.layer_size = np.array([self.num_states, self.num_hidden_units, 1])

        # Initialize Adam algorithm's m and v
        self.m = [dict() for i in range(self.num_hidden_layer+1)]
        self.v = [dict() for i in range(self.num_hidden_layer+1)]

        for i in range(self.num_hidden_layer+1):

            # Initialize self.m[i]["W"], self.m[i]["b"], self.v[i]["W"], self.v[i]["b"] to zero
            self.m[i]["W"] = np.zeros((self.layer_size[i], self.layer_size[i+1]))
            self.m[i]["b"] = np.zeros((1, self.layer_size[i+1]))
            self.v[i]["W"] = np.zeros((self.layer_size[i], self.layer_size[i+1]))
            self.v[i]["b"] = np.zeros((1, self.layer_size[i+1]))

        # Initialize beta_m_product and beta_v_product to be later used for computing m_hat and v_hat
        self.beta_m_product = self.beta_m
        self.beta_v_product = self.beta_v

    def update_weights(self, weights, g):
        """
        Given weights and update g, return updated weights
        """
        
        for i in range(len(weights)):
            for param in weights[i].keys():

                ### update self.m and self.v
                self.m[i][param] = self.beta_m * self.m[i][param] + (1 - self.beta_m) * g[i][param]
                self.v[i][param] = self.beta_v * self.v[i][param] + (1 - self.beta_v) * (g[i][param] * g[i][param])

                ### compute m_hat and v_hat
                m_hat = self.m[i][param] / (1 - self.beta_m_product)
                v_hat = self.v[i][param] / (1 - self.beta_v_product)

                ### update weights
                weights[i][param] += self.step_size * m_hat / (np.sqrt(v_hat) + self.epsilon)
                
        ### update self.beta_m_product and self.beta_v_product
        self.beta_m_product *= self.beta_m
        self.beta_v_product *= self.beta_v
        
        return weights

class SGD(BaseOptimizer):
    def __init__(self):
        pass
    
    def optimizer_init(self, optimizer_info):
        """Setup for the optimizer.

        Set parameters needed to setup the stochastic gradient descent method.

        Assume optimizer_info dict contains:
        {
            step_size: float
        }
        """
        self.step_size = optimizer_info.get("step_size")
    
    def update_weights(self, weights, g):
        """
        Given weights and update g, return updated weights
        """
        for i in range(len(weights)):
            for param in weights[i].keys():

                ### update weights
                # weights[i][param] = None
                
                weights[i][param] = weights[i][param] + self.step_size * g[i][param]
                # ----------------
                
        return weights

class TDAgent(BaseAgent):
    def __init__(self):
        self.name = "td_agent"
        pass

    def agent_init(self, agent_info={}):
        """Setup for the agent called when the experiment first starts.

        Set parameters needed to setup the semi-gradient TD with a Neural Network.

        Assume agent_info dict contains:
        {
            num_states: integer,
            num_hidden_layer: integer,
            num_hidden_units: integer,
            step_size: float, 
            discount_factor: float,
            self.beta_m: float
            self.beta_v: float
            self.epsilon: float
            seed: int
        }
        """
    
        # Set random seed for weights initialization for each run
        self.rand_generator = np.random.RandomState(agent_info.get("seed")) 
        
        # Set random seed for policy for each run
        self.policy_rand_generator = np.random.RandomState(agent_info.get("seed"))

        # Set attributes according to agent_info
        self.num_states = agent_info.get("num_states")
        self.num_hidden_layer = agent_info.get("num_hidden_layer")
        self.num_hidden_units = agent_info.get("num_hidden_units")
        self.discount_factor = agent_info.get("discount_factor")

        ### Define the neural network's structure
        # Specify self.layer_size which shows the number of nodes in each layer
        # self.layer_size = np.array([None, None, None])
        # Hint: Checkout the NN diagram at the beginning of the notebook
        
        # ----------------
        # your code here
        self.layer_size = np.array([self.num_states, self.num_hidden_units, 1])
        # ----------------

        # Initialize the neural network's parameter
        self.weights = [dict() for i in range(self.num_hidden_layer+1)]
        for i in range(self.num_hidden_layer+1):
            
            ### Initialize self.weights[i]["W"] and self.weights[i]["b"] using self.rand_generator.normal()
            # Note that The parameters of self.rand_generator.normal are mean of the distribution, 
            # standard deviation of the distribution, and output shape in the form of tuple of integers.
            # To specify output shape, use self.layer_size.

            # ----------------
            # your code here
            # self.rand_generator.normal(mu, sigma, tuple)

            self.weights[i]["W"] = self.rand_generator.normal(0, np.sqrt(2 / self.layer_size[i]), (self.layer_size[i], self.layer_size[i + 1]))
            self.weights[i]["b"] = self.rand_generator.normal(0, np.sqrt(2 / self.layer_size[i]), (1, self.layer_size[i + 1]))
            # ----------------
        
        # Specify the optimizer
        self.optimizer = Adam()
        self.optimizer.optimizer_init({
            "num_states": agent_info["num_states"],
            "num_hidden_layer": agent_info["num_hidden_layer"],
            "num_hidden_units": agent_info["num_hidden_units"],
            "step_size": agent_info["step_size"],
            "beta_m": agent_info["beta_m"],
            "beta_v": agent_info["beta_v"],
            "epsilon": agent_info["epsilon"],
        })
        
        self.last_state = None
        self.last_action = None

    def agent_policy(self, state):

        ### Set chosen_action as 0 or 1 with equal probability. 
        chosen_action = self.policy_rand_generator.choice([0,1])    
        return chosen_action

    def agent_start(self, state):
        """The first method called when the experiment starts, called after
        the environment starts.
        Args:
            state (Numpy array): the state from the
                environment's evn_start function.
        Returns:
            The first action the agent takes.
        """
        ### select action given state (using self.agent_policy()), and save current state and action
        # self.last_state = ?
        # self.last_action = ?

        # ----------------
        # your code here
        self.last_state = state
        self.last_action = self.agent_policy(state)
        # ----------------

        return self.last_action

    def agent_step(self, reward, state):
        """A step taken by the agent.
        Args:
            reward (float): the reward received for taking the last action taken
            state (Numpy array): the state from the
                environment's step based, where the agent ended up after the
                last step
        Returns:
            The action the agent is taking.
        """
        
        ### Compute TD error
        # delta = None

        # ----------------
        # your code here
        last_state    = one_hot(self.last_state, self.num_states)
        current_state = one_hot(state, self.num_states)

        delta = self.discount_factor * get_value(last_state, self.weights) - get_value(current_state, self.weights)
        # ----------------

        ### Retrieve gradients
        # grads = None

        # ----------------
        # your code here
        grads = get_gradient(last_state, self.weights)
        # ----------------

        ### Compute g (1 line)
        g = [dict() for i in range(self.num_hidden_layer+1)]
        for i in range(self.num_hidden_layer+1):
            for param in self.weights[i].keys():

                # g[i][param] = None
                # ----------------
                # your code here
                g[i][param] = (reward + delta) * grads[i][param]
                # ----------------

        ### update the weights using self.optimizer
        # self.weights = None
        
        # ----------------
        # your code here
        self.weights = self.optimizer.update_weights(self.weights, g)
        # ----------------

        ### update self.last_state and self.last_action

        # ----------------
        # your code here
        self.last_state = state
        self.last_action = self.agent_policy(state)
        # ----------------

        return self.last_action

    def agent_end(self, reward):
        """Run when the agent terminates.
        Args:
            reward (float): the reward the agent received for entering the
                terminal state.
        """

        ### compute TD error
        # delta = None

        # ----------------
        # your code here
        last_state    = one_hot(self.last_state, self.num_states)
        delta = self.discount_factor * get_value(last_state, self.weights)     
        # ----------------

        ### Retrieve gradients
        # grads = None

        # ----------------
        # your code here
        grads = get_gradient(last_state, self.weights)
        # ----------------

        ### Compute g
        g = [dict() for i in range(self.num_hidden_layer+1)]
        for i in range(self.num_hidden_layer+1):
            for param in self.weights[i].keys():

                # g[i][param] = None
                # ----------------
                # your code here
                g[i][param] = (reward + delta) * grads[i][param]
                # ----------------

        ### update the weights using self.optimizer
        # self.weights = None
        
        # ----------------
        # your code here
        self.weights = self.optimizer.update_weights(self.weights, g)
        # ----------------

    def agent_message(self, message):

        if message == 'get state value':
            state_value = np.zeros(self.num_states)
            for state in range(1, self.num_states + 1):
                s = one_hot(state, self.num_states)
                state_value[state - 1] = get_value(s, self.weights)
        return state_value

# Run the following code to test your implementation of the `get_value()` function:

# -----------
# Tested Cell
# -----------

def check_1():
    # The contents of the cell will be tested by the autograder.
    # If they do not pass here, they will not pass there.

    # Suppose num_states = 5, num_hidden_layer = 1, and num_hidden_units = 10 
    num_hidden_layer = 1
    s = np.array([[0, 0, 0, 1, 0]])

    weights_data = np.load("asserts/get_value_weights.npz")
    weights = [dict() for i in range(num_hidden_layer+1)]
    weights[0]["W"] = weights_data["W0"]
    weights[0]["b"] = weights_data["b0"]
    weights[1]["W"] = weights_data["W1"]
    weights[1]["b"] = weights_data["b1"]

    estimated_value = get_value(s, weights)
    print ("Estimated value: {}".format(estimated_value))

    assert(np.allclose(estimated_value, [[-0.21915705]]))

    # -----------
    # Tested Cell
    # -----------
    # The contents of the cell will be tested by the autograder.
    # If they do not pass here, they will not pass there.

    # Suppose num_states = 5, num_hidden_layer = 1, and num_hidden_units = 2 
    num_hidden_layer = 1
    s = np.array([[0, 0, 0, 1, 0]])

    weights_data = np.load("asserts/get_gradient_weights.npz")
    weights = [dict() for i in range(num_hidden_layer+1)]
    weights[0]["W"] = weights_data["W0"]
    weights[0]["b"] = weights_data["b0"]
    weights[1]["W"] = weights_data["W1"]
    weights[1]["b"] = weights_data["b1"]

    grads = get_gradient(s, weights)

    grads_answer = np.load("asserts/get_gradient_grads.npz")

    print('grads[0]["W"]: {0} - grads_answer["W0"]: {1}'.format(grads[0]["W"].shape, grads_answer["W0"].shape))
    print('grads[0]["b"]: {0} - grads_answer["b0"]: {1}'.format(grads[0]["b"].shape, grads_answer["b0"].shape))
    print('grads[1]["W"]: {0} - grads_answer["W1"]: {1}'.format(grads[1]["W"].shape,grads_answer["W1"].shape))
    print('grads[1]["b"]: {0} - grads_answer["b1"]: {1}'.format(grads[1]["b"].shape, grads_answer["b1"].shape))


    assert(np.allclose(grads[0]["W"], grads_answer["W0"]))
    assert(np.allclose(grads[0]["b"], grads_answer["b0"]))
    assert(np.allclose(grads[1]["W"], grads_answer["W1"]))
    assert(np.allclose(grads[1]["b"], grads_answer["b1"]))

def check_2():
    # The contents of the cell will be tested by the autograder.
    # If they do not pass here, they will not pass there.

    # Suppose num_states = 5, num_hidden_layer = 1, and num_hidden_units = 2 
    num_hidden_layer = 1

    weights_data = np.load("asserts/update_weights_weights.npz")
    weights = [dict() for i in range(num_hidden_layer+1)]
    weights[0]["W"] = weights_data["W0"]
    weights[0]["b"] = weights_data["b0"]
    weights[1]["W"] = weights_data["W1"]
    weights[1]["b"] = weights_data["b1"]

    g_data = np.load("asserts/update_weights_g.npz")
    g = [dict() for i in range(num_hidden_layer+1)]
    g[0]["W"] = g_data["W0"]
    g[0]["b"] = g_data["b0"]
    g[1]["W"] = g_data["W1"]
    g[1]["b"] = g_data["b1"]

    test_sgd = SGD()
    optimizer_info = {"step_size": 0.3}
    test_sgd.optimizer_init(optimizer_info)
    updated_weights = test_sgd.update_weights(weights, g)

    # updated weights asserts
    updated_weights_answer = np.load("asserts/update_weights_updated_weights.npz")

    assert(np.allclose(updated_weights[0]["W"], updated_weights_answer["W0"]))
    assert(np.allclose(updated_weights[0]["b"], updated_weights_answer["b0"]))
    assert(np.allclose(updated_weights[1]["W"], updated_weights_answer["W1"]))
    assert(np.allclose(updated_weights[1]["b"], updated_weights_answer["b1"]))

def check_3():
    # The contents of the cell will be tested by the autograder.
    # If they do not pass here, they will not pass there.

    agent_info = {
        "num_states": 5,
        "num_hidden_layer": 1,
        "num_hidden_units": 2,
        "step_size": 0.25,
        "discount_factor": 0.9,
        "beta_m": 0.9,
        "beta_v": 0.99,
        "epsilon": 0.0001,
        "seed": 0,
    }

    test_agent = TDAgent()
    test_agent.agent_init(agent_info)

    print("layer_size: {}".format(test_agent.layer_size))
    assert(np.allclose(test_agent.layer_size, np.array([agent_info["num_states"], 
                                                        agent_info["num_hidden_units"], 
                                                        1])))

    assert(test_agent.weights[0]["W"].shape == (agent_info["num_states"], agent_info["num_hidden_units"]))
    assert(test_agent.weights[0]["b"].shape == (1, agent_info["num_hidden_units"]))
    assert(test_agent.weights[1]["W"].shape == (agent_info["num_hidden_units"], 1))
    assert(test_agent.weights[1]["b"].shape == (1, 1))

    agent_weight_answer = np.load("asserts/agent_init_weights_1.npz")
    assert(np.allclose(test_agent.weights[0]["W"], agent_weight_answer["W0"]))
    assert(np.allclose(test_agent.weights[0]["b"], agent_weight_answer["b0"]))
    assert(np.allclose(test_agent.weights[1]["W"], agent_weight_answer["W1"]))
    assert(np.allclose(test_agent.weights[1]["b"], agent_weight_answer["b1"]))

def check_4():
    # The contents of the cell will be tested by the autograder.
    # If they do not pass here, they will not pass there.

    agent_info = {
        "num_states": 500,
        "num_hidden_layer": 1,
        "num_hidden_units": 100,
        "step_size": 0.1,
        "discount_factor": 1.0,
        "beta_m": 0.9,
        "beta_v": 0.99,
        "epsilon": 0.0001,
        "seed": 10,
    }

    # Suppose state = 250
    state = 250

    test_agent = TDAgent()
    test_agent.agent_init(agent_info)
    test_agent.agent_start(state)

    assert(test_agent.last_state == 250)
    assert(test_agent.last_action == 1)


# Run the following code to test your implementation of the `agent_step()` function:

def check_5():
    # The contents of the cell will be tested by the autograder.
    # If they do not pass here, they will not pass there.

    agent_info = {
        "num_states": 5,
        "num_hidden_layer": 1,
        "num_hidden_units": 2,
        "step_size": 0.1,
        "discount_factor": 1.0,
        "beta_m": 0.9,
        "beta_v": 0.99,
        "epsilon": 0.0001,
        "seed": 0,
    }

    test_agent = TDAgent()
    test_agent.agent_init(agent_info)

    # load initial weights
    agent_initial_weight = np.load("asserts/agent_step_initial_weights.npz")
    test_agent.weights[0]["W"] = agent_initial_weight["W0"]
    test_agent.weights[0]["b"] = agent_initial_weight["b0"]
    test_agent.weights[1]["W"] = agent_initial_weight["W1"]
    test_agent.weights[1]["b"] = agent_initial_weight["b1"]

    # load m and v for the optimizer
    m_data = np.load("asserts/agent_step_initial_m.npz")
    test_agent.optimizer.m[0]["W"] = m_data["W0"]
    test_agent.optimizer.m[0]["b"] = m_data["b0"]
    test_agent.optimizer.m[1]["W"] = m_data["W1"]
    test_agent.optimizer.m[1]["b"] = m_data["b1"]

    v_data = np.load("asserts/agent_step_initial_v.npz")
    test_agent.optimizer.v[0]["W"] = v_data["W0"]
    test_agent.optimizer.v[0]["b"] = v_data["b0"]
    test_agent.optimizer.v[1]["W"] = v_data["W1"]
    test_agent.optimizer.v[1]["b"] = v_data["b1"]

    # Assume the agent started at State 3
    start_state = 3
    test_agent.agent_start(start_state)

    # Assume the reward was 10.0 and the next state observed was State 1
    reward = 10.0
    next_state = 1
    test_agent.agent_step(reward, next_state)

    agent_updated_weight_answer = np.load("asserts/agent_step_updated_weights.npz")
    assert(np.allclose(test_agent.weights[0]["W"], agent_updated_weight_answer["W0"]))
    assert(np.allclose(test_agent.weights[0]["b"], agent_updated_weight_answer["b0"]))
    assert(np.allclose(test_agent.weights[1]["W"], agent_updated_weight_answer["W1"]))
    assert(np.allclose(test_agent.weights[1]["b"], agent_updated_weight_answer["b1"]))

    assert(test_agent.last_state == 1)
    assert(test_agent.last_action == 1)

# Run the following code to test your implementation of the `agent_end()` function:

def check_6():
    # -----------
    # Tested Cell
    # -----------
    # The contents of the cell will be tested by the autograder.
    # If they do not pass here, they will not pass there.

    agent_info = {
        "num_states": 5,
        "num_hidden_layer": 1,
        "num_hidden_units": 2,
        "step_size": 0.1,
        "discount_factor": 1.0,
        "beta_m": 0.9,
        "beta_v": 0.99,
        "epsilon": 0.0001,
        "seed": 0,
    }

    test_agent = TDAgent()
    test_agent.agent_init(agent_info)

    # load initial weights
    agent_initial_weight = np.load("asserts/agent_end_initial_weights.npz")
    test_agent.weights[0]["W"] = agent_initial_weight["W0"]
    test_agent.weights[0]["b"] = agent_initial_weight["b0"]
    test_agent.weights[1]["W"] = agent_initial_weight["W1"]
    test_agent.weights[1]["b"] = agent_initial_weight["b1"]

    # load m and v for the optimizer
    m_data = np.load("asserts/agent_step_initial_m.npz")
    test_agent.optimizer.m[0]["W"] = m_data["W0"]
    test_agent.optimizer.m[0]["b"] = m_data["b0"]
    test_agent.optimizer.m[1]["W"] = m_data["W1"]
    test_agent.optimizer.m[1]["b"] = m_data["b1"]

    v_data = np.load("asserts/agent_step_initial_v.npz")
    test_agent.optimizer.v[0]["W"] = v_data["W0"]
    test_agent.optimizer.v[0]["b"] = v_data["b0"]
    test_agent.optimizer.v[1]["W"] = v_data["W1"]
    test_agent.optimizer.v[1]["b"] = v_data["b1"]

    # Assume the agent started at State 4
    start_state = 4
    test_agent.agent_start(start_state)

    # Assume the reward was 10.0 and reached the terminal state
    reward = 10.0
    test_agent.agent_end(reward)

    # updated weights asserts
    agent_updated_weight_answer = np.load("asserts/agent_end_updated_weights.npz")
    assert(np.allclose(test_agent.weights[0]["W"], agent_updated_weight_answer["W0"]))
    assert(np.allclose(test_agent.weights[0]["b"], agent_updated_weight_answer["b0"]))
    assert(np.allclose(test_agent.weights[1]["W"], agent_updated_weight_answer["W1"]))
    assert(np.allclose(test_agent.weights[1]["b"], agent_updated_weight_answer["b1"]))

# ## Section 2 - Run Experiment
# 
# Now that you implemented the agent, we can run the experiment. Similar to Course 3 Programming Assignment 1, we will plot the learned state value function and the learning curve of the TD agent. To plot the learning curve, we use Root Mean Squared Value Error (RMSVE). 

# ---------------
# Discussion Cell
# ---------------
if __name__ == '__main__':

    check_1()
    check_2()
    check_3()
    check_4()
    check_5()
    check_6()
        
    true_state_val = np.load('data/true_V.npy')    
    state_distribution = np.load('data/state_distribution.npy')

    def calc_RMSVE(learned_state_val):
        assert(len(true_state_val) == len(learned_state_val) == len(state_distribution))
        MSVE = np.sum(np.multiply(state_distribution, np.square(true_state_val - learned_state_val)))
        RMSVE = np.sqrt(MSVE)
        return RMSVE

    # Define function to run experiment
    def run_experiment(environment, agent, environment_parameters, agent_parameters, experiment_parameters):
        
        rl_glue = RLGlue(environment, agent)
            
        # save rmsve at the end of each episode
        agent_rmsve = np.zeros((experiment_parameters["num_runs"], 
                                int(experiment_parameters["num_episodes"]/experiment_parameters["episode_eval_frequency"]) + 1))
        
        # save learned state value at the end of each run
        agent_state_val = np.zeros((experiment_parameters["num_runs"], 
                                    environment_parameters["num_states"]))

        env_info = {"num_states": environment_parameters["num_states"],
                    "start_state": environment_parameters["start_state"],
                    "left_terminal_state": environment_parameters["left_terminal_state"],
                    "right_terminal_state": environment_parameters["right_terminal_state"]}

        agent_info = {"num_states": environment_parameters["num_states"],
                    "num_hidden_layer": agent_parameters["num_hidden_layer"],
                    "num_hidden_units": agent_parameters["num_hidden_units"],
                    "step_size": agent_parameters["step_size"],
                    "discount_factor": environment_parameters["discount_factor"],
                    "beta_m": agent_parameters["beta_m"],
                    "beta_v": agent_parameters["beta_v"],
                    "epsilon": agent_parameters["epsilon"]
                    }
        
        print('Setting - Neural Network with 100 hidden units')
        os.system('sleep 1')

        # one agent setting
        for run in tqdm(range(1, experiment_parameters["num_runs"]+1)):
            env_info["seed"] = run
            agent_info["seed"] = run
            rl_glue.rl_init(agent_info, env_info)
            
            # Compute initial RMSVE before training
            current_V = rl_glue.rl_agent_message("get state value")
            agent_rmsve[run-1, 0] = calc_RMSVE(current_V)
            
            for episode in range(1, experiment_parameters["num_episodes"]+1):
                # run episode
                rl_glue.rl_episode(0) # no step limit

                if episode % experiment_parameters["episode_eval_frequency"] == 0:
                    current_V = rl_glue.rl_agent_message("get state value")
                    agent_rmsve[run-1, int(episode/experiment_parameters["episode_eval_frequency"])] = calc_RMSVE(current_V)
                elif episode == experiment_parameters["num_episodes"]: # if last episode
                    current_V = rl_glue.rl_agent_message("get state value")

            agent_state_val[run-1, :] = current_V

        save_name = "{}".format(rl_glue.agent.name).replace('.','')
        
        if not os.path.exists('results'):
                    os.makedirs('results')
        
        # save avg. state value
        np.save("results/V_{}".format(save_name), agent_state_val)

        # save avg. rmsve
        np.savez("results/RMSVE_{}".format(save_name), rmsve = agent_rmsve,
                                                    eval_freq = experiment_parameters["episode_eval_frequency"],
                                                    num_episodes = experiment_parameters["num_episodes"])


    # Run Experiment

    # Experiment parameters
    experiment_parameters = {
        "num_runs" : 20,
        "num_episodes" : 1000,
        "episode_eval_frequency" : 10 # evaluate every 10 episode
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
    agent_parameters = {
        "num_hidden_layer": 1,
        "num_hidden_units": 100,
        "step_size": 0.001,
        "beta_m": 0.9,
        "beta_v": 0.999,
        "epsilon": 0.0001,
    }

    current_env = RandomWalkEnvironment
    current_agent = TDAgent

    # run experiment
    run_experiment(current_env, current_agent, environment_parameters, agent_parameters, experiment_parameters)

    # plot result
    plot_script.plot_result(["td_agent"])

    shutil.make_archive('results', 'zip', 'results')


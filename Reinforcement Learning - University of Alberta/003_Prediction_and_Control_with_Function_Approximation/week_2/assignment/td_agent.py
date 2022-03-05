
from agent import BaseAgent
from assignment import one_hot, get_gradient, get_value
import numpy as np
from adam import Adam

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
        
        # ----------------

        ### Retrieve gradients
        # grads = None

        # ----------------
        # your code here
        
        # ----------------

        ### Compute g
        g = [dict() for i in range(self.num_hidden_layer+1)]
        for i in range(self.num_hidden_layer+1):
            for param in self.weights[i].keys():

                # g[i][param] = None
                # ----------------
                # your code here
                pass
                # ----------------

        ### update the weights using self.optimizer
        # self.weights = None
        
        # ----------------
        # your code here
        
        # ----------------

    def agent_message(self, message):

        if message == 'get state value':
            state_value = np.zeros(self.num_states)
            for state in range(1, self.num_states + 1):
                s = one_hot(state, self.num_states)
                state_value[state - 1] = get_value(s, self.weights)
        return state_value

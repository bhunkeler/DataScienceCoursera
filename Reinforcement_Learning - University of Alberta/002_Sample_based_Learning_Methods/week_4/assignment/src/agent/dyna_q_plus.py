from agent import BaseAgent
import numpy as np 

class DynaQPlusAgent(BaseAgent):
    
    def agent_init(self, agent_info):
        """Setup for the agent called when the experiment first starts.

        Args:
            agent_init_info (dict), the parameters used to initialize the agent. The dictionary contains:
            {
                num_states (int): The number of states,
                num_actions (int): The number of actions,
                epsilon (float): The parameter for epsilon-greedy exploration,
                step_size (float): The step-size,
                discount (float): The discount factor,
                planning_steps (int): The number of planning steps per environmental interaction
                kappa (float): The scaling factor for the reward bonus

                random_seed (int): the seed for the RNG used in epsilon-greedy
                planning_random_seed (int): the seed for the RNG used in the planner
            }
        """

        # First, we get the relevant information from agent_info 
        # Note: we use np.random.RandomState(seed) to set the two different RNGs
        # for the planner and the rest of the code
        try:
            self.num_states = agent_info["num_states"]
            self.num_actions = agent_info["num_actions"]
        except:
            print("You need to pass both 'num_states' and 'num_actions' \
                   in agent_info to initialize the action-value table")
        self.gamma = agent_info.get("discount", 0.95)
        self.step_size = agent_info.get("step_size", 0.1)
        self.epsilon = agent_info.get("epsilon", 0.1)
        self.planning_steps = agent_info.get("planning_steps", 10)
        self.kappa = agent_info.get("kappa", 0.001)

        self.rand_generator = np.random.RandomState(agent_info.get('random_seed', 42))
        self.planning_rand_generator = np.random.RandomState(agent_info.get('planning_random_seed', 42))

        # Next, we initialize the attributes required by the agent, e.g., q_values, model, tau, etc.
        # The visitation-counts can be stored as a table as well, like the action values 
        self.q_values = np.zeros((self.num_states, self.num_actions))
        self.tau = np.zeros((self.num_states, self.num_actions))
        self.actions = list(range(self.num_actions))
        self.past_action = -1
        self.past_state = -1
        self.model = {}

    def update_model(self, past_state, past_action, state, reward):
        """updates the model 

        Args:
            past_state  (int): s
            past_action (int): a
            state       (int): s'
            reward      (int): r
        Returns:
            Nothing
        """

        # Recall that when adding a state-action to the model, if the agent is visiting the state
        #    for the first time, then the remaining actions need to be added to the model as well
        #    with zero reward and a transition into itself.
        #
        # Note: do *not* update the visitation-counts here. We will do that in `agent_step`.
        #
        # (3 lines)

        if past_state not in self.model:
            self.model[past_state] = {past_action : (state, reward)}
            # ----------------
            # your code here
            for action in self.actions:
                if action != past_action:
                    self.model[past_state][action] = (past_state,0)
            # ----------------
        else:
            self.model[past_state][past_action] = (state, reward)

        pass 

    def planning_step(self):
        """performs planning, i.e. indirect RL.

        Args:
            None
        Returns:
            Nothing
        """
        
        # The indirect RL step:
        # - Choose a state and action from the set of experiences that are stored in the model. (~2 lines)
        # - Query the model with this state-action pair for the predicted next state and reward.(~1 line)
        # - **Add the bonus to the reward** (~1 line)
        # - Update the action values with this simulated experience.                            (2~4 lines)
        # - Repeat for the required number of planning steps.
        #
        # Note that the update equation is different for terminal and non-terminal transitions. 
        # To differentiate between a terminal and a non-terminal next state, assume that the model stores
        # the terminal state as a dummy state like -1
        #
        # Important: remember you have a random number generator 'planning_rand_generator' as 
        #     a part of the class which you need to use as self.planning_rand_generator.choice()
        #     For the sake of reproducibility and grading, *do not* use anything else like 
        #     np.random.choice() for performing search control.

        # ----------------
        # your code here
        for _ in range(self.planning_steps):
            
            state = self.planning_rand_generator.choice(list(self.model.keys()))
            action = self.planning_rand_generator.choice(list(self.model[state].keys()))
            
            next_state, reward = self.model[state][action]
            reward += self.kappa*np.sqrt( self.tau[state,action] )
            
            if next_state==-1:
                self.q_values[state, action] = self.q_values[state, action] + self.step_size * (reward - self.q_values[state,action] )
            else:
                self.q_values[state, action] = self.q_values[state, action] + self.step_size * (reward + self.gamma * np.max(self.q_values[next_state]) - self.q_values[state, action])        
        # ----------------

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
        
    def agent_start(self, state):
        """The first method called when the experiment starts, called after
        the environment starts.
        Args:
            state (Numpy array): the state from the
                environment's env_start function.
        Returns:
            (int) The first action the agent takes.
        """
        
        # given the state, select the action using self.choose_action_egreedy(), 
        # and save current state and action (~2 lines)
        ### self.past_state = ?
        ### self.past_action = ?
        # Note that the last-visit counts are not updated here.
        
        # ----------------
        # your code here
        
        self.past_state  = state
        self.past_action = self.choose_action_egreedy(state)
        # ----------------
        
        return self.past_action

    def agent_step(self, reward, state):
        """A step taken by the agent.
        Args:
            reward (float): the reward received for taking the last action taken
            state (Numpy array): the state from the
                environment's step based on where the agent ended up after the
                last step
        Returns:
            (int) The action the agent is taking.
        """  
        
        # Update the last-visited counts (~2 lines)
        # - Direct-RL step (1~3 lines)
        # - Model Update step (~1 line)
        # - `planning_step` (~1 line)
        # - Action Selection step (~1 line)
        # Save the current state and action before returning the action to be performed. (~2 lines)
        
        # ----------------
        # your code here
        self.tau += 1
        self.tau[self.past_state][self.past_action] = 0
        
        target = reward + self.gamma*np.max(self.q_values[state])
        self.q_values[self.past_state, self.past_action] = self.q_values[self.past_state, self.past_action] + self.step_size * (target - self.q_values[self.past_state, self.past_action])
        
        self.update_model(self.past_state, self.past_action, state, reward)
        self.planning_step()
        
        self.past_action = self.choose_action_egreedy(state)
        self.past_state  = state        
        # ----------------
        
        return self.past_action

    def agent_end(self, reward):
        """Called when the agent terminates.
        Args:
            reward (float): the reward the agent received for entering the
                terminal state.
        """
        # Again, add the same components you added in agent_step to augment Dyna-Q into Dyna-Q+
        
        # ----------------
        # your code here
        
        self.tau += 1
        self.tau[self.past_state][self.past_action] = 0

        target = reward 
        self.q_values[self.past_state, self.past_action] = self.q_values[self.past_state, self.past_action] + self.step_size * (target - self.q_values[self.past_state, self.past_action])

        self.update_model(self.past_state, self.past_action, -1, reward)
        self.planning_step()        
        # ----------------

 

 
from src.rlglue.environment import BaseEnvironment
import numpy as np

class GridWorld_Environment(BaseEnvironment):
    
    def env_init(self, env_info={}):
        """Setup for the environment called when the experiment first starts.
        Note:
            Initialize a tuple with the reward, first state, boolean
            indicating if it's terminal.
        """
        
        reward = None
        state = None # See Aside
        termination = None
        self.reward_state_term = (reward, state, termination)
        
        # Observation is a general term used in the RL-Glue files that can be interachangeably used with the term "state". 
        # A difference arises in the use of the terms when we have what is called Partial Observability where 
        # the environment may return states that may not fully represent all the information needed to 
        # predict values or make decisions (i.e., the environment is non-Markovian.)
        
        self._width = env_info.get("grid_width")
        self._height = env_info.get("grid_height")

        # self._A = list(range(env_info.get("actions")))
        self._A = env_info.get("actions")
        self._S = [states for states in range(self._width * self._height)] 
        
        # Starting location of agent is the bottom-left corner, (max x, min y). 
        self.start_loc = (self._height - 1, 0)

        # The state array is assigning a integer value to each given state   
        # e.g. height = 4 and width = 4 -> 0...15 States.
        self.state_array = np.arange(self._height * self._width).reshape(self._height, self._width) 

        # The obstacle will contain a location, which is an invalid state
        self.obstacle = []
        self.obstacle_states = []

        # The obstacle will contain a location, which is an invalid state
        if env_info.get("obstacle") != None:
            for i in range(len(env_info.get("obstacle"))):
                self.obstacle_states.append(self.state(env_info.get("obstacle")[i]))
                self.obstacle.append(env_info.get("obstacle")[i])

        # Defines the terminal location (in this example top- left and bottom-right corner).
        self.terminal = []
        self.terminal_states = []

        for i in range(len(env_info.get("terminal"))):
            self.terminal_states.append(self.state(env_info.get("terminal")[i]))
            self.terminal.append(env_info.get("terminal")[i])

        self.build_transitions()
        # self.prepare_transitions()
       

        pass   

    def build_transitions(self):
        
        self._transitions = {}
        
        # Prepare Rewards for terminal state and obstacles
        for s in self.S:
                
            self._transitions[s] = {a : [] for a in self.A}
            
            # set terminal state reward to 0
            reward = 0.0 if s in self.terminal_states else -1.0
            
            # set obstacle state reward to -10
            if s in self.obstacle_states: reward = -10 

            if (s in self.terminal_states): 
                
                # Current and final state will always be the same with terminal states a.k.a final state 
                p = 0.25
                self._transitions[s][0] = {'p': p, 'action': 'left',  'current_state': s, 'next_state': s, 'reward': reward, 'terminal': True, 'obstacle': False } 
                self._transitions[s][1] = {'p': p, 'action': 'up',    'current_state': s, 'next_state': s, 'reward': reward, 'terminal': True, 'obstacle': False } 
                self._transitions[s][2] = {'p': p, 'action': 'right', 'current_state': s, 'next_state': s, 'reward': reward, 'terminal': True, 'obstacle': False } 
                self._transitions[s][3] = {'p': p, 'action': 'down',  'current_state': s, 'next_state': s, 'reward': reward, 'terminal': True, 'obstacle': False } 
            
            if (s in self.obstacle_states):
                
                # obstacle states
                p = 0.25
                self._transitions[s][0] = {'p': p, 'action': 'left',  'current_state': s, 'next_state': s, 'reward': reward, 'terminal': False, 'obstacle': True } 
                self._transitions[s][1] = {'p': p, 'action': 'up',    'current_state': s, 'next_state': s, 'reward': reward, 'terminal': False, 'obstacle': True } 
                self._transitions[s][2] = {'p': p, 'action': 'right', 'current_state': s, 'next_state': s, 'reward': reward, 'terminal': False, 'obstacle': True } 
                self._transitions[s][3] = {'p': p, 'action': 'down',  'current_state': s, 'next_state': s, 'reward': reward, 'terminal': False, 'obstacle': True } 

        for s in self.S:

            # convert a state into a x, y grid coordinate 
            x, y = self.array_indices(s)

            if (s not in self.terminal_states) & (s not in self.obstacle_states):    
                
                # initial probability 
                p = 0.25 

                # None terminal states    
                left  = s if x == 0 else s - 1
                up    = s if y == 0 else s - self.width
                right = s if x == (self.width - 1) else s + 1
                down  = s if y == (self.height - 1) else s + self.width
                
                next_state = [left, up, right, down]
                direction = ['left', 'up', 'right', 'down']


                for i, s_ in enumerate(next_state):
                    # set terminal state reward to 0
                    reward = 0.0 if s_ in self.terminal_states else -1.0
                
                    # set obstacle state reward to -10
                    if s_ in self.obstacle_states: reward = -10 

                    self._transitions[s][i] = {'p': p, 'current_state': s, 'action': direction[i], 'next_state': s_, 'reward': reward, 'terminal': s in self.terminal_states, 'obstacle': s_ in self.obstacle_states }
        pass            

    def prepare_transitions(self):
        '''
        In this method we prepare the transitions od all states. Being in a state 's' we can take actions 'a' 
        left, up, right and down.  Each action takes us in a new state 

        a transition consists of:
        (p, state, reward, terminal_state, obstacle_state) = [(1.0, 0, -1.0, True, False)]

        '''
        
        self._transitions = {}
        for s in self.S:
                
            self._transitions[s] = {a : [] for a in self.A}
            
            # set terminal state reward to 0
            reward = 0.0 if s in self.terminal_states else -1.0
            
            # set obstacle state reward to -10
            if s in self.obstacle_states: reward = -10 
            x, y = self.array_indices(s)
             
            if (s in self.terminal_states): 

                # obstacle = True if s in self.obstacle_states else False
                # obstacle = self._transitions[s][0] if self._transitions[s][0] != [] else False
                
                # terminal states
                self._transitions[s][0] = [(1.0, s, reward, True, False)]
                self._transitions[s][1] = [(1.0, s, reward, True, False)]
                self._transitions[s][2] = [(1.0, s, reward, True, False)]
                self._transitions[s][3] = [(1.0, s, reward, True, False)]
            
            if (s in self.obstacle_states):
                
                # terminal = True if s in self.terminal_states else False
                # terminal = self._transitions[s][0] if self._transitions[s][0] != [] else False
                
                # terminal states
                self._transitions[s][0] = [(1.0, s, reward, False, True)]
                self._transitions[s][1] = [(1.0, s, reward, False, True)]
                self._transitions[s][2] = [(1.0, s, reward, False, True)]
                self._transitions[s][3] = [(1.0, s, reward, False, True)]                
                pass

            if (s not in self.terminal_states) & (s not in self.obstacle_states):    
                # None terminal states    
                left  = s if x == 0 else s - 1
                up    = s if y == 0 else s - self.width
                right = s if x == (self.width - 1) else s + 1
                down  = s if y == (self.height - 1) else s + self.width
                
                self._transitions[s][0] = [(1.0, left, reward, left in self.terminal_states, left in self.obstacle_states)]
                self._transitions[s][1] = [(1.0, up, reward, up in self.terminal_states, up in self.obstacle_states)]
                self._transitions[s][2] = [(1.0, right, reward, right in self.terminal_states, right in self.obstacle_states)]
                self._transitions[s][3] = [(1.0, down, reward, down in self.terminal_states, down in self.obstacle_states)]

        pass

    def env_start(self):
        """The first method called when the episode starts, called before the
        agent starts.

        Returns:
            The first state from the environment.
        """
        reward = 0
        # agent_loc will hold the current location of the agent
        self.agent_loc = self.start_loc
        # state is the one dimensional state representation of the agent location.
        state = self.state(self.agent_loc)
        termination = False
        self.reward_state_term = (reward, state, termination)

        return self.reward_state_term[1]        

    def env_step(self, action):
        """A step taken by the environment.

        Args:
            action: The action taken by the agent

        Returns:
            (float, state, Boolean): a tuple of the reward, state,
                and boolean indicating if it's terminal.
        """
        
        x, y = self.agent_loc

        # UP
        if action == 0:
            x = x - 1
            
        # LEFT
        elif action == 1:
            y = y - 1
            
        # DOWN
        elif action == 2:
            x = x + 1
            
        # RIGHT
        elif action == 3:
            y = y + 1
            
        # Uh-oh
        else: 
            raise Exception(str(action) + " not in recognized actions [0: Up, 1: Left, 2: Down, 3: Right]!")

        # if the action takes the agent out-of-bounds
        # then the agent stays in the same state
        if not self.__isInBounds(x, y, self._width, self._height):
            x, y = self.agent_loc
            
        # assign the new location to the environment object
        self.agent_loc = (x, y)
        
        # by default, assume -1 reward per step and that we did not terminate
        reward = -1
        terminal = False
      
        # check if agent is in a cliff position
        if self.agent_loc in self.cliff:
            reward = -10
            self.agent_loc = self.start_loc

        # set terminal state if agent reached the terminal state 
        if self.agent_loc == self.terminal:
           terminal = True 
        
        self.reward_state_term = (reward, self.state(self.agent_loc), terminal)
        return self.reward_state_term

    def env_cleanup(self):
        """Cleanup done after the environment ends"""
        
        self.agent_loc = self.start_loc  
        return self.agent_loc      
    
    # helper method
    def state(self, loc):
        '''
        Calculate the state number (int) based on the coordinates.
        
        params: 
        -------
        loc   - location tuple (e.g. (2, 3)) in grid

        return:
        value - int value of respective field 
        '''

        return self.state_array[loc]
    
    def array_indices(self, s):
        '''
        Convert a state into an x, y coordinate 

        Argument:
        ---------
        s - state (int)

        Returns:
        --------
        x, y - coordinate of respective state 

        '''
        
        coord = np.where(self.state_array == s)
        y = int(coord[0])
        x = int(coord[1])

        return x, y

    # ===========================================================
    #region mytransition
    def transition(self, s, a):

        x, y = self.array_indices(s)
        
        if a == 0:
            s_prime_x = x
            s_prime_y = max(0, y - 1)
        elif a == 1:
            s_prime_x = max(0, x - 1)
            s_prime_y = y
        elif a == 2:
            s_prime_x = x
            s_prime_y = min(self.width - 1, y + 1)
        else:
            s_prime_x = min(self.height - 1, x + 1)
            s_prime_y = y

        s_ = self.state((s_prime_x, s_prime_y))
        r = self.reward_1(s_)

        return s_, r
    #endregion mytransition
    # ===========================================================

    def get_transitions(self, s, a):
        trans_info = self._transitions[s][a][0]

        p = trans_info[0]
        s_ = trans_info[1]
        reward = trans_info[2]
        is_terminal_state = trans_info[3]
        is_obstacle_state = trans_info[4]
        return (p, s_, reward, is_terminal_state, is_obstacle_state)

    def retrieve_transitions(self, s, a):
        transition_info = self._transitions[s][a]

        p = transition_info['p']
        s = transition_info['current_state']
        s_ = transition_info['next_state']
        reward = transition_info['reward']
        is_terminal_state = transition_info['terminal']
        is_obstacle_state = transition_info['obstacle']
        return (p, s_, reward, is_terminal_state, is_obstacle_state)        

    #region transitions
    def transitions(self, s, a):
        
        q = []
        for s_, r in self.support(s, a):
            q.append((r, self.p(s_, r, s, a)))

        return np.array([[r, self.p(s_, r, s, a)] for s_, r in self.support(s, a)])

    def support(self, s, a):

        c = [] 
        for s_ in self._S:
            c.append((s_, self.reward(s, s_)))

        return [(s_, self.reward(s, s_)) for s_ in self._S]

    def p(self, s_, r, s, a):
        if r != self.reward(s, s_):
            return 0
        else:
            return 1

    def reward(self, s, s_):
        return self.state_reward(s) + self.state_reward(s_)

    def state_reward(self, s):
        '''
        return the reward of a given state 
        '''
        state_reward = 0 if s in self.terminal_states else -1
        
        return state_reward

    #endregion transitions
    
    def __isInBounds(self, x, y, width, height):

        in_bound = False

        # if ((x >= 0) & (x <= (height - 1))):
        #      print('ok')

        # if ((y >= 0) and (y <= (width - 1))):
        #      print('ok')
        
        if ((x >= 0) & (x <= (height - 1))) and ((y >= 0) and (y <= (width - 1))):
            in_bound = True

        return in_bound
        # your code here

    @property
    def A(self):
        return list(self._A)

    @property
    def width(self):
        return self._width

    @property
    def height(self):
        return self._height

    @property
    def S(self):
        return list(self._S)




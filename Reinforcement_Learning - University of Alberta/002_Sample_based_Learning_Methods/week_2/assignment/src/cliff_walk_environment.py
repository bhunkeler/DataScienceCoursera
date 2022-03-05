from Environment import BaseEnvironment 
import numpy as np

class Cliffwalk_Environment(BaseEnvironment):
    
    def env_init(self, env_info={}):
        """Setup for the environment called when the experiment first starts.
        Note:
            Initialize a tuple with the reward, first state, boolean
            indicating if it's terminal.
        """
        
        # Note, we can setup the following variables later, in env_start() as it is equivalent. 
        # Code is left here to adhere to the note above, but these variables are initialized once more
        # in env_start() [See the env_start() function below.]
        
        reward = None
        state = None # See Aside
        termination = None
        self.reward_state_term = (reward, state, termination)
        
        # AN ASIDE: Observation is a general term used in the RL-Glue files that can be interachangeably 
        # used with the term "state" for our purposes and for this assignment in particular. 
        # A difference arises in the use of the terms when we have what is called Partial Observability where 
        # the environment may return states that may not fully represent all the information needed to 
        # predict values or make decisions (i.e., the environment is non-Markovian.)
        
        # Set the default height to 4 and width to 12 (as in the diagram given above)
        # self.grid_h = env_info.get("grid_height", 4) 
        # self.grid_w = env_info.get("grid_width", 12)
        self.grid_h = env_info.get("grid_height") 
        self.grid_w = env_info.get("grid_width")
        
        # Now, we can define a frame of reference. Let positive x be towards the direction down and 
        # positive y be towards the direction right (following the row-major NumPy convention.)
        # Then, keeping with the usual convention that arrays are 0-indexed, max x is then grid_h - 1 
        # and max y is then grid_w - 1. So, we have:
        # Starting location of agent is the bottom-left corner, (max x, min y). 
        self.start_loc = (self.grid_h - 1, 0)
        # Goal location is the bottom-right corner. (max x, max y).
        # self.goal_loc = (self.grid_h - 1, self.grid_w - 1)
        self.goal_loc = (self.grid_h - 1, self.grid_w - 1)
        
        # The cliff will contain all the cells between the start_loc and goal_loc.
        self.cliff = [(self.grid_h - 1, i) for i in range(1, (self.grid_w - 1))]
        
        # Take a look at the annotated environment diagram given in the above Jupyter Notebook cell to 
        # verify that your understanding of the above code is correct for the default case, i.e., where 
        # height = 4 and width = 12.
        self.state_array = np.arange(self.grid_h * self.grid_w).reshape(self.grid_h, self.grid_w)        
        # raise NotImplementedError

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
        if not self.__isInBounds(x, y, self.grid_w, self.grid_h):
            x, y = self.agent_loc
            
        # assign the new location to the environment object
        self.agent_loc = (x, y)
        
        # by default, assume -1 reward per step and that we did not terminate
        reward = -1
        terminal = False
        
        # assign the reward and terminal variables 
      
        # check if agent is in a cliff position
        if self.agent_loc in self.cliff:
            reward = -100
            self.agent_loc = self.start_loc

        # set terminal state if agent reached goal
        if self.agent_loc == self.goal_loc:
           terminal = True 
        
        self.reward_state_term = (reward, self.state(self.agent_loc), terminal)
        return self.reward_state_term

    def env_cleanup(self):
        """Cleanup done after the environment ends"""
        
        self.agent_loc = self.start_loc  
        return self.agent_loc      
    
    # helper method
    def state(self, loc):

        return self.state_array[loc]
 
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
    


import numpy as np

class Policy():

    def __init__(self, env):

        self.pi = np.ones(shape=(env._width * env._height, 4)) / len(env.A)
        pass

    def improve(self, env, V, pi, gamma):
        '''
        Improve policy 

        arguments:
        ----------
        env    - environment 
        V      - values
        pi     - policies
        gamma  - discount

        return:
        -------
        pi     - updated policy 
        policy_stable 
        '''

        policy_stable = True

        for s in env.S:

            pi_old = pi[s].copy()
            pi = self.q_greedify_policy(env, V, pi, s, gamma)
            
            if not np.array_equal(pi[s], pi_old):
                policy_stable = False
                
        return pi, policy_stable

    def iteration(self, env, gamma, theta):
        V = np.zeros(len(env.S))
        pi = np.ones((len(env.S), len(env.A))) / len(env.A)
        policy_stable = False
        
        iteration_cnt = 0
        while iteration_cnt < 1000: 
            iteration_cnt +=1
            V = self.evaluate(env, V, pi, gamma, theta)
            pi, policy_stable = self.improve(env, V, pi, gamma)
            
        return V, pi    

    def evaluate(self, env, V, pi, gamma, theta):
        '''
        Evaluate a policy via bellman equation.

        Arguments:
        ----------
        env    - environment object
        V      - value for given state
        pi     - policy  for given state  
        gamma  - discounting factor 
        theta  - threshold 

        Return:
        -------
        V      - Value for given state  
        '''
        
        delta = float('inf')

        while delta > theta:
            
            delta = 0

            for s in env.S:
                v = V[s]

                V = self.bellman_update(env, V, pi, s, gamma)
                delta = max(delta, abs(v - V[s]))
            pass
                
        return V

    def bellman_update(self, env, V, pi, s, gamma):
        '''
        Mutate ``V`` according to the Bellman update equation.
        
        Arguments:
        ----------
        env    - environment object
        V      - value for given state
        pi     - policy  for given state  
        s      - state
        gamma  - discounting factor 
        

        Return:
        -------
        V      - Value for given state          
        '''

        v = 0
        for a in env.A:
            
            (p, s_, reward, is_terminal_state, is_obstacle_state) = env.retrieve_transitions(s, a) 
            
            # Ref: Sutton eq. 4.6.
            v += pi[s, a] * (p * (reward + (gamma * V[s_])))
            pass

        V[s] = v
        return V

    def q_greedify_policy(self, env, V, pi, s, gamma):
        """
        Mutate ``pi`` to be greedy with respect to the q-values induced by ``V``.
        The method takes a state and an action and returns a 2-dimensional array, where the entry 
        at $(i, 0)$ is the reward for transitioning to state $i$ from the current 
        state and the entry at $(i, 1)$ is the conditional probability of transitioning to state $i$ 
        given the current state and action.
        """

        best_value  = float('-inf')
        best_action = 0

        # Debugging purposes
        if (s == 6) | (s == 9):
            stop = 'stop'
            
        v = 0
        action_values = []
        for a in env.A:
            v = 0
            
            # for s_ in env.S:
                
            (p, s_, reward, is_terminal_state, is_obstacle_state) = env.retrieve_transitions(s, a) 
            v += p * (reward + (gamma * V[s_]))
            action_values.append(v)

            if best_value < v:
                best_value  = v
                best_action = a
        
        action_values = np.around(action_values, decimals=1)
        idx_of_maxval = np.where(action_values == np.amax(action_values))[0]

        pi[s] = np.zeros_like(pi[s])

        if s not in env.terminal_states:
            for ba in idx_of_maxval:
                pi[s][ba] = 1
                pass
        
        return pi 

    def get_pi(self):
        return self.pi

    
    def eval(self, env, V, pi, gamma):

        for a in self.A:
            sum_s_ = 0

            for s_ in self.S:
                sum_r = 0

                for r in self.R:
                    # sum_r += p(r | s, a) * r + gamma * V(s_)
                    pass 
                
            
        pass

    def impr():
        pass 
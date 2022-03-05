
import numpy as np


if __name__ == '__main__':
    
    A = list(range(0, 4)) # [0, 1, 2, 3]
    S = list(range(0, 16))
    transitions = {}

    transitions[0] = {a : [] for a in A}

    transitions[0][0] = {'p': 1.0, 'action': 'up', 'state': 2, 'terminal': False, 'obstacle': False }
    
    
    a = [15, 17, 19, 19]

    max_val = max(a) 
    idx_of_maxval = np.where(a == np.amax(a))

    print(idx_of_maxval)

    pass 
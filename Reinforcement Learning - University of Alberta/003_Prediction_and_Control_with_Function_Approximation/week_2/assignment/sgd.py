from assignment import BaseOptimizer
import numpy as np


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


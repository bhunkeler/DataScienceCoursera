# Import Necessary Libraries
import numpy as np
import itertools
import matplotlib.pyplot as plt
import tiles3 as tc
from rl_glue import RLGlue
from agent import BaseAgent
from utils import argmax
import mountaincar_env
import time

class MountainCarTileCoder:
    def __init__(self, iht_size=4096, num_tilings=8, num_tiles=8):
        """
        Initializes the MountainCar Tile Coder
        Initializers:
        iht_size -- int, the size of the index hash table, typically a power of 2
        num_tilings -- int, the number of tilings
        num_tiles -- int, the number of tiles. Here both the width and height of the
                     tile coder are the same
        Class Variables:
        self.iht -- tc.IHT, the index hash table that the tile coder will use
        self.num_tilings -- int, the number of tilings the tile coder will use
        self.num_tiles -- int, the number of tiles the tile coder will use
        """
        self.iht = tc.IHT(iht_size)
        self.num_tilings = num_tilings
        self.num_tiles = num_tiles
    
    def get_tiles(self, position, velocity):
        """
        Takes in a position and velocity from the mountaincar environment
        and returns a numpy array of active tiles.
        
        Arguments:
        position -- float, the position of the agent between -1.2 and 0.5
        velocity -- float, the velocity of the agent between -0.07 and 0.07
        returns:
        tiles - np.array, active tiles
        """
        # Use the ranges above and self.num_tiles to scale position and velocity to the range [0, 1]
        # then multiply that range with self.num_tiles so it scales from [0, num_tiles]
        
        position_scaled = 0
        velocity_scaled = 0
        
        POSITION_MAX = 0.5
        POSITION_MIN = -1.2
        VELOCITY_MAX = 0.07
        VELOCITY_MIN = -0.07

        # ----------------
        # your code here

        position_normalized = (position - POSITION_MIN) / (POSITION_MAX - POSITION_MIN)
        velocity_normalized = (velocity - VELOCITY_MIN) / (VELOCITY_MAX - VELOCITY_MIN)

        position_scaled = self.num_tiles * position_normalized
        velocity_scaled = self.num_tiles * velocity_normalized

        # ----------------
        
        # get the tiles using tc.tiles, with self.iht, self.num_tilings and [scaled position, scaled velocity]
        # nothing to implment here
        tiles = tc.tiles(self.iht, self.num_tilings, [position_scaled, velocity_scaled])
        
        return np.array(tiles)
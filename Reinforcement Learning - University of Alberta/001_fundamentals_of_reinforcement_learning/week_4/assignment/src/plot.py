import numpy as np
import matplotlib.pyplot as  plt
from matplotlib import colors
import seaborn as sns


class Plot():

    def grid(self, env, data):
        """Plot grid

        Args:
            env (Environment): grid world environment
        """

        # data = env.rewards.copy()
        # data[env.e_x, env.e_y] = 10

        # create discrete colormap
        cmap = colors.ListedColormap(['grey', 'white', 'steelblue'])
        bounds = [-11, -2, 0, 12]
        norm = colors.BoundaryNorm(bounds, cmap.N)

        fig, ax = plt.subplots()
        ax.imshow(data, cmap=cmap, norm=norm)

        # draw gridlines
        ax.grid(which='major', axis='both', linestyle='-', color='k', linewidth=1)
        ax.set_xticks(np.arange(-.5, env.width, 1))
        ax.set_yticks(np.arange(-.5, env.height, 1))

        plt.show()

    def v_values(self, v, n):
        """Plots the value function in each state as a grid.

        Args:
            v (array): numpy array representing the value function
            n (int):
        """

        fig, ax = plt.subplots()
        im = ax.imshow(v, cmap='YlOrBr', interpolation='nearest')

        # draw gridlines
        ax.grid(which='major', axis='both', linestyle='-', color='k', linewidth=1)
        ax.set_xticks(np.arange(-.5, n, 1))
        ax.set_yticks(np.arange(-.5, n, 1))

        # Loop over data dimensions and create text annotations.
        for i in range(n):
            for j in range(n):
                text = ax.text(j, i, "{:.2f}".format(v[i, j]), ha="center", va="center", color="black")

        ax.set_title("Value function")
        fig.tight_layout()
        plt.show()

    def optimal_actions(self, env, pi):
        """Plots the optimal action to take in each state

        Args:
            env (Environment): grid world environment
            pi (array): numpy array indicating the probability of taking each action in each state
        """

        data = np.array([[5., -1., -1., -1.],
                        [-1., -1., -1., -1.],
                        [-1., -1., -1., -1.],
                        [-1., -1., -1., 5.]])


        # create discrete colormap
        cmap = colors.ListedColormap(['grey', 'white', 'steelblue'])
        bounds = [-11, -2, 0, 12]
        norm = colors.BoundaryNorm(bounds, cmap.N)

        fig, ax = plt.subplots()
        ax.imshow(data, cmap=cmap, norm=norm)

        # draw gridlines
        ax.grid(which='major', axis='both', linestyle='-', color='k', linewidth=1)
        ax.set_xticks(np.arange(-.5, env.width, 1))
        ax.set_yticks(np.arange(-.5, env.height, 1))

        # Loop over data dimensions and create text annotations.

        for s in env.S:
            
            if s in env.terminal_states:
                arrow = 'T'
            else:
                arrow = self.get_arrow(pi[s])
            x, y = env.array_indices(s)
            j, i = env.array_indices(s)
            text = ax.text( x, y, arrow, fontsize=16, ha="center", va="center", color="black")

        ax.set_title("Policy")
        fig.tight_layout()
        plt.show()

    def get_arrow(self, prob_arr):
        """Returns the arrows that represent the highest probability actions.

        Args:
            prob_arr (array): numpy array denoting the probability of taking each action on a given state

        Returns:
            arrow (str): string denoting the most probable action(s)
        """
        action = np.where(prob_arr == np.amax(prob_arr))
        binary_value = ''
        for a in range(len(prob_arr)):
            binary_value += str(int(prob_arr[a]))
        
        act = int(binary_value, 2)   
        direction = self.bin_test(act)

        return direction

    def bin_test(self, act):
        match act:
            case 0:
                direction = r"$\leftarrow$"
                        
            case 1:
                direction = r"$\downarrow$"
                        
            case 2:
                direction = r"$\rightarrow$"
                    
            case 3:
                direction = r"$\rightarrow \downarrow$"
            
            case 4:
                direction = r"$\uparrow$"
                        
            case 5:
                direction = r"$\updownarrow$"
                        
            case 6:
                direction = r"$\uparrow \rightarrow$"
                    
            case 7:
                direction = r"$\updownarrow \rightarrow$"          

            case 8:
                direction = r"$\leftarrow$"
                        
            case 9:
                direction = r"$\leftarrow \downarrow$"
                        
            case 10:
                direction = r"$\leftrightarrow$"
                    
            case 11:
                direction = r"$\leftrightarrow \downarrow$"
            
            case 12:
                direction = r"$\leftarrow \uparrow$"
                        
            case 13:
                direction = r"$\leftarrow \updownarrow$"
                        
            case 14:
                direction = r"$\uparrow \leftrightarrow$"
                    
            case 15:
                direction = r"$\updownarrow \leftrightarrow$"                                        
            case _:
                print("Code not found")   

        return direction     
        # best_actions = np.where(prob_arr == np.amax(prob_arr))[0]
        # if len(best_actions) == 1:
        #     if 0 in best_actions:
        #         return r"$\leftarrow$"
        #     if 1 in best_actions:
        #         return r"$\uparrow$"
        #     if 2 in best_actions:
        #         return r"$\rightarrow$"
        #     else:
        #         return r"$\downarrow$"

        # elif len(best_actions) == 2:
        #     if 0 in best_actions and 1 in best_actions:
        #         return r"$\leftarrow \uparrow$"
        #     elif 0 in best_actions and 2 in best_actions:
        #         return r"$\leftrightarrow$"
        #     elif 0 in best_actions and 3 in best_actions:
        #         return r"$\leftarrow \downarrow$"
        #     elif 1 in best_actions and 2 in best_actions:
        #         return r"$\uparrow \rightarrow$"
        #     elif 1 in best_actions and 3 in best_actions:
        #         return r"$\updownarrow$"
        #     elif 2 in best_actions and 3 in best_actions:
        #         return r"$\downarrow \rightarrow$"

        # elif len(best_actions) == 3:
        #     if 0 not in best_actions:
        #         return r"$\updownarrow \rightarrow$"
        #     elif 1 not in best_actions:
        #         return r"$\leftrightarrow \downarrow$"
        #     elif 2 not in best_actions:
        #         return r"$\leftarrow \updownarrow$"
        #     else:
        #         return r"$\leftrightarrow \uparrow$"

        # else:
        #     return r"$\leftrightarrow \updownarrow$"

    def dashboard(self, data, env, v, pi, any = None):
        '''
        Create a dashboard from stream data reflecting plots for 6h of data. We also show 
        a IoT Component state, average filling level, trash bin volue of trash bins containing >50% of filling.

        arguments:
        ----------
        df  -     containing all the streamed data for 24h
        avg -     containing the precalculated average filling level in a given window (1h)
        vol -     total volume of garbage in a given hour (only trash bin filling > 50% ) 
        maint -   IoT component state, which requires maintenance

        return:
        -------
        dashboard - plot

        '''

        sns.set_style("darkgrid")
        blueish   = '#3891BC'
        redish    = '#E63323'
        yellowish = '#3891BC'    


        explode = (0, 0.1) 
        fig, ax = plt.subplots(figsize=(15, 8), ncols=3, nrows=2)

        left   =  0.125  # the left side of the subplots of the figure
        right  =  0.9    # the right side of the subplots of the figure
        bottom =  0.1    # the bottom of the subplots of the figure
        top    =  0.9    # the top of the subplots of the figure
        wspace =  0.7    # the amount of width reserved for blank space between subplots
        hspace =  0.7    # the amount of height reserved for white space between subplots

        # This function actually adjusts the sub plots using the above paramters
        plt.subplots_adjust(
        left    =  left, 
        bottom  =  bottom, 
        right   =  right, 
        top     =  top, 
        wspace  =  wspace, 
        hspace  =  hspace
        )

        # The amount of space above titles
        y_title_margin = 1.0

        plt.suptitle("Optimal Policy", y = 1.0, fontsize=12)

        # create discrete colormap
        cmap = colors.ListedColormap(['grey', 'white', 'steelblue'])
        bounds = [-11, -2, 0, 12]
        norm = colors.BoundaryNorm(bounds, cmap.N)

        # Grid 
        
        ax[0][0].imshow(data, cmap=cmap, norm=norm)

        # draw gridlines
        ax[0][0].grid(which='major', axis='both', linestyle='-', color='lightgray', linewidth=0.5)
        ax[0][0].set_xticks(np.arange(-.5, env.width, 1))
        ax[0][0].set_yticks(np.arange(-.5, env.height, 1))
        ax[0][0].set_xticklabels(np.arange(-0.5, env.width, 1))
        ax[0][0].set_yticklabels(np.arange(-0.5, env.height, 1))

        # V - values

        im = ax[0][1].imshow(v, cmap='Blues', interpolation='nearest')

        # draw gridlines
        ax[0][1].grid(which='major', axis='both', linestyle='-', color='lightgray', linewidth=0.5)
        ax[0][1].set_xticks(np.arange(-.5, env.width, 1))
        ax[0][1].set_yticks(np.arange(-.5, env.height, 1))

        # Loop over data dimensions and create text annotations.
        for i in range(env.width):
            for j in range(env.height):
                text = ax[0][1].text(j, i, "{:.2f}".format(v[i, j]), ha="center", va="center", color="black")

        ax[0][1].set_title("Value function")
        fig.tight_layout()

        # Optimal policy

        ax[0][2].imshow(data, cmap=cmap, norm=norm)

        # draw gridlines
        ax[0][2].grid(which='major', axis='both', linestyle='-', color='lightgray', linewidth=0.5)
        ax[0][2].set_xticks(np.arange(-0.5, env.width, 1))
        ax[0][2].set_yticks(np.arange(-0.5, env.height, 1))

        ax[0][0].set_title("Grid", y = y_title_margin)
        ax[0][1].set_title("V - values", y = y_title_margin)
        ax[0][2].set_title("Optimal policy", y = y_title_margin)

        # ax[1][0].set_title("2021-01-10 11:00", y = y_title_margin)
        # ax[1][1].set_title("2021-01-10 12:00", y = y_title_margin)
        # ax[1][2].set_title("2021-01-10 13:00", y = y_title_margin)

        ax[0][0].set_xticklabels(np.arange(-0.5, env.width, 1))
        ax[0][1].set_xticklabels(np.arange(-0.5, env.width, 1))
        ax[0][2].set_xticklabels(np.arange(-0.5, env.width, 1))

        # Loop over data dimensions and create text annotations.

        for s in env.S:
            
            if s == 6:
                stop = 'stop'


            if (s in env.terminal_states) | (s in env.obstacle_states):
                if (s in env.terminal_states):
                    arrow = 'T'
                else:
                    arrow = 'O' 
            else:
                arrow = self.get_arrow(pi[s])
            
            x, y = env.array_indices(s)
            j, i = env.array_indices(s)
            text = ax[0][2].text( x, y, arrow, fontsize=16, ha="center", va="center", color="black")

        fig.tight_layout()



        # ax[1][0].set_xticklabels(df[3]['city'],Rotation=80, fontsize = 8)
        # ax[1][1].set_xticklabels(df[4]['city'],Rotation=80, fontsize = 8)
        # ax[1][2].set_xticklabels(df[5]['city'],Rotation=80, fontsize = 8)

        # conditional_colors = np.where(df[0]['maintenance'] == True, 'y', np.where(df[0]['filling_level'] >= 50, redish, blueish))
        # ax[0][0].bar('city', 'filling_level', data = df[0], palette = conditional_colors)
        
        # ax[0][0].bar('city', 'filling_level', data = df[0])
        # ax[0][1].bar('city', 'filling_level', data = df[1])
        # ax[0][2].bar('city', 'filling_level', data = df[2])
    
        # ax[1][0].bar('city', 'filling_level', data = df[3])
        # ax[1][1].bar('city', 'filling_level', data = df[4])
        # ax[1][2].bar('city', 'filling_level', data = df[5])

        # ax[0][0].legend(['08:00', 2014, 2015])
        # ax[0][1].legend(['09:00', 2019, 2011])
        # ax[0][2].legend(['10:00', 2014, 2015])

        # ax[1][0].legend(['11:00', 2014, 2015])
        # ax[1][1].legend(['12:00', 2014, 2015])
        # ax[1][2].legend(['13:00', 2014, 2015])

        # Set all labels on the row axis of subplots data
        # ax[0][0].set_xlabel("location")
        # ax[0][1].set_xlabel("location")
        # ax[0][2].set_xlabel("location")

        ax[1][0].set_xlabel("location")
        ax[1][1].set_xlabel("location")
        ax[1][2].set_xlabel("location")

        # Set all labels on the row axis of subplots data
        # ax[0][0].set_ylabel("Filling_level")
        # ax[0][1].set_ylabel("Filling_level")
        # ax[0][2].set_ylabel("Filling_level")

        # ax[1][0].set_ylabel("Filling_level")
        # ax[1][1].set_ylabel("Filling_level")
        # ax[1][2].set_ylabel("Filling_level")


        # # ax[0][0].grid(b=True, linewidth=0.5, color=)
        # ax[0][0].grid(color='gray', linestyle='-', linewidth=0.5)
        # ax[0][0].axhline(y=50, color='red', linestyle='--', linewidth=1.5)
        # ax[0][1].axhline(y=50, color='red', linestyle='--', linewidth=1.5)
        # ax[0][2].axhline(y=50, color='red', linestyle='--', linewidth=1.5)
        # ax[1][0].axhline(y=50, color='red', linestyle='--', linewidth=1.5)
        # ax[1][1].axhline(y=50, color='red', linestyle='--', linewidth=1.5)
        # ax[1][2].axhline(y=50, color='red', linestyle='--', linewidth=1.5)

        # ax[2][0].axis("off")
        # ax[2][1].axis("off")
        # ax[2][2].axis("off")

        # ax[2][0].text(0, 0.8, 'Volume: ', fontsize=12, fontweight='bold' )    
        # ax[2][0].text(0, 0.7, '08:00 : ' + str(vol[0]) + ' $m^3$', fontsize=12)
        # ax[2][0].text(0, 0.6, '09:00 : ' + str(vol[1]) + ' $m^3$', fontsize=12)
        # ax[2][0].text(0, 0.5, '10:00 : ' + str(vol[2]) + ' $m^3$', fontsize=12)
        # ax[2][0].text(0, 0.4, '11:00 : ' + str(vol[3]) + ' $m^3$', fontsize=12)
        # ax[2][0].text(0, 0.3, '12:00 : ' + str(vol[4]) + ' $m^3$', fontsize=12)
        # ax[2][0].text(0, 0.2, '13:00 : ' + str(vol[5]) + ' $m^3$', fontsize=12)
        
        # ax[2][1].text(0, 0.8, 'Average Filling level: ', fontsize=12, fontweight='bold' )    
        # ax[2][1].text(0, 0.7, '08:00 : ' + str(avg[0]) + ' %', fontsize=12)
        # ax[2][1].text(0, 0.6, '09:00 : ' + str(avg[1]) + ' %', fontsize=12)
        # ax[2][1].text(0, 0.5, '10:00 : ' + str(avg[2]) + ' %', fontsize=12)
        # ax[2][1].text(0, 0.4, '11:00 : ' + str(avg[3]) + ' %', fontsize=12)
        # ax[2][1].text(0, 0.3, '12:00 : ' + str(avg[4]) + ' %', fontsize=12)
        # ax[2][1].text(0, 0.2, '13:00 : ' + str(avg[5]) + ' %', fontsize=12)

        # hw_failure = Stream_Helper.check_hw_failure(maint)

        # ax[2][2].text(0, 0.8, 'Maintenance: ', fontsize=12, fontweight='bold' )    
        # ax[2][2].text(0, 0.7, '08:00 : ' + str(hw_failure[0]), fontsize=12) 
        # ax[2][2].text(0, 0.6, '09:00 : ' + str(hw_failure[1]), fontsize=12)
        # ax[2][2].text(0, 0.5, '10:00 : ' + str(hw_failure[2]), fontsize=12)
        # ax[2][2].text(0, 0.4, '11:00 : ' + str(hw_failure[3]), fontsize=12)
        # ax[2][2].text(0, 0.3, '12:00 : ' + str(hw_failure[4]), fontsize=12)
        # ax[2][2].text(0, 0.2, '13:00 : ' + str(hw_failure[5]), fontsize=12)

        plt.show()

    def new_method(self):
        y_title_margin = 5
        return y_title_margin

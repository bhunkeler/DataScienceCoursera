**Module 01: On-policy prediction with approximation**  

**Lesson 1: Estimating Value Functions as Supervised Learning**  
- Understand how we can use parameterized functions to approximate value functions
- Explain the meaning of linear value function approximation
- Recognize that the tabular case is a special case of linear value function approximation.
- Understand that there are many ways to parameterize an approximate value function
- Understand what is meant by generalization and discrimination
- Understand how generalization can be beneficial
- Explain why we want both generalization and discrimination from our function approximation
- Understand how value estimation can be framed as a supervised learning problem
- Recognize not all function approximation methods are well suited for reinforcement learning

**Lesson 2: The Objective for On-policy Prediction**  
- Understand the mean-squared value error objective for policy evaluation
- Explain the role of the state distribution in the objective
- Understand the idea behind gradient descent and stochastic gradient descent
- Outline the gradient Monte Carlo algorithm for value estimation
- Understand how state aggregation can be used to approximate the value function
- Apply Gradient Monte-Carlo with state aggregation

**Lesson 3: The Objective for TD**  
- Understand the TD-update for function approximation
- Highlight the advantages of TD compared to Monte-Carlo
- Outline the Semi-gradient TD(0) algorithm for value estimation
- Understand that TD converges to a biased value estimate
- Understand that TD converges much faster than Gradient Monte Carlo

**Lesson 4: Linear TD**  
- Derive the TD-update with linear function approximation
- Understand that tabular TD(0) is a special case of linear semi-gradient TD(0)
- Highlight the advantages of linear value function approximation over nonlinear
- Understand the fixed point of linear TD learning
- Describe a theoretical guarantee on the mean squared value error at the TD fixed point

**Programming Assignment:**  
[Semi-gradient TD(0) with State Aggregation](Semi-gradient TD(0) with State Aggregation)

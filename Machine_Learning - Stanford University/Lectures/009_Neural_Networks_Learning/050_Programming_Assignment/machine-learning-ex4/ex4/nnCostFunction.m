function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%

% Claculate the costfunction 
% J(theta) = -1/m*sum( sum[-y*log(h)+(1-y)*log(1-h) )] 
%
% Layer 1 - input layer:   i = 400 
% Layer 2 - hidden layer:  j = 25
% Layer 3 - outupt layer:  K = 10 
% 
% h(x) = a(3) activation layer of k-th output unit 


% Convert numerical y values into vectors 
% mxn matrix [5000, 10]
K = num_labels;
Y = eye(K)(y,:);  

% prepare the input matrix with additional 1's in first row
% and assign it to the activation a1
% [5000x400] -> 5000, 401]
a1 = [ones(m, 1), X]; 

% theta1 mxn matrix [25x401]
% input layer - activation a1 mxn matrix [5000x401]
% therefore transpose a1
a2 = sigmoid(Theta1 * a1'); % results in [25, 5000]

% Theta2 is a [10x26] matrix to multiply we need to add 
% an additional rowof ones to the matrix 
a2 = [ones(1, size(a2, 2)); a2];

% mxn matrix [10, 5000]
% hypothesis = a3 
hypothesis = sigmoid(Theta2 * a2); 

% claculation of J 
J = -(1/m) * sum (sum(Y .* log(hypothesis)' + (1 - Y) .* log(1 - hypothesis)'));

% Regularized 
% ==================================================================

% unroll Theta1 / Theta2 matrices to vectors
% just for verification resons
theta1woBias = Theta1(:,2:end);
theta2woBias = Theta2(:,2:end);

regularization = (lambda / (2*m)) * ( sumsq(Theta1(:,2:end)(:)) + sumsq(Theta2(:,2:end)(:)) );
J = J + regularization;

% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%

% set all delata values to zero 
delta1 = zeros(size(Theta1));
delta2 = zeros(size(Theta2));

for t = 1:m,

  % Part 1 Forward propagation
  % use each row - column Vector mx1 [401x1] - activation a1
	a1 = [1; X(t,:)'];
 	z2 = Theta1 * a1;
  
  % use each row - column Vector mx1 [26x1] - activation a2
	a2 = [1; sigmoid(z2)]; 
  z3 = Theta2 * a2;
  
  % use each row - column Vector mx1 [10x1] - activation a3
  a3 = sigmoid( z3 ); 
  
  % Part 2  
	_Y = Y(t,:)';
	d3 = a3 - _Y;

  % Part 3  
	d2 = Theta2(:,2:end)' * d3 .* sigmoidGradient(z2);

   % Part 4  
	delta1 = delta1 + (d2 * a1');
	delta2 = delta2 + (d3 * a2');

end;

% Part 5
% delta1 mxn matrix [25x401]
% delta2 mxn matrix [10x26]

Theta1_grad = (1 / m) * delta1;
Theta2_grad = (1 / m) * delta2;

% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

Theta1_grad(:, 2:end) = Theta1_grad(:, 2:end) + ((lambda / m) * theta1woBias);
Theta2_grad(:, 2:end) = Theta2_grad(:, 2:end) + ((lambda / m) * theta2woBias);


% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end

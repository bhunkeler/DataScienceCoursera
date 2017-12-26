function [J, grad] = lrCostFunction(theta, X, y, lambda)
%LRCOSTFUNCTION Compute cost and gradient for logistic regression with 
%regularization
%   J = LRCOSTFUNCTION(theta, X, y, lambda) computes the cost of using
%   theta as the parameter for regularized logistic regression and the
%   gradient of the cost w.r.t. to the parameters. 

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(theta));

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the cost of a particular choice of theta.
%               You should set J to the cost.
%               Compute the partial derivatives and set grad to the partial
%               derivatives of the cost w.r.t. each parameter in theta
%
% Hint: The computation of the cost function and gradients can be
%       efficiently vectorized. For example, consider the computation
%
%           sigmoid(X * theta)
%
%       Each row of the resulting matrix will contain the value of the
%       prediction for that example. You can make use of this to vectorize
%       the cost function and gradient computations. 
%
% Hint: When computing the gradient of the regularized cost function, 
%       there're many possible vectorized solutions, but one solution
%       looks like:
%           grad = (unregularized gradient for logistic regression)
%           temp = theta; 
%           temp(1) = 0;   % because we don't add anything for j = 0  
%           grad = grad + YOUR_CODE_HERE (using the temp variable)
%

% J(theta) = 1/m*sum[-y*log(h)-(1-y)*log(1-h)] 

% hypothesis mxn Matrix  (5000x400) 
% theta mx1 column Vector (400x1)
hypothesis = sigmoid(X * theta);
cost = (-1/m) * sum(y .* log(hypothesis)+(1-y) .* log(1-hypothesis));

% theta(2:end) retrieve column values from index 2 to the end (399 values)
regularization = (lambda/(2*m)) * sum(theta(2:end) .^ 2);
 
% Costfunction without regularization  
%J = cost;

% costfunction with regularization
J = cost + regularization;

% gradient calculation 
% =========================================================
% Compute the partial derivatives and set grad to the partial
% derivatives of the cost w.r.t. each parameter in theta

% hypothesis   = mx1 column vector  (50000x400)
% y            = mx1 column vector  (400x1) 
% hypothesis-y = mx1 column vector  (5000x1)
% X            = mxn matrix         (5000x400) - transpose
% grad         = nx1 column vector  (400x1)

grad = (X' * (hypothesis - y));

% regularization = lambda/m * theta(2:end);
% this fails since it is just a 400X1 matrix add a 0 value for index 1
% regularization = lambda/m * [0; theta(2:end)]; 
regularization = (lambda/m) * [0; theta(2:end)]; 

% gradient without regularization 
% gradient = nx1 column vector
%grad = (1/m) .* grad;

% gradient with regularization 
% gradient = nx1 column vector
grad = (1/m) .* grad + regularization;

% =============================================================

grad = grad(:);

end

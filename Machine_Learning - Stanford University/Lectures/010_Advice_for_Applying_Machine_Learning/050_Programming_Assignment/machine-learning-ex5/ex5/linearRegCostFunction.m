function [J, grad] = linearRegCostFunction(X, y, theta, lambda)
%LINEARREGCOSTFUNCTION Compute cost and gradient for regularized linear 
%regression with multiple variables
%   [J, grad] = LINEARREGCOSTFUNCTION(X, y, theta, lambda) computes the 
%   cost of using theta as the parameter for linear regression to fit the 
%   data points in X and y. Returns the cost in J and the gradient in grad

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(theta));

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the cost and gradient of regularized linear 
%               regression for a particular choice of theta.
%
%               You should set J to the cost and grad to the gradient.
%

% hypothesis     = mx1 column vector  (12x1)
% y              = mx1 column vector  (12x1) 
% h-y            = single value       (1x1)
% X              = mxn matrix         (12x2) - transpose
% theta          = nx1 column vector  (2x1)
% cost           = single number         
% regularization = single number  

hypothesis = X * theta;                % prediction on hypothesis 
squared_error = (hypothesis - y).^2;   % calculate the squared error rate
cost = 1/(2*m) * sum(squared_error);   % calculate J(theta)

% theta(2:end) retrieve column values from index 2 
regularization = (lambda/(2*m)) * sum(theta(2:end) .^ 2);
 
% Costfunction with regularization  
J = cost + regularization;

% gradient calculation 
% =========================================================
% Compute the partial derivatives and set grad to the partial
% derivatives of the cost w.r.t. each parameter in theta

% hypothesis    = mx1 column vector  (12x1)
% y             = mx1 column vector  (12x1) 
% h-y           = single value       (1x1)
% X             = mxn matrix         (12x2) - transpose
% grad          = nx1 column vector  (2x1)

for i = 1:m
  grad = grad + ((hypothesis(i) - y(i)) * X(i, :)');
end 

% regularization = lambda/m * theta(2:end);
% this fails since it is just a 27X1 matrix add a 0 value for index 1
regularization = lambda/m * [0; theta(2:end)]; 
% gradient = nx1 column vector
grad = (1/m) * grad + regularization;



% =========================================================================

grad = grad(:);

end

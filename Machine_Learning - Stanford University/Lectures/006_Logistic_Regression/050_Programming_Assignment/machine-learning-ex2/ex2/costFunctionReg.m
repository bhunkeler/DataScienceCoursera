function [J, grad] = costFunctionReg(theta, X, y, lambda)
%COSTFUNCTIONREG Compute cost and gradient for logistic regression with regularization
%   J = COSTFUNCTIONREG(theta, X, y, lambda) computes the cost of using
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

% J(theta) = 1/m*sum[-y*log(h)-(1-y)*log(1-h)] + (lambda/2*m) * sum (theta)^2

% hypothesis mxn Matrix  (118x28) 
% theta mx1 coumn Vector (28x1)
hypothesis = sigmoid(X * theta);
cost = (-1/m) * sum(y .* log(hypothesis)+(1-y) .* log(1-hypothesis));

% theta(2:end) retrieve column values from index 2 to the end (27 values)
regularization = (lambda/(2*m)) * sum(theta(2:end) .^ 2);
 
% Costfunction with regularization  
J = cost + regularization;

% gradient calculation 
% =========================================================
% Compute the partial derivatives and set grad to the partial
% derivatives of the cost w.r.t. each parameter in theta

% h    = mx1 column vector  (118x28)
% y    = mx1 column vector  (118x1) 
% h-y  = single value       (1x1)
% X    = mxn matrix         (118x28) - transpose
% grad = nx1 column vector  (3x1)

for i = 1:m
  grad = grad + ((hypothesis(i) - y(i)) * X(i, :)');
end 

% regularization = lambda/m * theta(2:end);
% this fails since it is just a 27X1 matrix add a 0 value for index 1
regularization = lambda/m * [0; theta(2:end)]; 
% gradient = nx1 column vector
grad = (1/m) * grad + regularization;

% =============================================================

end

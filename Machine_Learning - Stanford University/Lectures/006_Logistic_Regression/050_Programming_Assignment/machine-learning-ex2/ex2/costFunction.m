function [J, grad] = costFunction(theta, X, y)
%COSTFUNCTION Compute cost and gradient for logistic regression
%   J = COSTFUNCTION(theta, X, y) computes the cost of using theta as the
%   parameter for logistic regression and the gradient of the cost
%   w.r.t. to the parameters.

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
% Note: grad should have the same dimensions as theta
%

% number of training samples
% m = mx1 column vector 
m = length(y);  

% cost function 
% J(theta) = 1/m * sum([-y *log(h(x)))-(1-y)*log(1-h(x))]
% =========================================================

% hypothesis mxn matrix with additional ones for x0
% X             = mxn matrix 
% theta         = nx1 column vector 
% h (hypothesis = mx1 column vector 
hypothesis = sigmoid(X * theta);

% calculate the probapilities for Y1 and Y0
% y1 = -y .* log(h)      mx1 column vector
% y0 = (1-y) .* log(1-h) mx1 column vector
% prob = -y .* log(h) - (1-y) .* log(1-h);
% sumOfProb = sum(probabilities);

% J is a single value
J = (-1/m) * sum(y .* log(hypothesis) + (1-y) .* log(1-hypothesis));

% gradient calculation 
% =========================================================
% Compute the partial derivatives and set grad to the partial
% derivatives of the cost w.r.t. each parameter in theta

% h    = mx1 column vector  (100x1)
% y    = mx1 column vector  (100x1) 
% h-y  = single value       (1x1)
% X    = mxn matrix         (100x3) - transpose
% grad = nx1 column vector  (3x1)

for i = 1:m
  grad = grad + (hypothesis(i) - y(i)) * X(i, :)';
end 

% gradient = nx1 column vector
grad = (1/m) * grad;

% =============================================================

end

function J = computeCost(X, y, theta)
%COMPUTECOST Compute cost for linear regression
%   J = COMPUTECOST(X, y, theta) computes the cost of using theta as the
%   parameter for linear regression to fit the data points in X and y

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the cost of a particular choice of theta
%               You should set J to the cost.

% predictions - mx1 column vector 
% X           - mxn matrix 
% theta       - nx1 column vector 

predictions = X * theta;               % prediction on hypothesis 

% squareedErrors = mx1 column vector
squared_error = (predictions - y).^2;  % calculate the squared error rate

% J = single number
J = 1/(2*m) * sum(squared_error);      % calculate J(theta)

% =========================================================================

end

function [C, sigma] = dataset3Params(X, y, Xval, yval)
%EX6PARAMS returns your choice of C and sigma for Part 3 of the exercise
%where you select the optimal (C, sigma) learning parameters to use for SVM
%with RBF kernel
%   [C, sigma] = EX6PARAMS(X, y, Xval, yval) returns your choice of C and 
%   sigma. You should complete this function to return the optimal C and 
%   sigma based on a cross-validation set.
%

% You need to return the following variables correctly.
C = 1;
sigma = 0.3;

% ====================== YOUR CODE HERE ======================
% Instructions: Fill in this function to return the optimal C and sigma
%               learning parameters found using the cross validation set.
%               You can use svmPredict to predict the labels on the cross
%               validation set. For example, 
%                   predictions = svmPredict(model, Xval);
%               will return the predictions on the cross validation set.
%
%  Note: You can compute the prediction error using 
%        mean(double(predictions ~= yval))
%

steps = [ 0.01 0.03 0.1 0.3 1 3 10 30 ];

% Initialize with some very high value 
% e.g. 10 * exp(500)

Error_min = 10 * exp(500);
C_min = 10 * exp(500);
Sigma_min = 10 * exp(500);

for i = 1:length(steps)
    for j = 1:length(steps)
        C_current = steps(i);
        Sigma_current = steps(j);
        model = svmTrain(X, y, C_current, @(x1, x2) gaussianKernel(x1, x2, Sigma_current));
        
        predictions = svmPredict(model, Xval);
        error = mean(double(predictions ~= yval));

        if error < Error_min
            Error_min = error;
            C_min = C_current;
            Sigma_min = Sigma_current;
        end
    end
end

C = C_min;
sigma = Sigma_min;


% =========================================================================

end

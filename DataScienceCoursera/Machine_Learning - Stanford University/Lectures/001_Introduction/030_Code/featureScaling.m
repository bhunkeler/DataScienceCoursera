% =======================================================================================
% Function name: FeatureScaling 
% Author:        Bruno Hunkeler 
%
% Description:   Calculate the 
% Date:          23.05.2015
% =======================================================================================
function Q = featureScaling(X, feature )

% Extract respective column from features
x = X(:, feature);

% calculate the min and max Value of column
minValue = min(X);
maxValue = max(X);

% calculate the difference value of highest and smalles value in column (Vector)
delta = max(maxValue(:,feature)) - min(minValue(:,feature));

% calculate the mean value 
mean = mean(X)(:,feature);

Q = (x - mean) ./ delta; 
function plotData(X, y)
%PLOTDATA Plots the data points X and y into a new figure 
%   PLOTDATA(x,y) plots the data points with + for the positive examples
%   and o for the negative examples. X is assumed to be a Mx2 matrix.

% Create New Figure
figure; hold on;

% ====================== YOUR CODE HERE ======================
% Instructions: Plot the positive and negative examples on a
%               2D plot, using the option 'k+' for the positive
%               examples and 'ko' for the negative examples.
%

% Find incices of positive and negative examples 
positiveLabels = find (y == 1);
negativeLabels = find (y == 0);

% plot positive examples 
plot(X(positiveLabels, 1), X(positiveLabels, 2), 'k+', 'Linewidth', 2, 'Markersize', 7);

% plot negative examples 
plot(X(negativeLabels, 1), X(negativeLabels, 2), 'ko', 'MarkerFaceColor', 'y', 'Markersize', 7);

% =========================================================================

hold off;

end

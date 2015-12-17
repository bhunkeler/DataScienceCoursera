%% 
% Machine Learning: Linear Regression

%  Instructions
%  ------------
%
%
% x refers to the population size in 10,000s
% y refers to the profit in $10,000s
%



% Clear and Close Figures
clear all; close all; clc

ctrl = 2;

if (ctrl == 1); 
  %% Load Data
  data = csvread('ex1data1.txt');
  X = data(:, 1); y = data(:, 2);
  m = length(y); % number of training examples

  %% Load Data
  data = csvread('ex1data2.txt');
  X = data(:, 1:2);
  y = data(:, 3);
  m = length(y); % number of training examples

  % Feature Scaling 
  y = featureScaling(X, 1);

end;

if (ctrl == 2);
  %% Load Data
  fprintf('1) Loading data ...\n');
  data = csvread('ex1data3.txt');
  X = data(:, 1:size(data, 2) - 1);
  y = data(:, size(data, 2));
  m = length(y); % number of training examples

  fprintf('2) Scale features ...\n');
  indices = size(X, 2);
  z = [];
  for i = 1:indices
    z = [z, featureScaling(X, i)];
  end;
  fprintf('3) Feature Scaling finished ...\n');
end;

if (ctrl == 3);
  %% Load Data
  data = csvread('ex1data3.txt');
  X = data(:, 1:4);
  y = data(:, 5);
  theta = NormalEqu(X, y);
end;

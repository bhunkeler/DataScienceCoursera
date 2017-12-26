## Copyright (C) 2015 bhunkeler
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{retval} =} NormalEquation (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: bhunkeler <bhunkeler@HAWAII>
## Created: 2015-05-24

function [theta] = NormalEqu (X, y)

% Extract respective column from features
m = length(X);
iX = ones(m, 1);
X = [iX, X];

theta = pinv(X' * X)* X' * y 
endfunction

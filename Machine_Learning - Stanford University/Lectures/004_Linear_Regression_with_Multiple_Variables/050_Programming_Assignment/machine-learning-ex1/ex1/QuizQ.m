v = [1 ; 2; 3; 4; 5; 6; 7]
w = [1 ; 2; 3; 4; 5; 6; 7]

x = magic(7)
for(i = 1:7)
  for(j = 1:7)
  A(i, j) = log(x(i,j));
  B(i, j) = x(i, j)^2;
  C(i, j) = x(i, j) + 1;
  D(i, j) = x(i, j) / 4;
  end
  end
  
  a = "OK"
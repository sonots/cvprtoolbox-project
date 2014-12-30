%% RES = factorial(NUM)

function res = factorial(num)

if (num<=0)
  res = 1;
else
  res = num * factorial(num-1);
end

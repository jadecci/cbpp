function unit_test_compare(file1, file2)
% This function compares two CBPP performance files and returns 1 if their r_test variables are
% the same, with a tolerance of epsilon
%
% Jianxiao Wu, last edited on 12-Sept-2019

perf1 = load(file1, 'r_test');
perf2 = load(file2, 'r_test');
diff = sum(abs(perf1.r_test(:) - perf2.r_test(:)));

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
if diff > eps
  disp('%%  The two performance results are different!  %%')
else
  disp('%%  The two performance results are identical.  %%')
end
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
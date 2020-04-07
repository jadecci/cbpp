function unit_test_compare(file1, file2)
% This function compares two CBPP performance files and returns 1 if their r_test variables are
% the same
%
% Jianxiao Wu, last edited on 04-Apr-2020

perf1 = load(file1, 'r_test', 'nrmsd_test');
perf2 = load(file2, 'r_test', 'nrmsd_test');
diff = sum(abs(perf1.r_test(:) - perf2.r_test(:)) + abs(perf1.nrmsd_test(:) - perf2.nrmsd_test(:)));

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
if diff ~= 0
  disp('%%  The two results are different!  %%')
else
  disp('%%  The two results are identical.  %%')
end
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
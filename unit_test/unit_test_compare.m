function unit_test_compare(file1, file2)
% This function compares two CBPP performance files and returns 1 if their r_test variables are
% the same
%
% Jianxiao Wu, last edited on 04-Apr-2020

perf1 = load(file1, 'r_test', 'nrmsd_test');
perf2 = load(file2, 'r_test', 'nrmsd_test');
perf1_r = round(perf1.r_test, 6);
perf1_n = round(perf1.nrmsd_test, 6);
perf2_r = round(perf2.r_test, 6);
perf2_n = round(perf2.nrmsd_test, 6);
diff = sum(abs(perf1_r(:) - perf2_r(:)) + abs(perf1_n(:) - perf2_n(:)));

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
if diff ~= 0
  disp('%%  The two results are different!  %%')
  disp(['%%  Difference: ' num2str(diff) '  %%'])
else
  disp('%%  The two results are identical.  %%')
end
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
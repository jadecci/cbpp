function combine_CBPP_results(in_dir, prefix, out_dir)
% combine_CBPP_results(in_dir, prefix, out_dir)
%
% This function reads in CBPP prediction results, compute the average prediction accuracy for each 
% of psychometric variablbe, combines them into 40 summary scores, and save the combined 
% results in a csv file
%
% The sequence of the psychometric variables is assumed to be the same as that in
% /data/BnB2/Projects/jwu_HCP_Derivatives/unit_test_data/unit_test_y.mat
%
% Inputs:
%       - in_dir   :
%                   Absolute path to input directory
%       - prefix   :
%                   Performance file prefix. The file should be named: prefix.mat
%       - out_dir  :
%                   Absolute path to output directory
%
% Output:
%       One .csv file will be saved to out_dir, containing combined results
%
% Example:
% combine_CBPP_results('~/results/', 'wbCBPP_SVR_standard_HCP_fix_parc300_Pearson', '~/results', 0)
% This command collects SVR-FIX-Pearson prediction results at 300-parcel granularity 
%
% Last edited by Jianxiao Wu on 30-Sept-2019 

% usage
if nargin ~= 3
    disp('Usage: combine_CBPP_results(in_dir, prefix, out_dir)');
    return
end

% load results and get average accuracies
input = load(fullfile(in_dir, [prefix '.mat']));
input.r_test(isnan(input.r_test)==1) = 0; % set NaN values to 0
r_avg = squeeze(mean(mean(input.r_test)));

% combine the psychometric variables
n_score = 40;
score_combine = string(1:n_score); r_combine = zeros(n_score, 1); 
score_combine(1) = 'Audition'; r_combine(1) = r_avg(94); % Noise_Comp
score_combine(2) = 'Contrast Sen'; r_combine(2) = r_avg(100); % Mars_Final
score_combine(3) = 'Strength'; r_combine(3) = r_avg(88); % Strength_AgeAdj
score_combine(4) = 'Dexterity'; r_combine(4) = r_avg(86); % Dexterity_AgeAdj
score_combine(5) = 'Gait Speed'; r_combine(5) = r_avg(84); % GaitSpeed_Comp
score_combine(6) = 'Endurance'; r_combine(6) = r_avg(83); % Endurance_AgeAdj
score_combine(7) = 'Delay Disc'; r_combine(7) = mean(r_avg(15:16)); % DDisc_AUC_200 & DDisc_AUC_40k
score_combine(8) = 'NEOFAC-O'; r_combine(8) = r_avg(90); % NEOFAC_O
score_combine(9) = 'Crystal Comp'; r_combine(9) = r_avg(33); % CogCrystalComp_AgeAdj
score_combine(10) = 'Reading'; r_combine(10) = r_avg(10); % ReadEng_AgeAdj
score_combine(11) = 'Pic Vocab'; r_combine(11) = r_avg(12); % PicVocab_AgeAdj
score_combine(12) = 'Pic Seq'; r_combine(12) = r_avg(2); % PicSeq_AgeAdj
score_combine(13) = 'List Sort'; r_combine(13) = r_avg(25); % ListSort_AgeAdj
score_combine(14) = '2-back Acc'; r_combine(14) = r_avg(72); % WM_Task_2bk_Acc
score_combine(15) = '2-back Acc Face'; r_combine(15) = r_avg(75); % WM_Task_2bk_Face_Acc
score_combine(16) = 'Lang task'; r_combine(16) = r_avg(63); % Language_Task_Acc
score_combine(17) = 'Rel Acc'; r_combine(17) = r_avg(66); % Relational_Task_Acc
score_combine(18) = 'Fluid Int'; r_combine(18) = r_avg(7); % PMAT24_A_CR
score_combine(19) = 'Total Comp'; r_combine(19) = r_avg(31); % CogTotalComp_AgeAdj
score_combine(20) = 'Fluid Comp'; r_combine(20) = r_avg(27); % CogFluidComp_AgeAdj
score_combine(21) = 'Card Sort'; r_combine(21) = r_avg(4); % CardSort_AgeAdj
score_combine(22) = 'Flanker'; r_combine(22) = r_avg(6); % Flanker_AgeAdj
score_combine(23) = 'Proc Speed'; r_combine(23) = r_avg(14); % ProcSpeed_AgeAdj
score_combine(24) = 'Fluid Int RT'; r_combine(24) = r_avg(8); % PMAT24_A_RTCR
score_combine(25) = '2-back RT'; r_combine(25) = r_avg(73); % WM_Task_2bk_Median_RT
% Gambling_Task_Median_RT, Gambling_Task_Median_RT_Larger, Gambling_Task_Median_RT_Smaller,
% Gambling_Task_Reward_Median_RT_Larger, Gambling_Task_Reward_Median_RT_Smaller,
% Gambling_Task_Punish_Median_RT_Larger & Gambling_Task_Punish_Median_RT_Smaller
score_combine(26) = 'Gambling RT'; r_combine(26) = mean(r_avg(57:62)); 
score_combine(27) = 'Rel RT'; r_combine(27) = r_avg(67); % Relational_Task_Median_RT
score_combine(28) = 'Emot Recog RT'; r_combine(28) = r_avg(35); % ER40_CRT
score_combine(29) = 'Emot Recog'; r_combine(29) = r_avg(34); % ER40_CR
% LifeSatisf_Unadj, MeanPurp_Unadj & PosAffect_Unadj
score_combine(30) = '+ve Psych'; r_combine(30) = mean(r_avg(46:48)); 
% Friendship_Unadj, EmotSupp_Unadj & InstruSupp_Unadj
score_combine(31) = '+ve Social Rel'; r_combine(31) = mean(r_avg([49 53:54])); 
score_combine(32) = 'Self Eff'; r_combine(32) = r_avg(56); % SelfEff_Unadj
score_combine(33) = 'NEOFAC-E'; r_combine(33) = r_avg(93); % NEOFAC_E
score_combine(34) = 'NEOFAC-A'; r_combine(34) = r_avg(89); % NEOFAC_A
score_combine(35) = 'NEOFAC-C'; r_combine(35) = r_avg(91); % NEOFAC_C
score_combine(36) = 'NEOFAC-N'; r_combine(36) = r_avg(92); % NEOFAC_O
score_combine(37) = 'Stress'; r_combine(37) = r_avg(55); % PercStress_Unadj
% AngAffect_Unadj, AngHostil_Unadj & AngAggr_Unadj
score_combine(38) = 'Anger Affect'; r_combine(38) = mean(r_avg(40:42)); 
% FearAffect_Unadj & FearSomat_Unadj
score_combine(39) = 'Fear Affect'; r_combine(39) = mean(r_avg(43:44));
score_combine(40) = 'Sadness'; r_combine(40) = r_avg(45); % Sadness_Unadj

% write to output file
output = fullfile(out_dir, [prefix '.csv'])
fid = fopen(output, 'w');
for row = 1:n_score
    fprintf(fid, '%s,%f \n', score_combine(row), r_combine(row));
end
fclose(fid);

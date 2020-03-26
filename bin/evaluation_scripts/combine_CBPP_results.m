function combine_CBPP_results(in_dir, prefix, out_dir)
% combine_CBPP_results(in_dir, prefix, out_dir)
%
% This function reads in CBPP prediction results, compute the average prediction accuracy for each 
% of psychometric variablbe, combines them into 40 summary scores, and save the combined 
% results in a csv file
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
%       Two .csv file will be saved to out_dir, containing the combined results for Pearson correlation
%       evaluation and for nRMSD evaluation correspondingly
%
% Example:
% combine_CBPP_results('~/results/', 'wbCBPP_SVR_standard_HCP_fix_parc300_Pearson', '~/results', 0)
% This command collects SVR-FIX-Pearson prediction results at 300-parcel granularity 
%
% Last edited by Jianxiao Wu on 26-Mar-2020

% usage
if nargin ~= 3
    disp('Usage: combine_CBPP_results(in_dir, prefix, out_dir)');
    return
end

% load results and get average accuracies
input = load(fullfile(in_dir, [prefix '.mat']));
input.r_test(isnan(input.r_test)==1) = 0; % set NaN values to 0
r_avg = squeeze(mean(mean(input.r_test)));
nrmsd_avg = squeeze(mean(mean(input.nrmsd_test)));

% combine the psychometric variables
n_score = 40;
score_combine = string(1:n_score); r_combine = zeros(n_score, 1); nrmsd_combine = zeros(n_score, 1);
score_combine(1) = 'NEOFAC-O'; r_combine(1) = r_avg(90); nrmsd_combine(1) = nrmsd_avg(90); % NEOFAC_O
score_combine(2) = 'Audition'; r_combine(2) = r_avg(94); nrmsd_combine(2) = nrmsd_avg(94); % Noise_Comp
score_combine(3) = 'Contrast Sen'; r_combine(3) = r_avg(100); nrmsd_combine(3) = nrmsd_avg(100); % Mars_Final
score_combine(4) = 'Strength'; r_combine(4) = r_avg(88); nrmsd_combine(4) = nrmsd_avg(88); % Strength_AgeAdj
score_combine(5) = 'Dexterity'; r_combine(5) = r_avg(86); nrmsd_combine(5) = nrmsd_avg(86); % Dexterity_AgeAdj
score_combine(6) = 'Gait Speed'; r_combine(6) = r_avg(84); nrmsd_combine(6) = nrmsd_avg(84); % GaitSpeed_Comp
score_combine(7) = 'Endurance'; r_combine(7) = r_avg(83); nrmsd_combine(7) = nrmsd_avg(83); % Endurance_AgeAdj
score_combine(8) = 'Proc Speed'; r_combine(8) = r_avg(14); nrmsd_combine(8) = nrmsd_avg(14); % ProcSpeed_AgeAdj
score_combine(9) = 'Fluid Int'; r_combine(9) = r_avg(7); nrmsd_combine(9) = nrmsd_avg(7); % PMAT24_A_CR
score_combine(10) = 'Total Comp'; r_combine(10) = r_avg(31); nrmsd_combine(10) = nrmsd_avg(31); % CogTotalComp_AgeAdj
score_combine(11) = 'Crystal Comp'; r_combine(11) = r_avg(33); nrmsd_combine(11) = nrmsd_avg(33); % CogCrystalComp_AgeAdj
score_combine(12) = 'Fluid Comp'; r_combine(12) = r_avg(27); nrmsd_combine(12) = nrmsd_avg(27); % CogFluidComp_AgeAdj
score_combine(13) = 'Delay Disc'; r_combine(13) = r_avg(16); nrmsd_combine(13) = nrmsd_avg(16); % DDisc_AUC_40k
score_combine(14) = 'Reading'; r_combine(14) = r_avg(10); nrmsd_combine(14) = nrmsd_avg(10); % ReadEng_AgeAdj
score_combine(15) = 'Pic Vocab'; r_combine(15) = r_avg(12); nrmsd_combine(15) = nrmsd_avg(12); % PicVocab_AgeAdj
score_combine(16) = 'Pic Seq'; r_combine(16) = r_avg(2); nrmsd_combine(16) = nrmsd_avg(2); % PicSeq_AgeAdj
score_combine(17) = 'List Sort'; r_combine(17) = r_avg(25); nrmsd_combine(17) = nrmsd_avg(25); % ListSort_AgeAdj
score_combine(18) = '2-back Acc'; r_combine(18) = r_avg(72); nrmsd_combine(18) = nrmsd_avg(72); % WM_Task_2bk_Acc
score_combine(19) = '2-back Acc Face'; r_combine(19) = r_avg(75); nrmsd_combine(19) = nrmsd_avg(75); % WM_Task_2bk_Face_Acc
score_combine(20) = 'Lang task'; r_combine(20) = r_avg(63); nrmsd_combine(20) = nrmsd_avg(63); % Language_Task_Acc
score_combine(21) = 'Rel Acc'; r_combine(21) = r_avg(66); nrmsd_combine(21) = nrmsd_avg(66); % Relational_Task_Acc
score_combine(22) = 'Card Sort'; r_combine(22) = r_avg(4); nrmsd_combine(22) = nrmsd_avg(4); % CardSort_AgeAdj
score_combine(23) = 'Flanker'; r_combine(23) = r_avg(6); nrmsd_combine(23) = nrmsd_avg(6); % Flanker_AgeAdj
score_combine(24) = 'Fluid Int RT'; r_combine(24) = r_avg(8); nrmsd_combine(24) = nrmsd_avg(8); % PMAT24_A_RTCR
score_combine(25) = '2-back RT'; r_combine(25) = r_avg(73); nrmsd_combine(25) = nrmsd_avg(73); % WM_Task_2bk_Median_RT
score_combine(26) = 'Gambling RT'; r_combine(26) = r_avg(58); nrmsd_combine(26) = nrmsd_avg(58); % Gambling_Task_Median_RT_Smaller
score_combine(27) = 'Rel RT'; r_combine(27) = r_avg(67); nrmsd_combine(27) = nrmsd_avg(67); % Relational_Task_Median_RT
score_combine(28) = 'Emot Recog RT'; r_combine(28) = r_avg(35); nrmsd_combine(28) = nrmsd_avg(35); % ER40_CRT
score_combine(29) = 'Emot Recog'; r_combine(29) = r_avg(34); nrmsd_combine(29) = nrmsd_avg(34); % ER40_CR
score_combine(30) = 'Life Satisf'; r_combine(30) = r_avg(46); nrmsd_combine(30) = nrmsd_avg(46); % LifeSatisf_Unadj
score_combine(31) = 'Emot Supp'; r_combine(31) = r_avg(53); nrmsd_combine(31) = nrmsd_avg(53); % EmotSupp_Unadj 
score_combine(32) = 'Self Eff'; r_combine(32) = r_avg(56); nrmsd_combine(32) = nrmsd_avg(56); % SelfEff_Unadj
score_combine(33) = 'Stress'; r_combine(33) = r_avg(55); nrmsd_combine(33) = nrmsd_avg(55); % PercStress_Unadj
score_combine(34) = 'Anger Aggr'; r_combine(34) = r_avg(42); nrmsd_combine(34) = nrmsd_avg(42); % AngAggr_Unadj
score_combine(35) = 'Fear Affect'; r_combine(35) = r_avg(43); nrmsd_combine(35) = nrmsd_avg(43); % FearAffect_Unadj 
score_combine(36) = 'Sadness'; r_combine(36) = r_avg(45); nrmsd_combine(36) = nrmsd_avg(45); % Sadness_Unadj
score_combine(37) = 'NEOFAC-N'; r_combine(37) = r_avg(92); nrmsd_combine(37) = nrmsd_avg(92); % NEOFAC_N
score_combine(38) = 'NEOFAC-E'; r_combine(38) = r_avg(93); nrmsd_combine(38) = nrmsd_avg(93); % NEOFAC_E
score_combine(39) = 'NEOFAC-A'; r_combine(39) = r_avg(89); nrmsd_combine(39) = nrmsd_avg(89); % NEOFAC_A
score_combine(40) = 'NEOFAC-C'; r_combine(40) = r_avg(91); nrmsd_combine(40) = nrmsd_avg(91); % NEOFAC_C

% write to output file
output = fullfile(out_dir, [prefix '_pearson.csv']);
fid = fopen(output, 'w');
for row = 1:n_score; fprintf(fid, '%s,%f \n', score_combine(row), r_combine(row)); end
fclose(fid);
output = fullfile(out_dir, [prefix '_nrmsd.csv']);
fid = fopen(output, 'w');
for row = 1:n_score; fprintf(fid, '%s,%f \n', score_combine(row), nrmsd_combine(row)); end
fclose(fid);

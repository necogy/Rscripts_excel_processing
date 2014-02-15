function scans_to_process = LONG_run_registration( scans_to_process )
%FUNCTION_NAME - SPM12b Longitudinal Registration
%
% Syntax:  participantstructure = SA_load_participant_info_longreg(listname)
%
% Inputs: scans_to_process - array of objects of class LONG_participant
%
% Outputs: scans_to_process - updated array with run status
%
%
% Other m-files required: LONG_participant.m, LONG_setup.m, SPM12b
% Subfunctions:
%
% MAT-files required: none
%
% See also:
%
% To Do:
%
% Author: Suneth Attygalle
% Created 02/14/2014
%
% Revisions:

%-----------------------------------------------------------------------
% Job saved on 11-Mar-2013 16:19:57 by cfg_util (rev $Rev: 4972 $)
% spm SPM - SPM12b (5174)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.tools.longit{1}.pairwise.vols1 = '<UNDEFINED>';
matlabbatch{1}.spm.tools.longit{1}.pairwise.vols2 = '<UNDEFINED>';
matlabbatch{1}.spm.tools.longit{1}.pairwise.tdif = '<UNDEFINED>';
matlabbatch{1}.spm.tools.longit{1}.pairwise.noise = NaN;
matlabbatch{1}.spm.tools.longit{1}.pairwise.wparam = [0 0 100 25 100];
matlabbatch{1}.spm.tools.longit{1}.pairwise.bparam = 1000000;
matlabbatch{1}.spm.tools.longit{1}.pairwise.write_avg = 1;
matlabbatch{1}.spm.tools.longit{1}.pairwise.write_jac = 1;
matlabbatch{1}.spm.tools.longit{1}.pairwise.write_div = 1;
matlabbatch{1}.spm.tools.longit{1}.pairwise.write_def = 1;

end


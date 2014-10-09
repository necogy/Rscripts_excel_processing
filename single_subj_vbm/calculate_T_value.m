function calculate_T_value(resultspath)

spmTmap=strcat(resultspath,'/spmT_0001.nii');
ttxt=strcat(resultspath,'/tvalue.txt');


V = spm_vol(spmTmap);
    mask = spm_read_vols(V);
    M = V.mat;
    DIM = V.dim;
    TF = 'T';
    T_start = strfind(V.descrip,'SPM{T_[')+length('SPM{T_[');
    if isempty(T_start); T_start = strfind(V.descrip,'SPM{F_[')+length('SPM{F_['); TF='F'; end
    if isempty(T_start)
        TF=[]; df=[];
    else
        T_end = strfind(V.descrip,']}')-1;
        df = str2num(V.descrip(T_start:T_end));    
    end

 tvalue = spm_invTcdf(.999,df);
 
 fileID = fopen(ttxt,'w');
 fprintf(fileID,'%s',tvalue);
 fclose(fileID);
 
end
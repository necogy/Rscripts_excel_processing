function  matNI_DTI_hessian_cardan( pathtoimage, FWHM )
%MATNI_DTI_HESSIAN_cardan - compute hessian and apply to 3D image
%   compute hessian and apply to 3D image and saves image in location of
%   processed image. Requires SPM. Uses the Cardan equation to solve for
%   eigenvalues, which could have accuracy issues vs a numerical solution
%   but is much faster.
%
% Syntax: matNI_DTI_hessian( pathtoimage, fWHM)
%
% Inputs: 
%           pathtoimage -  string with full path file to compute hessian 
%           FWHM - full width half maximum to use for gaussian smoothing,
%           SD and sigma are calculated from the FWHM automatically
%   
% Outputs: filtered image with "hess" prepended to original filename
%
% Other m-files required:  SPM, smooth3.m, 
% eig3.m from http://www.mathworks.com/matlabcentral/fileexchange/27680-multiple-eigen-values-for-2x2-and-3x3-matrices/content/Eig3Folder/eig3.m)
% Subfunctions:
%
% MAT-files required: SPM, Image Processing toolbox
%
% See also:
% To Do: 
%
% Author: Suneth Attygalle, UCSF Memory and Aging Center
% Created 05/16/2014
% Revisions:
%
% References:
% Sato et al. 3D multi-scale line filter for segmentation and visualization of curvilinear structures in medical images



%%
vol = spm_vol(pathtoimage);
img = spm_read_vols(vol);

%   gaussianfilter =  fspecial('gaussian',[6 6], 2);
%   img= imfilter(img, gaussianfilter);

% sigma = 3;
% cutoff = ceil(3*sigma);
% h = fspecial('gaussian',2*cutoff+1,sigma);
% img= imfilter(img, h)

% h = fspecial('gaussian',[1,2*cutoff+1],sigma);
% dh = h .* (-cutoff:cutoff) / (-sigma^2);
% out = conv2(dh,h,img,'same');


sd = FWHM/(2*sqrt(2*log(2)));
kernelscale = 3.5;
size = ceil(2*floor(kernelscale*sd/2)+1); %calculated kernel size (3.5* sd) and made an odd number

img = smooth3(img,'gaussian',size,sd);

spacing = 0.1; 
totalvoxels = vol.dim(1)*vol.dim(2)*vol.dim(3);

[gx,gy,gz] = gradient(img,spacing);
clear img;
[g.xx, g.xy, g.xz] = gradient(gx,spacing);
clear gx;
[g.yx, g.yy, g.yz] = gradient(gy,spacing);
clear gy;
[g.zx, g.zy, g.zz] = gradient(gz,spacing);
clear gz;

g.xx =reshape(g.xx, 1,totalvoxels) ;
g.xy =reshape(g.xy, 1,totalvoxels) ;
g.xz =reshape(g.xz, 1,totalvoxels) ;
g.yx =reshape(g.yx, 1,totalvoxels) ;
g.yy =reshape(g.yy, 1,totalvoxels) ;
g.yz =reshape(g.yz, 1,totalvoxels) ;
g.zx =reshape(g.zx, 1,totalvoxels) ;
g.zy =reshape(g.zy, 1,totalvoxels) ;
g.zz =reshape(g.zz, 1,totalvoxels) ;

H(1,1,:) = g.xx;
H(2,1,:) = g.yx;
H(3,1,:) = g.zx;
H(1,2,:) = g.xy;
H(2,2,:) = g.yy;
H(3,2,:) = g.zy;
H(1,3,:) = g.xz;
H(2,3,:) = g.yz;
H(3,3,:) = g.zz;

clear g;
D=eig3(H);
maxeig= min(D);
%maxeig= max(D);

%invertimage
maxeig=maxeig.*(-1);

%mask negative values
maxeig(maxeig<0) =0;

%shift image
%maxeig = maxeig+min(maxeig);

% sd = FWHM/2/(2*sqrt(2*log(2)));
% size = ceil(2*floor(3.5*sd/2)+1);

newimage =reshape(maxeig,vol.dim(1),vol.dim(2),vol.dim(3));
%newimage = smooth3(newimage,'gaussian',size,sd);
%newimage = mat2gray(newimage);
[pathstr, name, ext] = fileparts(vol.fname);

%generate new header
newfile = fullfile(pathstr, ['hess_' num2str(FWHM) '_' name ext]);
newvol=vol;
newvol.fname = newfile;

spm_write_vol(newvol,newimage);
end

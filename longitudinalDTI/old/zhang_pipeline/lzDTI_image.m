classdef lzDTI_image
    %lzDTI_image metadata for an image
    %   Detailed explanation goes here
    
    properties

        path % full path to image file
        scanType %MRI, FA etc
        %md5hash %
        mean % image average value
        sum % sum of all voxel values
        nVoxels % number of voxels in image
        voxelDimension % 3x1 vector of voxel dimension
        header % nifti/analyze header
    end
    
    methods     
        function li = lzDTI_image(pathtoimage)
            if nargin > 0 % Support calling with 0 arguments
                try % load parameters
                    li.path = pathtoimage;
                   % li.scanType = usePathToDetermineScanType(pathtoimage);
                    li.header = spm_vol(pathtoimage);
                    li.voxelDimension = li.header.dim;
                    li.nVoxels = prod(li.voxelDimension);
                    %li.mean
                   % li.sum
                    
                catch err
                    
                end
                
                
            end
            
            
            
        end
        
        function guessedscantype = usePathToDetermineScanType(pathtoimage)
            % use a dictionary of file type to file image to guess what
            % type of scan it was 
            strfind(pathtoimage, 'teststring')
            %MP-LAS = T1
            % v1_FA = DTI 
            guessedscantype ;
        end
    end
    
end

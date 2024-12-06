close all;
clc;
clear all;

addpath '/Users/tian_bc/repos/github/Drex-MATLAB/Contour/';
addpath '/Users/tian_bc/repos/github/Drex-MATLAB/functions/';

%% getting paths
% Save current directory
originalFolder = pwd;
% Define the target folder and the bash script path
targetFolder = '/Users/tian_bc/Documents/2024-LC_delamination/Model_results/GriggsExp/Andromeda/240724-Griggs-shear-5_particles/240724-Griggs-shear-5particles/particles_cpo/';
% copy filter script to target folder
filter_script_file = 'filter_weighted-to-all_data.sh'
copyfile(filter_script_file, targetFolder);
bashScript = fullfile('sh ',targetFolder, 'filter_weighted-to-all_data.sh');  % Replace with your bash script name

cd(targetFolder)
% Run the bash script located in the target folder
fprintf('Running bash script: %s\n', bashScript);
status = system(bashScript);

% Check if the script ran successfully
if status ~= 0
    error('Bash script failed to execute.');
end

% Define the output file path
outputFile = fullfile(targetFolder, 'all_data.txt');  % Replace with the actual output file name

% Check if the output file exists and read its content
if isfile(outputFile)
    % Load data from the output file into a matrix
    fprintf('Reading data from: %s\n', outputFile);
    dataMatrix = readmatrix(outputFile);  % Adjust based on file format
    disp('Data successfully loaded:');
    disp(dataMatrix);
else
    error('Output file not found.');
end

% Return to the original folder
cd(originalFolder);


% now build data matrix based on the dataMatrix
timestep0 = min(dataMatrix(:,1));
timestep_end = max(dataMatrix(:,1));




% file_fullpath=fullfile(path,filename);
% data = readtable(file_fullpath);
%extractedData = data{:, 7:9};
%extractedData = data{:, 3:5}; %for mineral 0
% from error message

% phi_raw = extractedData(:,1); %convert to 0-2pi
% theta_raw = extractedData(:,2);  
% z_raw = extractedData(:,3);
% figure
% plot(phi_raw,'r.'); hold on;
% plot(theta_raw,'g.')
% plot(z_raw,'b.')

% 
% phi = extractedData(:,1)/360; %convert to 0-2pi
% theta = extractedData(:,2)/180;  
% z = extractedData(:,3)/360;


%% PIPIPIPIPIPIPIPIP!!!!!!!!!!!!!!!!!! FORGOT THE PIIIIIIII!!!!!!!!
phi = extractedData(:,1)/360 * 2*pi; %convert to 0-2pi
theta = extractedData(:,2)/180 * pi;  
z = extractedData(:,3)/360 * 2*pi;

EulerAngle = [phi, theta, z];

%% rotate ASPECT results to MATLAB coordinate frame:
% % using mtex function
% EA_quat = euler2quat(phi,theta,z,'Bunge'); %-->quaternion
% orientation_tensor = orientation(EA_quat,crystalSymmetry('mmm'));
% odf = calcDensity(orientation_tensor);
% odf_rotated= rotate(odf,rotation.byAxisAngle(zvector,-90*degree));
% figure(1)
% plotx2east;
% plotPDF(odf,[Miller(1,0,0,crystalSymmetry('mmm')) Miller(0,1,0,crystalSymmetry('mmm')) Miller(0,0,1,crystalSymmetry('mmm'))],'colorrange',[1 5],'FontSize',14)
% figure(2)
% plotx2east
% plotPDF(odf_rotated,[Miller(1,0,0,crystalSymmetry('mmm')) Miller(0,1,0,crystalSymmetry('mmm')) Miller(0,0,1,crystalSymmetry('mmm'))],'colorrange',[1 5],'FontSize',22)


% using matlab functions
rotm_origin= eul2rotm(EulerAngle,'ZXZ');
nGrains=size(EulerAngle,1);
rotm_rotated=zeros(3,3,nGrains);
rotmX = rotx(-90);
rotmZ = rotz(-45);

EulerAngle_rotatedX = zeros(nGrains,3);
EulerAngle_rotatedXZ = zeros(nGrains,3);

% % for shearbox models that only require X axis rotation
for i = 1:nGrains
    rotm_rotatedX(:,:,i)=rotmX*rotm_origin(:,:,i);
    EulerAngle_rotatedX(i,:) = rotm2eul(rotm_rotatedX(:,:,i),'ZXZ');
end

% % for Griggs models that require X + Y axes rotation
for i = 1:nGrains
    rotm_rotatedXZ(:,:,i)=rotmZ*rotmX*rotm_origin(:,:,i);
    EulerAngle_rotatedXZ(i,:) = rotm2eul(rotm_rotatedXZ(:,:,i),'ZXZ');
end



%plot original Euler Angle figure 3
[hFig] = contourpolefigures(EulerAngle,'olivine','Gaussian',28.64,3-2,'lower');

%plot rotated wrt X by 90 degree figure 4
[hFig] = contourpolefigures(EulerAngle_rotatedX,'olivine','Gaussian',28.64,4-2,'lower');

%plot rotated wrt X by 90 degrees and Z by 45 degrees in figure 5
[hFig] = contourpolefigures(EulerAngle_rotatedXZ,'olivine','Gaussian',28.64,5-2,'lower');

%% calculate LS index for ASPECT output
%convert volume weighted eulerAngles back to direction cosines
%final_aijs_volweighted = euler2orientationmatrix(EulerAngle);
final_aijs_volweighted = euler2orientationmatrix(EulerAngle_rotatedX);
%final_aijs_volweighted = euler2orientationmatrix(EulerAngle_rotatedXZ);

[sum_aij_010,sum_aij_001,reshape_aijs,N] = LPO_indices(final_aijs_volweighted);
% construct the Mjk matrix
Mjk_010 = sum_aij_010./N;
Mjk_001 = sum_aij_001./N;
% get eigen values of Mjk
[eigen_vec_010,eigen_val_010] = eig(Mjk_010);
[eigen_vec_001,eigen_val_001] = eig(Mjk_001);

P010 = eigen_val_010(3,3) - eigen_val_010(2,2);
G010 = 2 * (eigen_val_010(2,2) - eigen_val_010(1,1));
R010 = 3 * eigen_val_010(1,1);
sumPGR010=P010+G010+R010

P001 = eigen_val_001(3,3) - eigen_val_001(2,2);
G001 = 2 * (eigen_val_001(2,2) - eigen_val_001(1,1));
R001 = 3 * eigen_val_001(1,1);
%check if they sum to one
sumPGR001=P001+G001+R001

P010
P001
G010
G001
% LS index
LS = 0.5 * (2-(P010/(G010+P010))-(G001/(G001+P001)))


function [sum_aij_010, sum_aij_001,aij_new, nGrains] = LPO_indices(aij_v)   
    nGrains = size(aij_v,1);
    aij_new = zeros(3,3,nGrains);
    sum_aij_010 = zeros(3,3);
    sum_aij_001 = zeros(3,3);

    for iGrain = 1:nGrains
        %aij_new(:,:,iGrain) = reshape(aij_v(iGrain,:),3,3);
        aij_new(:,:,iGrain) = [aij_v(iGrain,1), aij_v(iGrain,2), aij_v(iGrain,3);
              aij_v(iGrain,4), aij_v(iGrain,5), aij_v(iGrain,6);
              aij_v(iGrain,7), aij_v(iGrain,8), aij_v(iGrain,9)];

        %for [010]
        x010 = aij_new(2,1,iGrain);
        y010 = aij_new(2,2,iGrain);
        z010 = aij_new(2,3,iGrain);

        sum_aij_010(1,1) = sum_aij_010(1,1) + x010*x010;
        sum_aij_010(1,2) = sum_aij_010(1,2) + x010*y010;
        sum_aij_010(1,3) = sum_aij_010(1,3) + x010*z010;
        sum_aij_010(2,2) = sum_aij_010(2,2) + y010*y010;
        sum_aij_010(2,3) = sum_aij_010(2,3) + y010*z010;
        sum_aij_010(3,3) = sum_aij_010(3,3) + z010*z010;

        sum_aij_010(2,1) = sum_aij_010(1,2);
        sum_aij_010(3,1) = sum_aij_010(1,3);
        sum_aij_010(3,2) = sum_aij_010(2,3);

        %for [001]
        x001 = aij_new(3,1,iGrain);
        y001 = aij_new(3,2,iGrain);
        z001 = aij_new(3,3,iGrain);

        sum_aij_001(1,1) = sum_aij_001(1,1) + x001*x001;
        sum_aij_001(1,2) = sum_aij_001(1,2) + x001*y001;
        sum_aij_001(1,3) = sum_aij_001(1,3) + x001*z001;
        sum_aij_001(2,2) = sum_aij_001(2,2) + y001*y001;
        sum_aij_001(2,3) = sum_aij_001(2,3) + y001*z001;
        sum_aij_001(3,3) = sum_aij_001(3,3) + z001*z001;

        sum_aij_001(2,1) = sum_aij_001(1,2);
        sum_aij_001(3,1) = sum_aij_001(1,3);
        sum_aij_001(3,2) = sum_aij_001(2,3);
   
    end
end

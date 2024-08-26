%base script test
clear all;
close all;
clc;
global TEST_LPO; %Tian
Drex()


final_aijs = TEST_LPO.Final.directionCosines;
nGrains = size(final_aijs,1);
%final_aijs = TEST_LPO.Init.directionCosines;
final_eulerAngles = orientationmatrix2euler(TEST_LPO.Final.directionCosines); 

%close all
%figure(3); %clf
%[hFig] = contourpolefigures(final_eulerAngles,'olivine','Gaussian',Flow.shear_strain,2);
[hFig] = contourpolefigures(final_eulerAngles,'olivine','Gaussian',28.64,3);
%Tian this plot shows that it is plotting unweighted pole figure, different from results
%now convert results to volume weighted

% % 3. Write volume weighted euler angles, using random draws to convert odf
% % to a discrete number of orientations, weighted by volume

% %... sort by vol fraction
% [volFracSorted, idxVolFrac] = sort(LPO.Final.volumeFraction);
% eulerAnglesSorted = LPO.Final.eulerAngles(idxVolFrac,:);

% %... generate cumulative weight
% cumWeight = cumsum(volFracSorted);

% %... generate random indices
% % check for qrandstream (part of statistics toolbox)
% if exist('qrandstream','file') == 2;
%     q = qrandstream('halton', 3, 'Skip',1e3, 'Leap',1e2);
%     idxGrain = qrand(q,Grain.nGrains);
% else
%     idxGrain = rand(Grain.nGrains,3);
% end

% %... find correct eulerAngle and write to file
% fileName = ['Output/drex_',Flow.deformationSymmetry,'_volweighted.txt'];
% fid = fopen(fileName,'w');
% for i = 1:Grain.nGrains
%     % find the maximum cumWeight that is less than the random value.
%     %... the euler angle index is +1. For example, if the idxGrain(i) < cumWeight(1), the index should be 1 not zero) 
%     cumWeightIdx = numel(cumWeight(cumWeight <= idxGrain(i)))+1;
%     fprintf(fid,'%f %f %f\n', eulerAnglesSorted(cumWeightIdx,:)*180/pi);
% end
% fclose(fid);

% 3. Write volume weighted euler angles, using random draws to convert odf
% to a discrete number of orientations, weighted by volume
%... sort by vol fraction
[volFracSorted, idxVolFrac] = sort(TEST_LPO.Final.volumeFraction);
eulerAnglesSorted = final_eulerAngles(idxVolFrac,:);

%... generate cumulative weight
cumWeight = cumsum(volFracSorted);

%... generate random indices
% check for qrandstream (part of statistics toolbox)
if exist('qrandstream','file') == 2;
    q = qrandstream('halton', 3, 'Skip',1e3, 'Leap',1e2);
    idxGrain = qrand(q,nGrains);
else
    idxGrain = rand(nGrains,3);
end

%... find correct eulerAngle and write to file
%fileName = ['Output/drex_','_volweighted_main.txt'];
%fid = fopen(fileName,'w');
final_eulerAngles_weighted = zeros(nGrains,3);
for i = 1:nGrains
    % find the maximum cumWeight that is less than the random value.
    %... the euler angle index is +1. For example, if the idxGrain(i) < cumWeight(1), the index should be 1 not zero) 
    cumWeightIdx = numel(cumWeight(cumWeight <= idxGrain(i)))+1;
    %fprintf(fid,'%f %f %f\n', eulerAnglesSorted(cumWeightIdx,:)*180/pi);
    final_eulerAngles_weighted(i,:) = eulerAnglesSorted(cumWeightIdx,:);
end
%fclose(fid);
figure(4); %clf
%[hFig] = contourpolefigures(final_eulerAngles,'olivine','Gaussian',Flow.shear_strain,2);
[hFig] = contourpolefigures(final_eulerAngles_weighted,'olivine','Gaussian',28.64,5);

%convert volume weighted eulerAngles back to direction cosines
final_aijs = euler2orientationmatrix(final_eulerAngles_weighted); 


[sum_aij_010,sum_aij_001,reshape_aijs,N] = LPO_indices(final_aijs);
Mjk_010 = sum_aij_010./N;
Mjk_001 = sum_aij_001./N;

[eigen_vec_010,eigen_val_010] = eig(Mjk_010);
[eigen_vec_001,eigen_val_001] = eig(Mjk_001);


P010 = eigen_val_010(3,3) - eigen_val_010(2,2);
G010 = 2 * (eigen_val_010(2,2) - eigen_val_010(1,1));
R010 = 3 * eigen_val_010(1,1);
sumPGR010=P010+G010+R010


P001 = eigen_val_001(3,3) - eigen_val_001(2,2);
G001 = 2 * (eigen_val_001(2,2) - eigen_val_001(1,1));
R001 = 3 * eigen_val_001(1,1);

sumPGR001=P001+G001+R001

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
        % x010 = aij_new(1,2,iGrain);
        % y010 = aij_new(2,2,iGrain);
        % z010 = aij_new(3,2,iGrain);

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
        % x001 = aij_new(1,3,iGrain);
        % y001 = aij_new(2,3,iGrain);
        % z001 = aij_new(3,3,iGrain);

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




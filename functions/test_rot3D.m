% test rot3D.m
clear
close all
clc

n = [0,0,1];
%acsold = [1,0,0];
acsold = [1,0,0.5];

% n = [0,1,0];
% acsold = [1,1,0.5];


angle = 45;

acsnew = rot3D(acsold,n,angle);
figure(1)
quiver3(0,0,0,n(1),n(2),n(3),'k-','LineWidth',5);hold on;
quiver3(0,0,0,acsold(1),acsold(2),acsold(3),'--');hold on;
quiver3(0,0,0,acsnew(1),acsnew(2),acsnew(3),'r-');hold on;


%% for loop version
figure(2)
for angle = 0:10:360
    acsnew = rot3D(acsold,n,angle);
    quiver3(0,0,0,n(1),n(2),n(3),'k-','LineWidth',5);hold on;
    quiver3(0,0,0,acsold(1),acsold(2),acsold(3),'--','LineWidth',3);hold on;
    quiver3(0,0,0,acsnew(1),acsnew(2),acsnew(3),'r-');hold on;
    pause(0.2)
    xlabel("x")
    ylabel("y")
end


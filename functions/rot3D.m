function acsnew = rot3D(acsold, a, angle0)
% from ECOMAN 2.0 rotmat.f90
% 
% angle must be in radians                                                                                        
angle = angle0/180d0*pi;

%% Calculation
%Rotations are clockwise when the axis points toward the observer,                                               
%right handed coordinate system.                                                                                 
%Euler-Rodrigues's formula for rotation of a vector around an axis         
% https://mathworld.wolfram.com/RodriguesRotationFormula.html
acsrot(1,1)= cos(angle) + (1-cos(angle))*a(1)*a(1);
acsrot(1,2)= (1-cos(angle))*a(1)*a(2) - sin(angle)*a(3);
acsrot(1,3)= (1-cos(angle))*a(1)*a(3) + sin(angle)*a(2);
acsrot(2,1)= (1-cos(angle))*a(2)*a(1) + sin(angle)*a(3);
acsrot(2,2)= cos(angle) + (1-cos(angle))*a(2)*a(2);
acsrot(2,3)= (1-cos(angle))*a(2)*a(3) - sin(angle)*a(1);
acsrot(3,1)= (1-cos(angle))*a(3)*a(1) - sin(angle)*a(2);
acsrot(3,2)= (1-cos(angle))*a(3)*a(2) + sin(angle)*a(1);
acsrot(3,3)= cos(angle) + (1-cos(angle))*a(3)*a(3);
%Reverse rotation                                                                                                   
acsnew = acsold * acsrot;

end

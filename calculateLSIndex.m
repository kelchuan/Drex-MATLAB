function [LS] = calculateLSIndex(extractedData)
    % This function processes the Euler angles, applies rotations,
    % and calculates the LS index based on ASPECT output data.
    %
    % Inputs:
    %   extractedData - A matrix with Euler angles in columns 1, 2, and 3
    %
    % Outputs:
    %   LS - The calculated LS index
    %   P010 - The P value for 010 direction
    %   P001 - The P value for 001 direction
    %   G010 - The G value for 010 direction
    %   G001 - The G value for 001 direction

    % Convert extracted data to Euler angles in radians
    phi = extractedData(:,1)/360 * 2*pi; % Convert to 0-2pi
    theta = extractedData(:,2)/180 * pi;  
    z = extractedData(:,3)/360 * 2*pi;

    EulerAngle = [phi, theta, z];

    % Rotate ASPECT results to MATLAB coordinate frame using MATLAB functions
    rotm_origin = eul2rotm(EulerAngle, 'ZXZ');
    nGrains = size(EulerAngle, 1);
    rotm_rotated = zeros(3, 3, nGrains);
    rotmX = rotx(-90);
    rotmZ = rotz(-45);

    EulerAngle_rotatedX = zeros(nGrains, 3);
    EulerAngle_rotatedXZ = zeros(nGrains, 3);

    % For shearbox models that only require X-axis rotation
    for i = 1:nGrains
        rotm_rotatedX(:,:,i) = rotmX * rotm_origin(:,:,i);
        EulerAngle_rotatedX(i,:) = rotm2eul(rotm_rotatedX(:,:,i), 'ZXZ');
    end

    % For Griggs models that require X + Y axes rotation
    for i = 1:nGrains
        rotm_rotatedXZ(:,:,i) = rotmZ * rotmX * rotm_origin(:,:,i);
        EulerAngle_rotatedXZ(i,:) = rotm2eul(rotm_rotatedXZ(:,:,i), 'ZXZ');
    end

    % Plot original Euler Angle figure
    %hFig1 = contourpolefigures(EulerAngle, 'olivine', 'Gaussian', 28.64, 3-2, 'lower');

    % Plot rotated wrt X by 90 degrees figure
    %hFig2 = contourpolefigures(EulerAngle_rotatedX, 'olivine', 'Gaussian', 28.64, 4-2, 'lower');

    % Plot rotated wrt X by 90 degrees and Z by 45 degrees figure
    hFig3 = contourpolefigures(EulerAngle_rotatedXZ, 'olivine', 'Gaussian', 28.64, 5-2, 'lower');

    % Convert volume-weighted Euler angles back to direction cosines
    final_aijs_volweighted = euler2orientationmatrix(EulerAngle_rotatedX);

    % Calculate LPO indices
    [sum_aij_010, sum_aij_001, reshape_aijs, N] = LPO_indices(final_aijs_volweighted);

    % Construct the Mjk matrix
    Mjk_010 = sum_aij_010 ./ N;
    Mjk_001 = sum_aij_001 ./ N;

    % Get eigenvalues of Mjk
    [eigen_vec_010, eigen_val_010] = eig(Mjk_010);
    [eigen_vec_001, eigen_val_001] = eig(Mjk_001);

    % Calculate P, G, R values for 010 and 001
    P010 = eigen_val_010(3, 3) - eigen_val_010(2, 2);
    G010 = 2 * (eigen_val_010(2, 2) - eigen_val_010(1, 1));
    R010 = 3 * eigen_val_010(1, 1);
    sumPGR010 = P010 + G010 + R010;

    P001 = eigen_val_001(3, 3) - eigen_val_001(2, 2);
    G001 = 2 * (eigen_val_001(2, 2) - eigen_val_001(1, 1));
    R001 = 3 * eigen_val_001(1, 1);
    sumPGR001 = P001 + G001 + R001;

    % Output values for P, G, R
    disp(['P010: ', num2str(P010)]);
    disp(['P001: ', num2str(P001)]);
    disp(['G010: ', num2str(G010)]);
    disp(['G001: ', num2str(G001)]);

    % Calculate LS index
    LS = 0.5 * (2 - (P010 / (G010 + P010)) - (G001 / (G001 + P001)));

    % Return the LS index and other values
end

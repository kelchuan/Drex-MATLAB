close all;
clc;
clear all;

addpath '/Users/tian_bc/repos/github/Drex-MATLAB/Contour/';
addpath '/Users/tian_bc/repos/github/Drex-MATLAB/functions/';

%% getting paths and loading data
% input:
% 1. targetFolder for where the weighted cpo files are stored
% 
% Save current directory
originalFolder = pwd;
subfolder = 'dir_matlab_out';
% Define the target folder and the bash script path
%targetFolder = '/Users/tian_bc/Documents/2024-LC_delamination/Model_results/GriggsExp/Andromeda/240724-Griggs-shear-5_particles/240724-Griggs-shear-5particles/particles_cpo/';
%--------
% Natural cases
%--------
%--------
% V2e-16
%--------
% % T1073
% targetFolder ='/Users/tian_bc/Documents/2024-LC_delamination/Model_results/GriggsExp/Andromeda/241103/241203/241103-T1073-V2e-16-strong-piston/particles_cpo/'
% % T1273
%targetFolder='/Users/tian_bc/Documents/2024-LC_delamination/Model_results/GriggsExp/Andromeda/241103/241103-T1273-V2e-16/particles_cpo/'
% % T1473
% targetFolder='/Users/tian_bc/Documents/2024-LC_delamination/Model_results/GriggsExp/Andromeda/241103/241103-T1473-V2e-16/particles_cpo'
% 
% 
% %T1273 fix 
% %--------
% % V2e-14
% targetFolder='/Users/tian_bc/Documents/2024-LC_delamination/Model_results/GriggsExp/Andromeda/241103/241103-T1273-V2e-14/particles_cpo'
% % V2e-15
% targetFolder='/Users/tian_bc/Documents/2024-LC_delamination/Model_results/GriggsExp/Andromeda/241103/241103-T1273-V2e-15/particles_cpo'
% 
% % V2e-17
% targetFolder='/Users/tian_bc/Documents/2024-LC_delamination/Model_results/GriggsExp/Andromeda/241103/241203/241103-T1273-V2e-17-strong-piston/particles_cpo'
% 
% %--------
% % Lab cases
% %--------
% % V2e-6
% %--------
% %T1073
% targetFolder='/Users/tian_bc/Documents/2024-LC_delamination/Model_results/GriggsExp/Peloton_lc/241201/241201-T1073-V2e-6_corrected/particles_cpo'
% % T1273
targetFolder='/Users/tian_bc/Documents/2024-LC_delamination/Model_results/GriggsExp/Peloton_lc/241201/241201-T1273-V2e-6_corrected/particles_cpo'
% % T1473
% targetFolder='/Users/tian_bc/Documents/2024-LC_delamination/Model_results/GriggsExp/Peloton_lc/241201/241201-T1473-V2e-6_corrected/particles_cpo'
% % % V2e-15
% % targetFolder='/particles_cpo'
% % % V2e-15
% % targetFolder='/particles_cpo'
% % V2e-15
% targetFolder='/particles_cpo'

% Create the subfolder if it doesn't exist
fullFolderPath = fullfile(targetFolder, subfolder);
if ~exist(fullFolderPath, 'dir')
    mkdir(fullFolderPath); % Create the directory if it does not exist
end

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
    %fprintf('Reading data from: %s\n', outputFile);
    dataMatrix = readmatrix(outputFile);  % Adjust based on file format
    disp('Data successfully loaded:');
    %disp(dataMatrix);
else
    error('Output file not found.');
end

% Return to the original folder
cd(originalFolder);


% now build data matrix based on the dataMatrix
timestep0 = min(dataMatrix(:,1));
timestep_end = max(dataMatrix(:,1));
time = linspace(timestep0,timestep_end,timestep_end-timestep0+1);



%% now calculate LS index as a function of time!
time_step_increment = 10;%5; %<> <> means input
% particle_id = 1;
% matrix_time_indices = processMatrix(dataMatrix,timestep0,timestep_end,time_step_increment,particle_id);

N_particles = 5
cellArrays_matrices_time_indices = {};
for particle_id = 0:(N_particles-1) % particle id start from 0, loop through particles
    % get row indices for certain particle id at different time steps
    cellArrays_matrices_time_indices{end+1}=processMatrix(dataMatrix,timestep0,timestep_end,time_step_increment,particle_id);
end



cellArrays_matrices_LS_results = {};
for particle_id = 0:(N_particles-1) % particle id start from 0, loop through particles
    %copy for specific particle id
    matrix_time_indices = cellArrays_matrices_time_indices{particle_id+1};
    % get LS results for that particle id at different timesteps
    matrix_LS_results = [];
    particle_id
    starting_step = 5;%<> 
    for i =  starting_step : length(matrix_time_indices(:,1)) % for each particle loop through timesteps
        %disp('time step is:')
        timeStep = matrix_time_indices(i,1);
        extracted_EulerAngles = dataMatrix(matrix_time_indices(i,2):matrix_time_indices(i,3),4:6);
        LS = calculateLSIndex(extracted_EulerAngles,fullFolderPath,particle_id,timeStep);
        newRow = [timeStep, LS, particle_id];
        matrix_LS_results(end+1,:)=newRow;
    end
    disp("final LS is:")
    LS
    cellArrays_matrices_LS_results{end+1}=matrix_LS_results;
end



% Create the figure for LS index with time
figure;

% Customize colors for each loop
colors = lines(N_particles); % Generate a colormap with N_particles distinct colors

% Plot the data
for particle_id = 0:(N_particles-1)
    matrix_LS_results = cellArrays_matrices_LS_results{particle_id + 1};
    
    % Extract the color for this loop
    current_color = colors(particle_id + 1, :);
    
    % Extract the final value of LS index for this particle
    final_LS_value = matrix_LS_results(end, 2); % Assumes the second column contains LS index
    
    % Line and Marker plot
    f1 = plot(matrix_LS_results(:, 1), matrix_LS_results(:, 2), '-o', 'LineWidth', 5, ...
        'MarkerSize', 15, 'MarkerFaceColor', current_color, 'MarkerEdgeColor', current_color, ...
        'Color', current_color, 'DisplayName', ...
        ['id: ', num2str(particle_id), ', final LS: ', num2str(final_LS_value, '%.2f')]);

    hold on;
end

% Display legend for plots with DisplayName
legend('Location', 'northwest');

% Add X and Y axis labels
xlabel('Time step', 'FontSize', 16); % Adjust the label text and fontsize
ylabel('LS index', 'FontSize', 16); % Adjust the label text and fontsize

% Increase the font size of the axis ticks
set(gca, 'FontSize', 16);

% Adjust figure size (Optional: 6x6 inches, you can adjust as per your needs)
set(gcf, 'Position', [100, 100, 500, 500]); % [left, bottom, width, height]
grid on;

% Save the figure as a PDF in the new subfolder
saveas(gcf, fullfile(fullFolderPath, 'LS_index_time.pdf'));

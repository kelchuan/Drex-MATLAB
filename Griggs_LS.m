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
time = linspace(timestep0,timestep_end,timestep_end-timestep0+1);



%% now calculate LS index as a function of time!
time_step_increment = 10;
particle_id = 2;
matrix_time_indices = processMatrix(dataMatrix,timestep0,timestep_end,time_step_increment,particle_id);

matrix_LS_results = [];

for i =  5 : length(matrix_time_indices(:,1))
    disp('time step is:')
    timeStep = matrix_time_indices(i,1)
    LS = calculateLSIndex(dataMatrix(matrix_time_indices(i,2):matrix_time_indices(i,3),4:6))
    newRow = [timeStep, LS];
    matrix_LS_results(end+1,:)=newRow;
end

% Create the figure
figure;

% Plot the data
plot(matrix_LS_results(:,1), matrix_LS_results(:,2), 'ko', 'MarkerSize', 22);

% Add X and Y axis labels
xlabel('Time step', 'FontSize', 16); % Adjust the label text and fontsize
ylabel('LS index', 'FontSize', 16); % Adjust the label text and fontsize

% Increase the font size of the axis ticks
set(gca, 'FontSize', 16);

% Adjust figure size (Optional: 6x6 inches, you can adjust as per your needs)
set(gcf, 'Position', [100, 100, 500, 500]); % [left, bottom, width, height]
grid on;
% Save the plot as a PDF
saveas(gcf, 'LS_index_time.pdf');

% Display the plot

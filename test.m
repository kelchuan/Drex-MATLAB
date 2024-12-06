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

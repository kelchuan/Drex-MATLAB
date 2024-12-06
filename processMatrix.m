function  [matrix_time_indices]= processMatrix(matrix, timeStepStart, timeStepEnd, timeStepIncrement, particleId)
    % This function processes the matrix, looping through time steps with a given
    % increment. For each time step, it finds the rows with matching time and 
    % identifies the starting and ending indices for the specified particle ID.
    %
    % Inputs:
    %   matrix - The input matrix with numerical data (with time in the first column)
    %   timeStepStart - The starting time step
    %   timeStepEnd - The ending time step
    %   timeStepIncrement - The step increment for time steps
    %   particleId - The particle ID to match in the second column
    %
    % Example usage:
    %   processMatrix(A, 1, 10, 10, 3);  % For example, loop time from 1 to 10 with step 10, and particleId = 3
    
    matrix_time_indices = [];
   

    % Loop through the time steps with the given increment
    for timeStep = timeStepStart:timeStepIncrement:timeStepEnd
        % Get the indices for rows with the current time step
        [startIdx, endIdx] = getIndicesByNumber(matrix, timeStep);
        
        if ~isnan(startIdx) && ~isnan(endIdx)
            fprintf('Processing time step: %d\n', timeStep);
            
            % Use the getIndicesByNumber function to find the indices for particleId in the second column
            [startParticleIdx, endParticleIdx] = getIndicesByNumber(matrix(startIdx:endIdx, 2), particleId);
            
            %newRow = [timeStep, startParticleIdx, endParticleIdx];
            newRow = [timeStep, startIdx+startParticleIdx-1, startIdx+endParticleIdx-1];
            matrix_time_indices(end+1,:)=newRow;

            if ~isnan(startParticleIdx) && ~isnan(endParticleIdx)
                fprintf('  Found particle ID %d in time step %d, rows %d to %d\n', particleId, timeStep, startIdx+startParticleIdx-1, startIdx+endParticleIdx-1);
                % Process the data for these indices as needed
            else
                fprintf('  No data found for particle ID %d in time step %d\n', particleId, timeStep);
            end
        else
            fprintf('No data found for time step: %d\n', timeStep);
        end
    end
end
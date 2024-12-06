function [startIdx, endIdx] = getIndicesByNumber(matrix, number)
    % This function finds the starting and ending indices for rows where
    % the first column contains the specified 'number'.
    %
    % Inputs:
    %   matrix - The input matrix with numerical data
    %   number - The number to search for in the first column
    %
    % Outputs:
    %   startIdx - The row index where the first occurrence of the number is found
    %   endIdx - The row index where the last occurrence of the number is found
    
    % Find rows where the first column matches the given number
    matchingRows = find(matrix(:,1) == number);
    
    if isempty(matchingRows)
        % If no matching rows are found, return NaN to indicate no match
        startIdx = NaN;
        endIdx = NaN;
    else
        % Return the first and last indices where the number occurs
        startIdx = matchingRows(1);
        endIdx = matchingRows(end);
    end
end



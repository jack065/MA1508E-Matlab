function showmatrix(matrix)
    % Get matrix dimensions
    [m, n] = size(matrix);
    
    % Display opening bracket
    fprintf('[');
    
    % Iterate through rows
    for i = 1:m
        % Iterate through columns
        for j = 1:n
            % Format the number (handle integer vs decimal)
            if matrix(i,j) == round(matrix(i,j))
                fprintf('%d', matrix(i,j));
            else
                fprintf('%.4f', matrix(i,j));
            end
            
            % Add space between elements except for last column
            if j < n
                fprintf(' ');
            end
        end
        
        % Add semicolon after each row except the last
        if i < m
            fprintf(';');
        end
    end
    
    % Close the matrix
    fprintf(']\n');
end
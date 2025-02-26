function showmatrix(matrix)
    % Get matrix dimensions
    [m, n] = size(matrix);
    
    % Display opening bracket
    fprintf('[');
    
    % Iterate through rows
    for i = 1:m
        % Iterate through columns
        for j = 1:n
            element = matrix(i,j);
            % Check if element is symbolic
            if isa(element, 'sym')
                fprintf('%s', char(element));
            % Handle numeric values
            else
                if element == round(element)
                    fprintf('%d', element);
                else
                    fprintf('%.4f', element);
                end
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
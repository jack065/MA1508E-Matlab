function result = elem(matrix, row1, operation, row2, scalar)
    global matrix_history;
    matrix_history{end+1} = matrix;
    [m, ~] = size(matrix);
    
    % Validate inputs
    if row1 < 1 || row1 > m || row2 < 1 || row2 > m
        error('Invalid row indices. Not within matrix dimensions.');
    end
    
    % Initialize identity matrix for elementary operation
    E = eye(m);
    result = matrix;
    
    % Perform operations and construct elementary matrix
    switch lower(operation)
        case 's'
            E([row1,row2],:) = E([row2,row1],:);
            result([row1,row2],:) = result([row2,row1],:);
        case '+'
            if nargin < 5
                error('Scalar argument is required for addition operation');
            end
            E(row1,row2) = scalar;
            result(row1,:) = result(row1,:) + scalar * result(row2,:);
        case '-'
            if nargin < 5
                error('Scalar argument is required for subtraction operation');
            end
            E(row1,row2) = -scalar;
            result(row1,:) = result(row1,:) - scalar * result(row2,:);
        case '*'
            if nargin < 5
                error('Scalar argument is required for scalar operation');
            end
            E(row1,row1) = scalar;
            result(row1,:) = scalar * result(row1,:);
        otherwise
            error('Invalid operation. Use "s", "+", "-" or "*".');
    end
    
    % Display elementary matrix and its inverse
    fprintf('\nE:                 E^-1:\n');
    fprintf('--                 ----\n');
    
    % Get inverse of elementary matrix
    E_inv = inv(E);
    
    % Display matrices side by side
    for i = 1:m
        % Display row of E
        for j = 1:m
            if isa(E(i,j), 'sym')
                fprintf('%-6s ', char(E(i,j)));
            else
                fprintf('%-6g ', E(i,j));
            end
        end
        
        % Separator between matrices
        fprintf('    ');
        
        % Display row of E^-1
        for j = 1:m
            if isa(E_inv(i,j), 'sym')
                fprintf('%-6s ', char(E_inv(i,j)));
            else
                fprintf('%-6g ', E_inv(i,j));
            end
        end
        fprintf('\n');
    end
    fprintf('\n');
end
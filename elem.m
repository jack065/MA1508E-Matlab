function result = elem(matrix, row1, row2, operation, scalar)
    global matrix_history;
    matrix_history{end+1} = matrix;
    [m, ~] = size(matrix);
    if row1 < 1 || row1 > m || row2 < 1 || row2 > m
        error('Invalid row indices. Not within matrix dimensions.');
    end
    result = matrix;
    switch lower(operation)
        case 'swap'
            result([row1,row2],:) = result([row2,row1],:);
        case '+'
            if nargin < 5
                error('Scalar argument is required for addition operation');
            end
            result(row1,:) = result(row1, :) + scalar * result(row2, :);
        case '-'
            if nargin < 5
                error('Scalar argument is required for subtraction operation');
            end
            result(row1,:) = result(row1, :) - scalar * result(row2, :);
        case '*'
            if nargin < 5
                error('Scalar argument is required for scalar operation');
            end
            result(row1,:) = scalar * result(row1, :);
        otherwise
            error('Invalid operation. Use "swap", "+", "-" or "*".');
    end
end
function inverse(matrix)
    [m, n] = size(matrix);
    if m ~= n
        disp('No inverse found. Matrix must be square.');
        return;
    end
    
    % Check if the matrix is invertible (det != 0)
    if rcond(matrix) < eps
        disp('No inverse found. Matrix is singular.');
        return;
    else 
        result = inv(matrix);
        disp('Inverse of the matrix is:');
        showmatrix(result);
    end
end
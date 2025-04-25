function [rref_augmented, is_unique, projection] = least_square(A, b)
    % LEAST_SQUARE - Computes the least squares solution to Ax = b using RREF
    %
    % Usage:
    %   [rref_augmented, is_unique, projection] = least_square(A, b)
    %
    % Inputs:
    %   A - Coefficient matrix m×n
    %   b - Right-hand side vector m×1
    %
    % Outputs:
    %   rref_augmented - RREF of the augmented matrix [A'A|A'b]
    %   is_unique - Boolean indicating if solution is unique
    %   projection - Projection of b onto column space of A
    %
    % Example:
    %   A = [1 2; 3 4; 5 6];
    %   b = [7; 8; 9];
    %   [rref_aug, unique_flag, proj] = least_square(A, b);
    
    % Check input dimensions
    [m, n] = size(A);
    if size(b, 1) ~= m || size(b, 2) ~= 1
        error('Vector b must have dimensions m×1 where A is m×n');
    end
    
    % Calculate normal equations
    AtA = A' * A;
    Atb = A' * b;
    
    % Solve using RREF of augmented matrix
    aug = [AtA, Atb];
    rref_augmented = rref(aug);
    
    % Compute the rank to determine uniqueness
    rank_A = rank(A);
    is_unique = (rank_A == n);  % Solution is unique if A has full column rank
    
    % Extract a particular solution (for projection calculation)
    x_ls = zeros(n, 1);
    for i = 1:min(rank_A, n)
        % Find pivot position in row i
        pivot_col = find(abs(rref_augmented(i,:)) > 1e-10, 1);
        if pivot_col <= n  % Make sure it's not the RHS column
            % Find the next column with a pivot
            for j = pivot_col:n
                if abs(rref_augmented(i,j)) > 1e-10
                    x_ls(j) = rref_augmented(i, end);
                    break;
                end
            end
        end
    end
    
    % Calculate projection onto column space
    projection = A * x_ls;
    
    % Display results
    fprintf('\nRREF of augmented matrix [A''A | A''b]:\n');
    % Display the matrix with format_exact for numeric values
    for i = 1:size(rref_augmented, 1)
        fprintf('[');
        for j = 1:size(rref_augmented, 2)
            if j > 1
                fprintf(' ');
            end
            fprintf('%s', format_exact(rref_augmented(i,j)));
        end
        fprintf(']\n');
    end
    
    if is_unique
        fprintf('\nThe solution is UNIQUE (A has full column rank).\n');
    else
        fprintf('\nThe solution is NOT UNIQUE (A does not have full column rank).\n');
        fprintf('Use the RREF to determine the general solution in parametric form.\n');
        fprintf('Free variables correspond to columns without pivots.\n');
    end
    
    fprintf('\nProjection of b onto column space of A:\n');
    fprintf('[');
    for i = 1:length(projection)
        if i > 1
            fprintf('; ');
        end
        fprintf('%s', format_exact(projection(i)));
    end
    fprintf(']\n');
    
    % Calculate and display residual
    residual = b - projection;
    residual_norm = norm(residual);
    fprintf('\nResidual vector (b - projection):\n');
    fprintf('[');
    for i = 1:length(residual)
        if i > 1
            fprintf('; ');
        end
        fprintf('%s', format_exact(residual(i)));
    end
    fprintf(']\n');
    
    fprintf('Residual norm ||b - Ax|| = %s\n', format_exact(residual_norm));
    
    % Verify the residual is orthogonal to column space
    orth_check = A' * residual;
    fprintf('\nVerification that residual is orthogonal to column space:\n');
    fprintf('\nVerify that the vector shown below is almost 0.\n');
    fprintf('[');
    for i = 1:length(orth_check)
        if i > 1
            fprintf('; ');
        end
        fprintf('%s', format_exact(orth_check(i)));
    end
    fprintf(']\n');
end
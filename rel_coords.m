function coords = rel_coords(basis, vector, varargin)
    % REL_COORDS - Calculate coordinates of a vector relative to a basis
    %
    % Usage:
    %   coords = rel_coords(basis, vector)
    %   coords = rel_coords(basis, vector, 'norm')
    %
    % Inputs:
    %   basis - Cell array of basis vectors or matrix with basis vectors as columns
    %   vector - Column vector to express in terms of basis
    %   'norm' - Optional flag indicating basis is orthonormal (default: basis is orthogonal)
    %
    % Outputs:
    %   coords - Coordinates of the vector relative to the basis
    
    % Parse inputs
    is_orthonormal = false;
    if nargin > 2 && strcmpi(varargin{1}, 'norm')
        is_orthonormal = true;
    end
    
    % Convert matrix to cell array if needed
    if ~iscell(basis)
        if size(basis, 2) > 1  % Assume columns are basis vectors
            temp_basis = cell(1, size(basis, 2));
            for i = 1:size(basis, 2)
                temp_basis{i} = basis(:, i);
            end
            basis = temp_basis;
        else
            % Single column vector, put it in a cell
            basis = {basis};
        end
    end
    
    % Ensure vector is a column vector
    if size(vector, 2) > size(vector, 1)
        vector = vector';
    end
    
    % Check dimensions
    dim = length(basis{1});
    if length(vector) ~= dim
        error('Vector dimension does not match basis vector dimension');
    end
    
    % Check that all basis vectors have the same dimension
    for i = 2:length(basis)
        if length(basis{i}) ~= dim
            error('All basis vectors must have the same dimension');
        end
    end
    
    % Calculate coordinates
    n = length(basis);
    coords = zeros(n, 1);
    
    for i = 1:n
        if is_orthonormal
            % For orthonormal basis: c_i = v·b_i
            coords(i) = dot(vector, basis{i});
        else
            % For orthogonal basis: c_i = (v·b_i) / (b_i·b_i)
            coords(i) = dot(vector, basis{i}) / dot(basis{i}, basis{i});
        end
    end
    
    % Display the results in exact form where possible
    fprintf('Coordinates relative to the given basis:\n[');
    for i = 1:n
        if i > 1
            fprintf('; ');
        end
        
        % Format the coordinate in exact form
        formatted = format_exact(coords(i));
        fprintf('%s', formatted);
    end
    fprintf(']\n\n');
    
    % Verify result by reconstructing the vector
    reconstructed = zeros(dim, 1);
    for i = 1:n
        reconstructed = reconstructed + coords(i) * basis{i};
    end
    
    % Display the verification
    fprintf('Verification - reconstructing the vector using coordinates:\n');
    fprintf('Original vector: [');
    for i = 1:dim
        if i > 1
            fprintf('; ');
        end
        fprintf('%g', vector(i));
    end
    fprintf(']\n');
    
    fprintf('Reconstructed: [');
    for i = 1:dim
        if i > 1
            fprintf('; ');
        end
        fprintf('%g', reconstructed(i));
    end
    fprintf(']\n');
    
    % Check reconstruction accuracy
    error_norm = norm(vector - reconstructed);
    fprintf('Reconstruction error: %g\n', error_norm);
    
    if error_norm < 1e-10
        fprintf('Success! The coordinates correctly represent the vector.\n');
    else
        fprintf('Warning: Significant reconstruction error. Check if basis is valid.\n');
    end
end

function formatted = format_exact(val)
    % Enhanced function to format a number in exact form
    % Provides more sophisticated formatting similar to gram_schmidt.m
    
    tolerance = 1e-9;
    
    % Check for zero
    if abs(val) < tolerance
        formatted = '0';
        return;
    end
    
    % Try rational approximation first
    [n, d] = rat(val, tolerance);
    
    % Check if the approximation is good enough
    if abs(val - n/d) < tolerance * max(1, abs(val))
        if d == 1
            % It's an integer
            formatted = sprintf('%d', n);
            return;
        elseif d > 0 && d <= 1000
            % It's a simple fraction
            formatted = sprintf('%d/%d', n, d);
            return;
        end
    end
    
    % Check for square roots
    % First, try to find if val = a/√b or a*√b/c
    common_surds = [2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15];
    
    % Check for patterns like a/√b
    for num = 1:10
        for surd = common_surds
            % Check val ≈ num/√surd
            if abs(val - num/sqrt(surd)) < tolerance
                formatted = sprintf('%d/√%d', num, surd);
                return;
            end
            % Check val ≈ -num/√surd
            if abs(val + num/sqrt(surd)) < tolerance
                formatted = sprintf('-%d/√%d', num, surd);
                return;
            end
            % Check val ≈ √surd/num
            if abs(val - sqrt(surd)/num) < tolerance
                formatted = sprintf('√%d/%d', surd, num);
                return;
            end
            % Check val ≈ -√surd/num
            if abs(val + sqrt(surd)/num) < tolerance
                formatted = sprintf('-√%d/%d', surd, num);
                return;
            end
        end
    end
    
    % Try to express as a/b * √c
    for num = 1:20
        for denom = 1:20
            for surd = common_surds
                test_val = (num/denom) * sqrt(surd);
                if abs(val - test_val) < tolerance
                    if denom == 1
                        formatted = sprintf('%d√%d', num, surd);
                    else
                        formatted = sprintf('%d√%d/%d', num, surd, denom);
                    end
                    return;
                end
                if abs(val + test_val) < tolerance
                    if denom == 1
                        formatted = sprintf('-%d√%d', num, surd);
                    else
                        formatted = sprintf('-%d√%d/%d', num, surd, denom);
                    end
                    return;
                end
            end
        end
    end
    
    % Try to detect if it's √(a/b)
    for num = 1:100
        for denom = 1:100
            if abs(val^2 - num/denom) < tolerance
                if denom == 1
                    formatted = sprintf('√%d', num);
                else
                    formatted = sprintf('√(%d/%d)', num, denom);
                end
                return;
            end
            if abs(val^2 + num/denom) < tolerance
                if denom == 1
                    formatted = sprintf('-√%d', num);
                else
                    formatted = sprintf('-√(%d/%d)', num, denom);
                end
                return;
            end
        end
    end
    
    % If all else fails, return as a decimal
    formatted = sprintf('%g', val);
end
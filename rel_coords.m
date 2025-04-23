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
    %
    % Example:
    %   % With orthogonal basis
    %   B = {[2;0;0], [0;3;0], [0;0;4]};
    %   v = [4;6;8];
    %   rel_coords(B, v)
    %
    %   % With orthonormal basis
    %   B_norm = {[1;0;0], [0;1;0], [0;0;1]};
    %   rel_coords(B_norm, v, 'norm')
    
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
        
        % Try to detect and format exact forms
        [formatted, success] = format_exact(coords(i));
        if success
            fprintf('%s', formatted);
        else
            fprintf('%g', coords(i));
        end
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

function [formatted, success] = format_exact(val)
    % Try to format a number in exact form with surds
    success = false;
    formatted = '';
    
    % First try to see if it's a simple fraction
    [n, d] = rat(val, 1e-10);
    
    if d == 1
        % It's just an integer
        formatted = sprintf('%d', n);
        success = true;
        return;
    elseif d > 0 && d <= 1000
        % It's a simple fraction
        formatted = sprintf('%d/%d', n, d);
        success = true;
        return;
    end
    
    % Check for common surds like 1/√2, 1/√3, etc.
    common_surds = [2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15];
    
    % Check for patterns like 1/√n
    for surd = common_surds
        % Check if val is close to 1/sqrt(surd)
        if abs(val - 1/sqrt(surd)) < 1e-10
            formatted = sprintf('1/√%d', surd);
            success = true;
            return;
        end
        
        % Check if val is close to -1/sqrt(surd)
        if abs(val + 1/sqrt(surd)) < 1e-10
            formatted = sprintf('-1/√%d', surd);
            success = true;
            return;
        end
        
        % Check for patterns like a/√n
        for num = 2:10
            if abs(val - num/sqrt(surd)) < 1e-10
                formatted = sprintf('%d/√%d', num, surd);
                success = true;
                return;
            end
            
            if abs(val + num/sqrt(surd)) < 1e-10
                formatted = sprintf('-%d/√%d', num, surd);
                success = true;
                return;
            end
        end
        
        % Check for patterns like √n/b
        for denom = 2:10
            if abs(val - sqrt(surd)/denom) < 1e-10
                formatted = sprintf('√%d/%d', surd, denom);
                success = true;
                return;
            end
            
            if abs(val + sqrt(surd)/denom) < 1e-10
                formatted = sprintf('-√%d/%d', surd, denom);
                success = true;
                return;
            end
        end
    end
end
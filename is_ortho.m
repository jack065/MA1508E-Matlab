function [is_orthogonal, is_orthonormal, orthonormal_set] = is_ortho(varargin)
    % IS_ORTHO - Check if vectors form orthogonal/orthonormal set and normalize them
    %
    % Usage:
    %   [is_orthogonal, is_orthonormal, orthonormal_set] = is_ortho(v1, v2, ...)
    %   [is_orthogonal, is_orthonormal, orthonormal_set] = is_ortho({v1, v2, ...})
    %
    % Inputs:
    %   v1, v2, ... - Column vectors to check
    %   OR
    %   {v1, v2, ...} - Cell array of column vectors
    %
    % Outputs:
    %   is_orthogonal - Boolean indicating if vectors are orthogonal
    %   is_orthonormal - Boolean indicating if vectors are orthonormal
    %   orthonormal_set - Cell array of normalized vectors
    %
    % Example:
    %   [isOrtho, isOrthoNormal, normSet] = is_ortho([1;0;0], [0;1;0], [0;0;1])
    
    % Handle different input formats
    if nargin == 1 && iscell(varargin{1})
        vectors = varargin{1};
    else
        vectors = varargin;
    end
    
    % Convert any row vectors to column vectors
    for i = 1:length(vectors)
        if size(vectors{i}, 2) > size(vectors{i}, 1)
            vectors{i} = vectors{i}.';
        end
    end
    
    % Check vector dimensions
    n_vectors = length(vectors);
    if n_vectors < 2
        fprintf('Need at least 2 vectors to check orthogonality.\n');
        is_orthogonal = true;  % Single vector is trivially orthogonal
        is_orthonormal = (norm(vectors{1}) == 1);
        orthonormal_set = {vectors{1}/norm(vectors{1})};
        return;
    end
    
    % Verify all vectors have the same dimension
    dim = length(vectors{1});
    for i = 2:n_vectors
        if length(vectors{i}) ~= dim
            error('All vectors must have the same dimension.');
        end
    end
    
    % Check orthogonality
    is_orthogonal = true;
    tol = 1e-10;  % Tolerance for floating-point comparisons
    
    fprintf('Checking orthogonality...\n');
    for i = 1:n_vectors
        for j = i+1:n_vectors
            dot_product = dot(vectors{i}, vectors{j});
            if abs(dot_product) > tol
                fprintf('Vectors %d and %d are not orthogonal: dot product = %g\n', i, j, dot_product);
                is_orthogonal = false;
            end
        end
    end
    
    if is_orthogonal
        fprintf('The set is orthogonal!\n');
    else
        fprintf('The set is not orthogonal.\n');
    end
    
    % Check if vectors are unit length (for orthonormality)
    is_orthonormal = is_orthogonal;
    orthonormal_set = cell(size(vectors));
    
    fprintf('\nChecking vector norms...\n');
    for i = 1:n_vectors
        vector_norm = norm(vectors{i});
        fprintf('Vector %d norm = %g\n', i, vector_norm);
        
        if abs(vector_norm - 1) > tol
            is_orthonormal = false;
        end
        
        % Create normalized vector for output
        orthonormal_set{i} = vectors{i} / vector_norm;
    end
    
    if is_orthonormal
        fprintf('The set is orthonormal!\n');
    else
        fprintf('The set is not orthonormal.\n');
    end
    
    % Display normalized vectors
    fprintf('\nOrthonormal set:\n');
    for i = 1:n_vectors
        fprintf('Vector %d: [', i);
        for j = 1:length(orthonormal_set{i})
            if j > 1
                fprintf('; ');
            end
            fprintf('%g', orthonormal_set{i}(j));
        end
        fprintf(']\n');
    end
end
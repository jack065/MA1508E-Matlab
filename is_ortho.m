function is_ortho(varargin)
    % IS_ORTHO - Check if vectors form orthogonal/orthonormal set and normalize them
    %
    % Usage:
    %   is_ortho(v1, v2, ...)
    %   is_ortho({v1, v2, ...})
    %
    % Inputs:
    %   v1, v2, ... - Column vectors to check
    %   OR
    %   {v1, v2, ...} - Cell array of column vectors
    %
    % Example:
    %   is_ortho([1;0;0], [0;1;0], [0;0;1])
    
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
    
    fprintf('\nChecking vector norms...\n');
    for i = 1:n_vectors
        vector_norm = norm(vectors{i});
        fprintf('Vector %d norm = %g\n', i, vector_norm);
        
        if abs(vector_norm - 1) > tol
            is_orthonormal = false;
        end
    end
    
    if is_orthonormal
        fprintf('The set is orthonormal!\n');
    else
        fprintf('The set is not orthonormal.\n');
    end
    
    % Display normalized vectors with exact forms
    fprintf('\nOrthonormal set:\n');
    for i = 1:n_vectors
        % Calculate vector norm
        vector_norm = norm(vectors{i});
        
        % Display as 1/√(norm^2) × [original vector]
        fprintf('Vector %d: 1/√%d × [', i, round(vector_norm^2));
        
        % Print the original vector entries
        for j = 1:length(vectors{i})
            if j > 1
                fprintf('; ');
            end
            if vectors{i}(j) == round(vectors{i}(j))
                fprintf('%d', vectors{i}(j));
            else
                fprintf('%g', vectors{i}(j));
            end
        end
        fprintf(']\n');
    end
end
function [orthonormal_basis, orthogonal_basis] = gram_schmidt(varargin)
    % GRAM_SCHMIDT - Convert vectors into an orthonormal basis using Gram-Schmidt process
    %
    % Usage:
    %   [orthonormal_basis, orthogonal_basis] = gram_schmidt(v1, v2, ...)
    %   [orthonormal_basis, orthogonal_basis] = gram_schmidt({v1, v2, ...})
    %
    % Inputs:
    %   v1, v2, ... - Column vectors to orthogonalize
    %   OR
    %   {v1, v2, ...} - Cell array of column vectors
    %
    % Outputs:
    %   orthonormal_basis - Cell array of orthonormal vectors
    %   orthogonal_basis - Cell array of orthogonal vectors (before normalization)
    %
    % Example:
    %   % Create an orthonormal basis from standard vectors
    %   [ONB, OB] = gram_schmidt([1;1;0], [1;0;1], [0;1;1])
    
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
    if n_vectors < 1
        error('Need at least 1 vector for Gram-Schmidt process.');
    end
    
    % Verify all vectors have the same dimension
    dim = length(vectors{1});
    for i = 2:n_vectors
        if length(vectors{i}) ~= dim
            error('All vectors must have the same dimension.');
        end
    end
    
    % Initialize output arrays
    orthogonal_basis = cell(1, n_vectors);
    orthonormal_basis = cell(1, n_vectors);
    
    % Apply Gram-Schmidt process
    fprintf('Applying Gram-Schmidt process...\n\n');
    
    for i = 1:n_vectors
        % Start with the original vector
        u_i = vectors{i};
        
        % Display original vector
        fprintf('Vector %d: [', i);
        for j = 1:length(vectors{i})
            if j > 1
                fprintf('; ');
            end
            fprintf('%g', vectors{i}(j));
        end
        fprintf(']\n');
        
        % Subtract projections onto previous orthogonal vectors
        for j = 1:i-1
            proj = (dot(vectors{i}, orthogonal_basis{j}) / dot(orthogonal_basis{j}, orthogonal_basis{j})) * orthogonal_basis{j};
            u_i = u_i - proj;
            
            % Display projection step
            fprintf('  Subtracting projection onto u%d:\n', j);
            fprintf('  proj = (v%d·u%d / u%d·u%d) × u%d = [', i, j, j, j, j);
            for k = 1:length(proj)
                if k > 1
                    fprintf('; ');
                end
                fprintf('%g', proj(k));
            end
            fprintf(']\n');
        end
        
        % Store the orthogonal vector
        orthogonal_basis{i} = u_i;
        
        % Check for linear dependence
        if norm(u_i) < 1e-10
            fprintf('Warning: Vector %d is linearly dependent on previous vectors. Using zero vector.\n', i);
            orthogonal_basis{i} = zeros(dim, 1);
            orthonormal_basis{i} = zeros(dim, 1);
            continue;
        end
        
        % Normalize to get orthonormal vector
        orthonormal_basis{i} = u_i / norm(u_i);
        
        % Display orthogonal vector
        fprintf('  u%d = [', i);
        for j = 1:length(u_i)
            if j > 1
                fprintf('; ');
            end
            fprintf('%g', u_i(j));
        end
        fprintf(']\n');
        
        % Display normalized vector
        fprintf('  e%d = [', i);
        for j = 1:length(orthonormal_basis{i})
            if j > 1
                fprintf('; ');
            end
            fprintf('%g', orthonormal_basis{i}(j));
        end
        fprintf(']\n\n');
    end
    
    % Verify orthogonality
    fprintf('Verifying orthogonality of the basis:\n');
    is_orthogonal = true;
    
    for i = 1:n_vectors
        for j = i+1:n_vectors
            dot_product = dot(orthogonal_basis{i}, orthogonal_basis{j});
            fprintf('  u%d·u%d = %g\n', i, j, dot_product);
            
            if abs(dot_product) > 1e-10
                is_orthogonal = false;
            end
        end
    end
    
    if is_orthogonal
        fprintf('\nSuccess! The basis is orthogonal.\n');
    else
        fprintf('\nWarning: The basis is not perfectly orthogonal due to numerical precision.\n');
    end
    
    % Verify orthonormality
    fprintf('\nVerifying orthonormality of the basis:\n');
    is_orthonormal = true;
    
    for i = 1:n_vectors
        for j = 1:n_vectors
            if i == j
                norm_value = dot(orthonormal_basis{i}, orthonormal_basis{i});
                fprintf('  e%d·e%d = %g\n', i, i, norm_value);
                
                if abs(norm_value - 1) > 1e-10
                    is_orthonormal = false;
                end
            else
                dot_product = dot(orthonormal_basis{i}, orthonormal_basis{j});
                fprintf('  e%d·e%d = %g\n', i, j, dot_product);
                
                if abs(dot_product) > 1e-10
                    is_orthonormal = false;
                end
            end
        end
    end
    
    if is_orthonormal
        fprintf('\nSuccess! The basis is orthonormal.\n');
    else
        fprintf('\nWarning: The basis is not perfectly orthonormal due to numerical precision.\n');
    end
    
    % Return the orthonormal basis as column vectors
    fprintf('\nOrthonormal basis vectors:\n');
    for i = 1:n_vectors
        fprintf('e%d = [', i);
        for j = 1:length(orthonormal_basis{i})
            if j > 1
                fprintf('; ');
            end
            fprintf('%g', orthonormal_basis{i}(j));
        end
        fprintf(']\n');
    end
end
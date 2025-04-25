function basis_vectors = identify_basis(input_data, varargin)
    % IDENTIFY_BASIS - Find basis vectors for a vector space
    %
    % Usage:
    %   basis_vectors = identify_basis(param_vector)
    %   basis_vectors = identify_basis(vars, constraints)
    %   basis_vectors = identify_basis({v1, v2, ..., vn})
    %
    % Inputs:
    %   param_vector - Parametric representation of vector space [a+b; a+c; ...]
    %   vars - Column vector of symbolic variables [a; b; c; d; ...]
    %   constraints - Cell array of symbolic equations {a+b==c, d==0, ...}
    %   {v1, v2, ..., vn} - Cell array of column vectors that span the space
    %
    % Output:
    %   basis_vectors - Matrix whose columns are the basis vectors
    
    if nargin == 1
        if iscell(input_data)
            % Case: identify_basis({v1, v2, ..., vn})
            % Handle span of explicit vectors
            vectors = input_data;
            basis_vectors = find_basis_from_span(vectors);
        else
            % Case: identify_basis(param_vector)
            % Handle parametric vector with implicit real number constraints
            param_vector = input_data;
            basis_vectors = find_basis_from_parametric(param_vector);
        end
    elseif nargin == 2
        % Case: identify_basis(vars, constraints)
        % Handle symbolic variables with explicit constraints
        vars = input_data;
        constraints = varargin{1};
        basis_vectors = find_basis_from_constraints(vars, constraints);
    else
        error('Invalid number of inputs');
    end
end

function basis = find_basis_from_span(vectors)
    % Convert cell array of vectors to matrix
    n_vectors = length(vectors);
    if n_vectors == 0
        basis = [];
        return;
    end
    
    % Get dimension of vectors
    dim = length(vectors{1});
    
    % Create matrix with vectors as columns
    A = zeros(dim, n_vectors);
    for i = 1:n_vectors
        A(:,i) = vectors{i};
    end
    
    % Find basis using rank-revealing QR factorization
    [~, R, E] = qr(A, 0);
    r = sum(abs(diag(R)) > eps(norm(A,'fro'))*max(size(A)));
    
    % Extract linearly independent columns
    basis = A(:, E(1:r));
    
    % Display results
    fprintf('\nOriginal vectors:\n');
    for i = 1:n_vectors
        fprintf('v%d = [', i);
        for j = 1:length(vectors{i})
            % Use format_exact for vector components
            if isnumeric(vectors{i}(j))
                fprintf('%s', format_exact(vectors{i}(j)));
            else
                fprintf('%.4g', vectors{i}(j));
            end
            if j < length(vectors{i})
                fprintf('; ');
            end
        end
        fprintf(']\n');
    end
    
    fprintf('\nBasis for the vector space:\n');
    for i = 1:size(basis, 2)
        fprintf('b%d = [', i);
        for j = 1:size(basis, 1)
            % Use format_exact for basis vector components
            if isnumeric(basis(j,i))
                fprintf('%s', format_exact(basis(j,i)));
            else
                fprintf('%.4g', basis(j,i));
            end
            if j < size(basis, 1)
                fprintf('; ');
            end
        end
        fprintf(']\n');
    end
    
    fprintf('\nDimension of the vector space: %d\n', size(basis, 2));
end

function basis = find_basis_from_parametric(param_vector)
    % Extract symbolic variables from parametric vector
    vars = symvar(param_vector);
    n_vars = length(vars);
    
    % Create coefficient matrix where rows are the coefficients of each parameter
    A = sym(zeros(length(param_vector), n_vars));
    
    for i = 1:length(param_vector)
        for j = 1:n_vars
            A(i,j) = diff(param_vector(i), vars(j));
        end
    end
    
    % Display the coefficient matrix
    fprintf('Coefficient matrix A:\n');
    disp(A);
    
    % Use RREF to find basis vectors
    try
        A_double = double(A);
        [rref_A, pivot_cols] = rref(A_double, eps);
        
        % Create basis directly from standard basis vectors
        basis = zeros(size(A, 1), length(pivot_cols));
        for i = 1:length(pivot_cols)
            col = pivot_cols(i);
            basis(:, i) = A_double(:, col);
        end
    catch
        fprintf('Using symbolic calculations...\n');
        [rref_A, pivot_cols] = rref(A);
        
        % Create basis directly from standard basis vectors
        basis = sym(zeros(size(A, 1), length(pivot_cols)));
        for i = 1:length(pivot_cols)
            col = pivot_cols(i);
            basis(:, i) = A(:, col);
        end
    end
    
    % Display results
    fprintf('\nBasis vectors for the vector space:\n');
    for i = 1:size(basis, 2)
        fprintf('v%d = [', i);
        for j = 1:size(basis, 1)
            if isa(basis(j,i), 'sym')
                fprintf('%s', char(basis(j,i)));
            else
                % Use format_exact for numeric values
                fprintf('%s', format_exact(basis(j,i)));
            end
            if j < size(basis, 1)
                fprintf('; ');
            end
        end
        fprintf(']\n');
    end
    
    fprintf('\nDimension of the vector space: %d\n', size(basis, 2));
end

function basis = find_basis_from_constraints(vars, constraints)
    % Number of variables
    n = length(vars);
    
    % Create coefficient matrix for the constraints
    A = sym(zeros(length(constraints), n));
    
    % Process each constraint
    for i = 1:length(constraints)
        % Get left and right sides of equation
        eq = constraints{i};
        left_side = lhs(eq);
        right_side = rhs(eq);
        
        % Move everything to left side: left_side - right_side = 0
        expr = left_side - right_side;
        
        % Extract coefficients for each variable
        for j = 1:n
            A(i,j) = diff(expr, vars(j));
        end
    end
    
    % Display the coefficient matrix
    fprintf('Constraint coefficient matrix A:\n');
    disp(A);
    
    % Convert to double for null space calculation if possible
    try
        A_double = double(A);
        N = null(A_double);
    catch
        fprintf('Using symbolic null space calculation...\n');
        N = null(A);
    end
    
    % Display results
    fprintf('\nBasis vectors for the vector space:\n');
    for i = 1:size(N, 2)
        fprintf('v%d = [', i);
        for j = 1:n
            if isa(N(j,i), 'sym')
                fprintf('%s', char(N(j,i)));
            else
                fprintf('%.4g', N(j,i));
            end
            if j < n
                fprintf('; ');
            end
        end
        fprintf(']\n');
    end
    
    fprintf('\nDimension of the vector space: %d\n', size(N, 2));
    basis = N;
end

function str = format_exact(value)
    % FORMAT_EXACT - Format numeric values exactly
    %
    % Inputs:
    %   value - Numeric value to format
    %
    % Outputs:
    %   str - Formatted string representation of the value
    
    if abs(value) < 1e-10
        str = '0';
    else
        str = sprintf('%.10g', value);
    end
end
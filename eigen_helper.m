function [V_final, lambda_final, isGeneralized_final] = eigen_helper(A)
%EIGEN_HELPER Computes eigenvalues, regular eigenvectors, and generalized eigenvectors.
%   [V, lambda, isGeneralized] = eigen_helper(A) computes eigenvalues,
%   regular eigenvectors, and generalized eigenvectors for the square matrix A.
%
%   Input:
%       A : A square numeric matrix.
%
%   Outputs:
%       V_final : A matrix whose columns form a basis of eigenvectors and
%                 generalized eigenvectors.
%       lambda_final : A column vector containing the eigenvalues corresponding
%                      to the columns of V_final.
%       isGeneralized_final : A logical row vector where the k-th element is
%                             true if the k-th column of V_final is a generalized
%                             eigenvector, and false otherwise.

    if ~ismatrix(A) || size(A,1) ~= size(A,2)
        error('Input must be a square matrix.');
    end
    if ~isnumeric(A)
        error('Input matrix must be numeric.');
    end

    n = size(A, 1);
    symA = sym(A);
    I = eye(n);

    % Step 1: Find eigenvalues and their algebraic multiplicities
    % Use the characteristic polynomial method which is more reliable for
    % determining correct multiplicities
    syms lambda
    charPoly = det(symA - lambda*I);
    charPoly = expand(collect(charPoly, lambda));
    
    % Find roots of characteristic polynomial
    evals = solve(charPoly == 0, lambda);
    
    % Convert to column vector if not already
    if ~iscolumn(evals)
        evals = evals(:);
    end
    
    % Find unique eigenvalues and their multiplicities, handling complex values
    evals_double = double(evals);
    unique_evals = [];
    algebraic_mults = [];

    % Process each eigenvalue and group them based on numerical proximity
    for i = 1:length(evals)
        current_eval = evals(i);
        current_eval_double = evals_double(i);
        
        % Check if this eigenvalue is already in our list
        found = false;
        for j = 1:length(unique_evals)
            % For complex numbers, need to compare both real and imaginary parts
            if abs(current_eval_double - double(unique_evals(j))) < 1e-10
                algebraic_mults(j) = algebraic_mults(j) + 1;
                found = true;
                break;
            end
        end
        
        % If not found, add it as a new unique eigenvalue
        if ~found
            unique_evals = [unique_evals; current_eval];
            algebraic_mults = [algebraic_mults; 1];
        end
    end
    
    % Initialize output arrays
    V_final = sym(zeros(n, n));
    lambda_final = sym(zeros(n, 1));
    isGeneralized_final = false(1, n);
    col_idx = 1;
    
    % Step 2: For each eigenvalue, compute eigenvectors and generalized eigenvectors
    for i = 1:length(unique_evals)
        lambda_i = unique_evals(i);
        am_i = algebraic_mults(i);
        
        % Find regular eigenvectors (null space of A - λI)
        N_lambda = symA - lambda_i*I;
        eigenvectors = null(N_lambda);
        
        % Determine geometric multiplicity
        gm_i = size(eigenvectors, 2);
        
        % Add regular eigenvectors to output
        if gm_i > 0
            V_final(:, col_idx:(col_idx + gm_i - 1)) = eigenvectors;
            lambda_final(col_idx:(col_idx + gm_i - 1)) = lambda_i;
            col_idx = col_idx + gm_i;
        end
        
        % If algebraic multiplicity > geometric multiplicity, find generalized eigenvectors
        if am_i > gm_i
            % Compute null space of (A - λI)²
            N_lambda_squared = N_lambda^2;
            null_squared = null(N_lambda_squared);
            
            % Maximum number of generalized eigenvectors needed
            num_gen_needed = am_i - gm_i;
            gen_found = 0;
            
            for j = 1:size(null_squared, 2)
                v = null_squared(:, j);
                
                % Test if v is a generalized eigenvector: (A-λI)v ≠ 0
                result = N_lambda * v;
                
                % If result isn't zero and v isn't in the span of already found eigenvectors
                if norm(double(result)) > 1e-10
                    % Check linear independence - form a matrix of [eigenvectors, found_gen_vecs, v]
                    if gen_found == 0
                        test_matrix = [eigenvectors, v];
                    else
                        test_matrix = [eigenvectors, V_final(:, (col_idx-gen_found):(col_idx-1)), v];
                    end
                    
                    % If rank increases, this is a linearly independent vector
                    if rank(double(test_matrix)) > rank(double(test_matrix(:, 1:end-1)))
                        gen_found = gen_found + 1;
                        V_final(:, col_idx) = v;
                        lambda_final(col_idx) = lambda_i;
                        isGeneralized_final(col_idx) = true;
                        col_idx = col_idx + 1;
                        
                        if gen_found == num_gen_needed
                            break;
                        end
                    end
                end
            end
            
            if gen_found < num_gen_needed
                warning('Only found %d of %d needed generalized eigenvectors for eigenvalue %s', ...
                       gen_found, num_gen_needed, char(lambda_i));
            end
        end
    end
    
    % Trim any unused columns
    if col_idx <= n
        V_final = V_final(:, 1:(col_idx-1));
        lambda_final = lambda_final(1:(col_idx-1));
        isGeneralized_final = isGeneralized_final(1:(col_idx-1));
    end

    % Display which columns are regular vs. generalized eigenvectors
    fprintf('\nEIGENVECTOR CLASSIFICATION:\n');
    fprintf('---------------------------\n');
    
    % Display regular eigenvectors
    reg_indices = find(~isGeneralized_final);
    if ~isempty(reg_indices)
        fprintf('Regular eigenvectors: columns %s\n', mat2str(reg_indices));
        
        % Display eigenvalues for regular eigenvectors
        fprintf('Corresponding eigenvalues: ');
        for i = 1:length(reg_indices)
            if i > 1
                fprintf(', ');
            end
            % Format the eigenvalue, handling complex values properly
            format_complex_eigenvalue(lambda_final(reg_indices(i)));
        end
        fprintf('\n');
    else
        fprintf('No regular eigenvectors found.\n');
    end
    
    % Display generalized eigenvectors
    if any(isGeneralized_final)
        gen_indices = find(isGeneralized_final);
        fprintf('Generalized eigenvectors: columns %s\n', mat2str(gen_indices));
        
        % Display eigenvalues for generalized eigenvectors
        fprintf('Corresponding eigenvalues: ');
        for i = 1:length(gen_indices)
            if i > 1
                fprintf(', ');
            end
            % Format the eigenvalue, handling complex values properly
            format_complex_eigenvalue(lambda_final(gen_indices(i)));
        end
        fprintf('\n');
        
        % For each generalized eigenvector, show its relationship with regular eigenvector
        for i = 1:length(gen_indices)
            gen_idx = gen_indices(i);
            lambda_i = lambda_final(gen_idx);
            gen_vec = V_final(:, gen_idx);
            
            % Find regular eigenvectors with same eigenvalue
            same_lambda_reg = find(lambda_final == lambda_i & ~isGeneralized_final);
            if ~isempty(same_lambda_reg)
                reg_idx = same_lambda_reg(1);
                result = (symA - lambda_i*I) * gen_vec;
                
                fprintf('Column %d is a generalized eigenvector of column %d (λ = ', gen_idx, reg_idx);
                format_complex_eigenvalue(lambda_i);
                fprintf(')\n');
                
                % Display the equation and computed value
                fprintf('Demonstration: (A - λI)v₂ = v₁\n');
                fprintf('Where:\n');
                fprintf('- λ = ');
                format_complex_eigenvalue(lambda_i);
                fprintf('\n- v₂ = Column %d = ', gen_idx);
                display_vector(gen_vec);
                fprintf('\n\nComputed (A - λI)v₂:\n');
                display_vector(result);
                
                % Calculate the comparison with regular eigenvector
                reg_vec = V_final(:, reg_idx);
                fprintf('\nRegular eigenvector (Column %d):\n', reg_idx);
                display_vector(reg_vec);
                
                % Check if result is proportional to the regular eigenvector
                if norm(double(result)) > 1e-10
                    % Find scalar multiple
                    nonzero_idx = find(abs(double(reg_vec)) > 1e-10, 1);
                    if ~isempty(nonzero_idx)
                        scalar = result(nonzero_idx) / reg_vec(nonzero_idx);
                        fprintf('\nThe result is %s times the regular eigenvector\n', format_exact(scalar));
                        
                        % Calculate and display the actual generalized eigenvector
                        scaled_vec = gen_vec / scalar;
                        fprintf('\nActual generalized eigenvector (after normalization):\n');
                        display_vector(scaled_vec);
                        fprintf('\n\n');
                        
                        % Update V_final with the normalized generalized eigenvector
                        V_final(:, gen_idx) = scaled_vec;
                    end
                end
            end
        end
    else
        fprintf('No generalized eigenvectors needed - matrix is not defective.\n');
    end
end

function format_complex_eigenvalue(lambda_val)
    % Helper function to format complex eigenvalues correctly
    try
        % Convert to numeric for formatting
        numeric_lambda = double(lambda_val);
        
        % Check if it's a complex number
        if ~isreal(numeric_lambda)
            % Format complex number in a + bi form
            real_part = real(numeric_lambda);
            imag_part = imag(numeric_lambda);
            
            % Format real and imaginary parts using format_exact when possible
            if abs(real_part) > 1e-10
                real_str = format_exact(real_part);
                if abs(imag_part) > 1e-10
                    imag_str = format_exact(abs(imag_part));
                    if imag_part > 0
                        fprintf('%s + %si', real_str, imag_str);
                    else
                        fprintf('%s - %si', real_str, imag_str);
                    end
                else
                    fprintf('%s', real_str);
                end
            else
                % Only imaginary part
                if abs(imag_part) > 1e-10
                    imag_str = format_exact(abs(imag_part));
                    if imag_part > 0
                        fprintf('%si', imag_str);
                    else
                        fprintf('-%si', imag_str);
                    end
                else
                    fprintf('0'); % Both parts are zero
                end
            end
        else
            % Real number, use the standard format_exact
            fprintf('%s', format_exact(numeric_lambda));
        end
    catch
        % Fall back to symbolic display if numeric conversion fails
        fprintf('%s', char(lambda_val));
    end
end

function display_vector(vec)
    % Helper function to display a vector in column format
    fprintf('[');
    for i = 1:length(vec)
        if i > 1
            fprintf('\n ');
        end
        if isreal(vec(i))
            fprintf('%s', format_exact(vec(i)));
        else
            % Handle complex numbers
            real_part = real(vec(i));
            imag_part = imag(vec(i));
            
            if abs(real_part) > 1e-10
                real_str = format_exact(real_part);
                if abs(imag_part) > 1e-10
                    imag_str = format_exact(abs(imag_part));
                    if imag_part > 0
                        fprintf('%s + %si', real_str, imag_str);
                    else
                        fprintf('%s - %si', real_str, imag_str);
                    end
                else
                    fprintf('%s', real_str);
                end
            else
                % Only imaginary part
                if abs(imag_part) > 1e-10
                    imag_str = format_exact(abs(imag_part));
                    if imag_part > 0
                        fprintf('%si', imag_str);
                    else
                        fprintf('-%si', imag_str);
                    end
                else
                    fprintf('0'); % Both parts are zero
                end
            end
        end
    end
    fprintf(']');
end
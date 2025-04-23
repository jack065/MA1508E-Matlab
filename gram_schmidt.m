function gram_schmidt(N)
    % GRAM_SCHMIDT - Convert columns of a matrix into an orthonormal basis using Gram-Schmidt process (via QR decomposition)
    %
    % Usage:
    %   gram_schmidt(N)
    %
    % Inputs:
    %   N - Matrix where columns are the vectors to orthogonalize
    %
    % Example:
    %   % Create an orthonormal basis from the columns of a matrix
    %   A = [1 1 0; 1 0 1; 0 1 1];
    %   gram_schmidt(A)

    % Validate input
    if ~ismatrix(N) || isempty(N)
        error('Input must be a non-empty matrix.');
    end
    if ~isnumeric(N)
        error('Input matrix must be numeric.');
    end

    % Get dimensions
    [dim, n_vectors] = size(N);

    if n_vectors < 1
        error('Input matrix must have at least one column.');
    end

    % Initialize output arrays
    orthogonal_basis = cell(1, n_vectors);
    orthonormal_basis = cell(1, n_vectors);

    % --- Use QR decomposition for Gram-Schmidt ---
    fprintf('Applying Gram-Schmidt process via QR decomposition...\n\n');

    % Perform economy-size QR decomposition directly on the input matrix N
    [Q, R] = qr(N, 0);

    % The columns of Q form the orthonormal basis
    % The orthogonal basis can be derived from Q and R
    % Note: If the original vectors (columns of N) are linearly dependent,
    % the corresponding diagonal elements in R might be zero or near zero.
    % Q will still form an orthonormal basis for the column space of N.

    for i = 1:size(Q, 2) % Use size(Q, 2) in case of linear dependence
        orthonormal_basis{i} = Q(:, i);

        % Calculate the corresponding orthogonal vector u_i = Q(:,i) * R(i,i)
        % Handle potential zero diagonal elements in R for dependent vectors
        if abs(R(i, i)) > 1e-10
             orthogonal_basis{i} = Q(:, i) * R(i, i);
        else
             orthogonal_basis{i} = zeros(dim, 1); % Treat as zero vector if dependent
             % Also set the corresponding orthonormal vector to zero for consistency
             orthonormal_basis{i} = zeros(dim, 1);
        end
    end

    % Fill remaining cells if original vectors were linearly dependent
    % and qr produced fewer columns in Q than original vectors
    for i = (size(Q, 2) + 1):n_vectors
        orthogonal_basis{i} = zeros(dim, 1);
        orthonormal_basis{i} = zeros(dim, 1);
        fprintf('Warning: Vector %d (column %d) is linearly dependent on previous vectors. Using zero vector.\n', i, i);
    end
    fprintf('\n');


    % Verify orthogonality (using the calculated orthogonal basis)
    fprintf('Verifying orthogonality of the basis:\n');
    is_orthogonal = true;

    for i = 1:n_vectors
        for j = i+1:n_vectors
            % Use the calculated orthogonal basis for verification
            % Handle potential zero vectors gracefully
            if norm(orthogonal_basis{i}) > 1e-10 && norm(orthogonal_basis{j}) > 1e-10
                dot_product = dot(orthogonal_basis{i}, orthogonal_basis{j});
                fprintf('  u%d·u%d = %g\n', i, j, dot_product);
                if abs(dot_product) > 1e-10
                    is_orthogonal = false;
                end
            elseif norm(orthogonal_basis{i}) < 1e-10 || norm(orthogonal_basis{j}) < 1e-10
                 fprintf('  u%d·u%d = 0 (due to zero vector)\n', i, j);
            end
        end
    end

    if is_orthogonal
        fprintf('\nSuccess! The basis is orthogonal (or vectors are zero).\n');
    else
        fprintf('\nWarning: The basis is not perfectly orthogonal due to numerical precision.\n');
    end

    % Display the orthonormal basis in exact form
    % Note: formatNiceVector uses the orthogonal basis vectors before normalization
    fprintf('\nOrthonormal basis vectors (derived from QR):\n');
    for i = 1:n_vectors
        % Check if this corresponds to a zero vector (due to linear dependence)
        if norm(orthogonal_basis{i}) < 1e-10
            fprintf('e%d: [', i);
            % Ensure correct dimension for zero vector display
            for row_idx = 1:dim
                if row_idx > 1
                    fprintf('; ');
                end
                fprintf('0');
            end
            fprintf('] (zero vector due to linear dependence)\n');
        else
            % Format the vector nicely using the orthogonal vector
            % The normalization factor is handled inside formatNiceVector
            formatNiceVector(orthogonal_basis{i}, i);
        end
    end
end

function displayExactVector(u_i, index)
    % This function might not be directly needed if using formatNiceVector
    % Keeping it for potential future use or reference
    vector_norm = norm(u_i);
    dim = length(u_i); % Get dimension from the vector itself

    % Avoid division by zero or near-zero for dependent vectors
    if vector_norm < 1e-10
        fprintf('  e%d = [', index);
         for row_idx = 1:dim
             if row_idx > 1; fprintf('; '); end
             fprintf('0');
         end
         fprintf('] (zero vector)\n\n');
        return;
    end

    % Display as 1/√(norm^2) × [original vector]
    fprintf('  e%d = 1/√%g × [', index, round(vector_norm^2, 4));

    % Print the original vector entries
    for j = 1:dim
        if j > 1
            fprintf('; ');
        end
        if abs(u_i(j)) < 1e-10
            fprintf('0');
        else
            % Try to detect and format exact forms
            [formatted, success] = format_exact_number(u_i(j));
            if success
                fprintf('%s', formatted);
            else
                fprintf('%g', u_i(j));
            end
        end
    end
    fprintf(']\n\n');
end

function formatNiceVector(u_i, index)
    % Format vector with common factors extracted and nice surds
    % This function operates on the ORTHOGONAL vector u_i
    vector_norm = norm(u_i);
    dim = length(u_i); % Get dimension from the vector itself

    % Handle zero vector case explicitly
    if vector_norm < 1e-10
         fprintf('e%d: [', index);
         for j = 1:dim
             if j > 1; fprintf('; '); end
             fprintf('0');
         end
         fprintf('] (zero vector)\n');
         return;
    end

    vector_norm_squared = vector_norm^2;

    % Convert vector entries to fractions
    [nums, denoms] = deal(zeros(dim, 1));
    common_denom = 1;

    for j = 1:dim
        % Increase tolerance slightly for rat function with QR results
        [nums(j), denoms(j)] = rat(u_i(j), 1e-9);
        if denoms(j) > 1
            common_denom = lcm(common_denom, denoms(j));
        end
    end

    % If we found a common denominator greater than 1
    if common_denom > 1
        % Scale all entries to have the common denominator
        scaled_entries = zeros(dim, 1);
        for j = 1:dim
            scale_factor = common_denom / denoms(j);
            scaled_entries(j) = nums(j) * scale_factor;
        end

        % Now calculate the new radicand (combine common_denom^2 with original radicand)
        % Use a tolerance when calculating new_radicand
        new_radicand = vector_norm_squared * common_denom^2;

        % Check if the new radicand can be simplified
        [nr_num, nr_denom] = rat(new_radicand, 1e-9); % Use tolerance

        % Ensure nr_num is positive before factoring
        nr_num = abs(nr_num);

        if nr_denom == 1 && nr_num > 1e-10 % Check against tolerance
            nr_num_int = round(nr_num); % Round to nearest integer
            % Perfect square check
            sqrt_nr = sqrt(nr_num_int);
            if abs(sqrt_nr - round(sqrt_nr)) < 1e-9 % Use tolerance
                % It's a perfect square
                fprintf('e%d: 1/%d × [', index, round(sqrt_nr));
                for j = 1:dim
                    if j > 1
                        fprintf('; ');
                    end
                    fprintf('%d', round(scaled_entries(j))); % Round scaled entries
                end
                fprintf(']\n');
                return;
            end

            % Try to factor out perfect squares from the radicand
            if nr_num_int > 1 % Only factor if greater than 1
                try
                    factors_list = factor(nr_num_int);
                    unique_factors = unique(factors_list);
                    sqrt_factor = 1;
                    remaining_radicand = nr_num_int;

                    for f = unique_factors'
                        count = sum(factors_list == f);
                        if count >= 2
                            exponent = floor(count / 2);
                            sqrt_factor = sqrt_factor * (f ^ exponent);
                            remaining_radicand = remaining_radicand / (f ^ (2 * exponent));
                        end
                    end
                    remaining_radicand = round(remaining_radicand); % Round remaining part

                    if sqrt_factor > 1
                         % Format with the extracted perfect square
                         if remaining_radicand > 1
                             fprintf('e%d: 1/(%d√%d) × [', index, sqrt_factor, remaining_radicand);
                         else % Radicand simplified to 1
                             fprintf('e%d: 1/%d × [', index, sqrt_factor);
                         end
                         for j = 1:dim
                             if j > 1
                                 fprintf('; ');
                             end
                             fprintf('%d', round(scaled_entries(j))); % Round scaled entries
                         end
                         fprintf(']\n');
                         return;
                    end
                catch ME
                    % Handle cases where factor() might fail (e.g., very large numbers)
                    fprintf('Warning: Could not factor radicand %d for e%d. %s\n', nr_num_int, index, ME.message);
                end
            end


            % If no perfect squares or factoring failed, just show the simplified form
            fprintf('e%d: 1/√%d × [', index, nr_num_int);
            for j = 1:dim
                if j > 1
                    fprintf('; ');
                end
                fprintf('%d', round(scaled_entries(j))); % Round scaled entries
            end
            fprintf(']\n');
            return;
        end
    end

    % Fallback if common denominator extraction didn't work or wasn't needed
    % Use the original orthogonal vector u_i for display formatting
    vector_norm_squared_rounded = round(vector_norm_squared, 4); % Round for display

     % Check if norm squared is integer for cleaner sqrt display
    [norm_sq_num, norm_sq_den] = rat(vector_norm_squared, 1e-9);
    if norm_sq_den == 1 && norm_sq_num > 0
        norm_sq_int = norm_sq_num;
        % Try factoring this integer radicand
        if norm_sq_int > 1
             try
                 factors_list = factor(norm_sq_int);
                 unique_factors = unique(factors_list);
                 sqrt_factor = 1;
                 remaining_radicand = norm_sq_int;

                 for f = unique_factors'
                     count = sum(factors_list == f);
                     if count >= 2
                         exponent = floor(count / 2);
                         sqrt_factor = sqrt_factor * (f ^ exponent);
                         remaining_radicand = remaining_radicand / (f ^ (2 * exponent));
                     end
                 end
                 remaining_radicand = round(remaining_radicand);

                 if sqrt_factor > 1
                      if remaining_radicand > 1
                          fprintf('e%d: 1/(%d√%d) × [', index, sqrt_factor, remaining_radicand);
                      else
                          fprintf('e%d: 1/%d × [', index, sqrt_factor);
                      end
                      % Print vector elements (try formatting them)
                      for j = 1:dim
                          if j > 1; fprintf('; '); end
                          [formatted, success] = format_exact_number(u_i(j));
                          if success; fprintf('%s', formatted); else; fprintf('%g', u_i(j)); end
                      end
                      fprintf(']\n');
                      return;
                 end
             catch ME
                 fprintf('Warning: Could not factor radicand %d for e%d. %s\n', norm_sq_int, index, ME.message);
             end
        end
         % If no factors extracted or integer is 1
         fprintf('e%d: 1/√%d × [', index, norm_sq_int);
    else
        % Default display if norm squared is not a nice integer
        fprintf('e%d: 1/√%g × [', index, vector_norm_squared_rounded);
    end

    % Print vector elements (try formatting them)
    for j = 1:dim
        if j > 1
            fprintf('; ');
        end
        if abs(u_i(j)) < 1e-10
            fprintf('0');
        else
            % Try to detect and format exact forms
            [formatted, success] = format_exact_number(u_i(j));
            if success
                fprintf('%s', formatted);
            else
                fprintf('%g', u_i(j)); % Fallback to %g
            end
        end
    end
    fprintf(']\n');
end


function [formatted, success] = format_exact_number(val)
    % Format a number in exact form if possible
    success = false;
    formatted = '';
    tolerance = 1e-9; % Use slightly larger tolerance

    % Check for zero
    if abs(val) < tolerance
        formatted = '0';
        success = true;
        return;
    end

    % Try rational approximation
    [n, d] = rat(val, tolerance);

    % Check if the approximation is good enough
    if abs(val - n/d) < tolerance * abs(val) || abs(val - n/d) < tolerance
        if d == 1
            % It's an integer
            formatted = sprintf('%d', n);
            success = true;
        elseif d > 0 % Denominator limit removed for flexibility
            % It's a fraction
            formatted = sprintf('%d/%d', n, d);
            success = true;
        end
    end
end
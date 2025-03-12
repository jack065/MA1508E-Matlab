function result = custom_ref(matrix, varargin)
    % CUSTOM_REF - Convert a matrix to Row Echelon Form with detailed steps
    %
    % Usage:
    %   result = custom_ref(matrix)
    %   result = custom_ref(matrix, 'ShowSteps', true)
    %   result = custom_ref(matrix, 'NormalizePivots', true)
    %
    % Inputs:
    %   matrix - Input matrix (numeric or symbolic)
    %   
    % Optional parameters:
    %   'ShowSteps'      - Display step-by-step operations (default: false)
    %   'NormalizePivots'- Divide rows by pivot to get 1s on diagonal (default: false)
    %   'Simplify'       - Apply simplification after operations (default: true)
    %
    % Example:
    %   syms a b
    %   A = [a b 1; b a 2; a+b 1 3];
    %   R = custom_ref(A, 'ShowSteps', true)
    
    % Parse optional inputs
    p = inputParser;
    addParameter(p, 'ShowSteps', false, @islogical);
    addParameter(p, 'NormalizePivots', false, @islogical);
    addParameter(p, 'Simplify', true, @islogical);
    parse(p, varargin{:});
    
    show_steps = p.Results.ShowSteps;
    normalize_pivots = p.Results.NormalizePivots;
    apply_simplify = p.Results.Simplify;
    
    % Convert to symbolic if not already
    if ~isa(matrix, 'sym')
        matrix = sym(matrix);
    end
    
    % Error handling for empty matrices
    [m, n] = size(matrix);
    if m == 0 || n == 0
        result = matrix;
        fprintf('Empty matrix provided. No operations needed.\n');
        return;
    end
    
    % Initialize result and tracking
    result = matrix;
    global matrix_history;
    if isempty(matrix_history)
        matrix_history = {matrix};
    else
        matrix_history{end+1} = matrix;
    end
    
    % Setup for step tracking
    step_count = 0;
    
    % Print initial matrix
    if show_steps
        fprintf('Initial matrix:\n');
        disp(result);
        fprintf('\n');
    end
    
    % Row echelon form algorithm
    lead = 1;
    for row = 1:m
        if lead > n
            break;
        end
        
        % Find first nonzero entry in current column from current row down
        i = row;
        while i <= m && result(i,lead) == 0
            i = i + 1;
        end
        
        % If we found a nonzero entry
        if i <= m
            % Swap rows if necessary
            if i ~= row
                step_count = step_count + 1;
                if show_steps
                    fprintf('Step %d: Swap rows %d and %d\n', step_count, row, i);
                end
                
                % Create elementary matrix for swap and update history
                swap_matrix = eye(m);
                swap_matrix([row,i],:) = swap_matrix([i,row],:);
                
                % Perform the swap
                temp = result(row,:);
                result(row,:) = result(i,:);
                result(i,:) = temp;
                
                if show_steps
                    disp(result);
                    fprintf('\n');
                end
            end
            
            % Normalize pivot if requested
            pivot = result(row,lead);
            if normalize_pivots && pivot ~= 1
                step_count = step_count + 1;
                if show_steps
                    fprintf('Step %d: Multiply row %d by 1/%s\n', step_count, row, char(pivot));
                end
                
                % Perform the normalization
                result(row,:) = result(row,:) / pivot;
                
                if show_steps
                    disp(result);
                    fprintf('\n');
                end
            end
            
            % Eliminate entries below pivot
            for i = row+1:m
                if result(i,lead) ~= 0
                    factor = result(i,lead) / result(row,lead);
                    step_count = step_count + 1;
                    
                    if show_steps
                        if apply_simplify
                            factor = simplify(factor);
                        end
                        fprintf('Step %d: R%d = R%d - (%s) × R%d\n', ...
                            step_count, i, i, char(factor), row);
                    end
                    
                    % Perform elimination
                    result(i,:) = result(i,:) - factor*result(row,:);
                    
                    if show_steps
                        if apply_simplify
                            result = simplify(result);
                        end
                        disp(result);
                        fprintf('\n');
                    end
                end
            end
        end
        
        lead = lead + 1;
    end
    
    % Clean up expression and store final result
    if apply_simplify
        result = simplify(result);
    end
    
    matrix_history{end+1} = result;
    
    if show_steps
        fprintf('Final Row Echelon Form:\n');
        disp(result);
    end
end
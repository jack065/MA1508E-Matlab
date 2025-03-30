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
    %
    % Example:
    %   syms a b
    %   A = [a b 1; b a 2; a+b 1 3];
    %   R = custom_ref(A, 'ShowSteps', true)
    
    % Parse optional inputs
    p = inputParser;
    addParameter(p, 'ShowSteps', false, @islogical);
    addParameter(p, 'NormalizePivots', false, @islogical);
    parse(p, varargin{:});
    
    show_steps = p.Results.ShowSteps;
    normalize_pivots = p.Results.NormalizePivots;
    
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
        
        % Find best pivot row - prefer 1s, then numbers, then simple symbolic expressions
        best_row = 0;
        best_score = -Inf;
        
        for i = row:m
            if result(i,lead) == 0
                continue;  % Skip zero entries
            end
            
            current_score = -Inf;
            
            % Prefer 1s (highest score)
            if result(i,lead) == 1
                current_score = 1000;
            % Then prefer -1s
            elseif result(i,lead) == -1
                current_score = 900;
            % Then prefer integers/numeric values
            elseif isempty(symvar(result(i,lead)))
                % Only convert to double if there are no symbolic variables
                numeric_value = double(result(i,lead));
                current_score = 800 - abs(numeric_value);
            % Last resort: symbolic expressions (score based on complexity)
            else
                expr_str = char(result(i,lead));
                % Simpler expressions get higher scores
                current_score = 500 - length(expr_str);
            end
            
            if current_score > best_score
                best_score = current_score;
                best_row = i;
            end
        end
        
        % If we found a nonzero entry
        if best_row > 0
            i = best_row;
            
            % Swap rows if necessary
            if i ~= row
                step_count = step_count + 1;
                if show_steps
                    fprintf('Step %d: Swap rows %d and %d\n', step_count, row, i);
                end
                
                % Perform the swap
                temp = result(row,:);
                result(row,:) = result(i,:);
                result(i,:) = temp;
                
                if show_steps
                    result_display = simplify(result);
                    disp(result_display);
                    fprintf('\n');
                end
            end
            
            % Normalize pivot if requested and it's a numeric value
            pivot = result(row,lead);
            if normalize_pivots && pivot ~= 1 && isempty(symvar(pivot))
                step_count = step_count + 1;
                if show_steps
                    fprintf('Step %d: Multiply row %d by 1/%s\n', step_count, row, char(pivot));
                end
                
                % Perform the normalization
                result(row,:) = result(row,:) / pivot;
                
                if show_steps
                    result_display = simplify(result);
                    disp(result_display);
                    fprintf('\n');
                end
            end
            
            % Eliminate entries below pivot using multiplication instead of division
            for i = row+1:m
                if result(i,lead) ~= 0
                    pivot_row = result(row,lead);
                    pivot_i = result(i,lead);
                    
                    step_count = step_count + 1;
                    
                    % Check if pivot_row contains any symbolic variables
                    if ~isempty(symvar(pivot_row))
                        % Use multiplication and subtraction to avoid division by symbols
                        if show_steps
                            fprintf('Step %d: R%d = (%s)×R%d - (%s)×R%d\n', ...
                                step_count, i, char(pivot_row), i, char(pivot_i), row);
                        end
                        
                        % Multiply current row by pivot_row
                        result(i,:) = pivot_row * result(i,:);
                        
                        % Subtract pivot_i times the pivot row
                        result(i,:) = result(i,:) - pivot_i * result(row,:);
                    else
                        % Use standard elimination with division for numeric pivots
                        factor = pivot_i / pivot_row;
                        
                        if show_steps
                            factor_display = simplify(factor);
                            fprintf('Step %d: R%d = R%d - (%s)×R%d\n', ...
                                step_count, i, i, char(factor_display), row);
                        end
                        
                        % Perform elimination
                        result(i,:) = result(i,:) - factor * result(row,:);
                    end
                    
                    if show_steps
                        result_display = simplify(result);
                        disp(result_display);
                        fprintf('\n');
                    end
                end
            end
            
            lead = lead + 1;
        else
            % No nonzero entry found, move to next column
            lead = lead + 1;
        end
    end
    
    % Always simplify the final result
    result = simplify(result);
    
    matrix_history{end+1} = result;
    
    if show_steps
        fprintf('Final Row Echelon Form:\n');
        disp(result);
    end
end
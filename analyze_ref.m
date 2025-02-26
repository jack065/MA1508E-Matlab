function analyze_ref(A)
    % Check if matrix is in REF form by checking zeros below pivots
    [m, n] = size(A);
    last_pivot_col = 0;
    
    for i = 1:m
        % Find first non-zero element in row
        pivot_col = find(A(i,:) ~= 0, 1);
        if isempty(pivot_col)
            continue;  % Skip zero rows
        end
        
        % Check REF properties
        if pivot_col <= last_pivot_col || any(A(i+1:end, pivot_col) ~= 0)
            fprintf('Matrix is not in Row Echelon Form.\n');
            return;
        end
        last_pivot_col = pivot_col;
    end
    
    % Get diagonal elements and their critical values
    diag_elements = diag(A);
    params = symvar(diag_elements);
    
    if isempty(params)
        fprintf('Nothing to analyze - no symbolic variables in diagonal.\n');
        return;
    end
    
    % Initialize critical_vals struct
    critical_vals = struct();
    for p = 1:length(params)
        critical_vals.(char(params(p))) = [];
    end
    
    % Find critical values from diagonal
    for i = 1:length(diag_elements)
        if isa(diag_elements(i), 'sym')
            curr_params = symvar(diag_elements(i));
            for p = 1:length(curr_params)
                try
                    sol = solve(diag_elements(i) == 0, curr_params(p));
                    param_name = char(curr_params(p));
                    if ~isempty(sol)
                        critical_vals.(param_name) = [critical_vals.(param_name); sol];
                    end
                catch
                    continue;
                end
            end
        end
    end
    
    % Display results
    fprintf('\nCritical Values:\n');
    fprintf('===============\n\n');
    
    % Store relationships between variables
    var_relationships = {};
    
    param_names = fieldnames(critical_vals);
    for i = 1:length(param_names)
        vals = critical_vals.(param_names{i});
        if ~isempty(vals)
            vals = unique(vals);
            for j = 1:length(vals)
                if ~isnan(vals(j)) && ~isinf(vals(j))
                    if isa(vals(j), 'sym')
                        % Check if it's a relationship between variables
                        val_str = char(vals(j));
                        if any(strcmp(val_str, param_names))
                            rel = sprintf('%s = %s', param_names{i}, val_str);
                            rev_rel = sprintf('%s = %s', val_str, param_names{i});
                            % Only add if neither form exists
                            if ~any(strcmp(var_relationships, rel)) && ...
                               ~any(strcmp(var_relationships, rev_rel))
                                var_relationships{end+1} = rel;
                            end
                        else
                            fprintf('%s = %s\n', param_names{i}, val_str);
                        end
                    else
                        fprintf('%s = %s\n', param_names{i}, char(vals(j)));
                    end
                end
            end
        end
    end
    
    % Display variable relationships
    for i = 1:length(var_relationships)
        fprintf('%s\n', var_relationships{i});
    end
    
    fprintf('\nNote: When determinant = 0, the matrix has either:\n');
    fprintf('- No solution (inconsistent system)\n');
    fprintf('- Infinitely many solutions (dependent system)\n');
end
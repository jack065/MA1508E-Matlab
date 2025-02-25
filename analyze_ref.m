function analyze_ref(A)
    % Get matrix dimensions and symbolic variables
    [m, n] = size(A);
    params = symvar(A);
    
    fprintf('\nAnalysis of REF Matrix Solutions:\n');
    fprintf('================================\n\n');
    
    % Store critical cases
    critical_cases = struct('value', {}, 'equation', {}, 'position', {}, 'type', {});
    
    % Check diagonal elements for dependency
    for i = 1:min(m,n)
        if ~isnumeric(A(i,i))
            try
                zeros_i = solve(A(i,i) == 0, params);
                if ~isempty(zeros_i)
                    critical_cases(end+1) = struct('value', zeros_i, ...
                                                 'equation', A(i,i), ...
                                                 'position', i, ...
                                                 'type', 'dependent');
                end
            catch
                fprintf('Could not solve %s = 0 symbolically\n', char(A(i,i)));
            end
        elseif A(i,i) == 0
            critical_cases(end+1) = struct('value', 0, ...
                                         'equation', 0, ...
                                         'position', i, ...
                                         'type', 'always_dependent');
        end
    end
    
    % Check for inconsistency (0 = nonzero in last row)
    last_nonzero = find(A(end,:) ~= 0, 1, 'last');
    if last_nonzero == n+1  % Augmented matrix case
        critical_cases(end+1) = struct('value', [], ...
                                     'equation', A(end,end), ...
                                     'position', m, ...
                                     'type', 'inconsistent');
    end
    
    % Display analysis
    if ~isempty(critical_cases)
        fprintf('Critical Cases Found:\n');
        fprintf('-----------------\n');
        for i = 1:length(critical_cases)
            switch critical_cases(i).type
                case 'dependent'
                    fprintf('Case %d: When %s = 0 (at position %d,%d)\n', ...
                           i, char(critical_cases(i).equation), ...
                           critical_cases(i).position, critical_cases(i).position);
                    fprintf('       Parameter values: %s = %s\n', ...
                           char(params(1)), char(critical_cases(i).value));
                    fprintf('       → Infinitely many solutions\n\n');
                    
                case 'always_dependent'
                    fprintf('Case %d: Zero on diagonal at position (%d,%d)\n', ...
                           i, critical_cases(i).position, critical_cases(i).position);
                    fprintf('       → Always infinitely many solutions\n\n');
                    
                case 'inconsistent'
                    fprintf('Case %d: Inconsistent equation in row %d\n', ...
                           i, critical_cases(i).position);
                    fprintf('       → No solution exists\n\n');
            end
        end
        
        fprintf('Solution Summary:\n');
        fprintf('---------------\n');
        
        % Check solution types using logical indexing
        has_no_solution = any([critical_cases.type] == "inconsistent");
        has_always_dependent = any([critical_cases.type] == "always_dependent");
        has_dependent = any([critical_cases.type] == "dependent");
        
        if has_no_solution
            fprintf('* System has NO SOLUTION when the last row is 0 = nonzero\n');
        end
        if has_always_dependent
            fprintf('* System ALWAYS has infinitely many solutions\n');
        elseif has_dependent
            fprintf('* System has infinitely many solutions when:\n');
            dependent_cases = critical_cases([critical_cases.type] == "dependent");
            for i = 1:length(dependent_cases)
                fprintf('  - %s = %s\n', char(params(1)), char(dependent_cases(i).value));
            end
            fprintf('* System has a UNIQUE solution for all other parameter values\n');
        end
    else
        fprintf('No critical cases found.\n');
        fprintf('\nSolution Analysis:\n');
        fprintf('-----------------\n');
        fprintf('System has unique solutions for all parameter values.\n');
    end
    fprintf('\n');
end
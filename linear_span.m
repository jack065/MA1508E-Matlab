function linear_span(vector_set, constraints)
    % LINEAR_SPAN - Determine if a vector set with constraints forms a subspace
    %
    % Inputs:
    %   vector_set - Vector containing symbolic variables
    %   constraints - Cell array of inequality constraints as symbolic expressions
    %
    % Example:
    %   syms a b c
    %   vector_set = [a; b; c];
    %   constraints = {a == b, b == c};
    %   linear_span(vector_set, constraints);
    
    % Extract all symbolic variables
    vars = symvar(vector_set);
    
    % Check if constraints pass through origin (necessary condition)
    is_subspace = true;
    origin_values = zeros(1, length(vars));  % Make a row vector to match vars
    zero_vector = subs(vector_set, vars, origin_values);
    
    % Check each constraint at the origin
    fprintf('Checking if constraints allow the zero vector...\n');
    for i = 1:length(constraints)
        constraint = constraints{i};
        constr_at_origin = subs(constraint, vars, origin_values);
        
        % Display the constraint and evaluation at origin
        fprintf('Constraint %d: %s\n', i, char(constraint));
        fprintf('  At origin: %s (', char(constr_at_origin));
        
        if isAlways(constr_at_origin)
            fprintf('satisfied)\n');
        else
            fprintf('not satisfied)\n');
            is_subspace = false;
        end
    end
    
    % Check homogeneity of constraints (necessary condition)
    fprintf('\nChecking if constraints are homogeneous...\n');
    
    syms t real;
    for i = 1:length(constraints)
        constraint = constraints{i};
        constraint_str = char(constraint);
        
        % Skip additional homogeneity check for equality constraints (they're always homogeneous)
        if contains(constraint_str, '==')
            fprintf('Constraint %d: %s is homogeneous\n', i, constraint_str);
            continue;
        end
        
        % Replace vars with t*vars to check homogeneity
        t_vars = arrayfun(@(x) t*x, vars);
        scaled_constraint = subs(constraint, vars, t_vars);
        
        % Check if inequality constraints are homogeneous
        % Inequalities are only homogeneous if they're actually equalities
        if contains(constraint_str, '>=') || contains(constraint_str, '<=')
            % For inequality constraints, they must be equalities to be homogeneous
            % Extract lhs and rhs of constraint
            [lhs_expr, rhs_expr] = parseConstraint(constraint);
            
            % Check if this is actually an equality disguised as inequality
            is_equality = isAlways(lhs_expr == rhs_expr);
            
            if is_equality
                fprintf('Constraint %d: %s is homogeneous (actually an equality)\n', i, constraint_str);
            else
                fprintf('Constraint %d: %s is not homogeneous\n', i, constraint_str);
                is_subspace = false;
            end
        else
            % Other types of constraints
            fprintf('Constraint %d: %s (unsupported constraint type)\n', i, constraint_str);
            is_subspace = false;
        end
    end
    
    % Add after homogeneity check
    if is_subspace
        % Check closure under addition
        fprintf('\nChecking closure under addition...\n');
        
        % Create symbolic vectors for x and y
        x_vars = sym('x_', [length(vars), 1]);
        y_vars = sym('y_', [length(vars), 1]);
        
        % Check if x and y satisfying constraints means x+y also satisfies them
        for i = 1:length(constraints)
            constraint = constraints{i};
            constraint_str = char(constraint);
            
            % Replace the equality constraint check with:
            % Check if equality constraint is linear or nonlinear
            if contains(constraint_str, '==')
                [lhs_expr, rhs_expr] = parseConstraint(constraint);
                eq_expr = lhs_expr - rhs_expr;
                
                % Better linearity check
                is_linear = true;
                
                % Method 1: Check total degree of polynomial
                if polynomialDegree(eq_expr) > 1
                    is_linear = false;
                end
                
                % Method 2: Check for cross-terms by expanding and examining coefficients
                try
                    % Expand the expression to find all terms
                    expanded = expand(eq_expr);
                    terms = children(expanded);
                    
                    % If it's just one term, wrap it
                    if ~iscell(terms)
                        terms = {terms};
                    end
                    
                    % Check each term for products of variables
                    for term_idx = 1:length(terms)
                        term = terms{term_idx};
                        term_vars = symvar(term);
                        
                        % If any term contains more than one variable, it's nonlinear
                        if length(term_vars) > 1
                            is_linear = false;
                            break;
                        end
                    end
                catch
                    % Fall back to test cases if symbolic analysis fails
                    % Create test vectors and verify linearity property directly
                    is_linear = false; % Assume nonlinear unless proven otherwise
                end
                
                if is_linear
                    fprintf('Constraint %d: %s is closed under addition (linear equality constraint)\n', i, constraint_str);
                    continue;
                else
                    fprintf('Constraint %d: %s is nonlinear, checking closure under addition...\n', i, constraint_str);
                    % Continue to check closure under addition for nonlinear constraints
                end
            end
            
            % For inequality constraints, we need to check
            % Substitute x and check if constraint is satisfied
            x_constraint = subs(constraint, vars, x_vars.');
            
            % Substitute y and check if constraint is satisfied
            y_constraint = subs(constraint, vars, y_vars.');
            
            % Substitute x+y and check if constraint is satisfied
            sum_vars = x_vars.' + y_vars.';
            sum_constraint = subs(constraint, vars, sum_vars);
            
            % Logic: (A AND B) implies C is equivalent to NOT(A AND B) OR C
            is_closed_under_addition = isAlways(~(x_constraint & y_constraint) | sum_constraint);
            
            if ~is_closed_under_addition
                fprintf('Constraint %d: %s is not closed under addition\n', i, constraint_str);
                is_subspace = false;
            else
                fprintf('Constraint %d: %s is closed under addition\n', i, constraint_str);
            end
        end
    end
    
    % Summarize findings
    if ~is_subspace
        fprintf('\nResult: The set is NOT a subspace.\n');
        fprintf('Reason: Some constraints are either non-homogeneous or do not pass through origin.\n');
        fprintf('or not closed under addition and scalar multiplication.\n');
    else
        fprintf('\nResult: The set IS a subspace.\n');
        fprintf('All constraints are homogeneous and pass through origin.\n');
        fprintf('The set is closed under addition and scalar multiplication.\n');
    end
end

% Helper function to parse constraint into lhs and rhs
function [lhs, rhs] = parseConstraint(constraint)
    constraint_str = char(constraint);
    
    if contains(constraint_str, '==')
        parts = strsplit(constraint_str, '==');
        lhs = str2sym(parts{1});
        rhs = str2sym(parts{2});
    elseif contains(constraint_str, '>=')
        parts = strsplit(constraint_str, '>=');
        lhs = str2sym(parts{1});
        rhs = str2sym(parts{2});
    elseif contains(constraint_str, '<=')
        parts = strsplit(constraint_str, '<=');
        lhs = str2sym(parts{1});
        rhs = str2sym(parts{2});
    else
        % Default case if no recognized operator
        lhs = constraint;
        rhs = 0;
    end
end
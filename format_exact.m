function formatted = format_exact(val)
    % FORMAT_EXACT - Format a number in exact mathematical form
    %
    % Usage:
    %   formatted = format_exact(value)
    %
    % Inputs:
    %   value - Numeric value to format
    %
    % Outputs:
    %   formatted - String representation in exact mathematical form
    
    tolerance = 1e-9;
    
    % Check for zero
    if abs(val) < tolerance
        formatted = '0';
        return;
    end
    
    % Try rational approximation first
    [n, d] = rat(val, tolerance);
    
    % Check if the approximation is good enough
    if abs(val - n/d) < tolerance * max(1, abs(val))
        if d == 1
            % It's an integer
            formatted = sprintf('%d', n);
            return;
        elseif d > 0 && d <= 1000
            % It's a simple fraction
            formatted = sprintf('%d/%d', n, d);
            return;
        end
    end
    
    % Check for square roots
    % First, try to find if val = a/√b or a*√b/c
    common_surds = [2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15];
    
    % Check for patterns like a/√b
    for num = 1:10
        for surd = common_surds
            % Check val ≈ num/√surd
            if abs(val - num/sqrt(surd)) < tolerance
                formatted = sprintf('%d/√%d', num, surd);
                return;
            end
            % Check val ≈ -num/√surd
            if abs(val + num/sqrt(surd)) < tolerance
                formatted = sprintf('-%d/√%d', num, surd);
                return;
            end
            % Check val ≈ √surd/num
            if abs(val - sqrt(surd)/num) < tolerance
                formatted = sprintf('√%d/%d', surd, num);
                return;
            end
            % Check val ≈ -√surd/num
            if abs(val + sqrt(surd)/num) < tolerance
                formatted = sprintf('-√%d/%d', surd, num);
                return;
            end
        end
    end
    
    % Try to express as a/b * √c
    for num = 1:20
        for denom = 1:20
            for surd = common_surds
                test_val = (num/denom) * sqrt(surd);
                if abs(val - test_val) < tolerance
                    if denom == 1
                        formatted = sprintf('%d√%d', num, surd);
                    else
                        formatted = sprintf('%d√%d/%d', num, surd, denom);
                    end
                    return;
                end
                if abs(val + test_val) < tolerance
                    if denom == 1
                        formatted = sprintf('-%d√%d', num, surd);
                    else
                        formatted = sprintf('-%d√%d/%d', num, surd, denom);
                    end
                    return;
                end
            end
        end
    end
    
    % Try to detect if it's √(a/b)
    for num = 1:100
        for denom = 1:100
            if abs(val^2 - num/denom) < tolerance
                if denom == 1
                    formatted = sprintf('√%d', num);
                else
                    formatted = sprintf('√(%d/%d)', num, denom);
                end
                return;
            end
            if abs(val^2 + num/denom) < tolerance
                if denom == 1
                    formatted = sprintf('-√%d', num);
                else
                    formatted = sprintf('-√(%d/%d)', num, denom);
                end
                return;
            end
        end
    end
    
    % If all else fails, return as a decimal
    formatted = sprintf('%g', val);
end
function result = custom_ref(matrix)
    % Convert to symbolic if not already
    if ~isa(matrix, 'sym')
        matrix = sym(matrix);
    end
    
    [m, n] = size(matrix);
    result = matrix;
    lead = 1;
    
    for row = 1:m
        if lead > n
            return;
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
                temp = result(row,:);
                result(row,:) = result(i,:);
                result(i,:) = temp;
            end
            
            % Eliminate entries below pivot
            pivot = result(row,lead);
            for i = row+1:m
                if result(i,lead) ~= 0
                    factor = result(i,lead)/pivot;
                    result(i,:) = result(i,:) - factor*result(row,:);
                end
            end
        end
        
        lead = lead + 1;
    end
    
    % Clean up very small numbers
    result = simplify(result);
end
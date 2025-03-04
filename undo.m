function result = undo()
    % Access the global history variable
    global matrix_history;
    
    % Check if there's any history to undo
    if isempty(matrix_history) || length(matrix_history) < 1
        error('No operations to undo.');
    end
    
    % Get the previous matrix state (second last element)
    result = matrix_history{end};
    
    % Remove the last two entries from history
    % (the current matrix and the one we're returning to)
    matrix_history = matrix_history(1:end-1);
end
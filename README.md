# Matrix Operations Program

This MATLAB program provides a suite of tools for matrix manipulation and analysis, particularly useful for linear algebra operations.

## Getting Started

1. Open MATLAB
2. In MATLAB's file explorer, navigate to the folder you just downloaded
3. Double-click on `startup.m` in MATLAB's file explorer
4. Click the "Run" button in MATLAB's editor toolbar or press F5
   - This initializes the program and sets up the global matrix history for the undo function

## Available Functions

### Basic Matrix Display
```matlab
showmatrix(matrix)
```
Displays a matrix in a clean format with proper spacing and brackets.

Example:
```matlab
A = [1 2; 3 4];
showmatrix(A)
% Output:
% [1 2;3 4]
```

### Elementary Row Operations
```matlab
elem(matrix, row1, row2, operation, scalar)
```
Performs elementary row operations:
- `'swap'`: Swaps row1 and row2
- `'+'`: Adds scalar × row2 to row1
- `'-'`: Subtracts scalar × row2 from row1
- `'*'`: Multiplies row1 by scalar

Example:
```matlab
A = [1 2; 3 4];
A = elem(A, 1, 2, '+', 2)  % Adds 2 times row 2 to row 1
% Output:
% [7 10;3 4]
```

### Matrix Inverse
```matlab
inverse(matrix)
```
Calculates and displays the inverse of a square matrix if it exists.

Example:
```matlab
A = [1 2; 3 4];
inverse(A)
% Output:
% Inverse of the matrix is:
% [-2 1;1.5000 -0.5000]
```

### Row Echelon Form (REF)
```matlab
result = custom_ref(matrix)
```
Converts a matrix to Row Echelon Form using elementary row operations. Unlike MATLAB's built-in `rref`:

**Advantages over MATLAB's rref:**
- Handles symbolic expressions naturally without rounding or simplification errors
- Maintains exact fractions and symbolic terms throughout computation
- Shows step-by-step row operations for educational purposes
- Integrates with the program's undo history system

Example with symbolic matrix:
```matlab
syms a b
A = [a 2*b; 3*a b];
result = custom_ref(A)
% Output:
% [ a, 2*b]
% [ 0, -5*b]
```

### REF Analysis (USE AT YOUR OWN RISK! NOT WORKING AS EXPECTED!)
```matlab
analyze_ref(matrix)
```
Analyzes a matrix in REF form to determine:
- Whether the system has unique solutions
- Conditions for infinite solutions
- Cases where no solutions exist

Example:
```matlab
A = [1 2 3; 0 0 5; 0 0 0];
analyze_ref(A)
% Output:
% Analysis of REF Matrix Solutions:
% ================================
% 
% No critical cases found.
% 
% Solution Analysis:
% -----------------
% System has unique solutions for all parameter values.
```

### Undo Operation
```matlab
result = undo()
```
Reverts to the previous matrix state. The program automatically stores matrix history when using elementary row operations.

Example:
```matlab
result = undo()
% Output:
% Previous matrix state:
% [1 2;3 4]
```

## Error Handling

The program includes error checking for:
- Invalid matrix dimensions
- Non-square matrices for inverse operations
- Singular matrices
- Invalid row indices
- Missing arguments
- Invalid operations

## Tips

1. Always initialize with `startup.m` before beginning operations
2. Use `showmatrix()` to display results in a clean format
3. The undo function maintains a history of operations, allowing you to step back if you make a mistake
4. For symbolic calculations, you can input matrices using symbolic variables (e.g., using `sym` variables)

# Matrix Operations Program

This MATLAB program provides a suite of tools for matrix manipulation and analysis, particularly useful for linear algebra operations.

## Getting Started

1. Open MATLAB
2. Navigate to the downloaded folder in MATLAB's file explorer
3. Run `startup.m` to initialize the program
   - This sets up the global matrix history for undo functionality

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
Converts a matrix to Row Echelon Form with these advantages over MATLAB's `rref`:
- Full symbolic variable support
- Exact fraction handling
- Step-by-step row operations shown
- Maintains simpler symbolic expressions

Example with symbolic variables:
```matlab
syms a b
A = [1 a; b 4];
result = custom_ref(A)
% Output:
% [1 a;0 4-a*b]
```

### REF Analysis (USE AT YOUR OWN RISK! NOT WORKING AS EXPECTED!)
```matlab
analyze_ref(matrix)
```
Analyzes matrices in REF form to find critical values of parameters.

Example with parametric matrix:
```matlab
syms a b
A = [a b 1; 0 b/4 2; 0 0 a-3];
analyze_ref(A)
% Output:
% Critical Values:
% ===============
% a = 0
% a = 3
% b = 0
```

### Undo Operation
```matlab
result = undo()
```
Reverts to the previous matrix state.

## Error Handling
- Validates matrix dimensions
- Checks for square matrices in inverse operations
- Detects singular matrices
- Validates row indices and operations

## Tips
1. Always run `startup.m` first
2. Use `showmatrix()` for clean output
3. Leverage undo functionality for mistakes
4. Use symbolic variables (`syms`) for parametric matrices

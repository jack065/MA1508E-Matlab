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
Performs elementary row operations and displays the elementary operation matrix (E) with its inverse (E^-1):
- `'s'`: Swaps row1 and row2
- `'+'`: Adds scalar × row2 to row1
- `'-'`: Subtracts scalar × row2 from row1
- `'*'`: Multiplies row1 by scalar

Example:
```matlab
A = [1 2; 3 4];
A = elem(A, 1, 2, '+', 2)  % Adds 2 times row 2 to row 1
% Output:
% E:                 E^-1:
% --                 ----
% 1      2          1      -2     
% 0      1          0      1      
%
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

### Identify Basis
```matlab
basis = identify_basis(input)
```
Finds a basis for a vector space using three different input methods:

1. Parametric representation:
```matlab
syms a b c d
param_vector = [a+b; a+c; c+d; b+d];
basis = identify_basis(param_vector)
% Output:
% Coefficient matrix A:
% [1, 1, 0, 0]
% [1, 0, 1, 0]
% [0, 0, 1, 1]
% [0, 1, 0, 1]
% 
% Basis vectors for the vector space:
% v1 = [1; 0; 0; 1]
% v2 = [1; 0; 1; 0]
% v3 = [0; 1; 0; 1]
```

2. Spanning set of vectors:
```matlab
vectors = {[1;0;-1], [-1;2;3], [0;3;0], [1;-1;1]};
basis = identify_basis(vectors)
% Output:
% Basis for the vector space:
% b1 = [1; 0; -1]
% b2 = [-1; 2; 3]
% b3 = [0; 3; 0]
```

3. Constraints on variables:
```matlab
syms a b c d
vars = [a; b; c; d];
constraints = {a+b==c, d==0};
basis = identify_basis(vars, constraints)
% Output:
% Basis vectors for the vector space:
% v1 = [1; 0; 1; 0]
% v2 = [0; 1; 1; 0]
```

### Subspace Testing
```matlab
linear_span(vector_set, constraints)
```
Determines if a vector set with constraints forms a subspace by checking:
- Zero vector inclusion
- Homogeneity (closure under scalar multiplication)
- Closure under addition

Example with a subspace:
```matlab
syms a b c
vector_set = [a; b; c];
constraints = {a == b, b == c};
linear_span(vector_set, constraints)
% Output:
% Result: The set IS a subspace.
```

Example with a non-subspace:
```matlab
syms a b c d
vector_set = [a; b; c; d];
constraints = {a*b == c*d};
linear_span(vector_set, constraints)
% Output:
% Result: The set is NOT a subspace.
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

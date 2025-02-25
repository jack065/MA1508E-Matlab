# Matrix Operations Program

This MATLAB program provides a suite of tools for matrix manipulation and analysis, particularly useful for linear algebra operations.

## Getting Started

1. Launch MATLAB
2. Navigate to the program directory
3. Run `startup.m` to initialize the program
   - This sets up the global matrix history for the undo function

## Available Functions

### Basic Matrix Display
```matlab
showmatrix(matrix)
```
Displays a matrix in a clean format with proper spacing and brackets.

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
```

### Matrix Inverse
```matlab
inverse(matrix)
```
Calculates and displays the inverse of a square matrix if it exists.

### Row Echelon Form (REF)
```matlab
result = custom_ref(matrix)
```
Converts a matrix to Row Echelon Form using elementary row operations.

### REF Analysis
```matlab
analyze_ref(matrix)
```
Analyzes a matrix in REF form to determine:
- Whether the system has unique solutions
- Conditions for infinite solutions
- Cases where no solutions exist

### Undo Operation
```matlab
result = undo()
```
Reverts to the previous matrix state. The program automatically stores matrix history when using elementary row operations.

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

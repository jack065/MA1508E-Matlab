# Matrix Operations Program

This MATLAB program serves as a way to complete linear algebra computations quickly. Feel free to create a pull request or suggest possible changes.

## Getting Started

1. Open MATLAB
2. Navigate to the downloaded folder in MATLAB's file explorer
3. Run `startup.m` to initialize the program
   - This sets up the global matrix history for undo functionality
   - **Note:** Always run `startup.m` before using any other functions to ensure proper initialization.

## Available Functions

---

### `startup`
Initializes the global matrix history variable for undo functionality.  
**Usage:**  
```matlab
startup
```
**Note:** This function must be run first to enable the undo functionality and ensure the program operates correctly.

---

### `showmatrix`
Displays a matrix in a clean format with proper spacing and brackets.  
**Usage:**  
```matlab
showmatrix(matrix)
```
**Example Input:**
```matlab
A = [1 2; 3 4];
showmatrix(A)
```
**Example Output:**
```
[1 2;3 4]
```

---

### `elem`
Performs elementary row operations and displays the elementary operation matrix (E) with its inverse (E^-1):  
- `'s'`: Swaps row1 and row2  
- `'+'`: Adds scalar × row2 to row1  
- `'-'`: Subtracts scalar × row2 from row1  
- `'*'`: Multiplies row1 by scalar  
**Usage:**  
```matlab
elem(matrix, row1, operation, scalar, row2)
```
**Example Input:**
```matlab
A = [1 2; 3 4];
A = elem(A, 1, '+', 2, 2)
```
**Example Output:**
```
E:                 E^-1:
--                 ----
1  2               1  -2
0  1               0   1

Result:
[1 6; 3 4]
```

---

### `inverse`
Calculates and displays the inverse of a square matrix if it exists.  
**Usage:**  
```matlab
inverse(matrix)
```
**Example Input:**
```matlab
A = [1 2; 3 4];
inverse(A)
```
**Example Output:**
```
Inverse of the matrix is:
[-2.0000  1.0000; 1.5000 -0.5000]
```

---

### `custom_ref`
Converts a matrix to Row Echelon Form (REF) with symbolic support and optional step-by-step output.  
**Usage:**  
```matlab
result = custom_ref(matrix, 'ShowSteps', true, 'NormalizePivots', true)
```
**Example Input:**
```matlab
syms a b
A = [1 a; b 4];
result = custom_ref(A, 'ShowSteps', true)
```
**Example Output:**
```
Step 1: Swap rows 1 and 2
[1 a; 0 4 - a*b]

Final Row Echelon Form:
[1 a; 0 4 - a*b]
```

---

### `analyze_ref`
Analyzes a matrix in REF form to find critical parameter values where the matrix loses rank.  
**Usage:**  
```matlab
analyze_ref(matrix)
```
**Example Input:**
```matlab
syms a b
A = [a b 1; 0 b/4 2; 0 0 a-3];
analyze_ref(A)
```
**Example Output:**
```
Critical Values:
a = 3
b = 0
```

---

### `identify_basis`
Finds a basis for a vector space using parametric representation, spanning set, or constraints.  
**Usage:**  
```matlab
basis = identify_basis(param_vector)
basis = identify_basis({v1, v2, ...})
basis = identify_basis(vars, constraints)
```
**Example Input:**
```matlab
syms a b c d
param_vector = [a+b; a+c; c+d; b+d];
basis = identify_basis(param_vector)
```
**Example Output:**
```
Basis for the vector space:
b1 = [1; 0; 0; 1]
b2 = [0; 1; 1; 0]
```

---

### `linear_span`
Determines if a vector set with constraints forms a subspace by checking zero vector inclusion, homogeneity, and closure under addition.  
**Usage:**  
```matlab
linear_span(vector_set, constraints)
```
**Example Input:**
```matlab
syms a b c
vector_set = [a; b; c];
constraints = {a == b, b == c};
linear_span(vector_set, constraints)
```
**Example Output:**
```
Result: The set IS a subspace.
```

---

### `is_ortho`
Checks if a set of vectors is orthogonal or orthonormal and displays their normalized forms.  
**Usage:**  
```matlab
is_ortho(v1, v2, ...)
is_ortho({v1, v2, ...})
```
**Example Input:**
```matlab
is_ortho([1;0;0], [0;1;0], [0;0;1])
```
**Example Output:**
```
The set is orthonormal!
```

---

### `gram_schmidt`
Converts columns of a matrix into an orthonormal basis using the Gram-Schmidt process (via QR decomposition).  
**Usage:**  
```matlab
gram_schmidt(N)
```
**Example Input:**
```matlab
A = [1 1 0; 1 0 1; 0 1 1];
gram_schmidt(A)
```
**Example Output:**
```
Orthonormal basis vectors:
e1 = [0.5774; 0.5774; 0.5774]
e2 = [0.7071; -0.7071; 0]
e3 = [0.4082; 0.4082; -0.8165]
```

---

### `least_square`
Computes the least squares solution to Ax = b using RREF and provides projection and residual information.  
**Usage:**  
```matlab
[rref_augmented, is_unique, projection] = least_square(A, b)
```
**Example Input:**
```matlab
A = [1 2; 3 4; 5 6];
b = [7; 8; 9];
least_square(A, b)
```
**Example Output:**
```
RREF of augmented matrix:
[...]
Projection of b onto column space of A:
[6.3333; 7.6667; 9.0000]
```

---

### `undo`
Reverts to the previous matrix state using the global matrix history.  
**Usage:**  
```matlab
result = undo()
```
**Example Input:**
```matlab
undo()
```
**Example Output:**
```
Previous matrix restored.
```

---

### `rel_coords`
Calculates the coordinates of a vector relative to a (possibly orthogonal or orthonormal) basis.  
**Usage:**  
```matlab
coords = rel_coords(basis, vector)
coords = rel_coords(basis, vector, 'norm') % for orthonormal basis
```
**Example Input:**
```matlab
B = {[2;0;0], [0;3;0], [0;0;4]};
v = [4;6;8];
rel_coords(B, v)
```
**Example Output:**
```
Coordinates relative to the given basis:
[2; 2; 2]
```

---

### `eigen_helper`
Computes eigenvalues, regular eigenvectors, and generalized eigenvectors for a square matrix.  
**Usage:**  
```matlab
[V, lambda, isGeneralized] = eigen_helper(A)
[V, lambda, isGeneralized] = eigen_helper(A, 'stoch')  % for stochastic matrices
```
**Example Input:**
```matlab
A = [6 2 1; 0 3 1; 0 0 3];
[V, lambda, isGen] = eigen_helper(A, 'stoch')
```
**Example Output:**
```
Eigenvalues:
[6; 3; 3]
Eigenvectors:
[...]
```

---

### `format_exact`
Formats a numeric value in exact mathematical form, returning a fraction, surd, or decimal representation.  
**Usage:**  
```matlab
formatted = format_exact(value)
```
**Example Input:**
```matlab
result = format_exact(0.3333333)
```
**Example Output:**
```
1/3
```

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
5. Utilize `format_exact` for precise numerical formatting

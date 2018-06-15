## Run this through (a recent enough version of) Octave to (re)create
## 'octave.dat', using 'octave < octave.m'.

a_scalar = 1;
a_complex_scalar = i;
a_matrix = [1, 2; 3, 4];
a_complex_matrix = [1+2i, 3-4i; 5, -6];
a_range = 1 : 5;
a_string = [ "foo"; "bar" ];
a_3_d_array = zeros(2, 2, 2);
a_3_d_array(:,:,1) = a_matrix;
a_3_d_array(:,:,2) = a_matrix + 4;
a_complex_3_d_array = a_3_d_array;
a_complex_3_d_array(:,:,1) = a_complex_3_d_array(:,:,1) + i;
a_complex_3_d_array(:,:,2) = a_complex_3_d_array(:,:,2) - i;
a_struct = struct("a", a_scalar, "b", a_matrix, "c", "foo");
a_list = list(a_scalar, a_matrix, "foo");
a_cell = { a_scalar, a_matrix; "foo", "bar" };
a_bool = false;
a_bool_matrix = [ true, false ; false, true ];

save -ascii "octave.dat" a_*;

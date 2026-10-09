pow(0, _, _):-!.
pow(N, X, R):-N1 is N - 1, X1 is X, pow(N1, X1, R), R is X * X1.
% It doesn't work
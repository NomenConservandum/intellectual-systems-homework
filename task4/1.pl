pow(X, X, 1).
pow(Res, X, N):-N > 1, N1 is N - 1, pow(Res1, X, N1), Res is Res1 * X.
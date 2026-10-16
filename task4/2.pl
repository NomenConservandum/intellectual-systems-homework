f(0, 0):-!.
f(1, 1):-!.
f(N, F):-N1 is N - 1, f(N1, F1), N2 is N - 2, f(N2, F2), F is F1 + F2.
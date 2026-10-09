minDouble(X,Y,X):-X =< Y, !.
minDouble(_,Y,Y).

minTriple(X, Y, Z):-minDouble(X, Y, Min1), minDouble(Y, Z, Min2), minDouble(Min1, Min2, Min), write(Min).
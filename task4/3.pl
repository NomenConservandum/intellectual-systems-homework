h(0, _, _, _):-!.
h(N, Source, Auxiliary, Target):-
    N1 is N - 1, h(N1, Source, Target, Auxiliary),
    write("Move disk "), write(N), write(" from "), write(Source), write(" to "), write(Target), nl,
    h(N1, Auxiliary, Source, Target).

% h(3, 'A', 'B', 'C').
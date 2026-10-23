genl(N2,N2,[]):-!.
genl(N1,N2,[N1|L]):-
    N1 < N2, N is N1 + 3, genl(N,N2,L).

goal(N,L):-
    K is 3 * (N + 1) + 3,
    genl(3, K, L).

final(Num, Res):- goal(5, L1), append(L1, [Num], Res).
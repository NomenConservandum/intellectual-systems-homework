dedupe([], []).
dedupe([H|T], R) :-
    member(H, T),      % H appears again later
    !,                 % commit to skipping
    dedupe(T, R).
dedupe([H|T], [H|R]) :- % H does not appear later, let's keep it
    dedupe(T, R).

% правило
answer(L1, L2, Res):- append(L1, L2, C), dedupe(C, Res).

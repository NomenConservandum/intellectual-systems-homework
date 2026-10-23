remove(_, [], []).
remove(X, [X|T], R) :- !, remove(X, T, R).
remove(X, [H|T], R) :-
    remove(X, T, RT),
    R = [H|RT].

% remove("Вторник", ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"], Res).
% ugh
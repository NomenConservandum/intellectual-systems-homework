;;;********************************************************************
;;;  Раздел 2, задание 3. Упорядоченные факты (sotrudnik)
;;;
;;;  Условие:
;;;    Создать список из 4 упорядоченных фактов вида
;;;      (sotrudnik <fio> <otdel>)
;;;    Просмотреть полученный список.
;;;    а) удалить факт f-1;
;;;    б) изменить в факте f-3 значение <fio>.
;;;
;;;  Запуск: clips -f2 clips-labs/lab2_3_sotrudnik.clp
;;;********************************************************************

(clear)

;;; 1. Создание 4 упорядоченных фактов через assert
(assert (sotrudnik Ivanov IT)
        (sotrudnik Petrov Buchgalteria)
        (sotrudnik Sidorov Kadry)
        (sotrudnik Smirnov Logistika))

;;; 2. Просмотр полученного списка фактов (f-1 .. f-4)
(printout t "--- Исходный список фактов (4 сотрудника) ---" crlf)
(facts)

;;; 3. а) Удаление факта f-1
(retract 1)
(printout t "--- После удаления f-1 ---" crlf)
(facts)

;;; 4. б) Изменение в факте f-3 значения <fio> (Sidorov -> Sokolov)
(retract 3)
(assert (sotrudnik Sokolov Kadry))

(printout t "--- Итоговый список фактов после изменения <fio> в f-3 ---" crlf)
(facts)
(exit)


;;;********************************************************************
;;;  Раздел 3, задание 1 (части А и Б).
;;;  Неупорядоченные факты, modify, duplicate, save-facts, load-facts
;;;
;;;  Запуск: clips -f2 clips-labs/lab3_1_run.clp
;;;********************************************************************

;;; ==================== ЧАСТЬ А ====================
(clear)
(load "clips-labs/lab3_1_template.clp")
(load-facts "clips-labs/lab3_1_facts.clp")

(printout t "=== Часть А: исходные загруженные факты ===" crlf)
(facts)

;;; В факте f-1 изменить значение слота citi
(modify 1 (citi Saratov))

;;; В факте f-2 изменить фамилию (слот name)
(modify 2 (name Smirnov))

;;; Факт f-3 продублировать, изменив слот in
(duplicate 3 (in 1004))

(printout t "=== Часть А: после modify (f-1, f-2) и duplicate (f-3) ===" crlf)
(facts)

;;; Сохранить полученный список фактов
(save-facts "clips-labs/lab3_1_facts_a.clp")

;;; ==================== ЧАСТЬ Б ====================
(clear)
(load "clips-labs/lab3_1_template.clp")
(load-facts "clips-labs/lab3_1_facts_a.clp")

(printout t "=== Часть Б: загруженный список фактов из части А ===" crlf)
(facts)

;;; Добавить 2 новых неупорядоченных факта с помощью assert
;;; (у Orlov для слота citi подставится значение по умолчанию Moskva)
(assert (client (name Orlov) (in 1005))
        (client (name Volkov) (in 1006) (citi Sochi)))

(printout t "=== Часть Б: после добавления 2 новых фактов ===" crlf)
(facts)

;;; Удалить факты с индексами 1 и 3
(retract 1 3)

(printout t "=== Часть Б: итоговый список фактов после удаления f-1 и f-3 ===" crlf)
(facts)

;;; Сохранить полученный список фактов в другой файл
(save-facts "clips-labs/lab3_1_facts_b.clp")
(exit)


;;;********************************************************************
;;;  Раздел 7, задание 4. Обработка строковых величин
;;;
;;;  Условие:
;;;    Создайте функцию, добавляющую к заданной строке справа указанное
;;;    количество символов '*', и правило, которое вводит две строки и
;;;    выравнивает их длины, добавляя к меньшей символы '*'.
;;;
;;;  Запуск в CLIPS:
;;;    (clear)
;;;    (load "clips-labs/lab7_4_align_stars.clp")
;;;    (reset)
;;;    (run)
;;;********************************************************************

;;; Функция добавления ?count символов '*' справа к строке ?str
(deffunction add-stars (?str ?count)
   (if (> ?count 0)
       then
       (loop-for-count (?i 1 ?count) do
          (bind ?str (str-cat ?str "*"))))
   ?str)

(defrule align_strings "Ввод двух строк и выравнивание их длин символами '*'"
   =>
   (printout t "Введите первую строку: ")
   (bind ?s1 (readline))
   (printout t "Введите вторую строку: ")
   (bind ?s2 (readline))
   (bind ?n1 (str-length ?s1))
   (bind ?n2 (str-length ?s2))
   (if (< ?n1 ?n2)
       then (bind ?s1 (add-stars ?s1 (- ?n2 ?n1)))
       else (if (< ?n2 ?n1)
                then (bind ?s2 (add-stars ?s2 (- ?n1 ?n2)))))
   (printout t "Строка 1: " ?s1 crlf)
   (printout t "Строка 2: " ?s2 crlf))


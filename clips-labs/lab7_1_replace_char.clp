;;;********************************************************************
;;;  Раздел 7, задание 1. Обработка строковых величин
;;;
;;;  Условие:
;;;    Создайте правило, заменяющее в строке один указанный символ
;;;    другим.
;;;
;;;  Запуск в CLIPS:
;;;    (clear)
;;;    (load "clips-labs/lab7_1_replace_char.clp")
;;;    (reset)
;;;    (run)
;;;********************************************************************

(defrule replace_char "Замена всех вхождений указанного символа на другой"
   =>
   (printout t "Введите строку: ")
   (bind ?str (readline))
   (printout t "Введите заменяемый символ: ")
   (bind ?old (readline))
   (printout t "Введите новый символ: ")
   (bind ?new (readline))
   (if (= (str-length ?old) 0)
       then
       (printout t "Результат: " ?str crlf)
       else
       (bind ?old-len (str-length ?old))
       (bind ?rest ?str)
       (bind ?res "")
       (bind ?pos (str-index ?old ?rest))
       (while (neq ?pos FALSE) do
          (bind ?prefix (sub-string 1 (- ?pos 1) ?rest))
          (bind ?res (str-cat ?res ?prefix ?new))
          (bind ?rest (sub-string (+ ?pos ?old-len) (str-length ?rest) ?rest))
          (bind ?pos (str-index ?old ?rest)))
       (bind ?res (str-cat ?res ?rest))
       (printout t "Результат: " ?res crlf)))


;;;********************************************************************
;;;  Раздел 7, задание 5. Обработка строковых величин
;;;
;;;  Условие:
;;;    Создайте функцию, позволяющую удалить из строки лишние пробелы,
;;;    оставив по одному между словами.
;;;
;;;  Запуск в CLIPS:
;;;    (clear)
;;;    (load "clips-labs/lab7_5_trim_spaces.clp")
;;;    (reset)
;;;    (run)
;;;********************************************************************

;;; Функция удаления лишних пробелов (включая ведущие, хвостовые и подряд идущие)
(deffunction remove-extra-spaces (?str)
   ;;; Сжимаем все двойные пробелы в одиночные
   (bind ?pos (str-index "  " ?str))
   (while (neq ?pos FALSE) do
      (bind ?left (sub-string 1 ?pos ?str))
      (bind ?right (sub-string (+ ?pos 2) (str-length ?str) ?str))
      (bind ?str (str-cat ?left ?right))
      (bind ?pos (str-index "  " ?str)))
   ;;; Удаляем ведущий пробел, если есть
   (if (and (> (str-length ?str) 0) (eq (sub-string 1 1 ?str) " "))
       then (bind ?str (sub-string 2 (str-length ?str) ?str)))
   ;;; Удаляем хвостовой пробел, если есть
   (bind ?len (str-length ?str))
   (if (and (> ?len 0) (eq (sub-string ?len ?len ?str) " "))
       then (bind ?str (sub-string 1 (- ?len 1) ?str)))
   ?str)

(defrule trim_spaces_rule "Ввод строки и удаление лишних пробелов"
   =>
   (printout t "Введите строку: ")
   (bind ?str (readline))
   (bind ?clean (remove-extra-spaces ?str))
   (printout t "Результат: \"" ?clean "\"" crlf))


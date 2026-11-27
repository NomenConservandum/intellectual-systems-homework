;;;********************************************************************
;;;  Раздел 5, задание 2. Процедурные функции
;;;
;;;  Условие:
;;;    Создать правило spisok_sotr, которое запрашивает количество
;;;    сотрудников, вводит ФИО и должность каждого и добавляет факты
;;;    вида (sotrudnik <фамилия> <должность>).
;;;
;;;  Запуск в CLIPS:
;;;    (clear)
;;;    (load "clips-labs/lab5_2_spisok_sotr.clp")
;;;    (reset)
;;;    (run)
;;;    (facts)
;;;********************************************************************

(defrule spisok_sotr "Ввод списка сотрудников и добавление фактов sotrudnik"
   =>
   (printout t "Введите количество сотрудников n: ")
   (bind ?n (read))
   (while (or (not (integerp ?n)) (< ?n 0)) do
      (printout t "Ошибка: введите целое неотрицательное число n: ")
      (bind ?n (read)))
   (loop-for-count (?i 1 ?n) do
      (printout t "Сотрудник #" ?i " — фамилия (ФИО): ")
      (bind ?fio (readline))
      (while (eq ?fio "") do
         (bind ?fio (readline)))
      (printout t "Сотрудник #" ?i " — должность: ")
      (bind ?dolzh (readline))
      (while (eq ?dolzh "") do
         (bind ?dolzh (readline)))
      (assert (sotrudnik ?fio ?dolzh)))
   (printout t "Добавлено фактов: " ?n crlf))


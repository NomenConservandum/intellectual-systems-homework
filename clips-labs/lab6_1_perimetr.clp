;;;********************************************************************
;;;  Раздел 6, задание 1. Функции пользователя
;;;
;;;  Условие:
;;;    Создать функцию для вычисления длины отрезка по координатам
;;;    его концов (a1, a2) и (b1, b2):
;;;      D = sqrt((b1 - a1)^2 + (b2 - a2)^2)
;;;    Используя данную функцию, найти периметр треугольника по
;;;    координатам его вершин.
;;;
;;;  Запуск в CLIPS:
;;;    (clear)
;;;    (load "clips-labs/lab6_1_perimetr.clp")
;;;    (reset)
;;;    (run)
;;;********************************************************************

;;; Функция вычисления длины отрезка по координатам концов (a1, a2) и (b1, b2)
(deffunction segment-length (?a1 ?a2 ?b1 ?b2)
   (sqrt (+ (** (- ?b1 ?a1) 2) (** (- ?b2 ?a2) 2))))

;;; Функция вычисления периметра треугольника по координатам вершин A, B, C
(deffunction triangle-perimeter (?x1 ?y1 ?x2 ?y2 ?x3 ?y3)
   (+ (segment-length ?x1 ?y1 ?x2 ?y2)
      (segment-length ?x2 ?y2 ?x3 ?y3)
      (segment-length ?x3 ?y3 ?x1 ?y1)))

(defrule perimetr_treug "Ввод координат вершин и вычисление периметра треугольника"
   =>
   (printout t "Введите x1 (вершина A): ")
   (bind ?x1 (read))
   (printout t "Введите y1 (вершина A): ")
   (bind ?y1 (read))
   (printout t "Введите x2 (вершина B): ")
   (bind ?x2 (read))
   (printout t "Введите y2 (вершина B): ")
   (bind ?y2 (read))
   (printout t "Введите x3 (вершина C): ")
   (bind ?x3 (read))
   (printout t "Введите y3 (вершина C): ")
   (bind ?y3 (read))
   (bind ?ab (segment-length ?x1 ?y1 ?x2 ?y2))
   (bind ?bc (segment-length ?x2 ?y2 ?x3 ?y3))
   (bind ?ca (segment-length ?x3 ?y3 ?x1 ?y1))
   (bind ?p (triangle-perimeter ?x1 ?y1 ?x2 ?y2 ?x3 ?y3))
   (printout t "AB = " ?ab ", BC = " ?bc ", CA = " ?ca crlf)
   (printout t "Периметр треугольника P = " ?p crlf))

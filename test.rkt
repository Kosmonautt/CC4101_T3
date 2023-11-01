#lang play
(require "T3.rkt")

(print-only-errors #t)

#| P1 |#

#| Parte A |#

(test (parse-type 'Number) (numT))
(test (parse-type '(-> Number Number)) (arrowT (numT) (numT)))
(test (parse-type '(-> (-> Number Number) Number)) (arrowT (arrowT (numT) (numT)) (numT)))
(test (parse-type '(-> (-> (-> Number Number) (-> Number Number)) (-> Number Number))) (arrowT (arrowT (arrowT (numT) (numT)) (arrowT (numT) (numT))) (arrowT (numT) (numT))))

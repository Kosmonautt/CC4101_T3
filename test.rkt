#lang play
(require "T3.rkt")

(print-only-errors #t)

#| P1 |#

#| Parte A |#

(test (parse-type 'Number) (numT))
(test (parse-type '(-> Number Number)) (arrowT (numT) (numT)))
(test (parse-type '(-> (-> Number Number) Number)) (arrowT (arrowT (numT) (numT)) (numT)))
(test (parse-type '(-> (-> (-> Number Number) (-> Number Number)) (-> Number Number))) (arrowT (arrowT (arrowT (numT) (numT)) (arrowT (numT) (numT))) (arrowT (numT) (numT))))

#| Parte B |#

(test (infer-type (num 1) empty-tenv) (numT))
(test (infer-type (binop '+ (num 2) (num 4)) empty-tenv) (numT))
(test (infer-type (binop '+ (num 2) (binop '+ (num 2) (num 4))) empty-tenv) (numT))
(test (infer-type (binop '- (num 2) (num 4)) empty-tenv) (numT))
(test (infer-type (binop '- (num 2) (binop '- (num 2) (num 4))) empty-tenv) (numT))
(test (infer-type (binop '* (num 2) (num 4)) empty-tenv) (numT))
(test (infer-type (binop '* (num 2) (binop '* (num 2) (num 4))) empty-tenv) (numT))
(test (infer-type (binop '* (num 2) (binop '+ (binop '- (num 10) (num 5)) (num 4))) empty-tenv) (numT))
(test (infer-type (id 'x) (extend-tenv 'x (numT) empty-tenv) ) (numT))
(test (infer-type (id 'y) (extend-tenv 'y (arrowT (numT) (numT)) empty-tenv) ) (arrowT (numT) (numT)))
(test (infer-type (fun 'x (numT) (id 'x)) empty-tenv) (arrowT (numT) (numT)))
(test (infer-type (fun 'x (numT) (binop '+ (id 'x) (num 1))) empty-tenv) (arrowT (numT) (numT)))
(test (infer-type (fun 'x (arrowT (numT) (numT)) (id 'x)) empty-tenv) (arrowT (arrowT (numT) (numT)) (arrowT (numT) (numT))))
; (test (infer-type (app (fun 'x (numT) (id 'x)) (num 2))) (numT))
(test/exn (infer-type (binop '+ (num 1) (fun 'x (numT) (id 'x))) empty-tenv) "infer-type: invalid operand type for +")
(test/exn (infer-type (binop '- (num 1) (fun 'x (numT) (id 'x))) empty-tenv) "infer-type: invalid operand type for -")
(test/exn (infer-type (binop '* (num 1) (fun 'x (numT) (id 'x))) empty-tenv) "infer-type: invalid operand type for *")
; (test/exn (infer-type (app (num 1) (num 2)) empty-tenv) "infer-type: function application to a non-function") 
; (test/exn (infer-type (app (fun 'x (numT) (id 'x)) (fun 'x (numT) (id 'x))) empty-tenv) "infer-type: function argument type mismatch")
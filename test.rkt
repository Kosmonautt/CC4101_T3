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
(test (infer-type (fun 'x (numT) (num 2)) empty-tenv) (arrowT (numT) (numT)))
(test (infer-type (fun 'x (numT) (binop '+ (id 'x) (num 1))) empty-tenv) (arrowT (numT) (numT)))
(test (infer-type (fun 'x (arrowT (numT) (numT)) (id 'x)) empty-tenv) (arrowT (arrowT (numT) (numT)) (arrowT (numT) (numT))))
(test (infer-type (app (fun 'x (numT) (id 'x)) (num 2)) empty-tenv) (numT))
(test (infer-type (app (fun 'x (numT) (num 5)) (num 2)) empty-tenv) (numT))
(test (infer-type (app (fun 'y (arrowT (numT) (numT)) (num 5)) (fun 'x (numT) (binop '* (num 2) (id 'x)))) empty-tenv) (numT))
(test/exn (infer-type (binop '+ (num 1) (fun 'x (numT) (id 'x))) empty-tenv) "infer-type: invalid operand type for +")
(test/exn (infer-type (binop '- (num 1) (fun 'x (numT) (id 'x))) empty-tenv) "infer-type: invalid operand type for -")
(test/exn (infer-type (binop '* (num 1) (fun 'x (numT) (id 'x))) empty-tenv) "infer-type: invalid operand type for *")
(test/exn (infer-type (app (num 1) (num 2)) empty-tenv) "infer-type: function application to a non-function") 
(test/exn (infer-type (app (fun 'x (numT) (id 'x)) (fun 'x (numT) (id 'x))) empty-tenv) "infer-type: function argument type mismatch")

#| Parte B |#

;; función parse
(test (parse 'true) (tt))
(test (parse 'false) (ff))


;; función parse-type
(test (parse-type 'Boolean) (boolT))
(test (parse-type '(-> Boolean Boolean)) (arrowT (boolT) (boolT)))
(test (parse-type '(-> Number Boolean)) (arrowT (numT) (boolT)))
(test (parse-type '(-> Boolean Number)) (arrowT (boolT) (numT)))
(test (parse-type '(-> Boolean Number)) (arrowT (boolT) (numT)))
(test (parse-type '(-> (-> (-> Boolean Number) (-> Number Boolean)) (-> Boolean Boolean))) (arrowT (arrowT (arrowT (boolT) (numT)) (arrowT (numT) (boolT))) (arrowT (boolT) (boolT))))


;; función infer-type
(test (infer-type (tt) empty-tenv) (boolT))
(test (infer-type (ff) empty-tenv) (boolT))
(test/exn (infer-type (binop '+ (num 1) (tt)) empty-tenv) "infer-type: invalid operand type for +")
(test (infer-type (id 'b) (extend-tenv 'b (boolT) empty-tenv) ) (boolT))
(test (infer-type (fun 'b (boolT) (id 'b)) empty-tenv) (arrowT (boolT) (boolT)))
(test (infer-type (fun 'b (numT) (tt)) empty-tenv) (arrowT (numT) (boolT)))
(test (infer-type (fun 'b (numT) (ff)) empty-tenv) (arrowT (numT) (boolT)))
(test (infer-type (app (fun 'b (boolT) (id 'b)) (tt)) empty-tenv) (boolT))
(test (infer-type (app (fun 'b (boolT) (id 'b)) (ff)) empty-tenv) (boolT))
(test/exn (infer-type (app (tt) (num 2)) empty-tenv) "infer-type: function application to a non-function") 
(test/exn (infer-type (app (fun 'b (boolT) (id 'b)) (num 2)) empty-tenv) "infer-type: function argument type mismatch")
(test/exn (infer-type (app (fun 'x (numT) (id 'x)) (tt)) empty-tenv) "infer-type: function argument type mismatch")



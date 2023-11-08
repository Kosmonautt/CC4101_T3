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

;; función in-list
(test (in-list '+ (list '+ '- '*)) true)
(test (in-list '- (list '+ '- '*)) true)
(test (in-list '* (list '+ '- '*)) true)
(test (in-list '<= (list '+ '- '*)) false)
(test (in-list '+ (list '<=)) false)
(test (in-list '- (list '<=)) false)
(test (in-list '* (list '<=)) false)
(test (in-list '<= (list '<=)) true)

;; función parse
(test (parse 'true) (tt))
(test (parse 'false) (ff))

(test (parse '(<= 1 2)) (binop '<= (num 1) (num 2)))
(test (parse '(<= 5 2)) (binop '<= (num 5) (num 2)))

(test (parse '(if (<= 5 6) true false)) (ifc (binop '<= (num 5) (num 6)) (tt) (ff)))
(test (parse '(if (<= 5 6) 2 3)) (ifc (binop '<= (num 5) (num 6)) (num 2) (num 3)))
(test (parse '(if true 1 0)) (ifc (tt) (num 1) (num 0)))
(test (parse '(if false 1 0)) (ifc (ff) (num 1) (num 0)))

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

(test (infer-type (binop '<= (num 1) (num 2)) empty-env) (boolT))
(test (infer-type (binop '<= (num 5) (num 2)) empty-env) (boolT))
(test/exn (infer-type (binop '<= (num 1) (ff)) empty-env) "infer-type: invalid operand type for <=")
(test/exn (infer-type (binop '<= (tt) (num 1)) empty-env) "infer-type: invalid operand type for <=")
(test (infer-type (binop '<= (binop '+ (num 2) (num 4)) (binop '* (num 2) (binop '+ (binop '- (num 10) (num 5)) (num 4)))) empty-env) (boolT))

(test (infer-type (ifc (binop '<= (num 5) (num 6)) (num 2) (num 3)) empty-env) (numT))
(test (infer-type (ifc (binop '<= (num 5) (num 6)) (tt) (ff)) empty-env) (boolT))
(test (infer-type (ifc (app (fun 'b (boolT) (id 'b)) (tt)) (num 2) (num 3)) empty-env) (numT))
(test (infer-type (ifc (app (fun 'b (boolT) (id 'b)) (ff)) (num 2) (num 3)) empty-env) (numT))
(test/exn (infer-type (ifc (num 5) (num 2) (num 3)) empty-tenv) "infer-type: if condition must be a boolean")
(test/exn (infer-type (ifc (fun 'b (numT) (ff)) (num 2) (num 3)) empty-tenv) "infer-type: if condition must be a boolean")
(test/exn (infer-type (ifc (binop '<= (num 5) (num 6)) (num 2) (tt)) empty-tenv) "infer-type: if branches type mismatch")

#| P2 |#

#| Parte A |#

(test (final? (num 1)) #t)
(test (final? (fun 'x (numT) (id 'x))) #t)
(test (final? (fun 'x (numT) (binop + (num 2) (num 7)))) #t)
(test (final? (fun 'x (numT) (binop + (id 'x) (num 7)))) #t)
(test (final? (fun 'x (numT) (binop + (binop * (id 'x) (num 5)) (num 7)))) #t)
(test (final? (binop '+ (num 1) (num 2))) #f)
(test (final? (binop '- (num 4) (num 2))) #f)
(test (final? (binop '* (num 1) (num 7))) #f)
(test (final? (binop '+ (binop '- (num 4) (num 2)) (binop '* (num 1) (num 7)))) #f)
(test (final? (id 'x)) #f)
(test (final? (app (fun 'x (numT) (id 'x)) (num 2))) #f)
(test (final? (app (fun 'x (numT) (binop + (num 2) (num 7))) (num 2))) #f)
(test (final? (app (fun 'x (numT) (binop + (id 'x) (num 7))) (num 2))) #f)
(test (final? (app (fun 'x (numT) (binop + (binop * (id 'x) (num 5)) (num 7))) (num 2))) #f)

#| Parte D |#

(test (inject (num 1)) (st (num 1) empty-env empty-kont))
(test (inject (binop '* (num 2) (binop '+ (binop '- (num 10) (num 5)) (num 4))) ) (st (binop '* (num 2) (binop '+ (binop '- (num 10) (num 5)) (num 4)))  empty-env empty-kont))
(test (inject (id 'x)) (st (id 'x) empty-env empty-kont))
(test (inject (fun 'x (numT) (id 'x))) (st (fun 'x (numT) (id 'x)) empty-env empty-kont))
(test (inject (app (fun 'x (numT) (id 'x)) (num 2))) (st (app (fun 'x (numT) (id 'x)) (num 2)) empty-env empty-kont))

#| Parte E |#

(test (step (st (binop '+ (num 1) (num 2)) (mtEnv) (mt-k))) (st (num 1) (mtEnv) (binop-r-k '+ (num 2) (mtEnv) (mt-k))))
(test (step (st (num 1) (mtEnv) (binop-r-k '+ (num 2) (mtEnv) (mt-k)))) (st (num 2) (mtEnv) (binop-l-k '+ (num 1) (mtEnv) (mt-k))))
(test (step (st (num 2) (mtEnv) (binop-l-k '+ (num 1) (mtEnv) (mt-k)))) (st (num 3) (mtEnv) (mt-k)))

(test (step (st (app (fun 'x (numT) (id 'x)) (num 2)) (mtEnv) (mt-k))) (st (fun 'x (numT) (id 'x)) (mtEnv) (arg-k (num 2) (mtEnv) (mt-k))))
(test (step (st (fun 'x (numT) (id 'x)) (mtEnv) (arg-k (num 2) (mtEnv) (mt-k)))) (st (num 2) (mtEnv) (fun-k (fun 'x (numT) (id 'x)) (mtEnv) (mt-k))))
(test (step (st (num 2) (mtEnv) (fun-k (fun 'x (numT) (id 'x)) (mtEnv) (mt-k)))) (st (id 'x) (extend-env 'x (cons (num 2) (mtEnv)) (mtEnv)) (mt-k)))
(test (step (st (id 'x) (extend-env 'x (cons (num 2) (mtEnv)) (mtEnv)) (mt-k))) (st (num 2) (mtEnv) (mt-k)))
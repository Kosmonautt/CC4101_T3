#lang play


#|
  Expr  ::= <num>
          | (+ <Expr> <Expr>)
          | (- <Expr> <Expr>)
          | (* <Expr> <Expr>)
          | (<= <Expr> <Expr>)
          | (tt)
          | (ff)
          | (ifc <Expr> <Expr> <Expr>)
          | <id>
          | (fun (<id> : <Type>) <Expr>)
          | (<Expr> <Expr>);
|#
(deftype Expr
  ;; core
  (num n)
  (binop op l r)
  (tt)
  (ff)
  (ifc c t e)
  ;; unary first-class functions
  (id x)
  (fun binder binderType body)
  (app callee arg)
  )

#| BEGIN P1 |#

#|
  Type ::= (number)
         | (boolT)
         | (arrow Type Type) 

|#
;; Datatype que representa tipos (número, función, bool, ...) en el lenguaje


(deftype Type 
  (numT)
  (boolT)
  (arrowT input output))

;; parse-type : s-expr -> Type 
;; Pasa un expresión s-expr a una Type
(define (parse-type t)
  (match t
    [n #:when (equal? n 'Number) (numT)]
    [b #:when (equal? b 'Boolean) (boolT)]
    [(list '-> in out) (arrowT (parse-type in) (parse-type out))]))

;; parse : s-expr -> Expr
(define (parse s)
  (match s
    [n #:when (number? n) (num n)]
    [b #:when (equal? b 'true) (tt)] 
    [b #:when (equal? b 'false) (ff)] 
    [x #:when (symbol? x) (id x)]
    [(list '+ l r) (binop '+ (parse l) (parse r))]
    [(list '- l r) (binop '- (parse l) (parse r))]
    [(list '* l r) (binop '* (parse l) (parse r))]
    [(list '<= l r) (binop '<= (parse l) (parse r))]
    [(list 'if c t e) (ifc (parse c) (parse t) (parse e))]
    [(list 'fun (list binder ': type) body) (fun binder (parse-type type) (parse body))]
    [(list callee arg) (app (parse callee) (parse arg))]
    [_ (error 'parse "invalid syntax: ~a" s)]))

;; Implementación de ambientes de tipos
;; (análoga a la de ambientes de valores)

;; TypeEnv ::= ⋅ | <TypeEnv>, <id> : <Type>
(deftype TypeEnv (mtTenv) (aTenv id type env))
(define empty-tenv (mtTenv))
(define extend-tenv aTenv)

(define (tenv-lookup x env)
  (match env
    [(mtTenv) (error 'tenv-lookup "free identifier: ~a" id)]
    [(aTenv id type rest) (if (symbol=? id x) type (tenv-lookup x rest))]
    ))

;; in-list :: Symbol Listof(Symbol) -> bool
;; revisa si un simbolo está en una lista de simbolos, si es que
;; está retorna true, si no, retorna false
(define (in-list s l)
  (match l
    [(cons h t) (if (equal? s h) true (in-list s t))]
    [t (if (equal? s t) true false)]
    ['() false]))

;; infer-type : Expr tenv -> Type
;; Función que recibe una Expr y retorna su Type
(define (infer-type expr tenv) 
  (match expr
    [(num n) (numT)]
    [(binop op l r)
            (if (and (equal? (infer-type l tenv) (numT)) (equal? (infer-type r tenv) (numT))) 
              (if (in-list op (list '+ '- '*))
                (numT)
                (boolT))
              (error 'infer-type "invalid operand type for ~a" op))]
    [(ifc c t e) 
              (if (equal? (infer-type c tenv) (boolT))
                (if (equal? (infer-type t tenv) (infer-type e tenv))
                  (infer-type t tenv)
                  (error "infer-type: if branches type mismatch"))
                (error "infer-type: if condition must be a boolean"))]
    [(tt) (boolT)]
    [(ff) (boolT)]
    [(id s) (tenv-lookup s tenv)]
    [(fun s T1 e)
              (define T2 (infer-type e (extend-tenv s T1 tenv)))
              (arrowT T1 T2)]
    [(app e1 e2)
        (define e1-type (infer-type e1 tenv))
        (define e2-type (infer-type e2 tenv))

        (match e1-type
          [(arrowT T1 T2) 
                    (if (equal? T1 e2-type)
                          T2
                          (error "infer-type: function argument type mismatch"))]
          [_ (error "infer-type: function application to a non-function")])]))

#| END P1 |#

#| BEGIN P2 PREAMBLE |#

;; ambiente de sustitución diferida
(deftype Env
  (mtEnv)
  (aEnv id val env))

;; interface ADT (abstract data type) del ambiente
(define empty-env (mtEnv))

;; "Simplemente" asigna un nuevo identificador para aEnv
;(define extend-env aEnv)
;;
;; es lo mismo que definir extend-env así:
;; (concepto técnico 'eta expansion')
(define (extend-env id val env) (aEnv id val env))

(define (env-lookup x env)
  (match env
    [(mtEnv) (error 'env-lookup "free identifier: ~a" x)]
    [(aEnv id val rest) (if (symbol=? id x) val (env-lookup x rest))]))

;; num2num-op : (Number Number -> Number) -> Val Val -> Val
(define (num2num-op op)
  (λ (l r)
    (match (cons l r)
      [(cons (num n) (num m)) (num (op n m))]
      [_ (error 'num-op "invalid operands")])))


(define num+ (num2num-op +))
(define num- (num2num-op -))
(define num* (num2num-op *))

#| END P2 PREAMBLE |#

#| BEGIN P2 |#

;; final? : Expr -> Bool
;; Función que revisa si la expresión corresponde a un valor, si lo es retorna true, si no, retorna false
(define (final? e) 
  (match e
    [(num 1) #t]
    [(fun s T1 e) #t]
    [_ #f]))

#|
  Kont ::= (mt-k)
         | (binop-r-k r r-env <Kont>)
         | (binop-l-k l-eval l-env <Kont>)
         | (arg-k arg arg-env <Kont>)
         | (fun-k fun-eval fun-env <Kont>)

|#
;; Datatype que representa el stack de acciones por realizar
(deftype Kont
  (mt-k) ; empty kont
  (binop-r-k r r-env ref-last)
  (binop-l-k l-eval l-env ref-last)
  (arg-k arg arg-env ref-last)
  (fun-k fun-eval fun-env ref-last))

(define empty-kont (mt-k))

;; State ::= (<Expr>, <Env>, <Kont>)
;; Datatype que representa el estado de la máquina CEK
(deftype State
  (st expr env kont))

;; inject : ...
(define (inject expr) 
  (st expr empty-env empty-kont))

;; step : ...
(define (step c) '???)

;; eval : Expr -> Expr
(define (eval expr)
  (define (eval-until-final state)
    (def (st expr _ kont) state)
    (if (and (final? expr) (mt-k? kont))
        expr
        (eval-until-final (step state))))
  (eval-until-final (inject expr)))

;; run : ...
(define (run s-expr) '???)

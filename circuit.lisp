(load "src/Prelude.lampas")

" builtin features of book's lisp
"
(define 
  (set key val hash)
  (push (map
    (lambda (item)
      (if
        (equal? (car item) key)
        (list key val)
        item))
    hash) (list key val)))
(define (assocv key hash) (cadr (assoc key hash)))
(define
  (let-set vars expr)
  (if
    (null? vars)
    expr
    (list (list 'lambda (list (car (car vars))) (let-set (cdr vars) expr)) (car (cdr (car vars))))))
(defmacro (let* vars expr) (let-set vars expr))
  
(let*      
  ((make-gate
    (lambda
      (value get set)
      (list
        (list 'value value)
        (list 'get get)
        (list 'set set))))
   (const-gate 
    (lambda
      (value)
      (make-gate 
        value
        (lambda (obj env) (assocv 'value obj))
        (lambda (obj value) (set 'value value obj)))))
   (get-gate
    (lambda
      (name env)
      ((lambda (gate) ((assocv 'get gate) gate env)) (assocv name env))))
   (set-gate
    (lambda
      (name value env)
      (set name value env)))            
   (fn-gate 
    (lambda
      (fn a b)
      (make-gate 
        (lambda (a b) (fn a b))
        (lambda (obj env) 
          ((assocv 'value obj) 
             (get-gate a env)
             (get-gate b env)))
        (lambda (obj value) obj))))
   (or-gate (lambda (a b) (fn-gate (lambda (a b) (or a b)) a b)))
   (and-gate (lambda (a b) (fn-gate (lambda (a b) (and a b)) a b)))
   (not-gate (lambda (a) (fn-gate (lambda (a b) (not b)) a a))))
  (let* ((env (set-gate 'a (const-gate #t) '()))
   	   (env (set-gate 'b (const-gate #t) env))
   	   (env (set-gate '1 (or-gate 'a 'b) env))
   	   (env (set-gate '2 (and-gate 'a 'b) env))
   	   (env (set-gate '3 (not-gate '2) env))
   	   (env (set-gate '4 (and-gate '1 '3) env))
   	   (env (set-gate '5 (and-gate 'a 'b) env)))
   	 (write (list (get-gate '2 env) (get-gate '4 env)))))
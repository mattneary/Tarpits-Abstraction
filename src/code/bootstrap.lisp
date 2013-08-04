(load "src/Prelude.lampas")

" TODO: handle multiple passed arguments
"
(letrec eval (lambda (eval expr env) 
  (cond 
    (((atom? expr) (assocv expr env)) 
    ((eqv? (car expr) 'lambda) 
     (lambda (x) 5))
    ((atom? (car expr)) (eval (map (lambda (expr) (eval expr env)) expr) env))
    ((eqv? (car (car expr)) 'lambda) 
     ((lambda (argname) (eval (car (cdr (cdr (car expr)))) (set argname (cadr expr) env))) (car (car (cdr (car expr)))))))))
  (eval '((lambda (x) (x 2)) (lambda (x) x)) '((2 2))))
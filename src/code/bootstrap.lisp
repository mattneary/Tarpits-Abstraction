(load "src/Prelude.lampas")

"  TODO: handle multiple passed arguments.
"" TODO: `atom?` is not actually implemented.
"
(letrec eval (lambda (eval expr env) 
  (cond 
    (((atom? expr) (assocv expr env)) 
    ((equal? (car expr) 'lambda) 
     (lambda (x) 5))
    ((atom? (car expr)) (eval (map (lambda (expr) (eval expr env)) expr) env))
    ((equal? (car (car expr)) 'lambda) 
     ((lambda (argname) (eval (car (cdr (cdr (car expr)))) (set argname (cadr expr) env))) (car (car (cdr (car expr)))))))))
  (eval '((lambda (x) (x 2)) (lambda (x) x)) '((2 2))))
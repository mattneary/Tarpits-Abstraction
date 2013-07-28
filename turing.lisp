(load "src/Prelude.lampas")

" a builtin feature of book's lisp
"
(define
  (let-set vars expr)
  (if
    (null? vars)
    expr
    (list 'lambda (car vars) (let-set (cdr vars) expr))))
(defmacro (let* vars expr) (let-set vars expr))

" the lambda-reducible procedure
"
(let* 
  ((index 0)
   (rules '(((A 0) (1 R H))))
   (state 'A)
   (cadr (lambda (x) (car (cdr x))))
   (caddr (lambda (x) (car (cdr (cdr x)))))
   (move (lambda 
     (index motion)
     (if
       (equal? motion 'R)
       (+ 1 index)
       (- 1 index))))
  (iterate-rule (lambda
    (iterate rule rules index tape)
    (iterate
      (move index (cadr rule))
      rules
      (caddr rule)
      (write-rule tape index rule))))
  (letrec write-rule (lambda
    (write-rule tape index rule)
    (if
      (null? tape)
      tape
      (if
        (equal? index 0)
	(cons (car rule) (cdr tape))
	(cons (car tape) (write-rule (cdr tape) (- index 1) rule)))))
    (letrec iterate (lambda
      (iterate index rules state tape) 
      (if 
        (equal? state 'H)
        tape
        (iterate-rule 
	  iterate
          (cadr (assoc (list state index) rules))
          rules
          index
          tape)))
      (write (iterate index rules state '(0 0 0))))))

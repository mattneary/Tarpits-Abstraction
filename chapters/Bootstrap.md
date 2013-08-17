#Pulling Our Language up by Its Bootstraps
In the previous section, we successfully designed and implemented an
interpreter of the Lambda Calculus. This was a very interesting problem to
solve, because it allowed us to form a grammar of expression from within our working language; then allowing us to expand upon this grammar dynamically.

This achievement opens one up to question the limitations of the embedded
language. In other words, can we reach the language analog of *The 
Singularity*. The Singularity is the point at which sufficiently intelligent 
technology has been developed, as to enable this technology to form ever more 
advanced successive generations. In the analog of interest to us, we would be 
concerned with a language sufficiently advanced to form an interpreter of 
itself, and to then add features.

This phenomenon, the so-called singularity, is known in computation as a 
bootstrapped interpreter. In this section, we will aim to bootstrap our 
symbolic language, and to then unlock the potential of additional features.

##The Grammar
The grammar of our symbolic language is slightly more complex than the Lambda 
Calculus; however, it is luckily once again homoiconic. However, because we 
are now defining our grammar within another language, we will need to 
abstract over the implementation details of token representation. That is to 
say, although each string is a functional linked-list, we will consider them 
atomic just as in prior grammar definitions.

We return briefly to our formal definition of a Symbolic Expression from an 
earlier chapter; this time we will explicate the characters allowed in an 
`atom`.

```scheme
<expr> &::= <sexpr> | <atom>
<sexpr> &::= (<seq>)
<seq> &::= <dotted> | <list>
<dotted> &::= <expr> | <expr> . <expr>
<list> &::= <expr> | <expr> <exp>
<atom> &::= <char> | <atom> <char>
<char> &::= <letter> | <number> | <symbol>
<letter> &::= A | B | ... | Z
<number> &::= 0 | 1 | ... | 9
<symbol> &::= * | + | - | / | \# | < | > | _ | ?
```

Now, because we will be operating from within our Symbolic Language, we will 
be able to abstract away the details of the grammar. That is, S-Expressions 
will be represented as S-Expressions when provided as input to the 
interpreter, as will atoms as atoms.

##Lambda Forms
Recall from our definition of the Symbolic Language in terms of the Lambda 
Calculus that there were some functions considered more primitive to the 
language than others. We will expose these to the language which we 
interpret. Our first task is to enable the Lambda Calculus in these forms, 
not unlike in our earliest definition of the language.

```scheme
(letrec eval (eval expr env)
  (cond (((atom? expr) (assoc expr env))
         ((and 
            (atom? (car expr)) 
            (equal? (car expr) 'lambda)) 
          (lambda (x) 
            (eval 
              (caddr expr) 
              (set (cadr expr) x env))))
         (#t (apply-set 
           (eval (car expr) env) 
           (map (lambda (x) (eval x env)) (cdr expr)))))) ...)
```

This is all fine; however, notice that the arguments to the function are evaluated all at once and passed to the an applier-function. In the next section, we will discuss a better approach to evaluation.

##Laziness
This is not optimal, and does not allow for some nice features enabled by "laziness" in the interpreter. For this reason, we will change the application and variable reference components to reflect a lazy approach to evaluation.

```scheme
(letrec eval (eval expr env)
  (cond (((atom? expr) ((assoc expr env) nil))
         ((and 
            (atom? (car expr)) 
            (equal? (car expr) 'lambda)) 
          (lambda (x) 
            (eval 
              (caddr expr) 
              (set (cadr expr) x env))))
         (#t (apply-set 
           (eval (car expr) env) 
           (map (lambda (x) (eval '(lambda (_) x) env)) (cdr expr)))))) ...)
```

With very few changes we were able to implement this lazy approach. We simply made all arguments wrapped in a lambda before their evaluation, and all variable references then reduce these wrappings when appropriate. These small changes will make a world of difference in the potential of expressiveness in our language.

The most evident of advantages is in the ability to branch execution, i.e., perform `if` statements, without evaluating both branches. This later translates into the ability to recurse without invoking infinite recursion.

##Numbers
In order to interpret numbers, we would need our atomic values to be not so atomic. Rather than have atoms go against this nature, we will delay implementation of arbitrary numbers. For now, we will start with single digits.

```scheme
(let eval-prelude (lambda (expr env)
  (eval 
    expr
    (concat 
      env 
      '((0 (0)) (1 (1)) (2 (2)) (3 (3)) (4 (4)) 
        (5 (5)) (6 (6)) (7 (7)) (8 (8)) (9 (9)))))) ...)
```

The above is just another `eval` function, this time appending to the environment a prelude of definitions prior to calling the usual `eval` function. The equivalencies presented are merely from atom to singleton lists; no nature of numbers shows through. Why singletons? Numbers are lists of digits more than they are atomic values, after all, this is what allows us to perform arbitrary arithmetic.

There is one aspect of the environment that we failed to address in our setup 
of a prelude. Given the lazy nature of our interpreter in which all variable
access is reduction of a lambda, we will need to lambda wrap each set value.

```scheme
(let lazy-set (lambda (env hash)
  (concat
    env
    (map (lambda (pair) 
      (list 
        (car pair) 
        (lambda (z) (cadr pair)))) 
        hash))))
```

The above implements this lazy nature.

It will be our responsibility to implement arithmetic nature of these numbers 
by means of a `succ` function. As we have already shown, from this definition 
all else is possible.

```scheme
(let succ (lambda (x)
  (let singles '((0 (1)) (1 (2)) 
                 (2 (3)) (3 (4)) 
                 (4 (5)) (5 (6)) 
                 (6 (7)) (7 (8)) 
                 (8 (9)) (9 (0 1)))
    (cond (((null? (cdr x)) (assoc singles (car x)))
           ((equal? (car x) 9) (cons 0 (succ (cdr x))))
           (#t (cons (succ (car x)) (cdr x))))))) ...)
```

The above implementation is pretty simple; it is a very basic definition of the meaning of numbers in our decimal system. It says, "One follows zero; two follows one; etc." Next, it communicates the intricacies of place value. A number with a ones digit of nine will increment to a ones digit zero, with a once higher leading strand of digits. Finally, any other number with multiple digits will result in a once larger ones digit.

We will now expand our `eval-prelude` to be more extensible and to include the `succ` function.

```scheme
(let* 
  ((set-arithmetic (lambda (env)
     (set
       'succ
       (lambda (x) ...)
       env)))
   (set-numerals (lambda (env) 
     (lazy-set 
       env 
       '((0 (0)) (1 (1)) (2 (2)) (3 (3)) (4 (4)) 
         (5 (5)) (6 (6)) (7 (7)) (8 (8)) (9 (9))))))
   (eval-prelude (lambda (expr env)
     (eval 
       expr
       (set-arithmetic (set-numerals env)))))) ...)
```

##Booleans and Predicates
Our implementation of Booleans will be quite simple. Recall the use of atoms to symbolize numbers in the prior section, with the meaning of the numbers being more derived from the operations we defined than from their representation. The same will hold especially true for Booleans.

Our Booleans will be defined on the prelude by the names of `#t` and `#f`, as you have come to expect. Now, rather than decide on an arbitrary atom to which they will map, we will allow `#f` to equal `nil` and `#t` to equal `1`. Hence we would have a `set-booleans` definition to append to `let*` that looks like the following.

```scheme
(set-booleans (lambda (env)
  (lazy-set env (list (list '#t 1) (list '#f nil)))))
```

Given these definitions of true and false, we will now define an `if` 
function which follows very naturally from our native `if` function.

```scheme
(set-booleans (lambda (env) 
  (lazy-set 
    env
    (list 
      ...
      (list
        'if 
        (lambda (p t f)
          (if (null? x) f t))))))))
```

##List Primitives
The functions primitive to the manipulation of S-Expressions have yet to be 
discussed. The following is a list of these primitives.

- `car`
- `cdr`
- `cons`
- `eq?`
- `null?`
- `atom?`

These will be exposed to the interpreted language by means of the prelude.

```scheme
(set-primitives (lambda (env)
  (lazy-set
    env
    (list
      (list 'car car)
      (list 'cdr cdr)
      (list 'cons cons)
      (list 'eq? equal?)
      (list 'null? null?)
      (list 'atom? atom?)))))
```

##Recursion
Now, as was alluded to earlier, we will provide a Y combinator for the 
sake of recursion. Thanks to the lazy evaluation of our interpreter, this 
will be an easily achieved task.

Although combinators are possible without lazy evaluation, a function-based 
`if` statement is not; this is the key to our dependence on laziness. In the 
following, we set a Y-Combinator on the prelude.

```scheme
(set-Y (lambda (env)
  (lazy-set
    env
    (list (list 'Y (lambda (f) 
      ((lambda (x) (f (x x))) 
       (lambda (x) (f (x x))))))))))
```      

##Syntactic Sugars
In our definition of the language, we were sure to provide convenient 
shorthands and general niceties. Hence, we will now do the same within our 
interpreter.

Most of the syntactic constructs which we have yet to address are forms of 
`let`. For this reason, we begin with an exposure of `let` to the 
interpreter. `let` is merely syntactic sugar for reduction of a lambda; hence 
we provide the following implementation of let-forms.

```scheme
(letrec eval (eval expr env)
  (cond (((atom? expr) ((assoc expr env) nil))
         ((equal? (car expr) 'lambda) 
          (lambda (x) 
            (eval 
              (caddr expr) 
              (set (cadr expr) x env))))
         ((equal? (car expr) 'let)
          (eval 
            (list 
              (list 
                'lambda 
                (cadr expr) 
                (cadddr expr)) 
              (caddr expr)) env))
         (#t (apply-set 
           (eval (car expr) env) 
           (map (lambda (x) (eval '(lambda (_) x) env)) (cdr expr)))))) ...)
```

Note that this definition performs a rewrite of the S-Expression, and then
evaluates that new form. This is often referred to as a *macro*. Macros can
be exposed to the programmer of a language to allow for this same 
extensibility of the language from *within* the language.

Returning to our syntactic constructs, we similarly define `let*` forms. 
However, in this case, we will extract a function called `let-set` to avoid 
messiness in our main interpreter definition.

`let-set` is recursively defined, but its implementation is very similar to
that of `let`. If there are definitions to be applied, `let-set` creates a
wrapping lambda and reduces it with the first definition. Then, it recurses
until there are no more definitions to apply. At that time, it returns the
expression.

```scheme
(letrec let-set 
  (lambda (let-set defs expr)
    (if
      (null? defs)
      expr
      (list 
        (list 
          'lambda 
          (caar defs) 
          (let-set (cdr defs) expr)) 
        (cadar defs))))
  (letrec eval (eval expr env)
    (cond (...
           ((equal? (car expr) 'let*) 
            (eval (let-set (cadr expr) (caddr expr)) env))
           (#t ...))) ...))
```

Now, our last let-form is `letrec`. This syntax will be defined using the Y-
combinator, as alluded to earlier.

```scheme
(letrec eval (eval expr env)
  (cond (...
         ((equal? (car expr) 'letrec)
          (eval
            (list 
              'let 
              (cadr expr) 
              (list 'Y (caddr expr)) 
              (cadddr expr))
            env))
         (#t ...))) ...)
```

Once again we utilized a macro in our definition of a form; this time simply
applying the Y-Combinator prior to execution of `let`.

##The Evaluator
```scheme
(letrec let-set 
  (lambda (let-set defs expr)
    (...))
  (letrec apply-set (lambda (apply-set fn args)
    (letrec eval (eval expr env)
      (cond (((atom? expr) ((assoc expr env) nil))
             ((equal? (car expr) 'lambda) 
              (...))
             ((equal? (car expr) 'let)
              (...))
             ((equal? (car expr) 'let*) 
              (eval (let-set (cadr expr) (caddr expr)) env))
  	     ((equal? (car expr) 'letrec)
              (...))
             (#t (apply-set 
               (eval (car expr) env) 
               (map (lambda (x) (eval '(lambda (_) x) env)) (cdr expr))))))
      (let* ((lazy-set (lambda (env hash)
               (...)))
             (set-arithmetic (lambda (env)
               (...)))
             (set-numerals (lambda (env)
               (...)))
             (set-booleans (lambda (env)
               (...)))
             (set-primitives (lambda (env)
               (...)))
             (set-Y (lambda (env)
               (...)))
             (eval-prelude (lambda (expr env)
               (eval
               expr
               (set-arithmetic
                 (set-numerals
                   (set-booleans
                     (set-primitives
                      (set-Y env)))))))))
            (...))))))
```

##Conclusion
We have successfully defined an interpreter of the syntax of our language.
Even more interesting is the fact that we implemented this interpreter from
within the same language. By taking this route, we were able to reuse, or
*snarf*, some of the constructs of the language very easily in our
interpretation of it.
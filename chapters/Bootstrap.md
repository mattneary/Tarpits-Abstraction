#A Self-Hosted Language 

In the previous section, we successfully designed and implemented an
interpreter of the Lambda Calculus. This was a very interesting problem to
solve, because it allowed us to form a grammar of expression from within our
working language; then allowing us to expand upon this grammar dynamically.

This achievement opens one up to question the limitations of the embedded
language. Specifically, we would be concerned with a language sufficiently
advanced to form an interpreter of itself, and to then add features.

This phenomenon, a sort of singularity, is known in computation as a 
bootstrapped interpreter. In this section, we will aim to bootstrap our 
symbolic language, and to then unlock the potential of additional features.

##The Grammar
The grammar of our symbolic language is slightly more complex than the Lambda 
Calculus; however, it is luckily once again very uniform. However, because we 
are now defining our grammar within another language, we will need to 
abstract over the implementation details of token representation. That is to 
say, although each string is a functional linked-list, we will consider them 
atomic just as in prior grammar definitions.

We return briefly to our formal definition of a Symbolic Expression from an 
earlier chapter; this time we will explicate the characters allowed in an 
`atom`.

```fig:sexprGrammar
<expr> &::= <sexpr> | <atom>
<sexpr> &::= (<list>)
<list> &::= <expr> | <expr> <expr>
<atom> &::= <char> | <atom> <char>
<char> &::= <letter> | <number> | <symbol>
<letter> &::= A | B | ... | Z
<number> &::= 0 | 1 | ... | 9
<symbol> &::= * | + | - | / | \# | < | > | _ | ? | !
```

Now, because we will be operating from within our Symbolic Language, we will 
be able to abstract away the details of the grammar. That is, S-Expressions 
will be represented as S-Expressions when provided as input to the 
interpreter, as will atoms as atoms.

##Self-Interpretaion
###Lambda Forms
Recall from our definition of the Symbolic Language in terms of the Lambda 
Calculus that there were some functions considered more primitive to the 
language than others. We will expose these to the language which we 
interpret. Our first task is to enable the Lambda Calculus in these forms, 
not unlike in our earliest definition of the language.

```fig:lambdaCalculusEval
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

This is all fine; however, notice that the arguments to the function are 
evaluated all at once and passed to an applier-function. In the next 
section, we will discuss a better approach to evaluation.

###Laziness
This is not optimal, and does not allow for some nice features enabled by 
"laziness" in the interpreter. For this reason, we will change the 
application and variable reference components to reflect a lazy approach to 
evaluation.

```fig:lazinessEval
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
           (map 
             (lambda (x) 
               (eval (list 'lambda '(_) x) env)) 
             (cdr expr)))))) ...)
```

With very few changes we were able to implement this lazy approach. We simply 
made all arguments wrapped in a lambda before their evaluation, and all 
variable references then reduce these wrappings when appropriate. These small 
changes will make a world of difference in the potential of expressiveness in 
our language.

The most evident of advantages is in the ability to branch execution, i.e., 
perform `if` statements, without evaluating both branches. This later 
translates into the ability to recurse without invoking infinite recursion.

###Numbers
In order to interpret numbers, we would need our atomic values to be not so 
atomic. Rather than have atoms go against this nature, we will delay 
implementation of arbitrary numbers. For now, we will start with single 
digits.

```fig:evalPrelude
(let eval-prelude (lambda (expr env)
  (eval 
    expr
    (concat 
      env 
      '((0 (0)) (1 (1)) (2 (2)) (3 (3)) (4 (4)) 
        (5 (5)) (6 (6)) (7 (7)) (8 (8)) (9 (9)))))) ...)
```

The code in Figure~\ref{fig:evalPrelude} is just another `eval` function, this
time appending to the environment a prelude of definitions prior to calling the
usual `eval` function. The equivalencies presented are merely from atom to
singleton lists; no nature of numbers shows through. Why singletons? Numbers
are lists of digits more than they are atomic values, after all, this is what
allows us to perform arbitrary arithmetic.

There is one aspect of the environment that we failed to address in our setup 
of a prelude. Given the lazy nature of our interpreter in which all variable
access is reduction of a lambda, we will need to lambda wrap each set value.

```fig:lazySetDef
(let lazy-set (lambda (env hash)
  (concat
    env
    (map (lambda (pair) 
      (list 
        (car pair) 
        (lambda (z) (cadr pair)))) 
        hash))))
```

The function in Figure~\ref{fig:lazySetDef} implements this lazy nature.

It will be our responsibility to implement arithmetic nature of these numbers 
by means of a `succ` function. As we have already shown, from this definition 
all else is possible.

```fig:succDef
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

The implementation in Figure~\ref{fig:succDef} is pretty simple; it is a very
basic definition of the meaning of numbers in our decimal system. It says, "One
follows zero; two follows one; etc." Next, it communicates the intricacies of
place value. A number with a ones digit of nine will increment to a ones digit
zero, with a once higher leading strand of digits. Finally, any other number
with multiple digits will result in a once larger ones digit.

We will now expand our `eval-prelude` to be more extensible and to include 
the `succ` function.

```fig:evalPreludeExtension
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

###Booleans and Predicates
Our implementation of Booleans will be quite simple. Recall the use of atoms 
to symbolize numbers in the prior section, with the meaning of the numbers 
being more derived from the operations we defined than from their 
representation. The same will hold especially true for Booleans.

Our Booleans will be defined on the prelude by the names of `#t` and `#f`, as 
you have come to expect. Now, rather than decide on an arbitrary atom to 
which they will map, we will allow `#f` to equal `nil` and `#t` to equal `1`. 
Hence we would have a `set-booleans` definition to append to `let*` that 
looks like Figure~\ref{fig:setBooleansDef}.

```fig:setBooleansDef
(set-booleans (lambda (env)
  (lazy-set env (list (list '#t 1) (list '#f nil)))))
```

Given these definitions of true and false, we will now define an `if` 
function which follows very naturally from our native `if` function.

```fig:preludeIfDef
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

###List Primitives
The functions primitive to the manipulation of S-Expressions have yet to be 
discussed. The following is a list of these primitives.

- `car`
- `cdr`
- `cons`
- `eq?`
- `null?`
- `atom?`

These will be exposed to the interpreted language by means of the prelude.

```fig:preludePrimitives
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

###Recursion
Now, as was alluded to earlier, we will provide a Y combinator for the 
sake of recursion. Thanks to the lazy evaluation of our interpreter, this 
will be an easily achieved task.

Although combinators are possible without lazy evaluation, a function-based 
`if` statement is not; this is the key to our dependence on laziness. In 
Figure~\ref{fig:preludeY}, we set a Y-Combinator on the prelude.

```fig:preludeY
(set-Y (lambda (env)
  (lazy-set
    env
    (list (list 'Y (lambda (f) 
      ((lambda (x) (f (x x))) 
       (lambda (x) (f (x x))))))))))
```      

###Syntactic Sugars
In our definition of the language, we were sure to provide convenient 
shorthands and general niceties. Hence, we will now do the same within our 
interpreter.

Most of the syntactic constructs which we have yet to address are forms of 
`let`. For this reason, we begin with an exposure of `let` to the 
interpreter. `let` is merely syntactic sugar for reduction of a lambda; hence 
we provide the implementation of let-forms seen in Figure~\ref{fig:syntaxSugarEval}.

```fig:syntaxSugarEval
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
           (map 
             (lambda (x) 
               (eval (list 'lambda '(_) x) env)) 
             (cdr expr)))))) ...)
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

```fig:letSetDef
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

```fig:letRecDef
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

###The Evaluator
The full evaluator is displayed in Figure~\ref{fig:fullEval} on page \pageref{fig:fullEval}.

```fig:fullEval
(letrec let-set 
  (lambda (let-set defs expr)
    (...))
  (letrec apply-set 
    (lambda (apply-set fn args)
      (...))
    (letrec eval (lambda (eval expr env)
      ...
      (let* ((lazy-set (lambda (env hash)
               (...)))
             ...
             (eval-prelude (lambda (expr env)
               (eval
               expr
               (set-arithmetic
                   ...
                      (set-Y env))))))))))
            (...))))))
```

###Conclusion
We have successfully defined an interpreter of the syntax of our language.
Even more interesting is the fact that we implemented this interpreter from
within the same language. By taking this route, we were able to reuse, or
*snarf*, some of the constructs of the language very easily in our
interpretation of it.

##Language Expansion
Having successfully allowed our language to interpret itself, we are now able
to take it even farther. That is, we can begin to add features to our
language from within the language itself.

You have probably begun to notice the complexity of some of our procedures.
The nesting of definitions, amongst other things, leads to an expression very
hard for a human reader to parse. Additionally, you might recall from an
earlier section the utilization of mutation in a procedure, attributed to an
imperative approach, as an alternative to this heavy nesting.

In this section, we will implement the beginnings of an array of mutators
allowing for the imperative model. We will begin with a single, `set` 
function without scope. This means that the only way this form will take
effect is through its invocation at the top level.

###Mathematical Background
An important idea in functional programming is that of the Monad. Its name
comes from its origins in Mathematics, more specifically Category Theory.
Monad refers to its ability to generate everything from a single value. We,
however, will be viewing the Monad in a slightly different light. A Monad
is a triple, consisting of a Functor, and two transformations, $\nu$ and 
$\mu$. We will take a moment to unwrap this definition.

A Functor is a construct at a very high level of abstraction, we will briefly
define it in terms of familiar concepts. We begin with the idea of a set and
a relation on that same set. Of course, an example would be the set of Natural
Numbers. Then a relation on that set could be `<`. This will be our first
level of abstraction; that is to say, this is our first example of objects and
arrows between them. An arrow could flow from 0 to 1, and then 1 to 2, et cetera,
ad infinitum.

Given a set and a relation on that set, we will consider the two an object. An
object could have multiple relations defined upon it as well. Now, we imagine
having two objects, each with a different set and an analogous relation. For example,
we might introduce the rational numbers and their ordering. We then call some
function from the Natural Number object to the Rational Number object a morphism
so long as it preserves the ordering when mapping values from the naturals to
the rationals.

Next, we consider a category to be any collection of objects and arrows between
those objects. More specifically, a category consists of objects, morphisms between
those objects, and compositions of those morphisms.

Finally, we consider a Functor to consist of a mapping of objects and morphisms
from one category to another. Returning to our initial prompt, we consider a monad
to be a map from one category to another, along with two transformations.

###Monads in Computation
Given the previous explanation of Monads, it is probably still unclear how the
structure would relate to computation. We will now take a look at the traits of
the transformations $\nu$ and $\mu$. Let $T$ refer to the Functor of a given Monad.
The transformation $\nu$ then yields $\nu_{x}$ such that $\nu_{x}$ is a function from
$x$ to $T(x)$. Similarly, the transformation $\mu$ yields $\mu_{x}$ such that
$\mu_{x}$ is a function from $T(T(x))$ to $T(x)$. Thus, we can see that a Monad
includes a way of adding and taking away mappings by the Functor. If we consider
a map by the Functor to be a boxing of the value, we have that $\nu_{x}$ boxes
members of $x$, and that $\mu_{x}$ unboxes a box of boxes. In a similar vein, we will
refer to $\nu$ as unit and $\mu$ as join.

Now, one might be wondering why such a structure is valuable. The reason is
that Monads relate functions on a type of value to a similar function on a
boxed form of this type. Why are we interested in boxed values? One might box a
value in a pair, with an annotation as the other element. For example, one
could define a couting Monad which boxes by forming a tuple including the value
and `1` and unboxes a box of a box by adding together the number labels as
follows.

```
T(x) = x \times \mathbb{N}
T(f: A \to B)(a, n) = (f(a), n)
\nu_{x}: x \to T(x)
\nu_{x}(x) = (x, 1)
\mu_{x}: T(T(x)) \to T(x)
\mu_{x}((x, a), b) = (x, a+b)
```

A similar construct, then, could be used to accumulate log information, for example.
Monads are of interest to us for their potential in maintaining state. For this
purpose, one could maintain state as the second element of the tuple. However, for
applications like this one, programmers usually prefer to take a different outlook on
Monads, namely, to focus on `unit` and `bind` functions rather than `unit` and `join`.
The bind function can be defined in terms of join quite simply.

```fig:bindDef
bind_{x}: T(A) \to (A \to T(B)) \to T(B)
bind_{x}(a, f) = join(T(f)(a))
```

As you can see in Figure~\ref{fig:bindDef}, `bind` essentially elevates a
function from unboxed bearing boxed to boxed bearing boxed. Its innerworkings
are as simple as getting the boxed morphism defined by the category which
accepts a function from $A$ to $T(B)$ and returns a function from $T(A)$ to
$T(T(B))$. However, since we are seeking a function onto $T(B)$, we then unbox
the return value with `join`.

###A New Eval
In our new eval function we will form a function which boxes our previous
implementation with an environment. Given the recursive nature of the `eval`
function, we will elevate our previous function through a full rewrite of the
function, rather than by `unit` or `bind`. However, the reader might wish to
keep these ideas in mind.

The code in Figure~\ref{fig:monadicEval} is a rewrite of the `eval` function to
behave as this composite form. Note that macro forms behave the same as before,
but that all other forms return a list of expression result and environment. Of
course, these forms are also forced to interface with the new return values of
`eval` in order to bear the same effect as before.

```fig:monadicEval
(letrec eval (eval expr env)
  (cond (((atom? expr) (list ((assoc expr env) nil) env))
         ((equal? (car expr) 'lambda) 
          (list
            (lambda (x) 
              (eval 
                (caddr expr) 
                (set (cadr expr) x env)))
            env)
         ((equal? (car expr) 'let)
          (...))
         ((equal? (car expr) 'letrec)
          (...))
         ((equal? (car expr) 'let*) 
          (...))
         ((equal? (car expr) 'set!)
          (list 
            #t 
            (set 
              (cadr expr) 
              (car (eval (caddr expr) env)) 
              env)))
         (#t (list
               (car (apply-set 
                 (car (eval (car expr) env))
                 (map 
                   (lambda (x) 
                     (car (eval (list 'lambda '(_) x) env)) (cdr expr)))))
               env)))) ...)
```

With this new eval function, we have a way of maintaining state after 
mutation to the environment. Now we can define a function which will accept
a list of expressions and perform them one after the other on a gradually
mutating environment.

```fig:evalSeqDef
(letrec eval-seq (lambda (eval-seq exprs m)
  (if
     (null? exprs)
     m
     (eval-seq (cdr exprs) (eval (car exprs) (cadr m))))))
```

Hence we would achieve the behavior exhibited by the
Figure~\ref{fig:evalSeqExample}. 

```fig:evalSeqExample
(car (eval-seq '((set! c 1) (c)))) \implies 1
```

###Scope
So far we have for the most part left the environment alone, excepting for
invocations of `set!`. However, we will now take a look at scope and how it
will be implemented through the various syntactic forms.

The first prerequisite will be the existence of various scopes in which a
variable may be defined. For these to be present, we will need sub-procedures
with their own environments; that is, we will need lambdas with bodies of
multiple expressions.

Implementation of this feature is far from difficult. We may as well embrace
our early stages of an expanded language and provide as a prelude the
`eval-seq` function. The code in Figure~\ref{fig:evalSeqPrelude} combines our
set function with the Y-Combinator to form an alternative to `let-rec`. Note
that we have modified the function definition to return the full
value-environment pair, rather than just the value.

```fig:evalSeqPrelude
(set! eval-seq (Y (lambda (eval-seq exprs m)
  (if
     (null? exprs)
     m
     (eval-seq (cdr exprs) (eval (car exprs) (cadr m)))))))
```

Now we can utilize `eval-seq` from within the `eval` function; we will call
it from within the evaluation of a lambda.

```fig:multiExprEvalLambda
(set! eval-lambda (lambda (eval expr env)
  (list
    (lambda (x) 
      (eval-seq 
        (cddr expr) 
        (list
          #t
          (set (cadr expr) x env)))
    env))
```

Note our use of `cddr` rather than `caddr`. This is the portion of the
implementation accounting for a sequence of expressions following the
parameter list of a lambda definition. Additionally, notice that the initial
environment had to account for the full form expected by `eval-seq`, i.e.,
a value-environment pair.

What are the ramifications of this straightforward foundation for scope? Our
use of `eval-seq` sufficed for maintenance of values in the sequence of 
lambda body-expressions; however, it served to form a sort of fork from the
primary environment, one which never reconnects with its origin. We are now
faced with the problem of implementing this scope-traversal despite the
current forking.

In order to achieve this, we have already decided that a scope-traversing
function will be required. How would one be implemented? Well, if you attempt
to find the point at which two environments share a border, it is clearly at
the forming of a lambda. Hence, we could define a function, say 
`bubble-set!`, on the lambda's environment which will set a value on the
parent environment if the variable has yet to be declared on the child.

There is one issue with this idea, however: the environment value is not
mutable. Hence, we cannot simply change a value on it. Rather, we will need to
perform a manipulation at the return-time of the environment. To achieve this,
we will need to modify the default clause of the evaluator: application. The
code in Figure~\ref{fig:takeForkedEnvApply} would take on the environment value
of the forked environment.

```fig:takeForkedEnvApply
(#t (apply-set 
      (car (eval (car expr) env))
      (map 
        (lambda (x) 
          (car (eval (list 'lambda '(_) x) env)) (cdr expr))))))
```

This is not suitable, because you would then have all ideas of scope be lost to
a system of most recently set values. Instead, we will need to harness the
forked environment for manipulations on the primary environment, and then
discard it. The definition of `perform-bubbles` in
Figure~\ref{fig:performBubblesDef} handles the updating of the primary
environment.

```fig:performBubblesDef
(set! perform-bubbles (lambda (m env)
  (let bubbles (assoc 'bubbles (cadr m))
    (list
      (car m)
      (cadr 
        (eval-seq
          (map (lambda (b) (cons 'set! b)) bubbles)
          m))))))
...
(#t (perform-bubbles (apply-set 
      (car (eval (car expr) env))
      (map 
        (lambda (x) 
          (car (eval (list 'lambda '(_) x) env)) (cdr expr))))) env))
```

Of special note is the fact that rather than perform the value updates on the
environment manually, we allowed the evaluator to perform them. This choice
will prove helpful later when we devise a more formal scoping system governed
by rules based on variable declaration.

We are now left only with the issue of simulating updates to the primary
environment from within the forked environment. This can be achieved by some
tweaks to variable access and setting.

```fig:scopeReflectionTweaks
((atom? expr) 
  (if
    (present? expr env)
    (list ((assoc expr env) nil) env)
    (list ((assoc expr (assoc 'bubble env)) nil) env)))
...    
((equal? (car expr) 'set!)
 (list 
   #t 
   (if
     (present? expr env)
     (set 
       (cadr expr) 
       (eval (caddr expr) env) 
       env)
     (set
       'bubble
       (set
         (cadr expr)
         (eval (caddr expr) env)
         (assoc 'bubble env))
       env))))    
```

The two definitions in Figure~\ref{fig:scopeReflectionTweaks} serve to attempt
either a get or set on the forked environment, and, if the variable is
undeclared, perform that action on the `bubble` portion of the environment. Of
course, when appropriate, these bubbles will be reflected in the primary
environment.

Despite the elegance of the earlier definitions, our current foundation will
not allow them to be effective. Currently, we are creating the forked
environment from the primary environment. This means that changes to the
primary environment will not be seen as needing to bubble, but rather, as 
changes to local variables. To resolve this issue, we will need to change our
initial value for forked environments.

```fig:separateBubbleEnv
(set! eval-lambda (lambda (eval expr env)
  (list
    (lambda (x) 
      (eval-seq 
        (cddr expr) 
        (list
          #t
          (set (cadr expr) x '((bubble env)))))
    env))
```

The code in Figure~\ref{fig:separateBubbleEnv} is quite simple. Our only change
was to specify the primary environment as the bubbling cache.

You may have picked up on the fact that since all set operations bubble if
the variable is undeclared, `set!` will not suffice if we wish to maintain
various scopes. For this purpose, we will introduce a `define` function.
`define` will pin down a variable to a specific scope, if you will. Its
implementation is merely a reuse of our original, naive set function.

```fig:defineDef
((equal? (car expr) 'define)
 (list 
   #t 
   (set 
     (cadr expr) 
     (eval (caddr expr) env) 
     env)))
```     

Together, `define` and `set!` provide us with the ability to specify scope
for variables which will be maintained across any sort of sub-procedure. Our
implementation of a bubbling `set!` was very slick, and `define` was merely
a reuse of our old `set!` function.

##Conclusion
We have defined a means of evaluating our language from within the language
itself. Once this was done, we were able to expand upon the language's
constructs, adding imperative features, amongst other features. This is not
merely an academic exercise, but the way in which programming languages have
evolved from the time of the first computers. Henceforth, the grammar of our
language will be dynamic and fully extensible.


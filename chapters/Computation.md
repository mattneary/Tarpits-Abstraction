#Computation
*Computation* is the evaluation of a given expression, usually by means of
computer. For example, one could compute the addition $3+5$ and arrive at $8$. 
With a few basic operators and a number system, the entirety of
arithmetic is computable; however, there are more complex structures which
cannot be discussed under these limitations.

For the sake of working with more complex structures, we rely upon
*abstraction*. Let's look at an example. You have undoubtedly seen an
expression like the following in a mathematical setting.

```fig:mathFunction
f(x) = x^2
```

The object $f(x)$ is more complex than primitive operators and numbers because
it accepts argument to its computation. Objects like this one are formed by a
process known as abstraction. Along with abstraction, the other fundamental
aspects of computation are *variables* and *application*. A variable is a given
token within an expression intended for substitution, and application is the
reduction of an expression from an abstracted form. Here are some more concrete
examples.

In Figure~\ref{fig:mathApplication}, we have the abstraction of the expression $x^2$ in which x is
a variable. We then apply $f(x)$ to $3$.

```fig:mathApplication
f(x) = x^2
y = f(3) \implies y = 9
```

##A Foundational Grammar 

We have discussed the features necessary for a langauge to facillitate
computation; however, we have so far relied upon the familiar notation of
mathematics. We will now switch to a language defined specifically as a
foundation for computation. The Lambda Calculus is a language consisting of
variables, abstraction, and application. The notation can be summarized by
the Backus-Naur definition in Figure~\ref{fig:lambdaExprGrammar}.

```fig:lambdaExprGrammar
<expr> &::= &\lambda <var> <expr>
&| &(<expr>)<expr>
&| &<var>
```

BNF is perfect for the description of languages, both expressive and
formal. In describing the Lambda Calculus, an expression (*expr*)
is said to be one of three forms. The first form is a lambda followed by
a variable, its argument, and finally followed by another expression. The
next is simply the application of one expression to another, and the last
is simpe variable reference.

These are the only forms, a data-type like numbers is not provided. However,
we will for now take its potential to represent such data as granted. Let's
explore this notation.

The expression in Figure~\ref{fig:identity3} defines an identity function 
and then applies it to the number $3$. The result, of course, is $3$.

```fig:identity3
(\lambda x x)3
```

In the notation of traditional math, we would have defined this function
prior to its invocation. Such a form would appear as in Figure~\ref{fig:mathDefAndApply} 
and achieve the behavior of Figure~\ref{fig:identity3}. 

```fig:mathDefAndApply
f(x) = x
f(3)
```

The Lambda Calculus is a fully-versatile language; however, it is what some
describe as a *Turing tarpit*. Alan Perlis describes a Turing tarpit as a
language "in which everything is possible but nothing of interest is easy."
Despite this nature of the Lambda Calculus, we will be forming quite complex
programs throughout this book on its foundation. We will, in a sense, climb
out of its tarpit by means of abstraction. In order to do so, we will build up
a scaffolding of abstraction, building layer upon layer as we construct an
edifice of procedures.

##A Symbolic Language 
In the previous section, we utilized numbers within the Lambda Calculus; however,
we do not accept them as primitive. Rather, we will need to define them in
terms of the Lambda Calculus. Of course, the ability to refer to numbers by name
would be helpful. For this reason, amongst many others, we will begin by
defining a new, symbolic language on top of the Lambda Calculus, adding a layer
of abstraction to our computation.

Our layer of abstraction will be a uniform language of Symbolic Expressions which
is a dialect of the language called Lisp. 
These symbolic expressions are parentheses enclosed arrays of symbols, taking on
different meanings based on their matching of patterns which we will define.

Figure~\ref{fig:sexprExample} displays an example.

```fig:sexprExample
(+ 2 3)
```

The expression in Figure~\ref{fig:sexprExample} evaluates to 5. In this case our 
expression is a function application
receiving two numbers as arguments. This syntax is very simple, uniform and
legible. Additionally, as you will see later on in this book, it is very easily
interpreted by program.

##Symbolic Expressions
The language into which we are entering is one of symbolic expressions. All of
our expressions will take the form defined by the grammar in
Figure~\ref{fig:sexprBasicGrammar}. This uniformity will make its definition in
terms of Lambda Calculus far easier, and simplify its later interpretation or
compilation.

```fig:sexprBasicGrammar
<expr> &::= <sexpr> | <atom>
<sexpr> &::= (<list>)
<list> &::= <expr> | <expr> <expr>
```

##Defining Semantics
###Primitive Forms
Now, these Symbolic Expressions or *S-Expressions* can take any of a multitude of
forms. Of these, we will define meaning for forms of interesting patterns. We
begin, unsurprisingly, with an S-Expression which serves to create lambdas. All
forms matching the patterns which we discuss will be converted to the provided
form, labeled as the consequent.

```fig:lambdaSexpr
(lambda (var) expr) &\implies #{\lambda var} expr
(lambda (var rest...) expr) &\implies #{\lambda var} (lambda rest expr)
```

Essentially, we are saying that any expression of the given form
should be a function of the provided arguments bearing the provided expression. 

Additionally, we provide a default case for our S-Expressions. Should certain 
expression match none of our provided patterns, we will default to function
invocation. In other words, in Figure~\ref{fig:sexprApplication} we define a pattern
for those values which match no other patterns.

```fig:sexprApplication
(fn val) &= (fn)val
(fn val rest...) &= ((fn)val rest)
```

The Lambda Calculus has now been fully implemented in our symbolic forms; however, 
we will add many more features for the sake of convenience. After all, our goal
was to add abstraction, not move a few symbols around!


###Evaluation of Symbolic Forms
Before we continue, we'll look at some examples of our syntax as implemented so
far. In evaluating a Lambda Calculus expression, or in this case, derived form,
the single operation necessary is known as reduction. Reduction is conversion of
an expression of function application to a new expression, one derived by
substitution of the argument value.

To begin gaining familiarity with our language, we look at a function of two
variables. The function in Figure~\ref{fig:examplefx} performs `f` on a value `x`, and then `f`
once more on the resultant value.

```fig:examplefx
(lambda (f x) (f (f x)))
```

Now we will look at a similar form, a function of three variables. In Figure~\ref{fig:examplegfx} is a
function of values `g`, `f`, and `x`. The result is similar to that of the one
in Figure~\ref{fig:examplefx}, but this time replacing $(f x)$ with $(g f x)$.

```fig:examplegfx
(lambda (g f x) (f (g f x)))
```

So far we have covered some examples of Symbolic Expressions, but all of them have 
been of the lambda definition form. Furthermore, they have lacked any concrete
meaning. To explore the additional notation we have defined, we will apply the
former expression to the latter, which expands into Figure~\ref{fig:examplefxgfx}.

```fig:examplefxgfx
((lambda (g f x) (f (g f x))) (lambda (f x) (f (f x))))
```

This expression appears quite complex, so let's use the aforementioned reduction 
operation to simplify it. Recall from our definition of `lambda` that a function
of multiple variables evaluated for one results in a function of one-less variable 
than the initial form. Hence we begin by substituting our argument for `g`
throughout the expression; later steps are of a similar nature.

```fig:exampleReductions
&((lambda (g f x) (f (g f x))) (lambda (f x) (f (f x))))
\implies &(lambda (f x) (f ((lambda (f x) (f (f x))) f x)))
\implies &(lambda (f x) (f (f (f x))))
```

That looks much better! What we have arrived at is only slightly different than
our initial function of `f` and `x`. The only change was the number of times that
`f` was applied. We have explored the reduction of a symbolic expression to a
result; however, this result is far from tangible.

In order for computation by means of the Lambda Calculus to render a 
human-readable result, we will need a notation of expression exhibited by function
definitions. That means that, for example, the function 
$(lambda \; (a) \; (a \; (a \; (a \; a))))$ could serve to communicate the number four.

The expressive power of this notation is clear; however, application of a function 
to itself as in $(a a)$ is very rarely appropriate, and so we will slightly expand 
our expression of four to serve a more concrete purpose within the language. We
now expand our numeric function representing some number `n` to accept two
parameters, and return the application of the first parameter `n` times to the
second parameter. Hence, the number four would look like the function in Figure~\ref{fig:exampleNumber4}.

```fig:exampleNumber4
(lambda (f n) (f (f (f (f n)))))
```

This notation, of course, translates just as well into an expression of any
number. The number three would look like the function in Figure~\ref{fig:exampleNumber3}.

```fig:exampleNumber3
(lambda (f n) (f (f (f n))))
```

Hopefully these examples have given you a feel for how this syntax can work, and
maybe even an early sense of how useful functions will emerge from the Lambda
Calculus.

##Foundations in Lambda Calculus
To accompany our syntactic constructs, we will need to define some forms in the
Lambda Calculus, especially data-types and their manipulations. Our definitions
will be illustrated as equalities, like $id = \lambda xx$; however, syntactic
patterns will be expressed as implications. Recall that in Lambda Calculus there
are only functions, no literals or primitive data-types. To combat this apparent
shortcoming of the language, we will need to give data-types of interest a
functional form. The examples of the prior section were a preview into how our
conceptualization of numbers will behave.

###Numbers
Numbers are a rather fundamental data-type, especially in modern computing.
Additionally, they are in most other languages seen as atomic and primitive.
However, we must provide a definition for the behavior of numbers in our language 
constituent of functions. We begin with a means of defining all natural numbers
inductively, via the successor.

```fig:zeroAndSucc
0 &= \lambda f \lambda x x
succ &= \lambda n \lambda f \lambda x (f)((n)f)x
```

Our definition of numbers is just like the examples from the previous section.
Notice that `1`, for example, could be easily defined as $1 = (succ \; 0)$, as could
any positive integer with enough applications of `succ`. Later on when we return
to syntactic features we will define all numbers in this way; the numbers will
take on their usual form as a string of decimal digits.

Numbers are our first data-type. Their definition is iterative in nature, with
zero meaning no applications of the function `f` to `x`. We now will define
some elementary manipulations of this data-type, i.e., basic arithmetic. The
definitions in Figure~\ref{fig:arithmetic} are pretty straightforward; nearly
all of them consist exclusively of iterative application of a more primitive
function to a base value.

```fig:arithmetic
+ &= \lambda n \lambda m ((n)succ)m
* &= \lambda n \lambda m ((n)(sum)m)0
pred &= \lambda n \lambda f \lambda z ((((n) \lambda g \lambda h (h)(g)f)\lambda u z)\lambda u u)
- &= \lambda n \lambda m ((m)pred)n
```

Addition merely takes advantage of the iterative nature of our numbers to apply
the successor `n` times, starting with `m`. In a similar manner, multiplication
applies addition repeatedly starting with zero. The predecessor is much more
complicated, so let's work our way through its evaluation.

We'll begin our exploration of the `pred` function by looking at the value of two. 
Since two equals `(succ)(succ)0` we can work out its Lambda form, or simply take
as a given that is the function in Figure~\ref{fig:number2forPred}.

```fig:number2forPred
2 = \lambda f \lambda x (f)(f)x
```

Now we can evaluate `pred` for this value. `pred` has been defined already, but
let's briefly render it in the more succinct form of
Figure~\ref{fig:simplifiedPred}. The form in Figure~\ref{fig:simplifiedPred} is
very easily translated back to Lambda Calculus and should serve to cut through
at least a portion of the complexity of the definition.

```fig:simplifiedPred
pred = \lambda n \lambda f \lambda z ((\lambda g \lambda h (h)(g)f)^{n} \lambda u z) \lambda u u
```

With the rendering of the definition displayed in Figure~\ref{fig:simplifiedPred} 
in mind, we aim to reduce an application of `pred` to `2` to a result.

```fig:predPowerPlugin
(\lambda n \lambda f \lambda z ((\lambda g \lambda h (h)(g)f)^{n} \lambda u z) \lambda u u) 2
(\lambda f \lambda z ((\lambda g \lambda h (h)(g)f)^2 \lambda u z) \lambda u u)
```

Now that we have reduced the expression to the form of our prior rendering of
`pred`, we expand it into a true Lambda Calculus form, as seen in
Figure~\ref{fig:predReducedLambda} and continue our reduction.

```fig:predReducedLambda
(\lambda f \lambda z (((\lambda g \lambda h (h)(g)f) (\lambda g \lambda h (h)(g)f)) \lambda u z) \lambda u u)
```

In the conversions of Figure~\ref{fig:predRestReductions}, as in all, our reductions will need to take place in 
a right-to-left direction when evaluating expressions of the form `(f)(g)x`.
Recall that our goal here is to reduce a complex form to simplistic result, and we 
have already made significant progress.

```fig:predRestReductions
(\lambda f \lambda z ((\lambda g \lambda h (h)(g)f) (\lambda h (h)(\lambda u z)f)) \lambda u u)
(\lambda f \lambda z ((\lambda g \lambda h (h)(g)f) (\lambda h (h)z)) \lambda u u)
(\lambda f \lambda z (\lambda h (h)(\lambda h (h)z)f) \lambda u u)
(\lambda f \lambda z (\lambda h (h)(f)z) \lambda u u)
```

The forms in Figure~\ref{fig:predRestReductions} were all mere substitutions, as 
should be expected. If any were unclear, try working those steps out in a notebook. 
We are now finally ready to reduce the application of the identity 
($lambda \; u \; u$) and achieve our final result.

```fig:predFinalResult
\lambda f \lambda z (\lambda u u)(f)z
\lambda f \lambda z (f)z
```

Our result, seen in Figure~\ref{fig:predFinalResult} was a single application
of `f` to `z`, i.e., one. Hence you have seen that at least in this case, the
`pred` function did its job. Achieving an intuitive grasp of how it works is
unfortunately not as straight-forward. If you wish to, keep in mind that
$\lambda u z$ maps a value to the numeric starting point, and $\lambda u u$
leaves an expression alone. So the decrement occurs by the setting of the
origin later than it would normally occur.

With our complex definition of the predecessor complete, subtraction is trivial.
Once again we perform an iterative process on a base value, this time that process 
is `pred`.

###Booleans
Having defined numbers and their manipulations, we will work on booleans.
Booleans are the values of true and false, or in our syntax, $#t$ and $#f$.
Booleans are quite necessary in expressing conditional statements; thus we
provide the concomitant `if` function. These values will give us great power in
their ability to branch results to a function, in a sense constructing
piece-wise functions. It is by this ability that we are able to form a
multitude of inductive definitions, as well as other important forms.

```fig:booleanDefs
#t &= \lambda a \lambda b (a)id
#f &= \lambda a \lambda b (b)id
if &= \lambda p \lambda t \lambda f ((p)\lambda _ t)\lambda _ f
```

The key to our booleans is that they accept two functions as parameters, functions 
that serve to encapsulate values, of which one will be chosen. Once chosen, that 
function is executed with the arbitrarily-chosen identity as an argument. This
method of wrapping the decision serves as a means of lazy evaluation, and is fully 
realized in the lambda-underscores wrapping the branches of an `if` statement.

Now, since of course no boolean system is complete without some boolean algebra, 
we define `and` and `or`. These functions perform the operations you would expect; 
$(and a b)$ is true only when both `a` and `b` are true, but $(or a b)$ is true if 
either argument is true. Their definitions follow easily from our `if` function. 
Keep in mind that both of these functions operate only on booleans.

```fig:andOrDefs
and &= \lambda a \lambda b (((if)a)b)#f
or &= \lambda a \lambda b (((if)a)#t)b
```

With boolean manipulation and conditionals in hand, we need some useful predicates 
to utilize them. We define some basic predicates on numbers in Figure~\ref{fig:numberPreds}. 
`eq` will be very useful in later developments; it is one of McCarthy's elementary 
functions.

```fig:numberPreds
zero? &= \lambda n ((n)λx#f)#t
leq &= \lambda a \lambda b (zero?)((-)m)n
eq &= \lambda a \lambda b (and (leq a b) (leq b a))
```

The predicates in Figure~\ref{fig:numberPreds} serve to identify traits of a given 
number or given numbers. `zero?` is true when a number is zero, `leq` is true when 
the first number is less than or equal to the second, and `eq` determines whether 
two numbers are equal.

###Pairs
Finally we reach the most important part of our S-Expressions, their underlying 
lists. That is to say, every Symbolic Expression is innately a list of other 
expressions, whether atomic or symbolic, and these lists serve as an analog to 
a the list data-type. To construct lists we will opt for a sort of linked-list 
implementation in our lambda definitions. We begin with a pair and a `nil` 
definition, each readily revealing their type by opting for either the passed `c` 
or `n` function. The function definitions are displayed in Figure~\ref{fig:pairFuncDefs}.

```fig:pairFuncDefs
cons &= \lambda a \lambda b \lambda c \lambda n ((c)a)b
nil &= \lambda c \lambda n (n)id
```

`cons` constructs a pair when given two values, and accepts a function which will 
receive the two items to manipulate. `nil` on the other hand serves as a sort of 
empty pair, and instead fires the second provided function to identify itself as 
such.

Now, once again we follow a defined data-type with its manipulations. Just as did 
McCarthy, we will provide `car` and `cdr` as additional elementary functions, with 
`pair?` and `null?` serving as complements to each other in determining the end of 
a list. `car` returns the first value of a pair, and `cdr` the second. Their names 
are quite historical and refer to address access of a pair in memory, but you can 
just think of them as $/k \alpha r/$ and $/k u d e r/$.

```listFuncDefs
car &= \lambda l (((l)\lambda a \lambda b a)id)
cdr &= \lambda l (((l)\lambda a \lambda b b)id)
pair? &= \lambda l (((l)\lambda \_ \lambda \_ #t)\lambda \_ #f)
null? &= \lambda l (((l)\lambda \_ \lambda \_ #f)\lambda \_ #t)
```

`car` provides that pair with a pair handling function that returns the first 
element, and an arbitrary `nil` handling function. Similarly, `cdr` provides a 
pair handling function returning the second element. `pair?` and `nil?` are 
logical opposites to each other, each provides a pair- and nil-handling function, 
returning either `#t` or `#f` as is appropriate.

Together, these functions are sufficient for designing a list implementation. The 
implementation that comes naturally is known as a linked-list. A linked-list is 
essentially either a pair of an element and a linked-list or `nil`. If that is 
unclear, think of a tree with a fractal structure. The tree consists of a leaf and 
a child tree, which in turn has both leaf and child tree, until the tree ends with 
`nil` for a child tree.

###Recursion
Our last definition will be a bit more esoteric, or at least complex. We define a 
*Y Combinator*. This function, `Y`, will allow another to be executed accepting 
itself as an argument. The Y Combinator refers to a specific combinator, but you have
already seen another. The `I` Combinator is defined as $\lambda x x$ in the Lambda
Calculus. The key to combinators is that they use function application alone to
return a value. Although the Y Combinator can be expressed without using abstraction
in the function body, we will opt to define it in a way making use of lambda definitions
to present a simpler definition; the definition follows. 

```fig:YCombDef
Y = \lambda f(\lambda x (f)(x)x) \lambda x (f)(x)x
```

Let's work through an example. Let's say you want to define a function that will 
evaluate the factorial of a number `n`. Well then the fundamental idea would be to do 
something like the the function in Figure~\ref{fig:factSimpleSDef}.

```fig:factSimpleSDef
fact = (lambda (n) (* n ...))
```

Well the question remains, what should be present instead of the dots? Nothing we 
have discussed would give any help in answering that, besides the Y Combinator. If 
you recall from Mathematics, the factorial has an inductive definition like that
in Figure~\ref{fig:mathInductFact}.

```fig:mathInductFact
0! &= 1
n! &= n * (n-1)!
```

Our task is to translate this into our Symbolic Language; however, we wish to 
generalize this idea a bit, not to add a special expression type for every 
inductive definition we think of. Hence our duty is to make a factorial function 
which is self-aware, if you will. The function in Figure~\ref{fig:factRecurseInfinite}
is a rough form of the concept.

```fig:factRecurseInfinite
fact = (lambda (fact n) (* n (fact (pred n))))
```

There remains one issue! We have not handled the base case present in our prior 
definition. To achieve this in the Lambda Calculus we will utilize an if 
statement; this use case was alluded to earlier.

```fig:factRecurseBranch
fact = (lambda (fact n) 
  (if 
    (zero? n) 
    (succ 0) 
    (* n (fact (pred n))))
```

This is a complete realization of the definition, but there remains one problem. 
How are we to pass `fact` the value of `fact`? This is when the Y Combinator comes 
in. The invocation of `(Y fact)` will form a factorial function, aware of itself 
for the sake of recursion, accepting the single variable `n`.

###Conclusion
We have now laid a good foundation upon which our Symbolic Expressions can exist. 
As should be expected, lists will be our primary data-structure in our language of 
S-Expressions.

##Special Forms of S-Expressions 
###Numbers 
Returning to our prior definition of numbers, we will now define arbitrarily
long strings of decimal digits. As you can see, the patterns in
Figure~\ref{fig:numberPatterns} define numbers by either matching single digits
and defining them as a successor, or by matching leading digits and a final
digit and evaluating them separately.

```fig:numberPatterns
1 &= (succ 0)
2 &= (succ 1)
...
9 &= (succ 8)
ten &= (succ 9)
d...0 &= (mul d... ten)
d...1 &= (sum (mul d... ten) 1)
...
d...9 &= (sum (mul d... ten) 9)
```

Hopefully the rules in Figure~\ref{fig:numberPatterns} are a clear embodiment
of our decimal number system. Place value is achieved by two measures, (a)
inductive definition, and (b) multiplication by ten. This pattern of recursive
definition and symbolic pattern matching will be at the heart of our language
constructs.

###Predicate for Atoms
We will at times need a way of telling whether a given value is a list of an atom;
however, because of our decision to use the untyped lambda calculus, we do not have
such abilities innately. We will for now take the existence of such a function for
granted, as it could be created by simply opting for atoms which wrapped their values
in a list describing type, for example. This practice of wrapping values is described
as a Monad, and we will discuss these in a later chapter. The reason that we feel
comfortable skipping over this defintion is that we will eventually define the language
in terms of itself. At that time, the `atom` function would not be necessary, as we
could wrap the atoms in a Monadic way. Rather than dwell on this concept, we will
define an `atom?` function as a special syntax.

```fig:atomPredicate
(atom? (a b...)) &\implies #f
(atom? a) &\implies #t
```

###List Literals
We define our lists inductively based on the pair-constructing `cons` function we 
defined earlier. We choose to name this function `quote` because it is treating 
the entire expression as a literal, rather than as a symbolic expression. More 
importantly, the syntax of passed lists is indistinguishable from a regular 
S-Expression, hence we are utilizing the *quoted* form of such an expression.

The definition in Figure~\ref{fig:quotePatterns} has a rather sensitive
notation. Quotes show that an atomic value, that is, a value referred to in our
grammar as `<atom>` or more importantly, a value referred to as `<var>` in our
grammar of the Lambda Calculus, is being matched. This is unique from most
cases in which a portion of a pattern is being labeled by a variable.
Additionally, the italicized *ab...* is meant to label the first letter and
rest of a string as `a` and `b`, respectively.

```fig:quotePatterns
(quote (a)) &\implies cons a nil
(quote (a rest...)) &\implies (cons (quote a) (quote (rest...))
(quote a rest...) &\implies (cons (quote a) (quote (rest...)))
(quote "0") &\implies 0
...
(quote "99") &\implies 99
...
(quote "ab...") &\implies (cons a (quote b...))
(quote "a") &\implies (cons 97 nil)
...
(quote "z") &\implies (cons 122 nil)
```

In addition to defining the `quote` function, we will provide a shorthand for the 
operation. So often will we need to define list literals that it makes perfect 
sense for us to make it as brief as possible.

```fig:quoteShorthand
'a \implies (quote a)
```

Quoted forms will come up often in writing list literals, atomic values derived 
from strings, i.e., *atoms*, and forming more complex data-structures from lists 
such as tables.

###Equality
We have built up an array of atomic values, and a way of keeping them literal. Now 
we need a way of recognizing them, by means of equivalence. `eq` already solves 
this problem for numbers, but not for other quoted atoms. We generalize `eq` to 
all expressions in our definition of `equal?`.

```fig:equalDef
(equal? (a b...) (c d...)) 
  &\implies (and 
              (equal? a c) 
              (equal? (b...) (d...)))
(equal? a b) &\implies (eq a b)
```

The definition in Figure~\ref{fig:equalDef} is inductive in nature. It provides
a base case in which equivalence is determined by the Lambda Calculus
definition of `eq`, and an inductive step in which lists are equivalent only if
their constituents are equal.

###Variable Definition
Now we add some *syntactic sugar* that will make it easier to store values that 
will be used in an expression. `let` and `let*` set a single value and a list of 
values, respectively, to be utilized in a given expression. `letrec` takes this 
idea in another direction, performing the Y-Combinator on a passed function to 
prepare it for recursion in the passed expression.

```fig:letDefs
(let var val expr) 
\implies ((lambda (var) expr) val)
(let* ((var val)) expr) 
\implies (let var val expr)
(let* ((var val) rest...) expr) 
\implies ((lambda (var) (let* (rest...) expr)) val)
(letrec var fn expr) 
\implies (let var (Y (lambda f fn)) expr)
```

Once again we provide an inductive definition, and here we finally utilize the Y 
Combinator we discussed with regard to recursive functions.

###Conclusion
We have formed a basic language consisting of Symbolic Expressions defined by the 
Lambda Calculus. All of our expressions are reducible to Lambda forms, yet clearer 
or more concise given their symbolic form. This language will be utilized for 
expression of all sorts of computational ideas, including algorithms, simulators, 
and interpreters. Our choice of syntax was purely aesthetic; Lambda Calculus is 
sufficient for communication with machine, however, our language of Symbolic 
Expressions is far friendlier to a human reader. This motivation reveals the 
additional motivation for our construction of this language, to form a clear, 
formal, extensible, and uniform means of communicating ideas.

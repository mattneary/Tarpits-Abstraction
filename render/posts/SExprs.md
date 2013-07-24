Defining Symbolic Expressions
=============================
Introduction
------------
You have been told that the Lambda Calculus is computationally universal, capable of expressing any algorithm. However, this most likely seems intangible. We will begin to define a layer of abstraction over the Lambda Calculus which makes design of programs begin to seem conceivable.

Our layer of abstraction will be a uniform language of Symbolic Expressions, which is a dialect of the language called Lisp. These symbolic expressions are parentheses enclosed arrays of symbols, taking on different meanings based on their matching of patterns which we will define.

Here's an example:

$$(+ \space 2 \space 3)$$

The above evaluates to 5. In this case our expression is a function application receiving two numbers as arguments. This syntax is very simple, uniform and legible. Additionally, as you will see later on in this book, it is very easily interpreted by program.

Symbolic Expressions
--------------------
The language into which we are entering is one of symbolic expressions. All of our expressions will take the form defined by the following grammar. This uniformity will make its definition in terms of Lambda Calculus far easier, and simplify its later interpretation or compilation.

<div>
$$\text{A Symbolic Expression}$$
\begin{align*}
	\text{&lt;expr&gt;} &::= \text{&lt;sexpr&gt;} \space | \space \text{&lt;atom&gt;}
\\	\text{&lt;sexpr&gt;} &::= (\text{&lt;seq&gt;})
\\	\text{&lt;seq&gt;} &::= \text{&lt;dotted&gt;} \space | \space \text{&lt;list&gt;}
\\	\text{&lt;dotted&gt;} &::= \text{&lt;expr&gt;} \space | \space \text{&lt;expr&gt;} . \text{&lt;expr&gt;}
\\	\text{&lt;list&gt;} &::= \text{&lt;expr&gt;} \space | \space \text{&lt;expr&gt; &lt;exp&gt;}
\end{align*}
</div>	

A Symbolic Language
-------------------
Now, these Symbolic Expressions or *S-Expressions* can take any of a multitude of forms. Of these, we will define meaning for forms of interesting patterns. We begin, unsurprisingly, with an S-Expression which serves to create lambdas. All forms matching the patterns which we discuss will be converted to the provided form, labeled as the consequent.

<div>
\begin{align*}
(\text{lambda } (var) \space expr) &\implies \lambda var \space expr
\\ (\text{lambda } (var \space rest...)) &\implies \lambda var \space (\text{lambda }rest \space expr)
\end{align*}
</div>

Essentially, we are saying that any expression of the form `(lambda args expr)` should be a function of the provided arguments bearing the provided expression. 

Additionally, we provide a default case for our S-Expressions. Should no other mentioned pattern be a match to a given expression, we will default to function invocation. In other words, the following is a pattern we will match, with `fn` being some foreign form not selected for elsewhere. 

<div>
\begin{align*}
\\ & (fn \space val) = (fn)val
\\ & (fn \space val \space rest...) = ((fn)val \space rest)
\end{align*}
</div>

The Lambda Calculus has now been fully implemented in our symbolic forms; however, we will add many more features for the sake of convenience. After all, our goal was to add abstraction, not move a few symbols around!

Before we continue, we'll look at some examples of our syntax as implemented so far.

Let's begin with a simple function of two variables. The following performs a function `f` on a value `x`, and then `f` once more on the value of that.

$$(\text{lambda } (f \space x) \space (f \space (f \space x)))$$

The following is a function similar to the above, but now accept another argument, `g`, which changes the inner `(f x)` to `(g f x)`. This is a bit convoluted, so we'll evaluate it with an example.

$$(\text{lambda } (g \space f \space x) \space (f \space (g \space f \space x)))$$

Now we combine our prior two examples into a single Symbolic Expression in the following.

$$((\text{lambda } (g \space f \space x) \space (f \space (g \space f \space x))) \quad (\text{lambda } (f \space x) \space (f \space (f \space x))))$$

This is really beginning to appear complex, but let's step our way through the evaluation of this expression.

<div>
\begin{align*}
\\	&((\text{lambda } (g \space f \space x) \space (f \space (g \space f \space x))) \quad (\text{lambda } (f \space x) \space (f \space (f \space x))))
\\	\implies &(\text{lambda } (f \space x) \space (f \space ((\text{lambda } (f \space x) \space (f \space (f \space x))) \space f \space x)))
\\	\implies &(\text{lambda } (f \space x) \space (f \space (f \space (f \space x))))
\end{align*}
</div>

That looks much better! What we arrived at was only slightly different than our initial function of `f` and `x`. The only change was the number of times that `f` was applied. Hopefully these examples have given you a feel for how this syntax can work, and maybe even an early sense of how useful functions will emerge from the Lambda Calculus.

Foundations in Lambda Calculus
------------------------------
To accompany our syntactic constructs, we will need to define some forms in the Lambda Calculus, especially data-types and their manipulations. Our definitions will be illustrated as equalities, like $id = \lambda xx$; however, syntactic patterns will be expressed as implications. 

###Numbers
We begin with a means of defining all natural numbers inductively, via the successor.

<div>
$$\text{Numbers}$$
\begin{align*}
0 &= \lambda f \lambda x x
\\ succ &= \lambda n \lambda f \lambda x (f)((n)f)x
\end{align*}
</div>

Our definition of numbers is just like the examples from the previous section. Later on when we return to syntactic features we will define all numbers in this way.

Numbers are our first data-type. Their definition is iterative in nature, with zero meaning no applications of the function `f` to `x`. We now will define some elementary manipulations of this data-type, i.e., basic arithmetic.

<div>
$$\text{Arithmetic}$$
\begin{align*}
+ &= \lambda n \lambda m ((n)succ)m
\\ * &= \lambda n \lambda m ((n)(sum)m)0
\\ pred &= \lambda n \lambda f \lambda z ((((n) \lambda g \lambda h (h)(g)f)\lambda u z)\lambda u u)
\\	- &= \lambda n \lambda m ((m)pred)n
\end{align*}
</div>

Addition merely takes advantage of the iterative nature of our numbers to apply the successor `n` times, starting with `m`. In a similar manner, multiplication applies addition repeatedly starting with zero. The predecessor is much more complicated, so let's work our way through its evaluation. In doing this we will return temporarily to our symbolic forms.

We'll begin with the value of two. Since two equals `(succ)(succ)0` we can work out its Lambda form, or simply take as a given that is the following.

$$\lambda f \lambda x (f)(f)x$$

Now we can evaluate `pred` for this value. Let's, however, briefly reflect on a simpler expression of `pred`.

$$\lambda n \lambda f \lambda z ((\lambda g \lambda h (h)(g)f)^{n} \space \lambda u z) \space \lambda u u$$

Now we wish to, as an example, evaluate this function for two.

$$(\lambda n \lambda f \lambda z ((\lambda g \lambda h (h)(g)f)^{n} \space \lambda u z) \space \lambda u u) \space 2$$

$$(\lambda f \lambda z ((\lambda g \lambda h (h)(g)f)^2 \space \lambda u z) \space \lambda u u)$$

$$(\lambda f \lambda z ((\lambda g \lambda h (h)(g)f) \space (\lambda g \lambda h (h)(g)f) \space \lambda u z) \space \lambda u u)$$

$$(\lambda f \lambda z ((\lambda g \lambda h (h)(g)f) \space (\lambda h (h)(\lambda u z)f)) \space \lambda u u)$$

$$(\lambda f \lambda z ((\lambda g \lambda h (h)(g)f) \space (\lambda h (h)z)) \space \lambda u u)$$

$$(\lambda f \lambda z (\lambda h (h)(\lambda h (h)z)f) \space \lambda u u)$$

$$(\lambda f \lambda z (\lambda h (h)(f)z) \space \lambda u u)$$

$$(\lambda f \lambda z (\lambda u u)(f)z$$

$$(\lambda f \lambda z (f)z$$

__TODO:__ finish this part.

With the predecessor defined, however, subtraction is trivial. Once again we perform an iterative process on a base value, this time that process is `pred`.

###Booleans
Having defined numbers and their manipulations, we will work on booleans. Booleans are the values of true and false, or in our syntax, `#t` and `#f`. Booleans quite necessary in expressing conditional statements; hence we will define an `if` function as well.

<div>
$$\text{Booleans}$$
\begin{align*}
\text{#t} &= \lambda a \lambda b (a)id
\\ \text{#f} &= \lambda a \lambda b (b)id
\\ if &= \lambda p \lambda t \lambda f ((p)\lambda \_ t)\lambda \_ f
\end{align*}
</div>

The key to our booleans is that they accept two functions as parameters, functions that serve to encapsulate values, of which one will be chosen. Once chosen, that function is executed with the arbitrarily-chosen identity as an argument. This method of wrapping the decision serves as a means of lazy evaluation, and is fully realized in the lambda-underscores wrapping the branches of an `if` statement.

Now, since of course no boolean system is complete without some boolean algebra, we define `and` and `or`. These definitions follow easily from our `if` function.

<div>
$$\text{Boolean Algebra}$$
\begin{align*}
and &= \lambda a \lambda b (((if)a)b)\text{#f}
\\ or &= \lambda a \lambda b (((if)a)\text{#t})b
\end{align*}
</div>

With boolean manipulation and conditionals in hand, we need some useful predicates to make use of them. We define some basic predicates on numbers with the following. `eq` will be very useful in later developments; it is one of McCarthy's elementary functions.

<div>
$$\text{Numerical Predicates}$$
\begin{align*}
\\ zero? &= \lambda n ((n)λx\text{#f})\text{#t}
\\ leq &= \lambda a \lambda b (zero?)((-)m)n
\\ eq &= \lambda a \lambda b (and \space (\leq \space a \space b) (\leq \space b \space a))
\end{align*}
</div>

###Pairs
Finally we reach the most important part of our S-Expressions, their underlying lists. To construct lists we will opt for a sort of linked-list implementation in our lambda definitions. We begin with a pair and a `nil` definition, each readily revealing their type by opting for either the passed `c` or `n`.

<div>
$$\text{Pairs}$$
\begin{align*}
cons &= \lambda a \lambda b \lambda c \lambda n ((c)a)b
\\ nil &= \lambda c \lambda n (n)id
\end{align*}
</div>

Now, once again we follow a defined data-type with its manipulations. Just as did McCarthy, we will provide `car` and `cdr` as additional elementary functions, with `pair?` and `null?` complements to each other in determining the end of a list.

<div>
$$\text{Pair Operations}$$
\begin{align*}
car &= \lambda l (((l)\lambda a \lambda b a)id)
\\ cdr &= \lambda l (((l)\lambda a \lambda b b)id)
\\ pair? &= \lambda l (((l)\lambda \_ \lambda \_ \text{#t})\lambda \_ \text{#f})
\\ null? &= \lambda l (((l)\lambda \_ \lambda \_ \text{#f})\lambda \_ \text{#t})
\end{align*}
</div>

###Recursion
Our last definition will be a bit more esoteric, or at least complex. We define a *Y Combinator*. This function, `Y`, will allow another to perform recursion accepting itself as an argument.

<div>
$$\text{Recursion by a Combinator}$$
\begin{align*}
Y = λf(λx(f)(x)x)λx(f)(x)x
\end{align*}
</div>

We have now laid a good foundation upon which our Symbolic Expressions can exist. As should be expected, lists will be our primary data-structure in our language of S-Expressions.

A Language of S-Expressions
---------------------------
###Numbers
Returning to our prior definition of numbers, we will now define arbitrarily long strings of decimal digits.

<div>
\begin{align*}
1 &= (succ \space 0)
\\ 2 &= (succ \space 1)
\\ \dots
\\ 9 &= (succ \space 8)
\\ ten &= (succ \space 9)
\\ d...0 &= (mul \space d... \space ten)
\\ d...1 &= (sum \space (mul \space d... \space ten) \space 1)
\\ \dots
\\ d...9 &= (sum \space (mul \space d... \space ten) \space 9)
\end{align*}
</div>

###List Literals
We define our lists inductively based on the pair-constructing `cons` function we defined earlier. We choose to name this function `quote` because it is treating the entire expression as a literal, rather than as a symbolic expression.

The following has a rather sensitive notation. Quotes show that an atomic value is being matched rather than a portion of a pattern being labeled. Additionally, the italized *ab...* is meant to label the first letter and rest of a string as `a` and `b`, respectively.

<div>
\begin{align*}
(\text{quote } (a)) &\implies cons \space a \space nil
\\ (\text{quote } (a \space rest...)) &\implies (cons \space (\text{quote } a) \space (\text{quote } (rest...))
\\ (\text{quote } a \space rest...) &\implies (cons \space (\text{quote } a) \space (\text{quote } (rest...)))
\\ (\text{quote } "0") &\implies 0
\\ \dots
\\ \\ (\text{quote } "99") &\implies 99
\\ \dots
\\ (\text{quote } "ab...") &\implies (cons \space a \space (\text{quote } b...))
\\ (\text{quote } \text{"a"}) &\implies (cons \space 97 \space nil)
\\ \dots
\\ (\text{quote } \text{"z"}) &\implies (cons \space 122 \space nil)
\end{align*}
</div>

In addition to defining this quote function, we will provide a shorthand for the operation. So often will we need to define list literals that it makes perfect sense for us to make it as brief as possible.

<div>
\begin{align*}
'a = (\text{quote } a)
\end{align*}
</div>

###Equality
We have built up an array of atomic values, and a way of keeping them literal. Now we need a way of recognizing them, by means of equivalence. `eq` already solves this problem for numbers, but not for other quoted atoms. We generalize `eq` to all expressions in our definition of `equal?`.

<div>
\begin{align*}
(\text{equal? } (a \space b...) \space (c \space d...)) &\implies (and \space (\text{equal? } a \space c) \space (\text{equal? } (b...) \space (d...)))
\\ (\text{equal? } a \space b) &\implies (eq \space a \space b)
\end{align*}
</div>

###Variable Definition
Now we add some *syntactic sugar* that will make it easier to store values that will be used in an expression. `let` and `let*` set a single value and a list of values, respectively, to be utilized in a given expression. `letrec` takes this idea in another direction, performing the Y-Combinator on a passed function to prepare it for recursion in the passed expression.

<div>
\begin{align*}
(\text{let } var \space val \space expr) &\implies ((\text{lambda } (var) \space expr) \space val)
\\ (\text{let* } ((var \space val)) \space expr) &\implies (\text{let } var \space val \space expr)
\\ (\text{let* } ((var \space val) \space rest...) \space expr) &\implies ((\text{lambda } (var) \space (\text{let* } (rest...) \space expr)) \space val)
\\ (\text{letrec } var \space fn \space expr) &\implies (\text{let } var \space (Y \space (\text{lambda } f \space fn)) \space expr)
\end{align*}
</div>
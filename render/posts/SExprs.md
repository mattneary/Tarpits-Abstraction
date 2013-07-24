Defining Symbolic Expressions
=============================
Introduction
------------
You have been told that the Lambda Calculus is computationally universal, capable of expressing any algorithm. However, this most likely seems intangible. We will begin to define a layer of abstraction over the Lambda Calculus which makes design of programs begin to seem conceivable.

Symbolic Expressions
--------------------
The language into which we are entering is one of symbolic expressions. All of our expressions will take the form defined by the following grammar. This uniformity will make its definition in terms of Lambda Calculus far easier, as well as it will its later interpretation or compilation.

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


Foundations in Lambda Calculus
------------------------------
To accompany our syntactic constructs, we will need to define some forms in the Lambda Calculus, especially data-types and their manipulations. Our definitions will be illustrated as equalities, like $id = \lambda xx$; however, syntactic patterns will be expressed as implications. We begin with a means of defining all natural numbers inductively, via the successor.

<div>
$$\text{Numbers}$$
\begin{align*}
0 &= \lambda f \lambda x x
\\ succ &= \lambda n \lambda f \lambda x (f)((n)f)x
\end{align*}
</div>

This is our first data-type. The definition is iterative in nature, with zero meaning no applications of the function `f` to `x`. We now will define some elementary manipulations of this data-type, i.e., basic arithmetic.

<div>
$$\text{Arithmetic}$$
\begin{align*}
+ &= \lambda n \lambda m ((n)succ)m
\\ * &= \lambda n \lambda m ((n)(sum)m)0
\\ pred &= \lambda n \lambda f \lambda z (((n \lambda g \lambda h (h)(g)f)\lambda u z)\lambda u u)
\\	- &= \lambda n \lambda m ((m)pred)n
\end{align*}
</div>

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

Finally we reach the most important part of our S-Expressions, their underlying lists. To construct lists we will opt for a sort of linked-list implementation in our lambda definitions. We begin with a pair and a `nil` definition, each readily revealing their type by opting for either the passed `c` or `n`.

<div>
$$\text{Pairs}$$
\begin{align*}
cons &= \lambda a \lambda b \lambda c \lambda n ((c)a)b
\\ nil &= \lambda c \lambda n (n)id
\end{align*}
</div>

Now, once again we follow a defined data-type with its manipulations. Just as did McCarthy, we will provide `car` and `cdr` as additional elementary functions, with `pair?` serving as a close substitute-foundation for the operations made possible by `atom`. Of course we additionally provide the sibling to `pair?`, a nil-checker, in the form of `null?`.

<div>
$$\text{Pair Operations}$$
\begin{align*}
car &= \lambda l (((l)\lambda a \lambda b a)id)
\\ cdr &= \lambda l (((l)\lambda a \lambda b b)id)
\\ pair? &= \lambda l (((l)\lambda \_ \lambda \_ \text{#t})\lambda \_ \text{#f})
\\ null? &= \lambda l (((l)\lambda \_ \lambda \_ \text{#f})\lambda \_ \text{#t})
\end{align*}
</div>

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
Returning to our prior definition of numbers, we will now define arbitrarily long strings of decimal digits.

<div>
\begin{align*}
1 &= (succ)0
\\ 2 &= (succ)1
\\ \dots
\\ 9 &= (succ)8
\\ ten &= (succ)9
\\ d...0 &= ((mul)d...)ten
\\ d...1 &= ((sum)((mul)d...)ten)(1)
\\ \dots
\\ d...9 &= ((sum)((mul)d...)ten)(9)
\end{align*}
</div>

We define our lists inductively based on the pair-constructing `cons` function we defined earlier. We choose to name this function `quote` because it is treating the entire expression as a literal, rather than as a symbolic expression.

The following has a rather sensitive notation. Quotes show that an atomic value is being matched rather than a portion of a pattern being labeled. Additionally, the italized *ab...* is meant to label the first letter and rest of a string as `a` and `b`, respectively.

<div>
\begin{align*}
(\text{quote } (a)) &\implies cons \space a \space nil
\\ (\text{quote } (a \space rest...)) &\implies ((cons) (\text{quote } a)) (\text{quote } (rest...))
\\ (\text{quote } a \space rest...) &\implies ((cons) (\text{quote } a)) (\text{quote } (rest...))
\\ (\text{quote } "0") &\implies 0
\\ \dots
\\ \\ (\text{quote } "99") &\implies 99
\\ \dots
\\ (\text{quote } "ab...") &\implies ((cons)a)(\text{quote } b...)
\\ (\text{quote } \text{"a"}) &\implies ((cons)97)(nil)
\\ \dots
\\ (\text{quote } \text{"z"}) &\implies ((cons)122)(nil)
\end{align*}
</div>

In addition to defining this quote function, we will provide a shorthand for the operation. So often will we need to define list literals that it makes perfect sense for us to make it as brief as possible.

<div>
\begin{align*}
'a = (\text{quote } a)
\end{align*}
</div>

Now we will add a couple methods purely for convenience. These will serve as a means of defining values for use in a given expression.

<div>
\begin{align*}
(\text{let } var \space val \space expr) &\implies (\lambda var \space expr)val
\\ (\text{let* } ((var \space val)) \space expr) &\implies (\lambda var \space expr)val
\\ (\text{let* } ((var \space val) \space rest...) \space expr) &\implies (\lambda var \space (\text{let* } (rest...) \space expr))val
\\ (\text{letrec } var \space fn \space expr) &\implies (\text{let } var \space (Y)(\text{lambda } f \space fn) \space expr)
\end{align*}
</div>

Finally, we provide a default behavior for our Symbolic Expressions, as invocations of a function.

<div>
\begin{align*}
\\ & (fn \space val) = (fn)val
\\ & (fn \space val \space rest...) = ((fn)val \space rest)
\end{align*}
</div>
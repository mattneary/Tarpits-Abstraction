A Library of Symbolic Functions
===============================
Introduction
------------
We have formed a language constituent of Symbolic Expressions. Additionally, we have an array of useful and primitive Lambda Calculus functions at our disposal. Now in order to build expressive and powerful programs, it will be helpful to define a library of useful Symbolic Functions for manipulation of the various data-types we have formed by abstraction.

Predicates
----------
We begin with a trivial example, a boolean inverter.

$$(not \space (\text{lambda } (x) \space (if \space x \space \text{#f } \text{#t})))$$

Now we add to our current assortment of numeric predicates the functions `<` and `>`.

<div>
\begin{align*}
	&(< \space &(\text{lambda } (x \space y) (and \space (leq \space x \space y) (not \space (eq \space x \space y)))))
\\	&(> \space &(\text{lambda } (x \space y) (not \space (leq \space x \space y))))
\end{align*}
</div>	

With `>` and `<` defined, we can easily extrapolate positive and negative predicates. In the following we utilize the foundation of multi-argument lambdas which we elected, that is, we *curry* the comparator functions.

<div>
\begin{align*}
	&(positive? \space &(< \space 0))
\\	&(negative? \space &(> \space 0))
\end{align*}
</div>	

Lastly we provide predicates to determine whether a given number is even or odd.

<div>
\begin{align*}
	&(odd? \space &(\text{lambda } \space (x) \space (= \space (mod \space x \space 2) \space 1)))
\\	&(even? \space &(\text{lambda } \space (x) \space (= \space (mod \space x \space 2) \space 0)))
\end{align*}
</div>	

Higher-Order Functions
----------------------
In writing clear and concise expressions, it is often useful to have at your disposal higher-order functions (*HOF*), that is, functions that (a) return functions, (b) accept functions as arguments, or (c) do both *a* and *b*.

We begin with a couple of type (c) HOFs. The first of the following serves to flip the argument ordering of a given function, and the second composes two functions.
<div>
\begin{align*}
	&(flip \space &(\text{lambda } (func \space a \space b) \space (func \space b \space a)))
\\	&(compose \space &(\text{lambda } (f \space g) \space (\text{lambda } \space (arg) \space (f \space (g \space arg)))))
\end{align*}
</div>	

One of the most important HOFs is defined next. `fold` serves to accumulate a list of values into a single resultant value, based on a function of combination and a starting value. Note that this function is recursive and will be provided using `letrec`. Other functions accepting their name as the first argument should be assumed to follow the same practice.

<div>
\begin{align*}
\\	&(fold \space (\text{lambda } (fold \space func \space accum \space lst)
\\	&\quad  (if \space (null? \space lst)
\\  &\qquad  	accum
\\	&\qquad    (fold \space func \space (func \space accum \space (car \space lst)) \space (cdr \space lst)))))
\end{align*}
</div>	

As a complement to `fold` we define `reduce`. `reduce` is just like `fold` except right-associative. Hence the function applications are nested just like the `cons` basis of these lists.

<div>
\begin{align*}
\\	&(reduce \space (\text{lambda } (reduce \space func \space end \space lst)
\\	&\quad  (if \space (null? \space lst)
\\  &\qquad  	end
\\	&\qquad    (func (car lst) (reduce func end (cdr lst))))))
\end{align*}
</div>	

Together `reduce` and `fold` are sufficient basis for any iterative process. Now we will provide an inverse operation for constructing a list given a construction criterion. `unfold` serves to invert a folding.

<div>
\begin{align*}
\\	&(unfold \space (\text{lambda } (unfold \space func \space init \space pred)
\\	&\quad  (if \space (pred \space init)
\\  &\qquad  	(cons init nil)
\\	&\qquad    (cons init (unfold func (func init) pred)))))
\end{align*}
</div>

Together our definitions of `fold` and `reduce` are sufficient for definition of any iterative process. `unfold` in addition provides us with a means of constructing arbitrary lists based on constructing rules. We will now implement a variety of derived iterative forms based on `fold` and `reduce`.

Reductive Forms
---------------
We begin with some extensions to our basic binary operators of arithmetic and boolean algebra. The structure of these definitions is similar to that of our early definitions of arithmetic, an iterative process on a base value; however, in this case the conditions and multitude of application is determined by a provided list.

<div>
\begin{align*}
&(sum \space (\text{lambda } (lst) \space &(fold \space + \space 0 \space lst))
\\&	(product \space (\text{lambda } (lst) \space &(fold \space * \space 1 \space lst))
\\&	(and* \space (\text{lambda } (lst) \space &(fold \space and \space \text{#t} \space lst))
\\&	(or* \space (\text{lambda } (lst) \space &(fold \space or \space \text{#f} \space lst))
\end{align*}
</div>

Now we define some optimization functions, `max` and `min`.

<div>
\begin{align*}
&	(max \space &(list) \space (fold \space (\text{lambda } (old \space new) \space (if \space (> \space old \space new) \space old \space new)) \space (car \space list) \space (cdr \space list)))
\\&	(min \space &(list) \space (fold \space (\text{lambda } (old \space new) \space (if \space (< \space old \space new) \space old \space new)) \space (car \space list) \space (cdr \space list)))
\end{align*}
</div>

The following are methods that aid in treatment of lists in their entirety, `length` and `reverse`.

<div>
\begin{align*}
&	(length \space &(\text{lambda } (lst) \space (fold \space (\text{lambda } (x \space y) (+ \space x \space 1)) \space 0 \space lst)))
\\&	(reverse \space &(\text{lambda } (lst) \space (fold \space (flip \space cons) \space nil \space lst)))
\end{align*}
</div>

Now we provide a special function for determining associations in a list meant as a table. The setup of these lists is like the following.

<div>
\begin{align*}
&	'((apple \space &red)
\\& \space \space  (pear \space &green)
\\& \space \space   (banana \space &yellow))
\end{align*}
</div>

In determining the association, we `fold` with the aim of reaching  a value with a leading value matching our search key.

<div>
\begin{align*}
&	(assoc \space (\text{lambda } \space (x \space list)
\\&	\quad  (fold 
\\&	\qquad    (\text{lambda } 
\\&	\qquad \quad      (accum \space item) 
\\&	\qquad \quad      (if 
\\&	\qquad \qquad        (equal? \space item \space (car \space x))
\\&	\qquad \qquad        (cdr \space x)
\\&	\qquad \qquad        accum)))
\\&	\qquad    \text{#f}
\\&	\qquad list)))
\end{align*}
</div>    

List Manipulations
------------------
We now add some convenient, basic manipulations of lists.

<div>
\begin{align*}
&	(map &(\text{lambda } (func \space lst) \space (reduce \space (\text{lambda } (x \space y) \space (cons \space (func \space x) \space y)) \space nil \space lst)))
\\&	(filter &(\text{lambda } (pred \space lst) \space (reduce \space (\text{lambda } (x \space y) \space (if \space (pred \space x) \space (cons \space x \space y) \space y)) \space nil \space lst)))
\end{align*}
</div>

Now we provide functions for appending to a list, either a single element of a list of elements, i.e., *concatenation*.

<div>
\begin{align*}
&	(push \space &(\text{lambda } (a \space b) \space (reverse \space (cons \space b \space (reverse \space a)))))
\\&	(concat \space &(\text{lambda } (a \space b) \space (fold \space push \space a \space b)))
\end{align*}
</div>
A Library of Symbolic Functions
===============================
Introduction
------------
We have formed a language constituent of Symbolic Expressions. Additionally, we have an array of useful and primitive Lambda Calculus functions at our disposal. Now in order to build expressive and powerful programs, it will be helpful to define a library of useful Symbolic Functions for manipulation of the various data-types we have formed by abstraction.

Predicates
----------
We begin with a trivial example, a boolean inverter. Our definition is listed as an S-Expression because when we are ready to make use of it, we will include that pair in a call to `let*`. The name of the function is the first element, because this is the variable to which it will be assigned. The actual function definition is very familiar. We form a lambda of a single function that results in conditional behavior; if `x` is true, it results in `#f`, but if `x` is false, it results in `#t`.

$$(not \space (\text{lambda } (x) \space (if \space x \space \text{#f } \text{#t})))$$

Now we add to our current assortment of numeric predicates the functions `<` and `>`. These predicates are lambdas accepting two values, that they may be compared. With less-than-equal-to already defined as `leq`, both of these relations are trivial to define.

<div>
\begin{align*}
	&(< \space &(\text{lambda } (x \space y) \space (and \space (leq \space x \space y) (not \space (eq \space x \space y)))))
\\	&(> \space &(\text{lambda } (x \space y) \space (not \space (leq \space x \space y))))
\end{align*}
</div>	

An important conveniency to note in the above forms, is their nature given their Lambda Calculus definitions. That is, since they compile down to a curried form of a function, in other words, a function returning a function, they are very nice to work with. Let's look at an example form and apply appropriate reductions to get a better view of this function's nature.

<div>
\begin{align*}
	&(> \space 2)
\\ \implies &((\text{lambda } (x \space y) \space (not \space (leq \space x \space y))) \space 2)
\\ \implies &(\text{lambda } (y) \space (not \space (leq \space 2 \space y)))	
\end{align*}
</div>

What we see is that when a single value is passed, we achieve a convenient function ready to compare in terms of that parameter. This may seem obvious, familiar, or redundant, but the convenience of this fact should not be taken for granted. This phenomenon is known as currying; it can prove very useful in providing clearness to your expressions, our look at `>` was only an example of what is going on in all of the functions we discuss.

This ability to supply the arguments of a function one at a time makes for very legible code. Below is an example of an inductive definition utilizing this functionality. The predicate is `<` with the first argument supplied as two, the step is the `pred` function, and the combinator is multiplication.

<div>
$$\text{Generalized Inductive Calculator}$$
\begin{align*}
&(\text{let } 
\\& \quad induct 
\\& \quad (\text{lambda } 
\\& \qquad    (pred \space num \space step \space combo) 
\\& \qquad	  (if 
\\& \qquad \quad	(pred \space num) 
\\& \qquad \quad	num 
\\& \qquad \quad	(combo \space num \space (step \space num)))) 
\\& \quad  (induct \space (> \space 2) \space 6 \space pred \space *))
\\& \implies 720
\end{align*}
</div> 

This reads very well, as "perform induction while greater than 2 from 6 by means of decrement combining with multiplication", i.e., find the factorial of 6. Let's look at another instance of this, taking advantage of the interchangeability of the definition, and once again of partial function application. This time we induce addition up to and at five, stepping by two in each step up from one.

<div>
\begin{align*}
&(\text{let } 
\\& \quad induct 
\\& \quad \dots
\\& \quad  (induct \space (< \space 5) \space 1 \space (+ \space 2) \space +))
\\& \implies 16
\end{align*}
</div>

Our answer coincides with what you would expect, the sum of odd numbers one through seven. Hopefully you feel that our language displays complexity well. The above example handled a very generic problem type elegantly and concisely. It is thanks to our adding of abstraction as we go that we are able to make these creations both clear and versatile, and ones in which the creator can take pride.

Lastly we provide predicates to determine whether a given number is even or odd. This function is once again very easy given our convenient Lambda Calculus primitives. The following two functions simply check for a specific value of the modulus division by two applied to a number; this is the essence of parity.

<div>
\begin{align*}
	&(odd? \space &(\text{lambda } \space (x) \space (eq \space (mod \space x \space 2) \space 1)))
\\	&(even? \space &(\text{lambda } \space (x) \space (eq \space (mod \space x \space 2) \space 0)))
\end{align*}
</div>	

Use cases for these two predicates will arise later, but for now they are good at their simple duties, determining parity.

Higher-Order Functions
----------------------
In writing clear and concise expressions, it is often useful to have at your disposal higher-order functions (*HOF*), that is, functions that (a) return functions, (b) accept functions as arguments, or (c) do both *a* and *b*.

Hopefully you caught something odd in what I just said, the fact that everything, hence any possible argument or resultant value, is a function! However since we have defined some primitive data-types, I am referring to non-data-symbolizing functions. This may seem a fine line, but you will often seen this terminology tossed around, so you may as well utilize it even in when in the purest of functional languages.

We begin with a couple of type (c) HOFs. The first of the following serves to flip the argument ordering of a given function, and the second composes two functions.
<div>
\begin{align*}
	&(flip \space &(\text{lambda } (func \space a \space b) \space (func \space b \space a)))
\\	&(compose \space &(\text{lambda } (f \space g) \space (\text{lambda } \space (arg) \space (f \space (g \space arg)))))
\end{align*}
</div>	

The function `flip` is very convenient when aiming to apply only the second argument of a function, leaving the other free. The design of `flip` is quite simple, it merely accepts a function, then two arguments, and returns application of them in reverse order. Despite the simplicity of its operation, it can really greatly reduce the complexity of an expression. As an example, look at the following definition of a singleton constructor, that is, a creator of a pair with a single element.

$$\text{Singleton Constructor}$$
$$((flip \space cons) \space nil)$$


`compose` allows the results of various manipulations to be piped from one to another. A beautiful example of this is a linear function creator. Below is the function accepting slope and y-intercept as its two arguments.

<div>
$$\text{Linear Function Generator}$$
\begin{align*}
&(\text{lambda } 
\\& \quad (m \space b) 
\\& \quad (compose 
\\& \qquad (+ \space b) 
\\& \qquad (* \space m)))
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

Our definition of `fold` is as a manipulator of a list returning an accumulated value at the end of a list, and at other points recursing with the `cdr` of the list and an accumulator as determined by the passed function. If the meaning of `fold` is still unclear to you, consider some of these examples.

$$(fold \quad + \quad 0 \quad '(1 \space 2 \space 3)) \implies 6$$
$$(fold \quad * \quad 0 \quad '(1 \space 2 \space 3 \space 4)) \implies 24$$

As you can now see, the folding of an infix operation $a \bullet b$ over a sequence $a, b, c, \dots$ is the nested application of the operation, or the following.

$$( \dots ((a \bullet b) \bullet c) \dots )$$

As a complement to `fold` we define `reduce`. `reduce` is just like `fold` except right-associative; Hence the function applications are nested just like the `cons` basis of these lists.

<div>
\begin{align*}
\\	&(reduce \space (\text{lambda } (reduce \space func \space end \space lst)
\\	&\quad  (if \space (null? \space lst)
\\  &\qquad  	end
\\	&\qquad    (func \space (car \space lst) \space (reduce \space func \space end \space (cdr \space lst))))))
\end{align*}
</div>	

Our definition of `reduce` is as a manipulator of a list returning an accumulated value at the end of a list, and at other points returning a manipulation of a recursion with the `cdr`, manipulated by the passed function. If we do an expansion of an infix operator for `reduce` as we did for `fold` we achieve something like this following when dealing with a list $\dots , x, y, z$

$$( \dots (x \bullet (y \bullet z)) \dots )$$

Together `reduce` and `fold` are sufficient basis for any iterative process. Now we will provide an inverse operation for constructing a list given a construction criterion. `unfold` serves to invert a folding.

<div>
\begin{align*}
\\	&(unfold \space (\text{lambda } (unfold \space func \space init \space pred)
\\	&\quad  (if \space (pred \space init)
\\  &\qquad  	(cons \space init \space nil)
\\	&\qquad    (cons \space init \space (unfold \space func \space (func \space init) \space pred)))))
\end{align*}
</div>

To clarify the distinction between `fold` and `reduce`, we display the manner in which they can be thought of as opposites.

<div>
\begin{align*}
&(fold \quad (flip \space cons) \quad nil \quad '(1 \space 2 \space 3)) &\implies '(1 \space 2 \space 3)
\\& (reduce \quad cons \quad nil \quad '(1 \space 2 \space 3)) &\implies '(1 \space 2 \space 3)
\end{align*}
</div>

This examples drives home that the difference between the two is in direction of association, `reduce` is the natural operation for right associative operations and `fold` for left associative operations.

Together our definitions of `fold` and `reduce` are sufficient for definition of any iterative process. `unfold` in addition provides us with a means of constructing arbitrary lists based on constructing rules. We will now implement a variety of derived iterative forms based on `fold` and `reduce`.

Reductive Forms
---------------
We begin with some extensions to our basic binary operators of arithmetic and boolean algebra. The structure of these definitions is similar to that of our early definitions of arithmetic, an iterative process on a base value; however, in this case the conditions and multitude of application are determined by a provided list.

All of the following forms, which we will refer to as *Reductive Forms* are dependent on either `fold`. `fold` provides the generic versatile power to combine a list in an arbitrary way; hence you will see a variety of operations used in folding, so you may want to think back to the examples of the nested operator.

We begin with some definitions of arithmetic and boolean manipulations. The definitions of these forms are intuitive, each with an infix operator which fits the role very intuitively.

<div>
\begin{align*}
&(sum \space (\text{lambda } (lst) \space &(fold \space + \space 0 \space lst))
\\&	(product \space (\text{lambda } (lst) \space &(fold \space * \space 1 \space lst))
\\&	(and* \space (\text{lambda } (lst) \space &(fold \space and \space \text{#t} \space lst))
\\&	(or* \space (\text{lambda } (lst) \space &(fold \space or \space \text{#f} \space lst))
\end{align*}
</div>

Now we expand our application field in defining some optimization functions, `min` and `max`. Both of these works by comparing each element with a running extreme value, swapping if a new extreme is found. The definition of `max` follows, a simple folding onto the higher value.

<div>
\begin{align*}
&	(max 
\\&	\quad (list)
\\&	\quad (fold 
\\&	\qquad  (\text{lambda } 
\\&	\qquad \quad (old \space new)
\\&	\qquad \quad (if
\\&	\qquad \qquad (> \space old \space new)
\\&	\qquad \qquad old
\\&	\qquad \qquad new))
\\&	\quad (car \space list)
\\&	\quad (cdr \space list)))
\end{align*}
</div>

The application of this function to $'(1 \space 5 \space 3 \space 4)$, for example, would return 5. Our implementation of `min` is nearly identical, simply changing the criterion of the sort.

<div>
\begin{align*}
&	(min 
\\&	\quad (list)
\\&	\quad (fold 
\\&	\qquad  (\text{lambda } 
\\&	\qquad \quad (old \space new)
\\&	\qquad \quad (if
\\&	\qquad \qquad (> \space old \space new)
\\&	\qquad \qquad old
\\&	\qquad \qquad new))
\\&	\quad (car \space list)
\\&	\quad (cdr \space list)))
\end{align*}
</div>

Next we define some methods that aid in treatment of lists in their entirety, `length` and `reverse`. `length` is one of the simplest folds you could define, folding by increment. `reverse` on the other hand, is not as obvious in its means of operation; it folds by means of a swap operation, $(flip \space cons)$, in this way forming a fully reversed list.

<div>
\begin{align*}
&	(length \space &(\text{lambda } (lst) \space (fold \space (\text{lambda } (x \space y) (+ \space x \space 1)) \space 0 \space lst)))
\\&	(reverse \space &(\text{lambda } (lst) \space (fold \space (flip \space cons) \space nil \space lst)))
\end{align*}
</div>

Now we provide a special function for determining associations in a list meant as a table. The setup of these lists is like the following, where each element is a list, with the first element serving as a key, and the second serving as a value.

<div>
\begin{align*}
&	'((apple \space &red)
\\& \space \space  (pear \space &green)
\\& \space \space   (banana \space &yellow))
\end{align*}
</div>

In determining the association, we `fold` with the aim of reaching a value with a key matching that for which we are searching.

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

`assoc` is very important in modeling hash-tables, and in general keeping track of named values. If `assoc` were applied to the table displayed prior with `banana` as a key, it would evaluate to `yellow`. Here is the full form, with `table` referring to the aforementioned table.

$$(assoc \quad 'banana \quad table) \implies 'yellow$$

List Manipulations
------------------
In manipulating a list, there are two basic classes of operations, (a) mapping a list to a value, and (b) converting one list to another. We have thoroughly covered the former, starting first with general forms and then implementing some useful examples. Now we will move on to the latter.

In mapping one list to another, we will provide two generic functions. The first, `map`, will apply a single function to each element of a list; the second will filter out items based on a predicate. These functions are very useful, imagine for example finding a sum of squares or constructing a list of primes.

<div>
\begin{align*}
&	(map 
\\&	\quad (\text{lambda } 
\\&	\qquad (func \space lst)
\\&	\qquad (reduce
\\&	\qquad \quad (\text{lambda } 
\\&	\qquad \qquad (x \space y) 
\\&	\qquad \qquad (cons \space (func \space x) \space y)) 
\\&	\qquad \quad nil
\\&	\qquad \quad lst)))
\end{align*}
</div>

Our map implementation works as a reduction with `cons`; if this were the extent of the function, the initial list would be returned. However, each element is passed through the provided function to result in a list with modified elements. `filter` takes advantage of the same aspect of `reduce`; however, in its definition it casts away values not matching a predicate.

<div>
\begin{align*}
\\&	(filter 
\\&	\quad (\text{lambda } 
\\&	\qquad (pred \space lst)
\\&	\qquad (reduce
\\&	\qquad \quad (\text{lambda } 
\\&	\qquad \qquad (x \space y)
\\&	\qquad \qquad (if
\\&	\qquad \qquad \quad (pred \space x)
\\&	\qquad \qquad \quad (cons \space x \space y)
\\&	\qquad \qquad \quad y))
\\&	\qquad \quad nil
\\&	\qquad \quad lst)))
\end{align*}
</div>

Let's look at some examples of `map` and `reduce`; the extent of their usefulness was alluded to earlier, but below are some examples to clarify their usage.

<div>
\begin{align*}
	&(map \quad &(* \space 2) \quad &'(1 \space 2 \space 3)) &\implies '(2 \space 4 \space 6)
\\	&(filter \quad &odd? \quad &'(1 \space 2 \space 3 \space 4 \space 5 \space 6)) &\implies '(1 \space 3 \space 5)
\end{align*}
</div>

The above were very clear in their meaning, as one would hope. Now that we have some strong ways of manipulating a list, we will move on to means of adding elements to a list. We provide some functions for appending to a list, either a single element of a list of elements, i.e., *concatenation*. These functions serve as nice complements to the two which were defined above, as they allow for expansion to supersets, and the earlier two allow only for constructing a subset.

<div>
\begin{align*}
&	(push \space &(\text{lambda } (a \space b) \space (reverse \space (cons \space b \space (reverse \space a)))))
\\&	(concat \space &(\text{lambda } (a \space b) \space (fold \space push \space a \space b)))
\end{align*}
</div>

These list manipulations will prove very useful, and given our prior functions, were very concise and clear in definition. Below are some examples of `push` and `concat` applications.

<div>
\begin{align*}
	&(push \quad &4 \quad &'(1 \space 2 \space 3)) &\implies '(1 \space 2 \space 3 \space 4)
\\	&(concat \quad &'(1 \space 2) \quad &'(2 \space 4)) &\implies '(1 \space 2 \space 3 \space 4)
\end{align*}
</div>

Conclusion
----------
We have amassed a variety of useful and versatile functions of symbolic expressions. With these in hand, we are ready to build complex and useful programs.
Interpreting a Language
=======================
The most important revelation in learning the art of programming is that the language in which you work is completely arbitrary. More specifically, the language in which you express concepts was defined in terms of another language at some point. We have already made clear this concept in our definition of our symbolic language. We now turn to the interpretation of one language within another.

##Lambda Calculus
The language which we will interpret is one with which we are already familiar, Lambda Calculus. The Lambda Calculus has very simple syntax and will thus not be too hard to interpret. Recall the syntax, which is composed of the following expressions.

- A variable reference.
- A function definition of the form $\lambda a b$ where $a$ is a variable reference and $b$ is an expression.
- A function application of the form $(a)b$ where $a$ is an expression, as is $b$.

Note that the generality of the third form, function application, is what gives this syntax its description as the Untyped Lambda Calculus. Since no qualification is given to the expression which will be passed argument, this language is without types.

###Expression of Lambda Calculus in S-Expressions
In expression the Lambda Calculus in S-Expressions, we will utilize the `quote` function as well as the structure inherent of parenthetical expressions in these expressions. Hence an example of an expression which could be evaluated is the following.

$$'(lam \space x \space lam \space y \space (x) \space y)$$

###An Evaluator
We define our evaluator pretty easily. Note that we will begin by defining an `apply` function. This function accepts a function and list of arguments, and then applies each of these arguments to a lambda one by one.

<div>
\begin{align*}
& (define \space (\text{apply-set} \space fn \space args)
\\& \quad (if
\\& \qquad (null? \space args)
\\& \qquad fn
\\& \qquad (\text{apply-set} \space (fn \space (car \space args)) \space (cdr \space args))))
\end{align*}
</div>

Just like our definition of the syntax, our evaluator handles variable reference, lambda definition, and function application. 

Variable reference is a problem very easily solved. Atoms are considered variable references, and hence serve as keys in accessing values from the environment hash.

Function definition is achieved by returning a lambda of a single variable for expressions of the necessary form. Within the lambda, the passed argument is appended to the environment with the argument name as its key. The function body is then evaluated.

Function application is the default case, thus we match against the antecedent `#t`. The applier `apply-set` is then called with the evaluated form of the first argument and the evaluated arguments. This architecture is an explicit choice *not* to opt for a lazy method of evaluation.

<div>
\begin{align*}
& (evallam \space (\text{lambda} \space (evallam \space expr \space env)
\\& \quad (cond \space (((atom? \space expr) \space (assoc \space expr \space env))
\\& \qquad \qquad \space ((equal? \space (car \space expr) \space 'lam) \space 
\\& \qquad \qquad \quad \space (\text{lambda} \space (x) \space 
\\& \qquad \qquad \qquad \space (evallam \space 
\\& \qquad \qquad \qquad \quad \space (cddr \space expr) \space 
\\& \qquad \qquad \qquad \quad \space (set \space (cadr \space expr) \space x \space env))))
\\& \qquad \qquad \space ((null? \space (cdr \space expr)) \space 
\\& \qquad \qquad \quad (evallam \space (car \space expr) \space env))
\\& \qquad \qquad \space (\text{#t} \space 
\\& \qquad \qquad \quad \space (\text{apply-set} \space 
\\& \qquad \qquad \qquad \space (evallam \space (car \space expr) \space env) \space 
\\& \qquad \qquad \qquad \space (map \space 
\\& \qquad \qquad \qquad \quad \space (\text{lambda} \space (expr) \space (evallam \space expr \space env)) \space 
\\& \qquad \qquad \qquad \quad \space (cdr \space expr))))))))
\end{align*}
</div>

<div>
\begin{align*}
& (evallam \space (\text{lambda} \space (evallam \space expr \space env)
\\& \quad (cond \space (((atom? \space expr) \space (assoc \space expr \space env))
\\& \qquad \qquad \space ((equal? \space (car \space expr) \space 'lam) \space 
\\& \qquad \qquad \quad \space (\text{lambda} \space (x) \space 
\\& \qquad \qquad \qquad \space (evallam \space 
\\& \qquad \qquad \qquad \quad \space (cddr \space expr) \space 
\\& \qquad \qquad \qquad \quad \space (set \space (cadr \space expr) \space x \space env))))
\\& \qquad \qquad \space ((null? \space (cdr \space expr)) \space 
\\& \qquad \qquad \quad (evallam \space (car \space expr) \space env))
\\& \qquad \qquad \space (\text{#t} \space 
\\& \qquad \qquad \quad \space (\text{apply-set} \space 
\\& \qquad \qquad \qquad \space (evallam \space (car \space expr) \space env) \space 
\\& \qquad \qquad \qquad \space (map \space 
\\& \qquad \qquad \qquad \quad \space (\text{lambda} \space (expr) \space (evallam \space expr \space env)) \space 
\\& \qquad \qquad \qquad \quad \space (cdr \space expr))))))))
\end{align*}
</div>

###Evaluation of Forms
An example of a form which could be evaluated is the following.

<div>
\begin{align*}
& '(lam \space x \space lam \space y \space ((x) \space y) \space 1)
\end{align*}
</div>

##Flat-Input Lambda Calculus
In the prior implementation of an interpreter, we took advantage of the structure inherent to a nested S-Expression. This approach was sufficient for our initial purposes; however, to separate our interpreter from the details of its use within our Symbolic Language, we will now allow its interpretation to apply to a flat list of atoms.
In order to represent the expression previously expressed by nested S-Expressions, we will now utilize some symbols which will represent parenthetical expressions. The following example of this new flat structure.

$$'(lam \space x \space lam \space y \space < \space x \space > \space y)$$

Of course, this use of `<>` symbols would extend to any instance of parentheses in our prior method.

With our new, less inherently structured approach, we will need to provide an additional layer of parsing. Parsing will provide this missing aspect of structure. Parsing parentheses is actually our most complex algorithm yet attempted. We will take this algorithm's implementation as an opportunity to experiment with the second style of programming we have yet to investigate, imperative programming.

###The Two Styles of Programming
There are two basic approaches to programming, derived from the two original theories of computation. We have talked far more about functional programming tactics in prior sections of this book, leaving imperative programming on the sidelines. However, the problem at hand is a great case study in the relation between imperative and functional languages. We will begin with an imperative implementation, and then port the code over to our current language of choice.

###Imperative Constructs
In our exploration of imperative programming, we will encounter a few new operators, and utilize some new idioms. In later chapters, we will provide implementation of these operators. For now, however, these operators will be viewed as hypothetical constructs, fulfilling the utility with which we associate them.

####Mutators
The main difference between imperative and *purely* functional programming is the presence of mutability. In functional programs, a value can be defined but not mutated; however, when taking the imperative approach, values will often be set to a new value after their definition. The following is an example of this behavior.

<div>
\begin{align*}
& (define \space x \space 5)
\\& (set! \space x \space (* \space 2 \space x))
\\& (equal? \space x \space 5)
\\& ;; \space => \space \text{#f}
\\& (equal? \space x \space 10)
\\& ;; \space => \space \text{#t}
\\& => \space x \space = \space 10
\end{align*}
</div>

The `define` operator serves to allocate a variable and initiate it with a value. This variable, `x`, can then be accessed throughout the procedure, and even mutated to equal a new value. In the example, it was initiated as 5, but `set!` to 10.

The *scoping* of a variable is specified by the define operator; hence the following is another example of this behavior.

<div>
\begin{align*}
& (define \space x \space 5)
\\& ((\text{lambda} \space (y)
\\& \quad (set! \space x \space y)) \space 12)
\\& (equal? \space x \space 12) \space 
\\& ;; \space \text{#t}
\end{align*}
</div>

Of note is the fact that the `define` occurred separate from any function. This means that the defined variable will now take on the *global* scope, being accessible and mutable from within any function. If the `define` instead occurred within a function definition, as in the following, it would only be accessible from within that function, or other functions defined within it.

<div>
\begin{align*}
& (define \space scope \space (\text{lambda} \space (x)
\\& \quad (define \space y \space x)))
\\& (scope \space 5)
\\& y
\\& ;; \space The \space written \space variable, \space `y`, \space will \space be \space inaccessible.
\end{align*}
</div>

In the above we demonstrate definition with a single-function scope. Thus the `define` is fulfilling the same role as `let` did in prior programs. However, since `define` does not accept an expression which it will govern, the example definition is of no effect. In the following section we display a means of making use of this sort of `define` statement.

####Multiple Expression Procedures
In our earlier, purely-functional programs, a procedure consisting of multiple expressions would have been no use. Without side-effects, only the final expression could bear any form of result. However, now investigating an imperative approach, a procedure may utilize multiple expressions, each contributing its own mutation to a final effect. The following is an example of this in practice; the syntax is simply a chain of expressions where an individual would have previously existed.

<div>
\begin{align*}
& (define \space incr \space (\text{lambda} \space (x)
\\& \quad (define \space y \space (+ \space x \space 1))
\\& \quad y))
\end{align*}
</div>

Obviously, this example is of no utility. The desired function could be just as easily achieved with a single expression. Useful examples, however, will present themselves in the following sections.

####Loop Constructs
You will often see imperative programming avoiding use of recursion. Rather, these programs will often iterate, mutating the environment in each step. For convenience in utilization of this approach, we define a function for constructing a range over which to iterate.

<div>
\begin{align*}
& (define \space range \space (\text{lambda} \space (x)
\\& \quad (if \space (equal? \space x \space 0)
\\& \qquad nil
\\& \qquad (cons \space (- \space x \space 1) \space (range \space (- \space x \space 1))))))
\end{align*}
</div>

The above definition is pretty straight-forward, much like earlier function definitions. Note that the ranges are of the form $\{0, 1, \dots, n-1\}$. Here's an example of this function being used to calculate a factorial.

<div>
\begin{align*}
& (define \space fact \space (\text{lambda} \space (x)
\\& \quad (define \space ans \space 1)
\\& \quad (map \space (range \space x) \space (\text{lambda} \space (n)
\\& \qquad (set! \space ans \space (* \space and \space (+ \space 1 \space n)))))
\\& \quad ans))
\end{align*}
</div>

The starting value of the answer is 1, just like the sort of inductive definitions we provided earlier in the book. The final answer is then achieved by repeated multiplication performed on the previous `ans`. In the case of 5, for example, the accumulator `ans` takes on the following values.

<div>
\begin{align*}
& 1
\\& => \space 1*1 \space => \space 1
\\& => \space 1*2 \space => \space 2
\\& => \space 2*3 \space => \space 6
\\& => \space 4*6 \space => \space 24
\\& => \space 5*24 \space => \space 120
\end{align*}
</div>

###An Imperative Solution
Now we will jump right in to the non-trivial problem at hand, restated below.

<div>
\begin{align*}
\\	&\text{Given a string of nested angle-bracket delimited groups, return a }
\\	&\text{nested list containing the contents of these groups. For example, }
\\	&\text{given the list of characters } '(a \space \text{<} \space b \space c \space \text{>} \space d) \text{ return } '(a \space (b \space c) \space d) \text{.}
\end{align*}
</div>		

Since we are taking an imperative approach, think, "What is the easily defined iterative process underlying this problem?" The answer is clearly navigation of the string, and so we begin with a `range`-based loop that will cycle through each character of the string in order.

<div>
\begin{align*}
& (define \space parse \space (\text{lambda} \space (expr) \space 
\\& \quad (map \space (range \space (length \space expr)) \space (\text{lambda} \space (i)
\\& \qquad (define \space read \space (get \space expr \space i))
\\& \qquad // \space ...
\\& \quad )))
\end{align*}
</div>

Now we will need to describe a slightly more specific strategy in performing the desired process.

- A parenthetical will be split from the string, with a segment, although possibly an empty one, before and after it.
- Once a parenthetical has been removed, we will need to recurse on these segments, i.e., the parenthetical and the portion after it.

To make our way toward this implementation, we will define a variable `before` that will hold the segment of the string occurring prior to any parenthetical; a variable `accum` that will hold characters that have been read in but whose destination has yet to be determined, in this way serving as a cache; `paren` which will hold a separated out parenthetical; and `found` which will be true if and only if a parenthetical has been parsed.

<div>
\begin{align*}
& (define \space parse \space (\text{lambda} \space (expr) \space 
\\& \quad (define \space before)
\\& \quad (define \space accum \space nil)
\\& \quad (define \space paren)
\\& \quad (define \space found \space \text{#f)}
\\& \quad (map \space (range \space (length \space expr)) \space (\text{lambda} \space (i)
\\& \qquad (define \space read \space (get \space expr \space i))
\\& \qquad // \space ...
\\& \quad )))
\end{align*}
</div>

In order to parse out the parenthetical, however, we will need an additional variable. This variable will aid us in parsing nested parentheses to separate out the top-level parenthetical.

We will need to handle three obvious classes of characters in our parsing of the parentheses:

1. An opening parenthesis.
2. A closing parenthesis.
3. Any other character.

Additionally, the class of a character may be disregarded if we have already parsed a top-level parenthetical. Its parsing will be handled when we are ready to recurse. Given these additions of case-handling, we insert `if ... else` statements as in the following.

<div>
\begin{align*}
& (define \space parse \space (\text{lambda} \space (expr) \space 
\\& \quad (define \space before)
\\& \quad (define \space accum \space nil)
\\& \quad (define \space paren)
\\& \quad (define \space found \space \text{#f)}
\\& \quad (define \space nested \space 0)
\\& \quad (map \space (range \space (length \space expr)) \space (\text{lambda} \space (i)
\\& \qquad (define \space read \space (get \space expr \space i))
\\& \qquad (if \space (and \space (equal? \space '< \space read) \space (not \space found))
\\& \qquad \quad (..."1. \space an \space opening \space parenthesis"...)
\\& \qquad \quad (if \space (and \space (equal? \space '> \space read) \space (not \space found))
\\& \qquad \qquad (..."2. \space a \space closing \space parenthesis"...)
\\& \qquad \qquad (..."3. \space any \space other \space character"...))))))
\end{align*}
</div>

Of course, we will need to combine any separated out parenthetical with the components occurring before and after it to form the designated response. Hence we provide the following `return` statement.

<div>
\begin{align*}
& (define \space parse \space (\text{lambda} \space (expr) \space 
\\& \quad ..."variables"...
\\& \quad (map \space (range \space (length \space expr)) \space (\text{lambda} \space (i)
\\& \qquad (..."parse"...))
\\& \quad (if \space paren
\\& \qquad (concat \space (push \space before \space paren) \space (parse \space accum))
\\& \qquad expr)))
\end{align*}
</div>

Now we implement our nesting logic and the final algorithm. Nesting will be handled based on one of the following occurrences.

- A once nested expression was just opened.
- An expression was just closed to be un-nested.
 Parentheses occurred within a nested expression.

The first and second cases are handled under the conditionals for their respective character classes, and in either class under another nesting case, the third will be handled.

The last components missing from our implementation are the building up of an accumulator and the setting of the various components to the accumulator. We will implement these portions in the following code.

- When the parenthetical is closed, it is recursively `parsed` and set to the `paren` variable.
- When a parenthetical is open, `before` receives the accumulator value.

<div>
\begin{align*}
& (define \space parse \space (\text{lambda} \space (expr) \space 
\\& \quad (define \space before)
\\& \quad (define \space accum \space nil)
\\& \quad (define \space paren)
\\& \quad (define \space found \space \text{#f)}
\\& \quad (define \space nested \space 0)
\\& \quad (map \space (range \space (length \space expr)) \space (\text{lambda} \space (i)
\\& \qquad (define \space read \space (get \space expr \space i))
\\& \qquad (if \space (and \space (equal? \space '< \space read) \space (not \space found))
\\& \qquad \quad ((set! \space nested \space (+ \space 1 \space nested))
\\& \qquad \quad \space (if \space (equal? \space nested \space 1)
\\& \qquad \qquad \space ((set! \space before \space accum)
\\& \qquad \qquad \quad (set! \space accum \space nil))
\\& \qquad \qquad \space (set \space accum \space (push \space accum \space read)))
\\& \qquad \quad (if \space (and \space (equal? \space '> \space read) \space (not \space found))
\\& \qquad \qquad ((set! \space nested \space (- \space 1 \space nested))
\\& \qquad \qquad \space (if \space (equal? \space nested \space 0)
\\& \qquad \qquad \quad \space ((set! \space found \space \text{#t)}
\\& \qquad \qquad \qquad (set! \space paren \space (parse \space accum))
\\& \qquad \qquad \qquad (set! \space accum \space nil))
\\& \qquad \qquad \quad \space (set \space accum \space (push \space accum \space read)))
\\& \qquad \qquad (set \space accum \space (push \space accum \space read)))))
\\& \quad (if \space paren
\\& \qquad (concat \space (push \space before \space paren) \space (parse \space accum))
\\& \qquad expr)))
\end{align*}
</div>

###From Imperative to Functional
From the above final implementation of our program we can derive a functional version. The differences will be based on the following principles of functional programming:

- Values shall not be mutated.
- Control-flow shall not be explicit.
- Recursion is dope.

Let's begin by abiding to the second rule, inspired by the third. The first thing you will notice is that all variables were made function arguments. This is because in a pure function, the only state is provided by the arguments. Hence when recursing, we will need to pass all required data to the function as argument.

Also of note is the fact that rather than maintain an index of the list on which we are operating, we pass as argument to the recursive call only subsequent characters, i.e., those which have yet to be read. This is both logical in that our progress in navigating the list is maintained, and idiomatic as you have seen in prior programs written in our Symbolic Language.

<div>
\begin{align*}
& (define \space funparse \space (\text{lambda} \space (expr \space nested \space before \space paren \space accum \space found) \space 
\\& \quad (if \space (null? \space expr)
\\& \qquad (if \space (not \space (null? \space paren))
\\& \qquad \quad (concat \space (push \space before \space paren) \space (funparse_ \space accum))
\\& \qquad \quad expr)
\\& \qquad ((let \space read \space (get \space expr \space 0)
\\& \qquad \quad \space (if \space (and \space (equal? \space read \space '<) \space (not \space found)))
\\& \qquad \qquad \space ((set! \space nested \space (+ \space 1 \space nested))
\\& \qquad \qquad \quad (if \space (equal? \space 1 \space nested)
\\& \qquad \qquad \qquad ((set! \space before \space accum)
\\& \qquad \qquad \qquad \space (set! \space accum \space nil))
\\& \qquad \qquad \qquad (set \space accum \space (push \space accum \space read))))
\\& \qquad \qquad \quad (if \space (and \space (equal? \space read \space '>) \space (not \space found)))
\\& \qquad \qquad \quad \space ((set! \space nested \space (- \space 1 \space nested))
\\& \qquad \qquad \qquad (if \space (equal? \space 0 \space nested)
\\& \qquad \qquad \qquad \quad ((set! \space paren \space (funparse_ \space accum))
\\& \qquad \qquad \qquad \quad \space (set! \space found \space \text{#t)}
\\& \qquad \qquad \quad \space (set! \space accum \space nil))
\\& \qquad \qquad \qquad \quad (set \space accum \space (push \space accum \space read))))
\\& \qquad \quad \space (set \space accum \space (push \space accum \space read)))
\\& \qquad \space (funparse \space (cdr \space expr) \space nested \space before \space paren \space accum \space found)))))
\\& (define \space funparse_ \space (\text{lambda} \space (expr)
\\& \quad (funparse \space expr \space 0 \space '() \space '() \space '() \space \text{#f)))} \space 
\end{align*}
</div>

The final portion of our program includes a definition of `funparse_`. This was merely for convenience, as `funparse_` provides all of the initialization values as argument to `funparse`.

We now remove mutation to achieve implementation of the final principle we listed. Our means of achieving this is by allowing all values to be function arguments or expressions operating on arguments.

<div>
\begin{align*}
& (define \space funparse \space (\text{lambda} \space (expr \space nested \space before \space paren \space accum \space found) \space 
\\& \quad (if \space (null? \space expr)
\\& \qquad (if \space (not \space (null? \space paren))
\\& \qquad \quad (concat \space (push \space before \space paren) \space (funparse_ \space accum))
\\& \qquad \quad expr)
\\& \qquad (if \space (and \space (equal? \space '< \space (get \space expr \space 0)) \space (not \space found))
\\& \qquad \quad (if \space (equal? \space nested \space 0)
\\& \qquad \qquad (funparse \space (cdr \space expr) \space (+ \space nested \space 1) \space accum \space paren \space nil \space found)
\\& \qquad \qquad (funparse \space (cdr \space expr) \space (+ \space nested \space 1) \space before \space paren \space (push \space accum \space (car \space expr)) \space found))
\\& \qquad \quad (if \space (and \space (equal? \space '> \space (get \space expr \space 0)) \space (not \space found))
\\& \qquad \qquad (if \space (equal? \space nested \space 1)
\\& \qquad \qquad \quad (funparse \space (cdr \space expr) \space (- \space nested \space 1) \space before \space (funparse_ \space accum) \space nil \space \text{#t)}
\\& \qquad \qquad \quad (funparse \space (cdr \space expr) \space (- \space nested \space 1) \space before \space paren \space (push \space accum \space (car \space expr)) \space found))
\\& \qquad \qquad (funparse \space (cdr \space expr) \space nested \space before \space paren \space (push \space accum \space (car \space expr)) \space found))))))
\\& (define \space funparse_ \space (\text{lambda} \space (expr)
\\& \quad (funparse \space expr \space 0 \space '() \space '() \space '() \space \text{#f)))} \space 
\end{align*}
</div>

You should begin to see how our rewrite of this algorithm reads much more as an inductive definition than as a description of a process. In the following section we will make this even more evident.

###Adopting a Few Conventions
There are a few vestiges of our initial, imperative implementation which we will now remove. Of note is the prior `define` keyword that was appropriately substituted by `letrec`, with `funparse_` then being another definition within the `letrec` procedure.

<div>
\begin{align*}
& (letrec \space funparse \space (\text{lambda} \space (funparse \space expr \space nested \space before \space paren \space accum \space found) \space 
\\& \quad (let \space 
\\& \qquad funparse_ \space 
\\& \qquad (\text{lambda} \space (expr) \space (funparse \space expr \space 0 \space '() \space '() \space '() \space \text{#f))}
\\& \qquad (if \space (null? \space expr)
\\& \qquad \quad (if \space (null? \space paren) \space 
\\& \qquad \qquad expr
\\& \qquad \qquad (concat \space (push \space before \space paren) \space (funparse_ \space accum)))
\\& \qquad \quad (if \space (and \space (equal? \space '< \space (car \space expr)) \space (not \space found))
\\& \qquad \qquad (if \space (equal? \space nested \space 0)
\\& \qquad \qquad \quad (funparse \space (cdr \space expr) \space (+ \space nested \space 1) \space accum \space paren \space nil \space found)
\\& \qquad \qquad \quad (funparse \space (cdr \space expr) \space (+ \space nested \space 1) \space before \space paren \space (push \space accum \space (car \space expr)) \space found))
\\& \qquad \qquad (if \space (and \space (equal? \space '> \space (car \space expr)) \space (not \space found))
\\& \qquad \qquad \quad (if \space (equal? \space nested \space 1)
\\& \qquad \qquad \qquad (funparse \space (cdr \space expr) \space (- \space nested \space 1) \space before \space (funparse_ \space accum) \space nil \space \text{#t)}
\\& \qquad \qquad \qquad (funparse \space (cdr \space expr) \space (- \space nested \space 1) \space before \space paren \space (push \space accum \space (car \space expr)) \space found))
\\& \qquad \qquad \quad (funparse \space (cdr \space expr) \space nested \space before \space paren \space (push \space accum \space (car \space expr)) \space found)))))) \space ...)
\end{align*}
</div>

###The Parser
The parser now works as in the following example.

<div>
\begin{align*}
& (letrec \space parse \space (\text{lambda} \space (...) \space ...)
\\& \quad (parse \space '(< \space a \space > \space < \space b \space < \space c \space > \space > \space < \space d \space >)))
\\& => \space ((a) \space (b \space (c)) \space (d))
\end{align*}
</div>

###Evaluation
Combining the prior evaluator with the new addition of the parser, we have the behavior you would have expected.

#Syntax and Semantics

In linguistics, any given fragment of language is said to have three
componenets; these three parts are semantics, pragmatics, and syntax. Syntax
refers to the governing rules of a language, the way in which expressions may
be combined to form additional valid expressions. Semantics, then, refers to
the meaning of these constructs, the interpretation of an expression from
outside of the language. Pragmatics deals with context and ambiguity; hence
we will aim to form a language free of pragmatics and characterized
exclusively by its formal grammar and the meaning of its expressions.

##Natural Language 

In natural language, syntax refers to the grammar of a language, and
semantics to the meaning of the vocabulary. A common syntactic construct is
of the form S-V-O, that is, Subject-Verb-Object. This is an example of a
compound expression in the language of speech. Below is a formal definition
of this idea, utilizing the BNF grammar defining notation.

```
<SVO> ::= <subject> <verb> <object>
```

The definition above states that an `SVO` construct consists of a subject,
verb, and object in sequence. These constituents would then, in turn, need to
be defined until one is left with only combinations of the language's
primitives; in this case, what would remain would be a list of valid
sentences constituent of words from the language's vocabulary.

For example, the parts of speech would expand as in the following example.

```
<subject> &::= <indeclinable> | he | ... | they | ...
<verb> &::= ascend | ask | ... | yodel | ...
<object> &::= <indeclinable> | him | ... | them | ...
<indeclinable> &::= apple | animal | ... | zebra | ...
```

Of course, the simplistic combination rule specified as `<SVO>` is not
sufficient for the forming of valid sentences. Rather, we are left with a set
of inconsistent, hard to specify rules that make for an imprecise language
that is very hard to mechanically interpret.

Essentially, natural language is too full of pragmatics and inconsistency to
eaily define and form by machine.

##Formal Grammars

Rather than rely upon an inconsistent language like English for formal communication of complex ideas, we have devised various Domain-Specific Languages free of ambiguity.

Let's begin with an example of a small, strict grammar which is vastly useful
regardless.

```
<expression> &::= <proposition> | <quantified> | <variable>
<quantified> &::= (<quantifier> <variable> <expression>)
<proposition> &::= (<expression> <op> <expression>)
<quantifier> &::= \forall | \exists
<op> &::= \vee | \wedge | \Rightarrow | \Leftrightarrow
<variable> &::= a | b | ... | \top | \bot
```

The above successfully defines a formal grammar with sufficient expressive
potential. However, without corresponding semantics, we do not have a 
language, but mere strings of symbols.

In providing the semantics, we say things like $\bot$ means false, or $a
\Rightarrow b$ is logically equivalent to the statement "either both a and b
are true, or a is false." In this way we begin to build up our language to a
point at which expression of ideas becomes natural. Additionally, we might
specify reduction rules to allow for conversion from one form to another,
maintaining the same semantics but modifying the syntax. Recall, for example,
the reduction rule of the Lambda Calculus (sometimes referred to as $\beta$-reduction).

##Evaluating a Language

Every language is only useful so long as it can be interpreted. Throughout
this book, we will be using a small subset of the language Scheme. You can
use an arbitrary Scheme interpreter found online, or download the custom
implementation from the book website.

Now, let's take a look at the language itself. We begin with basic arithmetic
expressed in the following forms.

```scheme
(+ 2 3)
(* 7 5)
(- 7 6)
```

Above, we wrote three valid forms of the language. Once evaluated, the first
would equal 5, the second 35, and the third 1. Notice that counter to the
notation with which you have become familiar for arithmetic, the above forms
utilize what is known as Polish Notation. In Polish Notation, all operators
precede their arguments. Hence, rather than have the `+` symbol be infixed
between numbers, we allow `+` to serve as a prefix to the numbers.

The primary advantage of this notation is uniformity. By letting the operator
precede the arguments, we will have uniformity in all operations as we
gradually define more. Despite the simplicity of our first examples, the forms
which we have discussed can result in some rather complex expressions.

```scheme
(+ (* 7 2) (* 3 1))
(+ 5 (+ (* 7 2) (- 7 5)))
```
Interpretation of the above forms is not as immediately evident. Recall the
idea of reduction; we will utilize it in evaluating the above examples.

```scheme
(+ (* 7 2) (* 3 1))
\implies (+ 14 (* 3 1))
\implies (+ 14 3)
\implies 17
(+ 5 (+ (* 7 2)) (- 7 5))
\implies (+ 5 (+ 14 (- 7 5)))
\implies (+ 5 (+ 14 2))
\implies (+ 5 16)
\implies 21
```

Hopefully the methodologies used above are clear to you. So far, we have only
displayed the use of our language to express mathematical expressions;
however, our language has the potential for far more.

##Forming Procedures

##Semantic Primitives

##Complex Constructs

##Abstraction

Tarpits & Abstraction
=====================
View early versions of the beginning chapters as pdfs in the `build/pdf/` folder.

Tarpits & Abstraction is a book beginning with a discussion on Turing Machines and Lambda Calculus, and then exploring layers of abstraction, cross-interpreting, and compiling until the reader can understand computation at any layer of abstraction.

Currently, it is planned to have a preface (*A Tale of Two Theories*) and seven parts:

1. Syntax and Semantics
2. Defining Symbolic Expressions
3. Designing Primitive Procedures
4. Simulating Logical Devices
5. Mechanical Interpretation of a Language
6. A Self-Hosted Language
7. Communicating a Language to Machine

Compilation
-----------
The Makefile generates LaTeX for all chapters, and then renders an index LaTeX file which joins all chapters together. This outputs a pdf to `build/pdf/book.pdf`, with all LaTeX sources stored in `build/latex`.
Before reading, verify that it is the newest version by running the following from the *project root*.

```sh
$ make
```

Notes
-----
###Defining Symbolic Expressions
- __TODO:__ Dotted Lists
- __TODO:__ Discuss McCarthy's Influence
- __TODO:__ Modulo and Division functions
- __TODO:__ Change `quote` function to allow for `atom?`

###A Library of Symbolic Functions
- __TODO:__ Using conditionals and `cond` function
- __TODO:__ Improve `induct` example
- __TODO:__ Newton's Method: An Example
- __TODO:__ Variables: Reference and Scope
- __TODO:__ Expansion of Programs
- __TODO:__ Exponentiation & Efficiency: An Example
- __TODO:__ Primality
- __TODO:__ Diverse Data Structures

###Simulating Logical Devices
- Lazy structures
- __TODO__: Register machines.

###Interpreting a Language
- Interpret a Query Language

###Pulling Our Language up by Its Bootstraps
- __TODO__: multiple argument lambda definition
- __TODO__: examples of `define` and `set!`

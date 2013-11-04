Tarpits & Abstraction
=====================
Tarpits & Abstraction is a book beginning with a discussion on computation and
the Lambda Calculus, and then exploring layers of abstraction, and 
cross-interpreting until the reader can understand computation
at any layer of abstraction.

A preliminary print of the book will be maintained on 
[Lulu](http://www.lulu.com/content/paperback-book/tarpits-abstraction/14062801).

The full table of contents can be viewed in the book pdf located at 
`build/pdf/book.pdf`, but the chapter breakdown follows.

1. Computation - A Grammar and Data Structures
2. Primitive Procedures - Building Blocks for Programs
3. Simulating Logical Devices - Representation of Objects and Rules in FP
4. Interpreting a Language - Evaluating and Parsing
5. A Self-Hosted Language - Bootstrapping and Extending Our Language's Grammar

Compilation
-----------

The Makefile generates LaTeX for all chapters, and then renders an index LaTeX
file which joins all chapters together. This outputs a pdf to
`build/pdf/book.pdf`, with all LaTeX sources stored in `build/latex`.  Before
reading, verify that it is the newest version by running the following from the
*project root*.

```sh
$ make
```

TODO
----
###Defining Symbolic Expressions
- Change `quote` function to allow for `atom?`

###A Library of Symbolic Functions
- Using conditionals and `cond` function
- Diverse Data Structures

###Simulating Logical Devices
- Register machines.

###Pulling Our Language up by Its Bootstraps
- examples of `define` and `set!`

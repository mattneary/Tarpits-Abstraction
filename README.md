Tarpits & Abstraction
=====================

Introduction
------------

> The Lambda Calculus is a fully-versatile language; however, it is what some
describe as a *Turing tarpit*. Alan Perlis describes a Turing tarpit as a
language "in which everything is possible but nothing of interest is easy."
Despite this nature of the Lambda Calculus, we will be forming quite complex
programs throughout this book on its foundation. We will, in a sense, climb
out of its tarpit by means of abstraction. In order to do so, we will build up
a scaffolding of abstraction, building layer upon layer as we construct an
edifice of procedures.
> <br>— Section 1.1


"Tarpits & Abstraction" explores the nature of computation. It begins with a
discussion of computation and the Lambda Calculus, enters into an exploration
of layers of abstraction, and finally cross-interprets these layers, providing
the reader with an intuition for computation at any layer of abstraction.

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

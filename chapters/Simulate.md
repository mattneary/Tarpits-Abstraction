Simulating Logical Devices
==========================
The key innovation in the study of computation was the development of machines for the mechanization of algorithms. We have already seen Turing's proposal for such a device; however, we have not seen any relationship between his and Church's theories. In this chapter we will compose with our symbolic language a simulation of different logical devices.

Turing Machines
---------------
Having built up our language to a point of high-level abstraction, we will now try to simulate a trivial computational platform, a Turing Machine. In doing so we will address many key issues like immutability, hash-tables, and, once again, recursion. Additionally, we will become comfortable with the idea of interpreting one platform within another; this ability to interpret is the key to abstraction in computation.

###A Ruleset
A Turing Machine computes values based on an initial state, initial values, and rules of transition from a given state and value to a new state and value. The machine itself has a tape full of values and a head which navigates the tape, moving either right of left one slot at any given time. Additionally, this head maintains an idea of state, the mode in which it is observing a given value.

Together these primitive capabilities are enough to compute any algorithm. The usual manipulation could be broken down into a series of steps, most likely represented as different states. Each state, in turn, maintains a specific array of ways in which to manipulate read values, and in which direction to move in each case.

All of this methodology is governed by a single ruleset. Hence to simulate one, we will undoubtedly need a representation of these rules. The following is one way, and the way which we will choose, of representing such a set. We have already seen use of lists as hash-tables, so this should not be a surprising design decision.

<div>
\begin{align*}
&(let 
\\& \quad rules
\\& \quad '(((A \space 0) \space (0 \space R \space Z))
\\& \qquad  ((A \space 1) \space (1 \space R \space C))
\\& \qquad  ((Z \space 0) \space (0 \space R \space H))
\\& \qquad  ((Z \space 1) \space (1 \space L \space N))
\\& \qquad  ((C \space 0) \space (1 \space L \space N))
\\& \qquad  ((C \space 1) \space (0 \space L \space Y))
\\& \qquad  ((N \space 0) \space (0 \space R \space H))
\\& \qquad  ((N \space 1) \space (0 \space R \space H))
\\& \qquad  ((Y \space 0) \space (1 \space R \space H))
\\& \qquad  ((Y \space 1) \space (1 \space R \space H))
\\& \quad \dots)
\end{align*}
</div>

A ruleset like the one above serves to tell a simulation in what way to behave given a certain input state. Hence together with our earlier defined `assoc` function and an actual executor of the matching behavior, this ruleset will handle all state logic.

###Fundamental States
In order for our simulation to ever end we will need to designate a specific state the *halt-state*. In our implementation, `H` will signal the end of an algorithm. Additionally, the state in which our machine is initialized will not be the choice of the ruleset, and so we choose to once again arbitrarily designate a specific state value for this case. The state named `A` will be the initialization state of all simulations.

###Mutability
The Lambda Calculus does not allow for mutation of values, thus all values we wish to mutate will need to be parameters to functions. Let's work out some examples of wokring around immutability in lists.

```scheme
(set 
  (lambda 
    (hash key val) 
    (map 
      (lambda 
        (item) 
	(if 
	  (equal? item key) 
	  (cons key (cons val)) 
	  item)) 
    hash)))
```

###The Event Loop
Rules are executed recursively until the halt-state is reached. At this point, a final table is returned.

###A Simulator
All of the above principles can be combined to form a Turing Machine simulator.

Circuits
--------
Circuits are quite different in nature from the previously discussed Turing Machine. The main reason for this difference is that componenets, analogous to the prior discussed rules, are dpendent directly upon eachother, while in a Turing Machine a single processing unit handled transitions between states.

###Structure of Circuits (cf. #275)
Our model of circuits will consist of two component types, (a) relational boxes, and (b) wires. Relational boxes are atomic relations between circuit values, accepting input as electrical signlas and outputting in electrical signal. Wires serve to connect these boxes to each other, bearing these electircal signals in one of two sates. A wire bearing current is said to have the value `1`, but a wire without current is said to be of value `0`.

The relational boxes we will take as primitive are similar to our boolean operators already defined. We utilize an `and-gate`, an `or-gate`, and a `not-gate`. The first two gates accept two wires as input values and output to another wire a current value based on their logical operation. Hence an `and-gate` accepting two current-bearing wires will direct current to its output wire. A `not-gate` on the other hand accepts a single wire for input value and outputs the opposite value to another wire.

To begin our design of circuits, we design a relation constituent of the boolean operators listed above as gates.

```scheme
(let* 
  ((a #t) 
   (b #f) 
   (s (and (or a b) (not (and a b)))) 
   (r (and a b))) 
  (cons s (cons r nil)))
```

The above procedure is known as a half-adder. Given two bits as input, this procedure determines the added value, including any carried value. Recall that our language was designed not only for evaluation by machine, but for representation of ideas like the one presented above.

###Inter-Dependency
In our presentation of circuit design, we utilized `let*` to display relations in order of their dependency. However, you will notice that we repeated some computations without separating them out, and more importantly that some of the computed values were now of a single primitive value. Hence, they did not directly reflect a circuit.

To better reflect the reality of circuits, we will design a *modular* means of displaying the interconnectedness of relations, and a means of computing the values based on their dependencies.

###Computation with Circuits

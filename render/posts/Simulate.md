Simulating Logical Devices
==========================
Turing Machines
---------------
Having built up our language to a point of high-level abstraction, we will now try to simulate a trivial computational platform, a Turing Machine. In doing so we will address many key issues like immutability, hash-tables, and, once again, recursion. Additionally, we will become comfortable with the idea of interpreting one platform within another; this ability to interpret is the key to abstraction in computation.

###A Ruleset
A Turing Machine is governed by a ruleset. Hence to simulate one, we will need a representation of these rules. The following is one way, and the way which we will choose, of representing such a set. We have already seen use of lists as hash-tables, so this should not be a surprising methodology.

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

###A Halt State
In order for our simulation to ever end we will need to designate a specific state the *halt-state*. In our implementation, `H` will signal the end of an algorithm.

###Mutability
The Lambda Calculus does not allow for mutation of values, thus all values we wish to mutate will need to be parameters to functions.

###The Event Loop
Rules are executed recursively until the halt-state is reached. At this point, a final table is returned.

###A Simulator
All of the above principles can be combined to form a Turing Machine simulator.

Circuits
--------
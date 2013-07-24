Simulating a Tape Machine
=========================
A Ruleset
---------
A Turing Machine is governed by a ruleset. Hence to simulate one, we will need a representation of these rules. The following is one way, and the way which we will choose, of representing such a set.

```scheme
'(((A 0) (0 R Z))
  ((A 1) (1 R C))
  ((Z 0) (0 R H))
  ((Z 1) (1 L N))
  ((C 0) (1 L N))
  ((C 1) (0 L Y))
  ((N 0) (0 R H))
  ((N 1) (0 R H))
  ((Y 0) (1 R H))
  ((Y 1) (1 R H))
fold, (lambda (func accum lst)
  (if (null? lst)
    accum
    (fold func (func accum (car lst)) (cdr lst)))) 
assoc, (lambda (x list)
  (fold 
    (lambda 
      (accum item) 
      (if 
        (equal? item (car x))
        (cdr x)
        accum)))
    #f
    list)
```
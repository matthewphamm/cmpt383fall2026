# Tiny Lisp Introduction

Tiny Lisp is a simple dialect of Lisp designed for education. It has a small
number of features, and is a subset of Racket.

Here are it's main features:

- basic data types: symbols, numbers (integers, float, and rationals), booleans,
  lists, pairs

- arithmetic operators: `+`, `-`, `*`, `/`, `<=`, `>=`, `<`, `>`, `=`

- logical operators: `and`, `or`, `not`

- error handling: `error` for raising errors

- predicate functions: `equal?`, `symbol?`, `number?`, `boolean?`, `list?`,
  `pair?`, `even?`, `odd?`
  
- list functions: `empty?`, `first`, `rest`, `cons`, `list`

- special forms: `quote`, `cond`, `else`, `let`, `let*`, `define`, `lambda`


## Basic Data Types and Arithmetic

Arithmetic operations in Tiny Lisp all use **prefix** notation: the operator
comes first, followed by the operands. For example:

```lisp
> (+ 1 2)
3
> (- 10 5)
5
> (* 2 3)
6
> (/ 10 2)
5
> (<= 5 10)
#t
> (>= 10 5)
#t
```

You can pass more the two operands to arithmetic operations:

```lisp
> (+ 1 2 3)
6
> (* 2 3 4 )
24
> (/ 100 2 2)
25
> (< 1 2 3 6 10 20)
#t
> (> 10 9 4 5)
#f
> (= 5 5 5)
#t
> (= 5 5 6 5 5 5)
#f
```

Tiny Lisp supports rational numbers, which are represented as fractions. For
example, `1/2` is a rational number, one half:

```lisp
> (+ 1/2 1/2)
1/2
> (* 1/2 1/2)
1/4
```

The result of division can be a rational number:

```lisp
> (/ 1 2)
1/2
> (/ 10 4)
5/2
```

Note that `1/2` is the literal representation of the rational number one half,
while `(/ 1 2)` is an expression that calls the `/` function with the arguments
1 and 2.

Tiny Lisp also has some helpful mathematical functions: `sqrt`, `sin`, `cos`.
For example:

```lisp
> (sqrt 2)
1.4142135623730951
> (sin 45)
0.8509035245341184
> (cos 80)
-0.11038724383904756

> (+ (* (sin 19) (sin 19)) 
     (* (cos 19) (cos 19)))
0.9999999999999999
```

Notice how line-breaks and indentation are used to make the last expression a
little more readable.

## Logical Operators

In Tiny Lisp, `#t` is true and `#f` is false, and the logical operators work in
the usual way.

For example:

```lisp
> (and #t #t)
#t
> (and #t #f)
#f
> (and (= 2 2) (< 4 10))
#t

> (or #t #f)
#t
> (or #f #f)
#f
> (or (= 2 5) (< 4 10))
#f

> (not #t)
#f
> (not (= 2 4))
#t
```

As with arithmetic operations, you can pass more than two operands to `and` and
`or`:

```lisp
> (and #t #t #t)
#t
> (or #f #f #t #f)
#f
```

Importantly, `and` and `or` **short-circuit** operators, which means they work
like this:

- `(and <expr1> <expr2> ...)` evaluates the expressions in order, left to right,
  and stops on the first expression that evaluates to `#f` and returns `#f` for
  the entire expression. It does *not* evaluate the expressions after the first
  true one. If none of the expressions evaluate to `#f`, it returns `#t`.

- `(or <expr1> <expr2> ...)` evaluates the expressions in order, left to right,
  and stops on the first expression that evaluates to `#t` and returns `#t` for
  the entire expression. It does *not* evaluate the expressions after the first
  false one. If none of the expressions evaluate to `#t`, it returns `#f`.

For example, the expression `(error "oops!")` will raise an error, and this
shows how short-circuiting works: 

```lisp
> (and #t (error "oops!"))   ;; error not evaluated
#f
> (or #f (error "oops!"))    ;; error not evaluated
#f

> (and (error "oops!") #t)   ;; error evaluated
. . oops!
> (or #t (error "oops!"))    ;; error evaluated
. . oops!
```

This shows that, in general, the expressions `(and a b)` and `(and b a)` might
not evaluate to the same thing. Similarly, `(or a b)` and `(or b a)` might not
evaluate to the same thing.

## Symbols

**Symbols** are a special type of data in Tiny Lisp. They are used to represent
names, and start with the `'` character (single-quote). For example, `'cat`,
`'hamster`, and `'mouse` are all symbols. Symbols evaluate to themselves:

```lisp
> 'cat
'cat
> 'hamster
'hamster
> 'mouse
'mouse
```

You can test if two symbols are the same using the `equal?` predicate:

```lisp
> (equal? 'cat 'cat)
#t
> (equal? 'cat 'hamster)
#f
> (equal? 'cat 'mouse)
#f
```

Note that:

- symbols are *not* strings; you shouldn't be comparing them, you shouldn't be
  extracting their letters, you shouldn't use the to store text, etc.

- you can test if two symbols are equal, but you *can't* compare them with
  operators like `<` or `>=`, and you can't add (or concatenate) them

- symbols are sometimes called **atoms**

## Predicate Functions

A **predicate function**, or just **predicate**, is a function that takes any
number of argument and returns a boolean value, i.e. `#t` or `#f`. Tiny Lisp has
a number of useful built-in predicates.

`(number? <expr>)` returns `#t` if the argument is a number, and `#f` otherwise:

```lisp
> (number? 4)
#t
> (number? 4.0)
#t
> (number 4/5)
#t
> (number? +)  ;; + is a function
#f
```

`(even <expr>)` and `(odd <expr>)` return `#t` if the argument is an even or odd
number, and `#f` otherwise:

```lisp
> (even? 4)
#t
> (even? 5)
#f
> (odd? 4)
#f
> (odd? 5)
#t
```

`(boolean? <expr>)` returns `#t` if the argument is a boolean, and `#f` otherwise:

```lisp
> (boolean? #t)
#t
> (boolean? #f)
#t
> (boolean? 4)
#f
> (boolean? 'false)
#f
```

`(symbol? <expr>)` returns `#t` if the argument is a symbol, and `#f` otherwise:

```lisp
> (symbol? 'cat)
#t
> (symbol? 'dog)
#f
> (symbol? 4)
#f
```

The `(equal? <expr1> <expr2> ...)` predicate takes any number of arguments and
returns `#t` if all the arguments are equal, and `#f` otherwise:

```lisp
> (equal? 'cat 'cat)
#t
> (equal? 'cat 'dog)
#f
> (not (equal? 'cat 'dog))
#t
> (equal? 4 4 4 (* 2 2))
#t
```

## Lists

A **list** is a sequence of zero, or more, elements. List literals are written
between parentheses. For example, `'(1 of the cats)` is a list with four
elements. The `'` at the start is what distinguishes a list literal from a
function call.

For example:

```lisp
> (* 2 3 0)
0
> '(* 2 3 0)
'(* 2 3 0)

> '(carol has no hat today)
'(carol has no hat today)
> (carol has no hat today)
. . carol: undefined;
 cannot reference an identifier before its definition
```

The last example shows that if you don't quote a list, then the list is treated
as a function call (or a macro call). `(carol has no hat today)` is treated as a
function call to the `carol` function with the arguments `has`, `no`, and `hat`,
and `today`. But since there is no `carol` function, it raises an error.

You can put almost anything inside a list, including other lists, and other data
types. For example:

```lisp
> '(my lucky numbers are (2 3 and -4))
'(my lucky numbers are (2 3 and -4))

> '((()))
'((()))
```

Notice that the inner list is *not* quoted.

`'()` is the **empty list**, and it has no elements. You can test if a list is
empty with the `(empty? <expr>)` predicate:

```lisp
> (empty? '())
#t
> (empty? '(1 of the cats))
#f
> (empty? 0)
#f 
```

You can test if an value is a list with the `(list? <expr>)` predicate:

```lisp
> (list? '())
#t
> (list? '(1 of the cats))
#t
> (list? 56)
#f
> (list? (+ 2 3 4))
#f
```

The `(first <expr>)` function returns the first element of the list, and 
`(rest <expr>)` returns the list of all elements except the first element:

```lisp
> (first '(once upon a time))
'once
> (rest '(once upon a time))
'(upon a time)

> (first '(/ 50 2))
'/    ;; the symbol /, not the division function
> (rest '(/ 50 2))
'(50 2)

> (first (/ 50 2))
. . first: contract violation
  expected: (and/c list? (not/c empty?))
  given: 25

> (rest (/ 50 2))
. . rest: contract violation
  expected: (and/c list? (not/c empty?))
  given: 25
```

The last two examples cause an error because `first` and `rest` only work on
lists, and not on numbers --- and `(/ 50 2)` is the number 25.

You can create a new list with the `(cons x lst)` function, where `x` is any
value, and `lst` is a list:

```lisp
> (cons 'the '(big cat))
'(the big cat)
> (cons 4 '(1 2 3 4 5))
'(4 1 2 3 4 5)
> (cons 'the '())
'(the)
> (cons '(1 2) '(three four))
'((1 2) three four)
> (cons (- 10 2) '(a b c))
'(8 a b c)
```

Another way to create a new list is to use the `(list <expr1> <expr2> ...)`
function, where each `<expr>` is an expression:

```lisp
> (list 1 2 3)
'(1 2 3)
> (list 'result 'is (* 6 7))
'(result is 42)
> (list 'a '(b c) (cons 'd '(e)))
'(a (b c) (d e))
```

## Special Forms

A **special form** is an expression that is similar to a function call, but its
arguments are evaluated differently than for a function call. They let us do
some very useful things that are not possible with functions.

`(define <symbol> <expr>)` defines a new function or variable. For example, this
defines a variable `pi`:

```lisp
> (define pi 3.14159)
> pi
3.14159
> (* pi 2)
6.28318
```

Be careful: `pi` is a variable, *not* a symbol. For instance:

```lisp
> (define pi 3.14159)
> (list pi 'pi)
'(3.14159 pi)
```

`pi` evaluates to the number `3.14159`, while `'pi` is a symbol that evaluates
to itself.

`(define <symbol> <expr>)` can also be used to define a new function. For
example:

```lisp
> (define (square x) (* x x))
> (square 2)
4

> (define (inc n) (+ n 1))
> (inc 2)
3
> (inc (square 4))
17
```

`(cond <test1> <test2> ...)` is a special form that implements an if-else-if
statement. For example, the `(sign n)` function returns `'negative` if `n` is
less than 0, `'positive` if `n` is greater than 0, and `'zero` if `n` is 0. If
`n` is not a number, it raises an error:

```lisp
(define (sign n)
  (cond [(not (number? n)) (error "not a number")]
        [(< n 0)           'negative]
        [(> n 0)           'positive]
        [else              'zero]
        ))

> (sign 4)
'positive
> (sign -4)
'negative
> (sign 0)
'zero
> (sign 'cat)
. . not a number
oops!
```

Each `<test>` is an expression of the form `[<cond> <value>]`, where `<cond>` is
a boolean expression (that evaluates to `#t` or `#f`) and `<value>` is the
expression that is evaluated and returned if `<cond>` is `#t`. `cond` does each
`<test>` in the order given, and the for the first condition that is true it
stops and returns its value (and no further tests are evaluated).

The square brackets are purely cosmetic: [Racket] lets you use square brackets
in place of parentheses whenever you like, and they are often used in `cond`
expressions to make the code more readable.

The `else` keyword is the catch-all case: if none of the conditions before it
are true, then the value after `else` is evaluated and returned. Indeed, you
could replace the `else` with `#t`.

`let` and `let*` are special forms that create new local variables. For example:

```lisp
> (let [(x 1) (y 2)] (+ x y))
2
```

The general form of `let` is:


```lisp
(let [(<var1> <expr1>) 
      (<var2> <expr2>) 
      ...
     ] 
     <body>
)
```

`var1`, `var2`, etc. are new local variables that are bound to the values of the
corresponding expressions `<expr1>`, `<expr2>`, etc.  `<body>` is an expression
that is evaluated and returned, and it can refer to the variables `var1`,
`var2`, ...

`let` is often used in functions:

```lisp
(define (dist x1 y1 x2 y2)
  (let [(dx (- x2 x1))
        (dy (- y2 y1))]
    (sqrt (+ (* dx dx) (* dy dy)))))

> (dist 2 2 4 3)
2.23606797749979
```

`let*` is like `let`, but it binds the variables in the order given and so
allows previous variables to be used in the expressions for later variables. For
example:

```lisp
> (let* [(x 1) (y (+ x 1))] (* x y))
2
```

If you use `let` instead of `let*`, you get an error:

```lisp
> (let [(x 1) (y (+ x 1))] (* x y))
. . x: undefined;
 cannot reference an identifier before its definition
```

`(lambda (<arg1> <arg2> ...) <body>)` is a special form that creates a new
function *without a name*. For example:

```lisp
>(define sq (lambda (x) (* x x)))
> (sq 2)
4
> (sq 3)
9
```
Or:

```lisp
> ((lambda (x) (* x x)) 2)
4
> ((lambda (x) (* x x)) 3)
9
```

In practice, `lambda` functions are often a convenient way to create small
functions, especially when a name doesn't matter.

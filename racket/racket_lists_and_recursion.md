# Lists and Recursion in Racket

[Racket] has good built-in support for *singly-linked lists*. [Racket] supports
vectors, strings, and hash tables as well, but we will rarely use those in this
course.

## Making Lists

Lists can be created in a couple of ways. One way is with *quoting*:

```lisp
> '(1 2 3)
'(1 2 3)

> '(my dog has fleas)
'(my dog has fleas)

> '(my dog (and hamster) have 10 fleas each)
'(my dog (and hamster) have 10 fleas each)
```

Another way is with the `list` function:

```lisp
> (list 1 2 3)
'(1 2 3)

> (list 'my 'dog 'has 'fleas)
'(my dog has fleas)

> (list 'my 'dog (list 'and 'hamster) 'have 10 'fleas 'each)
'(my dog (and hamster) have 10 fleas each)
```

Since `list` is a function, it's useful when you want to evaluate expressions
*before* putting them on the list, e.g.:

```lisp
> (list (+ 1 2) (* 3 4) (- 5 6))
'(3 12 -1)
```

The **empty list** is a list with 0 values, and is written as `'()`. We'll use
`empty?` to test if a list is empty:

```lisp
> (empty? '(1 2))
#f
> (empty? '())
#t
```

## List Processing

[Racket] has many built-in list processing functions. 

The `first` function returns the first element of a list:

```lisp
> (first '(1 2 3))
1

> (first '((1 2) 3 4))
'(1 2)

> (first '(my dog has fleas))
'my

> (first '())
. . first: contract violation
  expected: (and/c list? (not/c empty?))
  given: '()
```

The empty list has no first element, so `(first '())` is an error.

The `rest` function returns everything on a list *except* for the first element:

```lisp
> (rest '(1 2 3))
'(2 3)

> (rest '((1 2) 3 4))
'(3 4)

> (rest '(my dog has fleas))
'(dog has fleas)

> (rest '())
. . rest: contract violation
  expected: (and/c list? (not/c empty?))
  given: '()
```

> **Aside** In the original version of [Lisp], `car` was the name for `first`,
> and `cdr` was the name for `rest`. These unusual names referred to the
> underlying hardware of the original computer on which [Lisp] was originally
> implemented.

The `(cons x lst)` function "constructs" a new list by adding `'x` to the
start of `lst`:

```lisp
> (cons 1 '(2 3))
'(1 2 3)

> (cons '(2 3) '(3 4))
'((2 3) 3 4)

> (cons 'my '(dog has fleas))
'(my dog has fleas)

> (cons 'x '())
'(x)
```

`first`, `rest`, and `cons` work well together, e.g.:

```lisp
> (cons (first '(1 2 3)) (rest '(1 2 3)))
'(1 2 3)
```

Since [Racket] lists are singly-linked, `first`, `rest`, and `cons` all run in
worst-case *constant* time.

### The Consed-out Form of a List

It can be useful to think of a list as a nested series of calls to `cons`. We
will call this the **consed-out** form of the list. For example, the consed-out
form of `'(a b c d)` is:

```lisp
> (cons 'a (cons 'b (cons 'c (cons 'd '()))))
'(a b c d)
```

### A Few More Examples

The `first` of the `rest` of a list is its second element:

```lisp
> (first (rest '(a b c d)))
'b
```

The first element of the rest of the rest of a list is its third element, and so
on.

[Racket] even lets you do things like this:

```lisp
> ((first (list + *)) 2 3)
5
```

To evaluate this expression, first `(first (list + *))` is evaluated. The
sub-expression `(list + *)` evaluates to the list `(<+-fn> <*-fn>)`, i.e. the
`+` function followed by the `*max*` function. Calling `first` on this list
returns the `+` function, and the expression simplifies to `(+2 3)`, which
evaluates to 5.

Notice that we wrote `(list + *)`. `'(+ *)` would *not* give the same result:

```lisp
> ((first '(+ *)) 2 3)
. . application: not a procedure;
 expected a procedure that can be applied to arguments
  given: '+
```

The problem is that the `+` inside the quoted list is *not* evaluated, and so
the result of `(first '(+ *))` is the *symbol* `'+`. In contrast, when 
`(list + *)` is called, both `+` and `*` are replaced with their corresponding
*functions*. So `(first (list + *))` is the `+` *function*, while 
`(first '(+ *))` is the *symbol* `'+`.


## Pairs, Lists, and Racket Syntax

`(cons x y)` lets you combine **any** two values:

```lisp
> (cons 2 3)
'(2 . 3)
> (cons 'a 'b)
'(a . b)
> (cons (list 1 2 3) 'a)
'((1 2 3) . a)
```

Values of  the form `(x . y)` are called **dotted pairs**, or just **pairs** for
short. `pair?` tests if a value is a pair:

```lisp
> (pair? '(1 . 2))
#t
> (pair? '(a . b))
#t
> (pair? '(one two))
#t
> (pair? '(3 4 5))
#t
> (pair? 'two)
#f
```

A dotted pair is implemented in memory as a **cons cell**, a value with two
pointers:

<img src="consCell.png" width="200" alt="cons cell diagram">

Diagrams like this are called **cons cell diagrams**.

Lists are nested pairs. Written as pairs, `'(3 4 5)` has this structure:

```lisp
> '(3 . (4 . (5 . ())))
'(3 4 5)
```

In memory it looks like this:

<img src="list123.png"  alt="list 123 diagram">

It has the structure `'(3 . something)`, and so it's a pair.

`list?` tests if a value is a list, e.g.:

```lisp
> (list? '(1 . 2))
#f
> (list? '(1 2))
#t
```

Both `'(1 . 2)` and `(1 2)` are pairs, but only `'(1 2)` is a list because it
is has the proper structure: `'(1 . (2 . ()))`.

### Garbage Collection

`cons` *creates* a pair in [Racket], but how do you *delete* a pair? [Racket]
deletes it automatically using **garbage collection**, which means that it keeps
track of which pairs are in use, and automatically deletes the ones that aren't.

[Lisp] was one of the first languages to use garbage collection. While this
makes managing memory much easier, it happens while your program is running, and
so can slow your program down, or even pause it. Many of the computers that
[Lisp] ran on in the 50s-80s were quite slow, and garbage collection pauses were
noticeable and occurred at random times, and so made it hard to use in practice.

But nowadays, computers are much faster and have more memory, and so garbage
collection is far more common. For example, Python, JavaScript, C#, and Go all
use garbage collection.

## Recursive Functions

Suppose we want to calculate the length of a list.
[tiny-lisp](tiny-lisp/README.md) doesn't have a function that does this, so lets
write our own. We want it to work like this:

```lisp
> (length '(a b c d))
4
> (length '(1 (2 3) 4))
3
> (length '())
0
```

Lists do *not* store their own length, so we will need to calculate it using
recursion.

```lisp
(define (length lst)
  (cond [(empty? lst) ;; base case
         0]      
        [else         ;; recursive case
         (+ 1 (length (rest lst)))] 
        ))
```

`len` has two cases:

- *Base case*: when `lst` is empty
- *Recursive case*: calculate the length of the `rest` of `lst`, then add 1

Every recursive function must have one, or more, non-recursive base cases, and
one, or more, recursive cases. Thus we will usually structure recursive
functions, as done here, using`cond` to decide which case to run.


## Linear Search

Linear search determines if a value `x` is on a list. The `contains` function
returns `#t` if `x` is on the list, and `#f` if it's not:

```lisp
;; Returns true if x is in lst, and false otherwise.
(define (contains x lst)
  (cond [(empty? lst)
         #f]
        [(equal? x (first lst)) 
         #t]
        [else 
         (contains x (rest lst))]
        ))

> (contains 'apple '(lemon orange apple pear))
#t
```

## Challenge: linear search location

Using recursion, implement a function called `(index-of x lst)` that returns the
index location of the *first* occurrence of `x` in `lst`. The first index value
is 0. If `x` is not in `lst`, then return -1.

For example:

```lisp
> (index-of 'a '(a 1 2 3 4))
0
> (index-of 'a '(0 1 2 a a))
3
> (index-of 'a '(one two three four))
-1
```

## Counting

Using the `symbol?` function (which tests if an object is a symbol, such as
`'cat`), we ca calculate the number of symbols in a list as follows:

```lisp
(define (count-sym1 lst)
  (cond [(empty? lst) 0]
        [(symbol? (first lst)) 
         (+ 1 (count-sym1 (rest lst)))]
        [else
         (count-sym1 (rest lst))]))
```

Now suppose we want to count *numbers* instead of symbols. We can modify
`count-sym1` to this:

```lisp
(define (count-num lst)
  (cond [(empty? lst) 0]
        [(number? (first lst))
         (+ 1 (count-num (rest lst)))]
        [else 
         (count-num (rest lst))]))
```

This is the same as `count-sym1`, except `number?` is used instead of `symbol?`,
and each occurrence of `count-sym1` is now `count-num`. Everything else is the
same.

Lets write a general-purpose counting function whose input is a list and a
**predicate**. A predicate is a function that takes one value as input and
returns either `#t` or `#f`:

```lisp
(define (count-fn pred? lst)
  (cond [(empty? lst) 0]
        [(pred? (first lst))
         (+ 1 (count-fn pred? (rest lst)))]
        [else 
         (count-fn pred? (rest lst))]))
```

`pred?` names the passed-in predicate. [Racket] lets you use a `?` in a variable
name, and a `?` at the end of a function is a convention that tells the
programmer that it returns `#t` or `#f`.

We can now count anything we have a predicate for:

```lisp
> (count-fn even? '(1 2 3 4 5 6 7))
3
> (count-fn odd? '(1 2 3 4 5 6 7))
4
> (count-fn number? '(1 2 3 4 5 6 7))
7
> (count-fn symbol? '(1 2 3 4 5 6 7))
0
> (count-fn (lambda (n) (< n 4)) '(1 2 3 4 5 6 7))
3
```

We can re-write the previous functions using `count-fn1`:

```lisp
(define (count-symbol lst) (count-fn symbol? lst))

(define (count-number lst) (count-fn number? lst))
```

## Linear Search with a Predicate

We can also do linear search using a predicate:

```lisp
(define (contains-fn pred? lst)
  (cond [(empty? lst) 
         #f]
        [(pred? (first lst)) 
         #t]
        [else 
         (contains-fn pred? (rest lst))]))
```

For example, this tests if a list contains an even number:

```lisp
> (contains-fn even? '(1 3 5 6 9 9))
#t
> (contains-fn even? '(1 3 5 61 9 9))
#f
```

We can re-write the original `contains` function for like this:

```lisp
(define (contains x lst)
  (contains-fn (lambda (b) (equal? b x))
               lst))
```

## The append Function

`append` takes two lists as input and returns a new list that i s the
*concatenation* of them:

```lisp
> (append '(one two) '(3 4 5))
'(one two 3 4 5)
> (append '(once) '(upon a) '(time))
'(once upon a time)
```

You can implement your own version of `append` using recursion:

```lisp
;;
;; Appends two lists together, i.e. returns the same
;; result as (append lst lst2).
;;
(define (append lst1 lst2)
  (cond [(empty? lst1) 
         lst2]
        [else 
         (cons (first lst1)
               (append (rest lst1) lst2))]))
```

Note that [Racket] has a built-in `append` function that does the same thing,
and even allows appending three our more lists at once. Our `append` is simple
and only takes exactly two lists as input.

A general rule of thumb is: `append` is expensive. The issue is that hides a
linear-time copy of the first list you pass it. To run `(append a b)`, [Racket]
*can't* simply make the last element of `a` point to `b` because the last
element of `a` is an *immutable* pair. So it has to copy `a` and make the copies
last element point to `b`.

So `(append a b)` runs in linear time proportional to the length of `a`. Keep
this in mind for the next function!


## The reverse Function

Lets write the `reverse` function, which reverses the order of a list's
elements:

```lisp
> (reverse '())
'()
> (reverse '(cow))
'(cow)
> (reverse '(a b))
'(b a)
> (reverse '(a b c))
'(c b a)
> (reverse '(all the cows (in the world)))
'((in the world) cows the all)
```

The recursive idea is to reverse the *rest* of the list, and then *append* the
first item to the end of the reversed rest:

```lisp
(define (reverse lst)
  (cond [(empty? lst) '()]
        [else (append (reverse (rest lst))
                      (list (first lst)))]))
```

Conceptually, this words, but because it repeatedly calls `append` this runs in
**quadratic time** with respect to the length of the list.

We can speed this up by using an **accumulator** variable to store the reversed
list as we go. Take a look at `reverse-helper`:

```lisp
(define (reverse-helper lst acc)
  (cond [(empty? lst)
         acc]
        [else
         (reverse-helper (rest lst)
                         (cons (first lst) acc))]
        ))
```

It takes two arguments: the `lst` we want to reverse, and `acc`, a helper list
that will store the reversed list as we go. Each recursive call to
`reverse-helper` removes the first element of `lst` and adds it to the front of
`acc`. All the operations are constant-time, and so this reverse the list in
linear time.

For convenience, we can wrap `reverse-helper` in a new function called
`my-reverse`:

```lisp
(define (my-reverse lst)
  (reverse-helper lst '()))
```

This trick of adding an extra accumulator variable is a common pattern in
LISP-like languages, and [Racket] even has language features that support it.
However, it puts the burden of recognizing the problem, and managing the
accumulator, on the programmer.

## More Examples of Recursive Functions

In the following examples, **top-level** means the elements of the list are
*not* nested within other lists:

```lisp
;;
;; Remove all top-level occurrences of x from lst.
;;
(define (remove-all x lst)
  (cond [(empty? lst) 
           '()]
        [(equal? x (first lst))
           (remove-all x (rest lst))]
        [else
           (cons (first lst) (remove-all x (rest lst)))]))

> (remove-all 'a '(a b c a d))
'(b c d)

;;
;; Replace all top-level occurrences of 'biden with 
;; 'trump.
;;
(define (trumpify lst)
  (cond [(empty? lst) '()]
        [(equal? 'biden (first lst))
         (cons 'trump (trumpify (rest lst)))]
        [else
         (cons (first lst) (trumpify (rest lst)))]))

> (trumpify '(biden thinks biden should be president))
'(trump thinks trump should be president)

;;
;; Replace all top-level occurrences of old with new.
;;
(define (replace old new lst)
  (cond [(empty? lst) '()]
        [(equal? old (first lst))
         (cons new (replace old new (rest lst)))]
        [else
         (cons (first lst) (replace old new (rest lst)))]))

> (replace 'cat 'dog '(the cat gave the cat a hug))
'(the dog gave the dog a hug)
```

## Challenge: subsets

Implement a function called `(my-subset? lst1 lst2)` that returns true just when
every element of `lst1` is a member of `lst2`. The empty list is considered a
subset of all other lists.

For example:

```lisp
> (my-subset? '() '())
#t
> (my-subset? '() '(1 2))
#t
> (my-subset? '(2 1 1) '(1 2))
#t
> (my-subset? '(2 1 3) '(1 2))
#f
> (my-subset? '(a d (3 1)) '(1 a (3 d))
#f
> (my-subset? '((1) (2 2)) '((3 3 3) a (2 2) (1))
#t
```

[Racket] already has a built-in function called `subset?`, but
[tiny-lisp](tiny-lisp/README.md) does not.

## Challenge: set equality

Implement a function called `(same-set? lst1 lst2)` that returns `#t` just when
`lst1` and `lst2` contain the same elements, and `#f` otherwise. Order and
duplicate values *don't* matter. In other words, `lst1` and `lst2` are equal in
the set theory sense.

For example:

```lisp
> (same-set? '(1 2 3) '(3 1 2))
#t
> (same-set? '(1 2 3 3) '(2 3 1 1 1 2))
#t
> (same-set? '(1 2 3 3) '(2 1 1 1 2))
#f
> (same-set? '(3 1) '(1 2 4 3))
#f
```

## Challenge: pairing two lists

Using recursion, implement a function called `(pairs lst1 lst2)` that returns a
list of all pairs of items in `lst1` and `lst2` that are in the same position.
If one list is longer than the other, then ignore the extra elements.

For example:

```lisp
> (pairs '(a b c) '(1 2 3))
'((a 1) (b 2) (c 3))
> (pairs '(a b c) '(1 2))
'((a 1) (b 2))
> (pairs '(a b) '(1 2 3))
'((a 1) (b 2))
```

## Challenge: removing duplicates

Implement a function called `(my-remove-duplicates lst)` that returns a list
that is the same as `lst` except all elements in `lst` that occur 2 or more
times have their extra copies removed. The exact order of the elements on the
returned list doesn't matter.

For example:

```lisp
> (my-remove-duplicates '(1 2 3 2))
'(1 3 2)
> (my-remove-duplicates '(4 4 4))
'(4)
> (my-remove-duplicates '(up up and a way way))
'(up and a way)
```

[Racket] already has a built-in function called `remove-duplicates`. Of course,
don't use it in your function!

## Challenge: finding multiples

Implement a function called `(keep-multiples lst)` that returns a list of all
the elements that appear two, or more, times in `lst`. The returned list should
*not* have any duplicate values. The order of the elements in the returned list
doesn't matter.

For example:

```lisp
> (keep-multiples '(a b c))
'()
> (keep-multiples '(a b a c))
'(a)
> (keep-multiples '(a b a c c a))
'(a c)
> (keep-multiples '(a b a c c b))
'(a c b)
```

## Challenge: maximizing a function

Implement a function called `(maximum f lst)` that returns the value `x` in
`lst` that makes `(f x)` as big as possible. You can assume:

- `lst` is *not* empty.
- `f` takes one input, and can be applied to any element in `lst`, and returns
  a number.
- If there is more than one value on `lst` that maximizes `f`, then *any* one
  of those values can be returned.

For example:

```lisp
> (maximum sum '((1 2 0 0 2) (9) (2 8 2 -2)))
'(2 8 2 -2)
> (maximum length '((1 2 0 0 2) (9) (2 8 2 -2)))
'(1 2 0 0 2)
> (maximum last '((1 2 0 0 2) (9) (2 8 2 -2)))
'(9)
> (maximum string-length '("one" "two" "three" "four" "five"))
"three"
```

`sum` is *not* a built-in [Racket] function. You can define it like this:

```lisp
(define (sum lst) (foldr + 0 lst))

> (sum '(3 4 2))
9
```

## Counting All the Numbers in a List

Suppose we want to count *all* the numbers in a list, not just the ones at the
top-level. For example, `'(7 (b 8 9) ((up (or 16 you))))` has 4 numbers in
total.

The solution to this problem is similar to `count-num`, except we need to
recognize when an element is a list, and then count the numbers in it.

```lisp
;; Returns the number of numbers on lst, even numbers
;; inside of lists:
(define (deep-count-num lst)       
  (cond [(empty? lst) 
         0]
        [(list? (first lst))
         (+ (deep-count-num (first lst)) 
            (deep-count-num (rest lst)))]
        [(number? (first lst))
         (+ 1 (deep-count-num (rest lst)))]
        [else
         (deep-count-num (rest lst))]
        ))
```

There's one base case and are three recursive cases:

- *Base case*: when `lst` is the empty list, return 0 (because there are no
  numbers in the empty list).

- *Recursive case 1*: when `lst` starts with a list, and the number of numbers
  in that list (recursively calculated) to the number of items in the rest of
  the list (again recursively calculated).

- *Recursive case 2*: when `lst` starts with a number, add 1 (for that number)
  to the number of numbers in the rest of the list (recursively calculated).

- *Recursive case 3*: when `lst` is non-empty and starts with a value other than
  a list or number, return the number of numbers in the rest of the list
  (recursively calculated).


### Challenge: deep counting with a predicate

Write a function called `(deep-count-fn pred? lst)` that *deeply* counts the
number of items in `lst` that satisfy `pred?`, even for items nested within
sub-lists. `pred?` is a predicate function.


### Flattening a List

Consider the problem of *flattening* a list, i.e. removing all the lists, and
sub-lists, and leaving just the non-list elements in their original order. The
built-in [Racket] function `flatten` function does this:

```lisp
> (flatten '(1 (a b) (c (d) ((e) g))))
(1 a b c d e g)
```

Here's an implementation of `flatten`:

```lisp
(define (flatten x)
  (cond [(empty? x) 
           x]
        [(not (list? x)) 
           x]
        [(list? (first x))
           (append (flatten (first x))
                   (flatten (rest x)))]
        [else ;; first element is not a list
           (cons (first x) 
                 (flatten (rest x)))]
))
```

Using `flatten` we can re-write `deep-count-num` like this:

```lisp
(define (deep-count-num lst)
    (count-num (flatten lst)))
```

As long as you know what `count-num` and `flatten` do, this implementation of
`deep-count-num` is easier to read than the original version. It's a good
example of simpler functions can be used to build a more complicated function.


## Challenge: calculating consed-out lists

A **consed-out** list is a representation of a list using nested calls to
`cons`. For example, the consed-out version of `'(a b c)` is `(cons 'a (cons 'b
(cons 'c '())))`. Any elements of the list that are also lists are also
consed-out, and so on recursively. For example, the consed-out version of `((a)
b c)` is `(cons (cons 'a '()) (cons 'b (cons 'c '()))`.

Implement a function called `(make-consed x)` that returns the consed-out
version of the list `x`. If `x` is not a list, just return `x` without any
change. All nested sub-lists in `x` should be consed-out.

For example:

```lisp
> (make-consed '())
'()

> (make-consed '(a b c))
'(cons a (cons b (cons c ())))

> (make-consed '((a b) c d))
'(cons (cons a (cons b ())) (cons c (cons d ())))
```

When `x` is a list, the value returned by `(make-consed x)` is a quoted list,
and so symbols and the empty list that appear in it are **not** quoted.


[Scheme]: https://en.wikipedia.org/wiki/Scheme_(programming_language)
[Racket]: https://racket-lang.org/
[LISP]: https://en.wikipedia.org/wiki/Lisp_(programming_language)
[Java]: https://en.wikipedia.org/wiki/Java

# Haskell Quiz Study Notes (CMPT 383)

These notes cover everything listed under **"The in-class Haskell quiz will be
based on these notes"** in [haskell/README.md](../../haskell/README.md), plus the
practice material. The "extra" chapters (10, 12, QuickCheck, 15, 16) are left
out on purpose. They aren't on the quiz unless they get covered in class.

| # | Topic | Source notes | Class time |
|---|-------|--------------|-----------|
| 1 | Introduction | Ch 1 | 1 hr (with Ch 2) |
| 2 | First steps | Ch 2 | (with Ch 1) |
| 3 | Types and classes | Ch 3 | 1 hr |
| 4 | Defining functions | Ch 4 (+ practice Qs) | 1 hr |
| 5 | List comprehensions | Ch 5 (+ practice Qs) | read on your own |
| 6 | Recursive functions | Ch 6 (+ practice Qs) | read on your own |
| 7 | Higher-order functions | Ch 7 (+ practice Qs) | **2 hrs** |
| 8 | Approval voting (extended example) | Approval_Voting | 1 hr |
| 9 | Declaring types and classes | Ch 8 | 1 hr |
| 10 | Intro to do-notation | do_blocks/ | 1 hr |

**How the quiz is described** (from `Haskell_problemset.md`): *"The questions on
the Haskell quiz will mainly be variations of the questions below, or questions
that are similar. ... stick to basic Haskell features and code as used in the
notes."* So expect these kinds of questions:

1. **Predict the output** of an expression (no GHCi).
2. **Write the most general type signature** of a value or function.
3. **Implement a function** with a required technique: recursion, guards,
   a list comprehension, `foldr`, point-free composition, or sections.
4. **Explain the bug** in some code and fix it.
5. **Explain a concept** (e.g. currying) in plain words.
6. **Declare a data type** and write functions on it.

The instructor also wrote: *"Understand how [`bits`] works as it could be on the
quiz ... it would be half or more than half of the quiz."* (That comment is in
`example.hs`.) See [§7.10](#710-the-bits--bools-function-very-likely-on-the-quiz).

---

## Table of Contents

1. [Chapter 1: Introduction](#1-chapter-1-introduction)
2. [Chapter 2: First steps](#2-chapter-2-first-steps)
3. [Chapter 3: Types and classes](#3-chapter-3-types-and-classes)
4. [Chapter 4: Defining functions](#4-chapter-4-defining-functions)
5. [Chapter 5: List comprehensions](#5-chapter-5-list-comprehensions)
6. [Chapter 6: Recursive functions](#6-chapter-6-recursive-functions)
7. [Chapter 7: Higher-order functions](#7-chapter-7-higher-order-functions)
8. [Extended example: Approval voting](#8-extended-example-approval-voting)
9. [Chapter 8: Declaring types and classes](#9-chapter-8-declaring-types-and-classes)
10. [Intro to do-notation (IO)](#10-intro-to-do-notation-io)
11. [How to work out the most general type](#11-how-to-work-out-the-most-general-type)
12. [Type signature cheat sheet](#12-type-signature-cheat-sheet)
13. [Common bugs and gotchas](#13-common-bugs-and-gotchas)
14. [Errors and quirks in the course notes](#14-errors-and-quirks-in-the-course-notes)
15. [Practice map: what to drill](#15-practice-map-what-to-drill)
16. [Worked solutions to the in-notes challenges](#16-worked-solutions-to-the-in-notes-challenges)
17. [Quiz-day checklist](#17-quiz-day-checklist)

---

## 1. Chapter 1: Introduction

### 1.1 Pure functions

A function is **pure** if:

1. its output depends **only on its inputs**, and
2. it has **no side effects** (it doesn't change global variables, print, read
   files, use the network, and so on).

- `f(x) = x + 1` is pure.
- `get_time()` is **not** pure, because each call can return something different.

**In Haskell, all functions are pure.** That's the key thing that sets it apart
from other languages. Side effects like I/O are handled with special types
(`IO`, monads, applicatives) so that functions stay pure. See [§10](#10-intro-to-do-notation-io).

### 1.2 Functional style in one example

Make a list of the even numbers from 1 to 100:

```cpp
// C++ (imperative): a mutable variable, a loop, an if
vector<int> nums;
for (int i = 1; i <= 100; i++)
    if (i % 2 == 0) nums.push_back(i);
```

```haskell
-- Haskell (functional)
filter even [1..100]
```

- `even` is a function, `n -> Bool`.
- `filter` is a **higher-order function** because it takes a function (`even`) as input.
- The Haskell version has no variables, no loops, no `if`, no explicit types,
  and very little punctuation.

### 1.3 Main features of Haskell (know these by name)

| Feature | Meaning |
|---|---|
| **Concise programs** | Designed for readability. Code is short, sometimes *too* terse for beginners. |
| **Powerful type system** | Every expression has a type. Type errors are caught **before** running. **Type inference** works out most types for you. |
| **Higher-order functions** | You can pass functions as arguments and return them as results. |
| **Effectful functions** | Functions are pure, so effects (I/O, randomness) are handled with **monads** and **applicatives**. |
| **Lazy evaluation** | An argument is evaluated only **when it is needed**. This allows **infinite lists**, and lets you write `if`-like or short-circuit functions as ordinary functions (other languages need macros). |
| **Equational reasoning** | Programs are sets of equations, so you can reason about and transform them like math. |

**Lazy evaluation example:** in `f (g 2)`, most languages compute `g 2` first.
Haskell passes `g 2` **unevaluated** and only computes it if `f` actually uses it.

### 1.4 History (light, but could be a short-answer question)

- Its roots are in 1930s logic and computation: Schönfinkel, **Alonzo Church**,
  Alan Turing, **Haskell Curry** (the language and "currying" are named after him).
- Haskell is basically the **typed lambda calculus** (Church, 1930s).
- Haskell was started in **1987** by a committee of PL researchers. It isn't
  mainstream, but it has been a rich source of ideas.

### 1.5 First taste: `mysum` (recursion)

```haskell
mysum :: Num a => [a] -> a      -- type signature (read :: as "has type")
mysum []     = 0                -- base case: sum of empty list is 0
mysum (n:ns) = n + mysum ns     -- recursive case: first + sum of rest
```

`(n:ns)` is a **cons pattern**: `n` is the first element (head) and `ns` is the
rest (tail).

**Hand trace** (practise doing these):

```
mysum [1,2,3]
= 1 + mysum [2,3]
= 1 + (2 + mysum [3])
= 1 + (2 + (3 + mysum []))
= 1 + (2 + (3 + 0))
= 6
```

The type `Num a => [a] -> a` says: take a list of `a`s and return an `a`, where
`a` must be a numeric type (an instance of the **type class** `Num`). GHCi may
print it as `Num p => [p] -> p`. The name of the type variable doesn't matter.

GHCi tip: `:t expr` (or `:type`) shows a type, `:info Class` shows a class,
`:load file.hs` / `:reload` loads code.

**Big ideas:**
- There are **no loops** in Haskell. Use recursion and higher-order functions instead.
- There are **no mutable variables**. Once a name is bound, its value never changes.

### 1.6 First taste: `qsort`

```haskell
qsort []     = []
qsort (n:ns) = qsort smalls ++ [n] ++ qsort bigs
  where smalls = [a | a <- ns, a <= n]   -- list comprehension
        bigs   = [b | b <- ns, b > n]
```

- `++` concatenates two lists.
- `[a | a <- ns, a <= n]` is a **list comprehension**: "all `a` drawn from
  `ns` such that `a <= n`".
- It isn't *real* quicksort, because it **copies** sublists instead of
  partitioning in place, so it's slower than C++ quicksort. But it's short and clear.
- Type: `qsort :: Ord a => [a] -> [a]`. It works on **anything orderable**
  (numbers, chars, strings).
  - `qsort "SimonFraserUniversity"` → `"FSUaeeiiimnnorrrsstvy"`. Capitals
    come before lowercase letters in character order.

---

## 2. Chapter 2: First steps

The **standard prelude** is the library of basic functions that loads automatically.

### 2.1 Standard list functions (memorize behaviour and edge cases)

| Expression | Result | Notes |
|---|---|---|
| `head [3,2,1]` | `3` | `head []` → **error** |
| `tail [3,2,1]` | `[2,1]` | `tail []` → **error** |
| `last [9,1,4]` | `4` | `last []` → **error** |
| `init [1,2,3,4]` | `[1,2,3]` | everything but the last element |
| `length "road"` | `4` | `length [] = 0` |
| `[8,3,5] !! 0` | `8` | **0-indexed**. `[8,3,5] !! 3` → error (index too large) |
| `take 2 [9,3,2,1]` | `[9,3]` | `take 10 [9,3,2,1] = [9,3,2,1]` (no error). `take 0 xs = []` |
| `drop 2 [9,3,2,1]` | `[2,1]` | `drop 10 [9,3,2,1] = []` (no error) |
| `sum [2,10,-4]` | `8` | `sum [] = 0` |
| `product [2,10,-4]` | `-80` | `product [] = 1` |
| `[2,7] ++ [0,0,9]` | `[2,7,0,0,9]` | also joins strings: `"red " ++ "popper"` |
| `reverse "orchestra"` | `"artsehcro"` | |
| `[1..5]` | `[1,2,3,4,5]` | a range. `[0..]` is **infinite** |

Strings are lists of characters, so **all list functions work on strings**:
`head "person" = 'p'`, `tail "person" = "erson"`, `take 2 "SFU" = "SF"`.

### 2.2 Function application

- Apply `g` to `x` by writing `g x` (no parentheses, no commas).
- `f a b c` means `((f a) b) c`. **Function application is left-associative.**
- Function application has the **highest precedence**. It binds tighter than any operator:
  `f x + 1` means `(f x) + 1`, and `double 3 * 2` means `(double 3) * 2`.
- To compute g(g(x)), write **`g (g x)`**. Writing `g g x` means `(g g) x`,
  which applies `g` to the function `g`. That's usually a type error.

| Math | Haskell |
|---|---|
| f(x) | `f x` |
| f(x, y) | `f x y` |
| f(g(x)) | `f (g x)` |
| f(x, g(y)) | `f x (g y)` |
| f(x)·g(y) | `f x * g y` |

### 2.3 Naming rules

- Functions and variables **must start lowercase**: `e = 2.718` works, but
  `E = 2.718` is an error, because capitalized names are constructors.
- After that you can use letters, digits, `_`, and `'`. `f'` is a normal name,
  and the `'` has no special meaning.
- Convention: list names end in `s`. `x` is an element, `xs` is a list,
  `xss` is a list of lists.
- Types, type classes, and constructors start **uppercase**: `Int`, `Num`, `True`, `Just`.

### 2.4 The layout rule (indentation matters)

```haskell
f = b + c
    where
       b = 1
       c = 2
d = 2 * f        -- back at column 1, so NOT part of the where
```

- Definitions at the same level must be lined up in the same column.
- You *can* use `{ ; }` explicitly, but nobody does.
- **Don't use tabs.** Use spaces.

### 2.5 Comments

```haskell
-- single-line comment
{- multi-line
   comment -}
```

### 2.6 Simple definitions from the notes

```haskell
double x    = x + x
quadruple x = double (double x)
factorial n = product [1..n]
average ns  = sum ns `div` length ns     -- `div` = integer division, written infix
ends1 lst   = [head lst, last lst]
ends2 lst   = [head lst] ++ [last lst]
```

**Backticks** turn a named function into an infix operator:
``div 7 2 == 7 `div` 2``.

### 2.7 Classic exercises: `last` and `init` two ways

```haskell
mylast1 lst = head (drop (length lst - 1) lst)   -- drop all but the last
mylast2 lst = head (reverse lst)                 -- reverse, take the head

myinit1 lst = take (length lst - 1) lst          -- keep the first n-1
myinit2 lst = reverse (tail (reverse lst))       -- reverse, drop the head, reverse back
```

---

## 3. Chapter 3: Types and classes

### 3.1 Core vocabulary

- A **type** is a collection of related values. For example, `Bool` = {`True`, `False`}.
- `v :: t` means "`v` has type `t`".
- `s -> t` is the type of a **function** from `s` to `t` (it "maps" `s` to `t`).
- **Static type checking**: all types are checked *before* running.
  Haskell is **type safe**, so there are no type errors during evaluation.
  - Python, Racket, and JS are **dynamic**: type errors show up at runtime.
  - C++ and Java are static, but don't catch every type error.

```haskell
False      :: Bool
not        :: Bool -> Bool
not False  :: Bool
```

### 3.2 Type inference: the application rule

```
  f :: a -> b     e :: a
  ----------------------
        f e :: b
```

- `not :: Bool -> Bool` and `True :: Bool`, so `not True :: Bool`.
- `not 3` is a **type error** because `3` isn't a `Bool`, and it's caught before evaluation.
- The underlying theory is the **Hindley-Milner** type system.

### 3.3 Basic types

| Type | Values | Notes |
|---|---|---|
| `Bool` | `True`, `False` | |
| `Char` | `'a'`, `'A'`, `'8'`, `'\n'` | **single quotes** |
| `String` | `""`, `"cat"` | **double quotes**. `String` = `[Char]` |
| `Int` | fixed precision, −2⁶³ to 2⁶³−1 on 64-bit | fast (hardware ints), can **overflow** |
| `Integer` | arbitrary precision | never overflows, slower |
| `Float` | single-precision floating point | |
| `Double` | double-precision floating point | more accurate |

- A literal like `5` can be `Int`, `Integer`, `Float`, or `Double`.
  Force a type with `5 :: Float`.
- `:t 4` gives `4 :: Num p => p`. A numeric literal is **overloaded**.
- Python and Racket use arbitrary-precision ints by default (like `Integer`).
  C, C++, and Java `int` is fixed (like `Int`).

### 3.4 Lists vs tuples (classic comparison question)

| | **List** `[t]` | **Tuple** `(t1, t2, ...)` |
|---|---|---|
| Element types | **all the same** type | **can differ** |
| Length / size | any, **even infinite** | fixed and **finite** (its *arity*) |
| Does the type tell you the size? | **No**. `[1]` and `[1,2,3]` are both `[Int]` | **Yes**. `(Bool,Char)` has arity 2 |
| Examples | `[False,True] :: [Bool]`, `["one","two"] :: [String]`, `[["a"],["b","c"]] :: [[String]]` | `(False,'-',True) :: (Bool,Char,Bool)`, `("Yep",True,'z') :: (String,Bool,Char)` |

- `()` is the empty tuple (arity 0). Its type is also written `()`.
- **There are no 1-tuples.** `(2 + 3)` is just a parenthesized expression.
  (Python allows `(2+3,)`, Haskell doesn't.)
- Python and Racket lists can mix types. Haskell lists can't.

### 3.5 Function types

```haskell
add :: (Int, Int) -> Int          -- ONE input: a pair
add (x, y) = x + y

range :: Int -> [Int]
range n = [0..n]

twice :: (Int -> Int) -> Int -> Int   -- first input is itself a function
twice f x = f (f x)
```

- A **total function** returns a result for **every** input of its type.
  `add` is total. `head` is **not** total, because `head []` is an error.
  Haskell **doesn't require** functions to be total.

### 3.6 Curried functions (very likely quiz material)

```haskell
add' :: Int -> (Int -> Int)       -- same as Int -> Int -> Int
add' x y = x + y

plus5 = add' 5                    -- partial application gives a new function
plus5 2                           -- 7
(add' 5) 2                        -- 7
```

```haskell
mult :: Int -> Int -> Int -> Int  -- really Int -> (Int -> (Int -> Int))
mult x y z = x * y * z
```

| Expression | Type |
|---|---|
| `mult` | `Int -> Int -> Int -> Int` |
| `mult 8` | `Int -> Int -> Int` |
| `mult 8 7` | `Int -> Int` |
| `mult 8 7 1` | `Int` (= 56) |

**Definition (in plain words):** a *curried* function takes its arguments
**one at a time**. If you give it fewer arguments than it needs, you get back a
**new function** waiting for the rest. In Haskell **every function is curried by
default**, so every function really has exactly **one** input.

**Two rules that go together:**

- In types, **`->` is right-associative**: `a -> b -> c` = `a -> (b -> c)`.
- In expressions, **application is left-associative**: `f x y` = `(f x) y`.
- The **rightmost** type is the final output. Everything before it is an input.

**Why currying is useful:**
1. It makes new functions from old ones easily: `map (+1)`, `filter even`, `take 3`.
2. It lets you treat every function as a one-input function.

**Comparison with C++ and Python:** if `f(x, y)` takes two arguments, calling
`f(8)` is an **error**. Racket has a `curry` function but doesn't curry by
default. JS needs a library (Ramda).

**Currying examples with `map` and `filter`:**

```haskell
incAll  = map (+1)          -- :: Num b => [b] -> [b]
evens   = filter even       -- :: Integral a => [a] -> [a]
first3  = take 3            -- :: [a] -> [a]
incAll [1,2,3]              -- [2,3,4]
evens [1..10]               -- [2,4,6,8,10]
```

**Tuple vs curried:** `add :: (Int,Int) -> Int` takes **one** input (a pair)
and **can't** be partially applied. `add' :: Int -> Int -> Int` is curried.

### 3.7 Polymorphic types (type variables)

A **type variable** (lowercase, e.g. `a`, `b`) can stand for **any** type. A
type that contains type variables is **polymorphic**.

```haskell
head   :: [a] -> a
fst    :: (a, b) -> a
snd    :: (a, b) -> b
take   :: Int -> [a] -> [a]
zip    :: [a] -> [b] -> [(a, b)]
id     :: a -> a              -- the identity function
length :: [a] -> Int
```

- `zip [1,2,3] ["cat","dog","bird"]` → `[(1,"cat"),(2,"dog"),(3,"bird")]`
- `id 7.5 = 7.5`. `id head` is the function `head`. `id id` is `id`.
- GHCi **can't print functions**. Evaluating `id head` alone gives an error
  ("No instance for Show ...").

### 3.8 Overloaded types and class constraints

```haskell
(+) :: Num a => a -> a -> a
```

- `=>` is the "fat arrow". `Num a` is a **class constraint**: "`a` can be any
  type **that is an instance of** `Num`".
- A type with a constraint is **overloaded**.
- `"cat" + "dog"` is an **error**: `No instance for (Num [Char])`. Strings
  aren't numbers. Use `++`: `"cat" ++ "dog"` = `"catdog"`.
- `(++) :: [a] -> [a] -> [a]` has **no** constraint. It works for any element type.
- Multiple constraints go in parentheses: `(Num a, Ord a) => a -> String`.

### 3.9 The basic type classes (know the methods and instances)

| Class | Meaning | Key functions | Instances (common) |
|---|---|---|---|
| `Eq` | equality types | `(==)`, `(/=)` | numbers, `Char`, `Bool`, `String`, lists/tuples of `Eq`. **Not functions.** |
| `Ord` | ordered types (**needs `Eq`**) | `(<)`, `(<=)`, `(>)`, `(>=)`, `min`, `max` | numbers, `Char`, `Bool`, `String`, lists/tuples of `Ord` |
| `Show` | can be converted **to** a String | `show :: a -> String` | most types (not functions) |
| `Read` | can be parsed **from** a String | `read :: String -> a` | most basic types |
| `Num` | numeric types | `(+)`, `(-)`, `(*)`, `negate`, `abs`, `signum`, `fromInteger` | `Int`, `Integer`, `Float`, `Double` |
| `Integral` | integer types (**needs `Num`**) | `div`, `mod` | `Int`, `Integer` |
| `Fractional` | fractional types (**needs `Num`**) | `(/)`, `recip` | `Float`, `Double` |

**Details to remember:**

- A list `[t]` is in `Eq` (or `Ord`) **just when** `t` is.
- Lists and strings are compared **lexicographically**, element by element
  from the left: `"apple" < "banana"`, `[1,2,3] < [1,3]`, `False < True`.
- `show`: `show 3.14 = "3.14"`, `show 'a' = "'a'"`, `show "off" = "\"off\""`.
  Showing a string adds quotes.
- `read` often needs a type annotation because Haskell can't guess what to parse into:
  `read "5" :: Int` gives `5`, `read "5" :: Float` gives `5.0`,
  `read "[8,-2,6]" :: [Int]` gives `[8,-2,6]`.
- `signum 3 = 1`, `signum 0 = 0`, `signum (-3) = -1`.
- **Negative literal gotcha:** `signum -3` parses as `signum - 3` (subtraction)
  and gives a confusing error. **Always write `(-3)`** when passing a negative number.
- `div` and `mod` can be prefix (`div 8 3` = 2) or infix (``10 `mod` 3`` = 1).
- `2 / 3` = `0.666...`, `4 / 0` = `Infinity`, `0 / 0` = `NaN`,
  `recip 10` = `0.1`.
- `:info Num` lists the class methods and all its instances.

### 3.10 Integer division vs fractional division (common bug source)

| Operator | Class needed | Example |
|---|---|---|
| `` `div` `` | `Integral` (`Int`, `Integer`) | ``7 `div` 2 = 3`` |
| `` `mod` `` | `Integral` | ``7 `mod` 2 = 1`` |
| `/` | `Fractional` (`Float`, `Double`) | `7 / 2 = 3.5` |

- `length` returns an **`Int`**, and `Int` is **not** `Fractional`.
  So you can't use `/` directly on an `Int`.
- To convert an integral value into any numeric type, use
  `fromIntegral :: (Integral a, Num b) => a -> b`. Ch 5's `percent` uses it:
  `fromIntegral n / fromIntegral m`.

---

## 4. Chapter 4: Defining functions

### 4.1 Defining with equations ("new from old")

```haskell
middle1 :: [a] -> [a]
middle1 []     = []                         -- empty list
middle1 [x]    = []                         -- exactly one element
middle1 (_:xs) = reverse (tail (reverse xs))   -- 2 or more elements
```

- Equations are tried **top to bottom**. The **first match wins**.
- `_` is the **wildcard**: it matches anything and doesn't bind a name.
  Use it when you don't need the value.
- The type signature is optional, but you should always write one (it documents the function).

### 4.2 Conditional expressions

```haskell
pluralize1 :: String -> String
pluralize1 "" = ""
pluralize1 s  = s ++ (if last s == 's' then "" else "s")
```

- Form: `if cond then a else b`. `cond` must be a `Bool`.
- **`else` is mandatory.** Every expression must produce a value.
- **`a` and `b` must have the same type.**
- `if` is an **expression** (like C's `? :`), not a statement, so it can go anywhere a value can.
- Nested version: `if n == 0 then "zero" else if n < 0 then "negative" else "positive"`.

### 4.3 Guarded equations

```haskell
sign1 n | n == 0    = "zero"
        | n < 0     = "negative"
        | otherwise = "positive"
-- inferred: sign1 :: (Num a, Ord a) => a -> [Char]
```

- Each `|` guard is a **`Bool` expression**. Guards are checked top to bottom,
  and the first `True` one wins.
- `otherwise` is just `True`. It's the catch-all, so put it last.
- Guards are cleaner than nested `if`s when there are many cases.
- If no guard matches (and there's no `otherwise`), Haskell moves on to the
  next equation. If nothing matches at all, you get a runtime error.
- **Order matters:** in FizzBuzz, test "divisible by 15" (both) **first**.

```haskell
letter n | n >= 90   = "A"     -- example pattern of ordered guards
         | n >= 80   = "B"     -- only reached if n < 90
         | otherwise = "F"
```

### 4.4 `where` clauses

```haskell
heron a b c = sqrt (s * (s-a) * (s-b) * (s-c))
  where s = (a + b + c) / 2
```

`where` defines local helper values and functions. They're visible across
**all guards** of that equation. Indent them consistently.

### 4.5 Pattern matching

**Literal patterns:**

```haskell
coin1 :: Int -> String
coin1 1  = "penny"
coin1 5  = "nickel"
coin1 10 = "dime"
coin1 25 = "quarter"
coin1 _  = "unknown"     -- catch-all, must come LAST
```

**Boolean patterns (truth table style):**

```haskell
nand :: Bool -> Bool -> Bool
nand True True = False
nand _    _    = True        -- each _ independently matches anything
```

The same idea from `example.hs`:

```haskell
myand :: Bool -> Bool -> Bool
myand True True = True
myand _    _    = False
```

**Tuple patterns:**

```haskell
get_x :: (Double, Double) -> Double
get_x (x, _) = x
```

**List patterns, fixed length:** `[x]` (1 element), `[x,y]` (2), `[_, "+", _]` (3).

```haskell
is_expr :: [String] -> String
is_expr [_, "+", _] = "addition"
is_expr [_, "-", _] = "subtraction"
is_expr ["-", _]    = "negation"
is_expr [_, op,  _] = "unknown operator " ++ op
is_expr _           = "unknown expression"
```

**Cons patterns (`x:xs`):**

```haskell
firsts2 :: [a] -> [b] -> (a, b)
firsts2 (x:_) (y:_) = (x, y)
```

- `(x:xs)` matches **non-empty** lists only. It does **not** match `[]`, so
  handle `[]` separately.
- **Parentheses are required** around cons patterns in arguments: `f (x:xs)`, not `f x:xs`.
- Match several elements at the front: `remove812 (8:1:2:xs) = xs`.
- `(x:y:rest)` matches lists with **at least 2** elements.

**Patterns cheat sheet:**

| Pattern | Matches |
|---|---|
| `[]` | the empty list only |
| `[x]` | exactly 1 element |
| `[x,y]` | exactly 2 elements |
| `(x:xs)` | 1 or more elements |
| `(x:y:xs)` | 2 or more elements |
| `_` | anything |
| `(a, b)` | any pair |
| `"" ` | the empty string |
| `5`, `'c'`, `True` | that exact value |

**Pattern rules that become "explain the bug" questions:**
1. **A variable can't appear twice** in one equation's patterns
   (`same a a = True` is a compile error: "Conflicting definitions").
   Use `==` in a guard or the body instead.
2. A catch-all equation (`_`) placed **before** more specific ones makes them
   unreachable.
3. Comparing values **requires `Eq`** in the type signature.

### 4.6 The cons operator `(:)` builds lists

```haskell
(:) :: a -> [a] -> [a]
4 : [2,6,1]     -- [4,2,6,1]
1 : []          -- [1]
2 : 6 : 1 : []  -- [2,6,1]   (: is right-assoc: 2 : (6 : (1 : [])))
```

- `[4,2,6,1]` is shorthand for its **consed-out form** `4:2:6:1:[]`.
- `"apple"` = `'a':'p':'p':'l':'e':[]`.
- `:` adds **one element to the front**. `++` joins **two lists**.
  `[1,2] ++ [3]` works, `[1,2] : 3` is a type error.

### 4.7 Lambda expressions

```haskell
(\x -> x*x) 3                -- 9
(\x -> (\y -> x * y)) 3 4    -- 12
(\x y -> x * y) 3 4          -- 12 (shorthand for the nested form)
inc1 = \n -> n + 1           -- define a named function using a lambda
plus = \x y -> x + y
```

- A lambda is a **function with no name**. It's handy for small one-off
  functions, e.g. `map (\x -> x^2 + 1) xs`.
- `\` is read "lambda" (λ).
- **Closure:** `(\x -> (\y -> x * y)) 3` returns `\y -> 3 * y`. The inner
  function **remembers** that `x = 3`. A closure is a function **plus an
  environment** of variable bindings.
- Lambdas can use patterns: `\(x, y) -> (y, x)` swaps a pair.

### 4.8 Operator sections

An infix operator in parentheses becomes a prefix function: `(+) 2 5` = `7`.
If you also put **one argument inside**, you get a **section**:

| Section | Means | Example |
|---|---|---|
| `(2+)` | `\x -> 2 + x` | `(2+) 4 = 6` |
| `(/2)` | `\x -> x / 2` | `map (/2) [2,4,6,8] = [1.0,2.0,3.0,4.0]` |
| `(2/)` | `\x -> 2 / x` | `map (2/) [2,4] = [1.0,0.5]` |
| `(1/)` | reciprocal | `map (1/) [1,2,4] = [1.0,0.5,0.25]` |
| `(^2)` | square | `map (^2) [1..5] = [1,4,9,16,25]` |
| `(2^)` | power of 2 | `map (2^) [0..4] = [1,2,4,8,16]` |
| `(>2)` | `\x -> x > 2` (a predicate) | `filter (>2) [1,6,0,4,2] = [6,4]` |
| `(==' ')` | is a space? | `dropWhile (==' ') "  hi" = "hi"` |
| `` (`elem` "aeiou") `` | is a vowel? | `takeWhile (`elem` "aeiou") "eat" = "ea"` |
| `('0':)` | put `'0'` in front | `('0':) "11" = "011"` |

- **The position matters** for non-commutative operators: `(/2)` ≠ `(2/)`,
  and `(-1)` ≠ `(1-)`.
- **Gotcha:** `(-1)` is the **number** −1, not "subtract 1". Use
  `subtract 1` or `(\x -> x - 1)` instead.
- Lambda vs section: `\x -> x + 1` is the same as `(+1)`, and `\x -> 2 * x` is
  the same as `(2*)` or `(*2)`.

---

## 5. Chapter 5: List comprehensions

### 5.1 Basic syntax

```haskell
[x^2 | x <- [1..5]]           -- [1,4,9,16,25]
```

- Read `|` as "such that" and `<-` as "is drawn from".
- `x <- [1..5]` is a **generator**.
- Equivalent with `map`: `map (^2) [1..5]`. A comprehension is often clearer
  when the expression is more complex (`[x^2 + 1 | x <- xs]` vs `map (\x -> x^2+1) xs`).

### 5.2 Multiple generators (nested loops)

```haskell
[(x,y) | x <- [1..4], y <- [1..3]]
-- [(1,1),(1,2),(1,3),(2,1),(2,2),(2,3),(3,1),(3,2),(3,3),(4,1),(4,2),(4,3)]
```

- **Later generators change fastest**, like an inner loop. `y` cycles through
  all its values for each `x`.
- This gives the **Cartesian product**.
- All 3-bit patterns: `[(a,b,c) | a<-[0,1], b<-[0,1], c<-[0,1]]` gives 8 tuples
  in binary-counting order.

### 5.3 Dependent generators

A later generator can use variables from earlier ones:

```haskell
concat :: [[a]] -> [a]
concat xss = [x | xs <- xss, x <- xs]     -- flatten a list of lists
concat [[1,2],[],[3,4,5],[6]]             -- [1,2,3,4,5,6]

[(x,y) | x <- [1..3], y <- [x..3]]        -- [(1,1),(1,2),(1,3),(2,2),(2,3),(3,3)]
```

### 5.4 The wildcard generator trick

```haskell
len :: [a] -> Int
len xs = sum [1 | _ <- xs]       -- one 1 per element
```

### 5.5 Guards (filters)

```haskell
[n | n <- [1..10], n `mod` 2 == 0]                     -- [2,4,6,8,10]
[n | n <- [1..100], n `mod` 2 == 0, n `mod` 3 == 0]   -- every guard must be True
```

- A guard is any `Bool` expression after a comma.
- With several guards, **all** must hold (they act like `&&`).

### 5.6 Factors and primes

```haskell
factors :: Int -> [Int]
factors n = [d | d <- [1..n], n `mod` d == 0]   -- factors 12 = [1,2,3,4,6,12]

is_prime :: Int -> Bool
is_prime n = factors n == [1,n]                  -- only factors are 1 and n

primes :: [Int]
primes = [n | n <- [2..], is_prime n]            -- an INFINITE list

firstNprimes n   = take n primes                 -- first n primes
primesLessThan n = takeWhile (< n) primes        -- primes below n
```

- Laziness means only **as much as needed** of `primes` gets computed.
  Evaluating all of `primes` would never finish.
- `take n` stops after n elements. `takeWhile p` stops at the **first element
  that fails** `p`. **`filter` on an infinite list never stops**:
  `filter (<100) primes` hangs after printing the primes below 100, because it
  keeps looking for more.

A faster `isPrime`, from `example.hs`:

```haskell
isPrime :: Int -> Bool
isPrime n = n > 1 && all nonDivisor candidates
  where nonDivisor d = n `mod` d /= 0
        leqSquare d  = d * d <= n
        candidates   = takeWhile leqSquare [2..]   -- only test 2..sqrt(n)

nthPrime n = primes !! (n - 1)    -- 1st prime is primes !! 0
```

### 5.7 Lookup tables (association lists)

```haskell
find :: Eq a => a -> [(a,b)] -> [b]
find key table = [v | (k, v) <- table, k == key]

find "Bob" [("Mei",20),("Bob",10),("Kel",19),("Bob",15)]   -- [10,15]
```

- You can use **patterns** in generators: `(k, v) <- table`.
- `Eq a` is needed because keys are compared with `==`. `b` needs no constraint.
- It's simple but O(n). Hash tables are faster.

### 5.8 FizzBuzz

```haskell
fb_rule :: Int -> String
fb_rule n | n `mod` 15 == 0 = "FizzBuzz"     -- check "both" FIRST
          | n `mod` 3  == 0 = "Fizz"
          | n `mod` 5  == 0 = "Buzz"
          | otherwise       = show n

fizzbuzz :: Int -> [String]
fizzbuzz n = [fb_rule a | a <- [1..n]]
```

(The course notes' version swaps "Fizz" and "Buzz". See [§14](#14-errors-and-quirks-in-the-course-notes).)

### 5.9 `zip` tricks

```haskell
zip [1,2,3] ["Bob","Bill","Jaya"]   -- [(1,"Bob"),(2,"Bill"),(3,"Jaya")]
zip [1,2]   ["Bob","Bill","Jaya"]   -- [(1,"Bob"),(2,"Bill")]   stops at the SHORTER list
zip "abc" [1..]                     -- [('a',1),('b',2),('c',3)]  OK with an infinite list
```

**Adjacent pairs:**

```haskell
pairs :: [a] -> [(a,a)]
pairs xs = zip xs (tail xs)          -- pairs [4,9,1,1,2] = [(4,9),(9,1),(1,1),(1,2)]

is_sorted :: Ord a => [a] -> Bool
is_sorted xs = and [x <= y | (x,y) <- pairs xs]
```

- `and :: [Bool] -> Bool` is `True` if there's no `False` (and `and [] = True`).
  `or` is the dual.

**Index positions**, a classic use of `zip xs [0..]`:

```haskell
positions :: Eq a => a -> [a] -> [Int]
positions x xs = [i | (x', i) <- zip xs [0..], x == x']
positions 'p' "apple"   -- [1,2]
```

### 5.10 String comprehensions

Strings are lists of `Char`, so comprehensions work on them directly:

```haskell
lowers :: String -> Int
lowers xs = length [x | x <- xs, x >= 'a' && x <= 'z']   -- count lowercase letters

count :: Char -> String -> Int
count c s = length [c' | c' <- s, c == c']               -- count occurrences

[c | c <- "Hello World", c /= ' ']                        -- "HelloWorld"
['a'..'z']                                                -- the whole alphabet
```

### 5.11 Caesar cipher (read and understand, don't memorize)

Key pieces (they need `import Data.Char` for `ord`, `chr`, `isLower`):

```haskell
let2int c = ord c - ord 'a'                 -- 'a' -> 0 ... 'z' -> 25
int2let n = chr (ord 'a' + n)
shift n c | isLower c = int2let ((let2int c + n) `mod` 26)   -- wrap around
          | otherwise = c
encode n cs = [shift n c | c <- cs]
rotate n xs = drop n xs ++ take n xs        -- rotate 2 [1,2,3,4] = [3,4,1,2]
```

`crack` decodes by building a letter **frequency table** of the message,
trying all 26 rotations, scoring each one against English frequencies with
**chi-square**, and picking the rotation with the **smallest** score
(`head (positions (minimum chitab) chitab)`). Notice how `where` breaks the
work into named steps.

---

## 6. Chapter 6: Recursive functions

Haskell has no loops, so **recursion** is fundamental.

### 6.1 Base case and recursive case

```haskell
fact1 :: Integer -> Integer
fact1 n = product [1..n]           -- non-recursive

fact2 :: Integer -> Integer
fact2 0 = 1                        -- base case (no recursive call)
fact2 n = n * fact2 (n-1)          -- recursive case
```

- The **base case** stops the recursion, like a loop's exit condition.
  Without it you get infinite recursion (a stack overflow or a hang).
- The recursive call must work on a **smaller** input (`n-1`, or `xs`
  instead of `x:xs`) so it moves toward the base case.
- **Base cases go first.**

### 6.2 The standard list recursion template

```haskell
f []     = <answer for empty list>
f (x:xs) = <combine x with f xs>
```

```haskell
myproduct []     = 1                 -- the identity value for *
myproduct (x:xs) = x * myproduct xs

len []     = 0
len (_:xs) = 1 + len xs              -- x unused, so use _

rev []     = []
rev (x:xs) = rev xs ++ [x]           -- x goes to the END (wrapped in a list!)

append []     ys = ys                -- my own ++
append (x:xs) ys = x : append xs ys
```

**Choosing base-case values:** sum gives `0`, product gives `1`, length gives `0`,
`and`/`all` give `True`, `or`/`any` give `False`, and list-building functions give `[]`.

### 6.3 More recursion patterns (from example.hs and practice.hs)

```haskell
-- two-element base case: last element
mylast [x]    = x
mylast (_:xs) = mylast xs

-- init: drop the last element
myinit [x]    = []
myinit (x:xs) = x : myinit xs

-- conditional recursion with guards: count occurrences
count _ []     = 0
count a (x:xs) | a == x    = 1 + count a xs
               | otherwise = count a xs

-- recursion on two lists at once: zip
myzip [] _          = []
myzip _ []          = []
myzip (x:xs) (y:ys) = (x, y) : myzip xs ys

-- consume two at a time: every other element
everyOther []       = []
everyOther [x]      = [x]
everyOther (x:_:xs) = x : everyOther xs

-- recursion with a counter: take
mytake _ []     = []
mytake n (x:xs) | n <= 0    = []
                | otherwise = x : mytake (n - 1) xs

-- numeric recursion: power
myPow _ 0 = 1
myPow b e = b * myPow b (e - 1)
```

### 6.4 Insert and insertion sort

```haskell
insert :: Ord a => a -> [a] -> [a]      -- assumes the list is already sorted
insert a []     = [a]
insert a (x:xs) | a <= x    = a : x : xs
                | otherwise = x : insert a xs

isort :: Ord a => [a] -> [a]
isort []     = []
isort (x:xs) = insert x (isort xs)

-- the same thing with foldr (from example.hs):
isort' :: Ord a => [a] -> [a]
isort' = foldr insert []
```

**Trace** `isort [3,1,2]`:

```
isort [3,1,2]
= insert 3 (isort [1,2])
= insert 3 (insert 1 (isort [2]))
= insert 3 (insert 1 (insert 2 []))
= insert 3 (insert 1 [2])
= insert 3 [1,2]
= 1 : insert 3 [2]
= 1 : 2 : insert 3 []
= [1,2,3]
```

### 6.5 Selection sort, merge sort, quicksort

```haskell
ssort :: Ord a => [a] -> [a]
ssort [] = []
ssort xs = [m] ++ ssort (remove m xs)    -- smallest first, then sort the rest
  where m = mymin xs

quicksort :: Ord a => [a] -> [a]
quicksort []           = []
quicksort (pivot:rest) = quicksort smalls ++ [pivot] ++ quicksort bigs
  where smalls = filter (<= pivot) rest
        bigs   = filter (>  pivot) rest
-- descending order: swap them, i.e. quicksort bigs ++ [pivot] ++ quicksort smalls

merge :: Ord a => [a] -> [a] -> [a]
merge [] ys = ys
merge xs [] = xs
merge (x:xs) (y:ys) | x <= y    = x : merge xs (y:ys)
                    | otherwise = y : merge (x:xs) ys

mergesort :: Ord a => [a] -> [a]
mergesort []  = []
mergesort [x] = [x]                       -- needed, or [x] would split forever
mergesort xs  = merge (mergesort (take h xs)) (mergesort (drop h xs))
  where h = length xs `div` 2
```

### 6.6 Advice from the notes

- Recursion is **low-level**. Idiomatic Haskell often prefers list
  comprehensions or higher-order functions (`map`, `filter`, `foldr`, `zip`)
  where they fit.
- Recursion with immutable lists is often **less efficient** than loops in
  C++ or Python. The course focuses on correct and readable code, not speed.

---

## 7. Chapter 7: Higher-order functions

**2 hours of class time. Expect a lot of quiz weight here.**

A **higher-order function** takes a function as input and/or **returns** a function.

### 7.1 `twice`: takes a function

```haskell
twice :: (a -> a) -> a -> a
twice f x = f (f x)
-- or: twice f = f . f

twice (+1) 5          -- 7
twice (*2) 5          -- 20
twice reverse "apple" -- "apple"
twice tail "haskell"  -- "skell"
```

Why `(a -> a)` and not `(a -> b)`? Because `f`'s output is fed back into `f`,
so input and output must be the same type.

### 7.2 Returning functions: `makeAdder`

```haskell
makeAdder :: Int -> (Int -> Int)     -- same as Int -> Int -> Int
makeAdder n = (+) n                  -- or (+ n), or \x -> x + n

plus2 = makeAdder 2
plus2 10                             -- 12

makeMultiplier :: Int -> (Int -> Int)
makeMultiplier n = (* n)
map (makeMultiplier 10) [1,2,3]      -- [10,20,30]
```

### 7.3 `flip`

```haskell
flip :: (a -> b -> c) -> b -> a -> c
flip f x y = f y x

(-) 10 6               -- 4
flip (-) 10 6          -- -4   (that is, 6 - 10)
flip map [2,3,4] (+1)  -- [3,4,5]
```

### 7.4 The core list higher-order functions: definitions to know by heart

```haskell
map :: (a -> b) -> [a] -> [b]
map _ []     = []
map f (x:xs) = f x : map f xs

filter :: (a -> Bool) -> [a] -> [a]
filter _ []     = []
filter p (x:xs) | p x       = x : filter p xs
                | otherwise = filter p xs

all :: (a -> Bool) -> [a] -> Bool
all _ []     = True                     -- vacuously true
all p (x:xs) = p x && all p xs

any :: (a -> Bool) -> [a] -> Bool
any _ []     = False
any p (x:xs) = p x || any p xs

takeWhile :: (a -> Bool) -> [a] -> [a]
takeWhile _ []     = []
takeWhile p (x:xs) | p x       = x : takeWhile p xs
                   | otherwise = []           -- STOP at the first failure

dropWhile :: (a -> Bool) -> [a] -> [a]
dropWhile _ []     = []
dropWhile p (x:xs) | p x       = dropWhile p xs
                   | otherwise = x : xs       -- keep EVERYTHING from here on
```

(You can't redefine Prelude names in your own file without hiding them, so
on a quiz call yours `mymap`, `myfilter`, and so on.)

**A predicate** is a function of type `a -> Bool`. If `p x` is `True`,
"`x` satisfies `p`".

**Behaviour comparison (predict-the-output questions):**

| Expression | Result | Why |
|---|---|---|
| `map (*2) [1,2,3]` | `[2,4,6]` | apply to each |
| `filter even [1..10]` | `[2,4,6,8,10]` | keep **all** that pass, anywhere |
| `takeWhile even [2,4,5,6,8]` | `[2,4]` | stops at 5 |
| `dropWhile even [2,4,5,6,8]` | `[5,6,8]` | drops only the **leading** evens. 6 and 8 stay |
| `takeWhile odd [2,4,5]` | `[]` | the first element already fails |
| `all even []` | `True` | vacuous |
| `any even []` | `False` | |
| `all (>0) [1..5]` | `True` | |
| `any (=='e') "horse"` | `True` | |
| `takeWhile (<10) (map (^2) [1..])` | `[1,4,9]` | works on an infinite list |
| `map (*2) (filter odd [1..10])` | `[2,6,10,14,18]` | filter first, then map |

**Small derived functions:**

```haskell
removeIf p = filter (not . p)               -- the opposite of filter
none p xs  = not (any p xs)                 -- equivalently: all (not . p) xs
doublemap f = map (f . f)
countIf p xs = length (filter p xs)
```

### 7.5 Functions that build functions: `change_val`

```haskell
change_val :: Eq a => (a -> b) -> a -> b -> (a -> b)
change_val f x y = \z -> if z == x then y else f z
```

It returns a **new function** that acts like `f`, except at input `x`.
Only `a` needs `Eq`, because only inputs get compared.

### 7.6 `foldr`: the right fold (very important)

**Motivation:** `mysum` and `myprod` share the same structure. Only the base
value (`0` vs `1`) and the operator (`+` vs `*`) differ. So abstract them out:

```haskell
myfoldr :: (a -> b -> b) -> b -> [a] -> b
myfoldr _  v []     = v
myfoldr op v (x:xs) = x `op` (myfoldr op v xs)
```

**The consed-out view (the easiest way to think about it):**
`foldr op v` **replaces every `:` with `op` and the `[]` with `v`**.

```
[2,1,3,4]             = 2 :  (1 :  (3 :  (4 :  [])))
foldr (+) 0 [2,1,3,4] = 2 +  (1 +  (3 +  (4 +  0)))  = 10
foldr (*) 1 [2,1,3,4] = 2 *  (1 *  (3 *  (4 *  1)))  = 24
foldr (-) 0 [2,1,3,4] = 2 -  (1 -  (3 -  (4 -  0)))  = 0
foldr (:) [] xs       = xs        -- replace : with :, [] with [], so no change
foldr (-) 0 [1,2,3]   = 1 - (2 - (3 - 0)) = 1 - (2 - 3) = 1 - (-1) = 2
```

It's a "right" fold because it groups **from the right**: the innermost
(rightmost) operation is evaluated first.

**Deriving the type** `(a -> b -> b) -> b -> [a] -> b`:
- Look at `4 `op` (1 `op` (2 `op` v))`.
- The **result** of `op` is fed into `op`'s **second** argument, so
  `op :: a -> b -> b`.
- `v` sits in a second-argument position, so `v :: b`.
- Every list element is a **first** argument, so the list is `[a]`.
- The final result comes from `op`, so it's `b`.
- (The real `foldr :: Foldable t => (a -> b -> b) -> b -> t a -> b`.
  `Foldable` means "list-like". For lists, `t a` = `[a]`.)

**The recipe for writing X with `foldr`:**
1. Write out `x1 `op` (x2 `op` (x3 `op` init))`.
2. Decide what `init` must be: the answer for `[]`.
3. Decide what `op x acc` must do, where `acc` is **the answer for the rest of the list**.

```haskell
mysum'    xs = foldr (+) 0 xs
myprod'   xs = foldr (*) 1 xs
mylength' xs = foldr (\_ acc -> 1 + acc) 0 xs
mymap   f xs = foldr (\x acc -> f x : acc) [] xs
myrev     xs = foldr (\x acc -> acc ++ [x]) [] xs      -- x goes to the END
myfilter p xs = foldr (\x acc -> if p x then x : acc else acc) [] xs
myall    p xs = foldr (\x acc -> p x && acc) True xs
myany    p xs = foldr (\x acc -> p x || acc) False xs
fcount   n xs = foldr (\x acc -> if x == n then acc + 1 else acc) 0 xs
myconcat xss  = foldr (++) [] xss
isort'        = foldr insert []
```

Notes' style with a `where`:

```haskell
mymap2 f xs = foldr op [] xs
  where op x accum = f x : accum
```

**Trace** `mymap (*10) [1,2]` with `foldr`:

```
foldr op [] (1 : (2 : []))
= 1 `op` (2 `op` [])
= 1 `op` [20]           -- op 2 [] = 2*10 : [] = [20]
= [10,20]               -- op 1 [20] = 10 : [20]
```

### 7.7 `foldl`: the left fold

```haskell
myfoldl :: (a -> b -> a) -> a -> [b] -> a
myfoldl _  v []     = v
myfoldl op v (x:xs) = myfoldl op (v `op` x) xs    -- TAIL recursive
```

```
foldl (+) 0 [1,2,3] = ((0 + 1) + 2) + 3 = 6
foldl (-) 0 [1,2,3] = ((0 - 1) - 2) - 3 = -6
foldr (-) 0 [1,2,3] = 1 - (2 - (3 - 0)) = 2       -- different!
```

**Trace:**

```
myfoldl (+) 0 [1,2,3]
= myfoldl (+) (0+1) [2,3]
= myfoldl (+) ((0+1)+2) [3]
= myfoldl (+) (((0+1)+2)+3) []
= ((0+1)+2)+3
= 6
```

**`foldr` vs `foldl` comparison:**

| | `foldr op v [x1,x2,x3]` | `foldl op v [x1,x2,x3]` |
|---|---|---|
| Shape | `x1 op (x2 op (x3 op v))` | `((v op x1) op x2) op x3` |
| `op`'s type | `a -> b -> b` (element on the **left**, acc on the **right**) | `a -> b -> a` (acc on the **left**, element on the **right**) |
| Signature | `(a -> b -> b) -> b -> [a] -> b` | `(a -> b -> a) -> a -> [b] -> a` |
| Tail recursive? | no | **yes**. The last thing it does is call `foldl`, so tail-call optimization can turn it into a loop |
| Same answer? | yes, for operators like `+` and `*` (associative/commutative) | **different** for `-`, `++ [x]`, and so on |

- **Commutative** means `a + b == b + a`. `+` and `*` are, `-` and `/` aren't.
- Reverse is easy with `foldl`: `foldl (\acc x -> x : acc) [] xs`, or `foldl (flip (:)) []`.
- About infinite lists, see the warning in [§14](#14-errors-and-quirks-in-the-course-notes).

### 7.8 Function composition `(.)`

```haskell
(.) :: (b -> c) -> (a -> b) -> a -> c
(f . g) x = f (g x)            -- "f after g": g runs FIRST
```

```haskell
f n = n^2
g n = 3*n + 1
h = f . g          -- h 1 = f (g 1) = f 4 = 16;  h 2 = 49

((+1) . (*2)) 5    -- (*2) first gives 10, then (+1) gives 11
((*2) . (+1)) 5    -- (+1) first gives 6, then (*2) gives 12
```

- Read it **right to left**: in `f . g . h`, `h` runs first.
- Types must line up: `g`'s **output** type must equal `f`'s **input** type.
- `(.)` is **associative**: `f . (g . h)` = `(f . g) . h`, so no parentheses are needed.
- `id` is the identity for `(.)`: `f . id = id . f = f` (like 1 in multiplication).
- Bracketing matters: `f g 1` = `(f g) 1` is an error. Use `f (g 1)` or `(f . g) 1`.
- `f . g x` parses as `f . (g x)`, because application binds tighter than `.`.
  To apply a composition, write `(f . g) x`.

### 7.9 Point-free style and pipelines

**Point-free** means defining a function **without naming its argument**:

```haskell
h x = (f . g) x        -- pointed
h   = f . g            -- point-free (drop the x from both sides)

sumSquaresEven :: [Int] -> Int
sumSquaresEven = sum . map (^2) . filter even    -- a "function pipeline"
-- reads right to left: filter evens, then square each, then sum

countEvens     = length . filter even
countLongWords = length . filter ((> 3) . length)
sumDoubledEvens = sum . map (*2) . filter even
removeIf p     = filter (not . p)                 -- "negation of predicate p"
count p        = length . filter p                -- count :: (a -> Bool) -> [a] -> Int
twice f        = f . f
thrice f       = f . f . f
opposite       = turnRight . turnRight
```

**How to convert to point-free:** if the definition looks like
`name x = A (B (C x))`, rewrite it as `name = A . B . C`. The argument must be
the **last** thing, appearing **once** on each side.
(`foo x = bar x 5` can't be written point-free this simply, because `x` isn't last.)

### 7.10 The `bits` / `bools` function (very likely on the quiz)

```haskell
bits :: Int -> [String]
bits 0 = [[]]                                -- ONE string: the empty string [""]
bits n = map ('0':) bs ++ map ('1':) bs
  where bs = bits (n - 1)
```

**Idea:** every bit string of length n is either `'0'` followed by a length-(n−1)
string, or `'1'` followed by one. Recursion plus higher-order functions.

**Trace:**

```
bits 0 = [""]
bits 1 = map ('0':) [""] ++ map ('1':) [""]
       = ["0"] ++ ["1"]                    = ["0","1"]
bits 2 = map ('0':) ["0","1"] ++ map ('1':) ["0","1"]
       = ["00","01"] ++ ["10","11"]        = ["00","01","10","11"]
bits 3 = ["000","001","010","011","100","101","110","111"]
```

**Key details:**
- `bits 0 = [[]]` is `[""]`, a list with **one** element (the empty string).
  It is **not** `[]`. If the base case were `[]`, then
  `map ('0':) [] ++ map ('1':) [] = []` and **everything** would be empty.
- `('0':)` is a **section of cons**: "put `'0'` in front". It must be the
  **Char** `'0'`, not the String `"0"`, because the strings are `[Char]`.
- `length (bits n) = 2^n`. `take 3 (bits 10)` is fast thanks to laziness.
- A variant with `[[Bool]]`, from `tautology.hs`:
  `bools n = map (False:) bss ++ map (True:) bss`.
- Generalization: `ternary n` uses 3 maps (`'0'`, `'1'`, `'2'`), giving 3^n strings.

### 7.11 Other useful patterns from `example.hs`

```haskell
agree :: Eq b => (a -> b) -> (a -> b) -> a -> Bool    -- testing helper
agree f g x = f x == g x
check = agree insertion_sort insertion_sort'           -- check "pizza" gives True

range :: Int -> [Int]
range n = take n [0..]          -- uses laziness: range 4 = [0,1,2,3]

type Predicate a = a -> Bool
remove_if :: Predicate a -> [a] -> [a]
remove_if p = filter (not . p)
```

---

## 8. Extended example: Approval voting

### 8.1 The problem

- Each ballot is a **set** of approved candidates. Order doesn't matter and
  **duplicates are ignored**. An empty ballot approves nobody.
- The winner is the candidate who appears on the most ballots.

```
Ballots:  "ABD", "B", "BDB", "", "ABCD"
Counts:   A:2  B:4  C:1  D:3     -->  winner is B
```

**Representation:** a candidate is a `Char`, a ballot is a `String`, and all
the ballots together are a `[String]`.

### 8.2 Strategy (the top-level plan)

1. Remove duplicates **within each ballot**, then join them all into one big string.
2. The candidates are that big string with duplicates removed.
3. Count each candidate's occurrences in the big string.
4. Return `(candidate, count)` pairs sorted from most to fewest votes.

### 8.3 Helpers

```haskell
removeDups :: Eq a => [a] -> [a]
removeDups []     = []
removeDups (x:xs) = if x `elem` xs
                    then removeDups xs          -- a later copy exists, so skip this one
                    else x : removeDups xs

-- foldr version (point-free)
removeDups' :: Eq a => [a] -> [a]
removeDups' = foldr (\x acc -> if elem x acc then acc else x : acc) []

count :: Eq a => a -> [a] -> Int
count v xs = length (filter (== v) xs)          -- keep only the v's, then count them

-- foldr version
count' :: Eq a => a -> [a] -> Int
count' v = foldr (\x acc -> acc + (if x == v then 1 else 0)) 0
```

`removeDups` keeps the **last** occurrence of each element:
`removeDups "BDB" = "DB"`.

Sorting: either write insertion sort, or add `import Data.List` at the top of
the file and use `sort`.

### 8.4 Building it up in GHCi

```haskell
ballots = ["ABD", "B", "BDB", "", "ABCD"]
map removeDups ballots                       -- ["ABD","B","DB","","ABCD"]
concat (map removeDups ballots)              -- "ABDBDBABCD"
removeDups (concat (map removeDups ballots)) -- "ABCD"   (the candidates)
[(count c allVotes, c) | c <- candidates]    -- [(2,'A'),(4,'B'),(1,'C'),(3,'D')]
reverse (sort it)                            -- [(4,'B'),(3,'D'),(2,'A'),(1,'C')]
map (\(x,y) -> (y,x)) it                     -- [('B',4),('D',3),('A',2),('C',1)]
```

**Why `(count, candidate)` and not `(candidate, count)`?** Tuples are compared
lexicographically, **first component first**. Putting the count first makes
`sort` order the pairs by vote count. Then `reverse` gives descending order,
and the final `map` swaps each pair back.

### 8.5 The final function

```haskell
approvalCount :: [String] -> [(Char, Int)]
approvalCount ballots = map (\(x,y) -> (y,x)) results
  where
    allVotes   = concat (map removeDups ballots)
    candidates = removeDups allVotes
    rawCounts  = [(count c allVotes, c) | c <- candidates]
    results    = reverse (sort rawCounts)
```

Skills shown here: top-down decomposition, `where`, `map`, `concat`, list
comprehensions, tuple patterns in lambdas, and the lexicographic tuple-sort trick.

---

## 9. Chapter 8: Declaring types and classes

### 9.1 `type`: a synonym (a new name for an existing type)

```haskell
type String = [Char]                -- from the Prelude
type Predicate a = a -> Bool        -- with a type parameter
type Pos = (Int, Int)
type Assoc k v = [(k, v)]           -- from tautology.hs

remove_if :: Predicate a -> [a] -> [a]
remove_if p lst = filter (not . p) lst
```

- It's like C/C++ `typedef`. It creates **no new type**, so the synonym and
  the original are interchangeable.
- **A `type` can't be recursive**: `type Tree = (Int, [Tree])` is an **error**.
  Use `data` for recursive types.

### 9.2 `data`: a brand-new type

```haskell
data Bool  = True | False            -- how the Prelude defines Bool
data Light = Red | Yellow | Green
  deriving (Eq, Show)
```

- `Red`, `Yellow`, and `Green` are **constructors**. `|` is read "or".
- **The type name and constructor names must be capitalized.**
- `deriving (Eq, Show)` auto-generates `==`/`/=` and `show`. Without `Show`,
  GHCi can't print the values. Without `Eq`, you can't compare them with `==`.
  (`Ord` can also be derived. Constructors are then ordered in declaration order.)
- It's similar to an enum in C++ and Java, but **not OOP**: there's no
  inheritance, no methods, and constructors aren't OOP constructors.

```haskell
change :: Light -> Light
change Red    = Green
change Yellow = Red
change Green  = Yellow

change2 = change . change     -- change2 Red == Yellow
```

**A wrap-around enum** (the Season / Direction pattern):

```haskell
data Direction = North | East | South | West
  deriving (Eq, Show)

turnRight :: Direction -> Direction
turnRight North = East
turnRight East  = South
turnRight South = West
turnRight West  = North           -- wraps around

opposite :: Direction -> Direction
opposite = turnRight . turnRight  -- reuse via composition
```

### 9.3 Constructors with arguments

```haskell
data Shape = Circle Float | Rect Float Float
  deriving Show

-- constructors ARE functions:
-- Circle :: Float -> Shape
-- Rect   :: Float -> Float -> Shape

area :: Shape -> Float
area (Circle r) = pi * r^2         -- pattern match on the constructor, binding its fields
area (Rect w h) = w * h

perimeter :: Shape -> Float
perimeter (Circle r) = 2 * pi * r
perimeter (Rect w h) = 2 * (w + h)

totalArea :: [Shape] -> Float
totalArea shapes = sum (map area shapes)
```

- **Parentheses are required** in the pattern: `area (Circle r)`, not `area Circle r`.
- In OOP you'd write a `Shape` base class with subclasses. Haskell uses
  **one type with several constructors** and no inheritance.

### 9.4 Parameterized types: `Maybe`

```haskell
data Maybe a = Nothing | Just a
```

- `Maybe a` is a box that's either **empty** (`Nothing`) or holds **one** `a` (`Just x`).
- It's used for **safe** functions that might have no answer, so they don't crash:

```haskell
safeHead :: [a] -> Maybe a
safeHead []    = Nothing
safeHead (x:_) = Just x            -- safeHead "apple" = Just 'a'

safeMin :: Ord a => [a] -> Maybe a
safeMin [] = Nothing
safeMin xs = Just (minimum xs)

safeInvert :: Double -> Maybe Double
safeInvert 0 = Nothing
safeInvert x = Just (1 / x)

safeDiv :: Int -> Int -> Maybe Int
safeDiv _ 0 = Nothing
safeDiv m n = Just (m `div` n)

safeLast :: [a] -> Maybe a
safeLast []     = Nothing
safeLast [x]    = Just x
safeLast (_:xs) = safeLast xs
```

- `Just 5` is a `Maybe Int`, **not** an `Int`. You can't write `Just 5 + 1`.
  Unwrap it with pattern matching first.

**Working with `Maybe` values (handle every case):**

```haskell
add1 :: Maybe Double -> Maybe Double -> Double        -- treat Nothing as 0
add1 Nothing  Nothing  = 0
add1 Nothing  (Just n) = n
add1 (Just n) Nothing  = n
add1 (Just m) (Just n) = m + n

add2 :: Maybe Double -> Maybe Double -> Maybe Double  -- Nothing "spreads"
add2 (Just m) (Just n) = Just (m + n)
add2 _        _        = Nothing                      -- shorter than listing all 3 cases

sumMaybes :: [Maybe Int] -> Int                       -- recursion over Maybes
sumMaybes []             = 0
sumMaybes (Nothing : xs) = sumMaybes xs
sumMaybes (Just n  : xs) = n + sumMaybes xs
```

Which `add` is "right" depends on the application.

### 9.5 Recursive types

**Natural numbers:**

```haskell
data Nat = Zero | Succ Nat
  deriving (Eq, Show)
-- values: Zero (0), Succ Zero (1), Succ (Succ Zero) (2), ...

nat2int :: Nat -> Int
nat2int Zero     = 0
nat2int (Succ n) = 1 + nat2int n        -- peel off one Succ

int2nat :: Int -> Nat
int2nat 0 = Zero
int2nat n = Succ (int2nat (n - 1))

int2nat 3   -- Succ (Succ (Succ Zero))
```

**Your own list type:**

```haskell
data List a = Nil | Cons a (List a)

-- Cons 1 (Cons 2 (Cons 3 Nil))   is like   1 : (2 : (3 : []))

first :: List a -> a
first Nil        = error "first: empty list"
first (Cons x _) = x

len :: List a -> Int
len Nil         = 0
len (Cons _ xs) = 1 + len xs

hlist2list :: [a] -> List a
hlist2list = foldr Cons Nil      -- replace : with Cons and [] with Nil

foldright :: (a -> b -> b) -> b -> List a -> b
foldright _  v Nil         = v
foldright op v (Cons x xs) = x `op` foldright op v xs

list2hlist :: List a -> [a]
list2hlist = foldright (:) []    -- replace Cons with : and Nil with []
```

"Cons" comes from **LISP**, where list nodes are called "cons cells".

**Pattern to notice:** functions over a recursive `data` type have **one
equation per constructor**, and they recurse wherever the type refers to itself.

### 9.6 Tautology checker (a "little language" built with data types)

```haskell
data Prop = Const Bool
          | Var Char
          | Not Prop
          | And Prop Prop
          | Imply Prop Prop

type Subst = Assoc Char Bool       -- e.g. [('A',True),('B',False)]

eval :: Subst -> Prop -> Bool      -- one equation per constructor
eval _ (Const b)   = b
eval s (Var x)     = find x s
eval s (Not p)     = not (eval s p)
eval s (And p q)   = eval s p && eval s q
eval s (Imply p q) = eval s p <= eval s q   -- False <= anything is True, so this is implication
```

- `vars` collects the variables, and `bools n` generates every True/False
  assignment.
- A proposition is a **tautology** if `eval` is `True` under **every**
  substitution.
- Takeaway: the **shape of the functions mirrors the shape of the data declaration**.

---

## 10. Intro to do-notation (IO)

### 10.1 Why `IO` exists

A pure function always returns the same output for the same input. So what
would `getStringFromUser` return? It can't be a plain `String`, because the
answer changes every time. Haskell's answer is the **`IO` type**, which
represents a **computation that may have side effects**. A value of type
`IO String` is an *action* that, when run, produces a `String`.

### 10.2 `main` and the key IO functions

```haskell
main :: IO ()                 -- the program entry point
main = do
    putStrLn "Hello, world!"
```

| Function | Type | Does |
|---|---|---|
| `putStrLn` | `String -> IO ()` | prints a line (with newline) |
| `putStr` | `String -> IO ()` | prints without a newline |
| `getLine` | `IO String` | reads a line the user types |
| `print` | `Show a => a -> IO ()` | prints any showable value (`putStrLn . show`) |
| `return ()` | `IO ()` | an action that does **nothing** |
| `randomRIO (1, 6 :: Int)` | `IO Int` | a random number in [1, 6] (needs `import System.Random`) |
| `read` | `Read a => String -> a` | **pure**: parses a string |
| `show` | `Show a => a -> String` | **pure**: converts to a string |

- `()` is the **unit** type/value, the 0-tuple. `IO ()` is like `void` in C:
  you run the action for its side effect, not for a result.

### 10.3 The rules of `do` blocks

```haskell
main :: IO ()
main = do
    putStr "What is your name? "
    name <- getLine                       -- (1) <- runs an IO action and binds its result
    putStr "How many times? "
    numStr <- getLine
    let n = read numStr :: Int            -- (2) let binds a PURE value
    printName name n                      -- (3) the last line must be an IO action

printName :: String -> Int -> IO ()
printName name n =
    if n <= 0
    then return ()                        -- (4) "do nothing" (it does NOT exit early like C's return)
    else do                               -- (5) a nested do for several actions
        putStrLn name
        printName name (n - 1)            -- (6) loops are done with recursion
```

1. **`x <- action`** works **only** with `IO` values. It runs the action and
   names the result. `name <- getLine` gives `name :: String`.
2. **`let x = expr`** is for **pure** values. `n <- read numStr` is **wrong**,
   because `read` doesn't return an `IO`.
3. Statements run **in order**, like C statements.
4. **`return ()` doesn't end the function.** It's just an action that does
   nothing and produces `()`.
5. `if` inside IO still needs **both** `then` and `else`, and **both branches
   must be `IO`** of the same type.
6. To loop, **recurse**, possibly with a counter argument (`rollUntilSix (n + 1)`).
7. Use `show` to put numbers into strings: `"You rolled " ++ show roll`.
   `"x" ++ roll` is a type error.

### 10.4 The example programs (know what each one shows)

| Program | Shows |
|---|---|
| `helloWorld.hs` | `main :: IO ()`, `do`, `putStrLn` |
| `greetUser.hs` | `name <- getLine`, string `++` |
| `repeatName.hs` | `let n = read numStr :: Int`, a recursive IO function, `return ()` |
| `oneRandomRoll.hs` | `import System.Random`, `roll <- randomRIO (1, 6 :: Int)` |
| `threeRandomRolls.hs` | several `<-` binds, `show (roll1 + roll2 + roll3)` |
| `NrandomRolls.hs` | read a count, then **recursive** `rollDice n` with `if n <= 0 then return () else do ...` |
| `rollUntilSix.hs` | recursion with an accumulator counter, `if` inside `do`, stopping on a condition |

```haskell
rollUntilSix :: Int -> IO ()
rollUntilSix n = do
    roll <- randomRIO (1, 6 :: Int)
    putStrLn ("You rolled a " ++ show roll)
    if roll == 6
    then putStrLn ("Got a 6 after " ++ show n ++ " rolls.")
    else rollUntilSix (n + 1)
```

---

## 11. How to work out the most general type

A step-by-step method that works on quiz questions:

1. **Count the arguments.** Each one adds an `->`.
2. **Give each unknown a fresh type variable** (`a`, `b`, ...).
3. **Gather constraints from how values are used:**
   - used with `+ - *` or a numeric literal: `Num a`
   - compared with `==` or `/=`, or matched against a literal: `Eq a`
   - compared with `< <= > >=`, or sorted: `Ord a` (`Ord` already includes `Eq`, so don't write both)
   - `div`, `mod`, `even`, `odd`: `Integral a`
   - `/`, `recip`: `Fractional a`
   - `sqrt`, `pi`: `Floating a`
   - `show`: `Show a`
   - a range `[x..y]`: `Enum a`
4. **Unify:** if two things must be equal (e.g. `f`'s output is fed back into
   `f`), give them the same variable.
5. **Concrete types win:** `length` returns `Int`, `not` needs `Bool`, and
   `'x'` is `Char`.
6. **Don't over-constrain.** Only add constraints that are actually needed.
   (`change_val` needs `Eq a` but **not** `Eq b`.)

**Worked examples:**

| Expression | Most general type | Reasoning |
|---|---|---|
| `('a', True, "cat")` | `(Char, Bool, String)` | a tuple keeps each type. `String` = `[Char]` |
| `(True, "x", 'x')` | `(Bool, String, Char)` | `"x"` (string) vs `'x'` (char) |
| `(:)` | `a -> [a] -> [a]` | an element and a list of the same type |
| `\x y -> x : y` | `a -> [a] -> [a]` | the same as `(:)` |
| `\x -> [x]` | `a -> [a]` | wrap in a list |
| `(++)` | `[a] -> [a] -> [a]` | |
| `map fst` | `[(a, b)] -> [a]` | `fst :: (a,b) -> a` plugged into `map` |
| `filter` | `(a -> Bool) -> [a] -> [a]` | |
| `zip` | `[a] -> [b] -> [(a, b)]` | |
| `twice` | `(a -> a) -> a -> a` | output fed back in |
| `flip` | `(a -> b -> c) -> b -> a -> c` | |
| `(.)` | `(b -> c) -> (a -> b) -> a -> c` | |
| `\x -> x + 1` | `Num a => a -> a` | |
| `\x -> x == 'a'` | `Char -> Bool` | concrete |
| `\xs -> length xs > 2` | `[a] -> Bool` | |
| `sum . map (^2)` | `Num c => [c] -> c` | |
| `outside` (first and last as a pair) | `[a] -> (a, a)` | |
| `middle_test m1 m2 x = m1 x == m2 x` | `Eq a => ([a] -> [a]) -> ([a] -> [a]) -> [a] -> Bool` | |
| `clamp lo hi x` (with `<`, `>`) | `Ord a => a -> a -> a -> a` | |
| `find key table` | `Eq a => a -> [(a,b)] -> [b]` | only keys compared |
| `sign1` (with `==0`, `<0`) | `(Num a, Ord a) => a -> String` | literal `0` gives `Num`, `<` gives `Ord` |
| `fst (1, 'a')` | `Num a => a` | it's a value now, not a function |

**Partial application changes the type.** Remove one input from the front for
each argument you supply:
`take :: Int -> [a] -> [a]`, so `take 3 :: [a] -> [a]`, so `take 3 "hey" :: [Char]`.

---

## 12. Type signature cheat sheet

(These are simplified to lists. GHC shows some with `Foldable t => t a` instead
of `[a]`, e.g. `length`, `sum`, `elem`, `foldr`. Either is accepted in this course.)

```haskell
-- list basics
head, last         :: [a] -> a
tail, init, reverse:: [a] -> [a]
length             :: [a] -> Int
null               :: [a] -> Bool
(!!)               :: [a] -> Int -> a
take, drop         :: Int -> [a] -> [a]
(++)               :: [a] -> [a] -> [a]
(:)                :: a -> [a] -> [a]
concat             :: [[a]] -> [a]
elem               :: Eq a => a -> [a] -> Bool
sum, product       :: Num a => [a] -> a
minimum, maximum   :: Ord a => [a] -> a
and, or            :: [Bool] -> Bool
zip                :: [a] -> [b] -> [(a, b)]
fst                :: (a, b) -> a
snd                :: (a, b) -> b

-- higher-order
map                :: (a -> b) -> [a] -> [b]
filter             :: (a -> Bool) -> [a] -> [a]
all, any           :: (a -> Bool) -> [a] -> Bool
takeWhile          :: (a -> Bool) -> [a] -> [a]
dropWhile          :: (a -> Bool) -> [a] -> [a]
foldr              :: (a -> b -> b) -> b -> [a] -> b
foldl              :: (b -> a -> b) -> b -> [a] -> b
(.)                :: (b -> c) -> (a -> b) -> a -> c
flip               :: (a -> b -> c) -> b -> a -> c
id                 :: a -> a

-- numbers and conversion
(+), (-), (*)      :: Num a => a -> a -> a
negate, abs, signum:: Num a => a -> a
div, mod           :: Integral a => a -> a -> a
even, odd          :: Integral a => a -> Bool
(/)                :: Fractional a => a -> a -> a
(^)                :: (Num a, Integral b) => a -> b -> a
sqrt               :: Floating a => a -> a
fromIntegral       :: (Integral a, Num b) => a -> b
show               :: Show a => a -> String
read               :: Read a => String -> a

-- comparison and logic
(==), (/=)         :: Eq a => a -> a -> Bool
(<), (<=), (>), (>=):: Ord a => a -> a -> Bool
min, max           :: Ord a => a -> a -> a
not                :: Bool -> Bool
(&&), (||)         :: Bool -> Bool -> Bool
error              :: String -> a          -- crashes with a message, fits any type

-- IO
putStrLn, putStr   :: String -> IO ()
getLine            :: IO String
print              :: Show a => a -> IO ()
```

---

## 13. Common bugs and gotchas

These are prime material for "explain the bug" questions.

| Bug | Example | Fix |
|---|---|---|
| **Missing parentheses** around a nested call | `reverse tail reverse xs` means `((reverse tail) reverse) xs`, a type error | `reverse (tail (reverse xs))` |
| **Negative literal** without parentheses | `signum -3` (parsed as `signum - 3`) | `signum (-3)` |
| **Recursing on the element instead of the rest** | `mylength (x:xs) = 1 + mylength x` | `... + mylength xs` |
| **Recursing on the same value** (no progress, infinite recursion) | `nat2int_bad n = 1 + nat2int_bad n` | match `(Succ n)` and recurse on `n` |
| **`if` without `else`** | `if n `mod` 2 == 0 then True` | add `else`. Better: just `n `mod` 2 == 0` |
| **`mod` used infix without backticks** | `n mod 2` | ``n `mod` 2`` or `mod n 2` |
| **`/` on Ints** | `sum xs / length xs` where `length :: Int` | use `` `div` ``, or `fromIntegral` to convert |
| **Missing class constraint** | `sign_bug1 :: Num a => ...` uses `<` | `(Num a, Ord a) =>` |
| **Comparing without `Eq`** | `f :: [a] -> ...` with `x == y` | add `Eq a =>` |
| **A guard that isn't a Bool** | `| 1 = "penny"` | `| n == 1 = ...`, or use literal patterns |
| **Repeated variable in a pattern** | `same a a = True` | `same a b = a == b` |
| **Catch-all equation first** | `f _ _ = False` before `f a b = ...` | put specific equations first |
| **Equation ignores the data** | `diff_heads (x:_) (y:_) = False` never compares x and y | `= x /= y` (and add `Eq a`) |
| **No base case, or the wrong one** | `myinit (x:xs) = x : myinit xs` with no `[x]` case copies the whole list | add `myinit [x] = []` |
| **`bits 0 = []`** instead of `[[]]` | every result becomes empty | `bits 0 = [""]`, or add a base case at 1 |
| **`("0":)` instead of `('0':)`** | conses a String onto a String, a type error | use the Char `'0'` |
| **`:` used to append at the end** | `xs : x` | `xs ++ [x]` |
| **`[x]` vs `x`** in `++` | `rev xs ++ x` | `rev xs ++ [x]` |
| **Uppercase variable name** | `E = 2.718` | lowercase `e` |
| **Lowercase type or constructor** | `data shape = circle Float` | `data Shape = Circle Float` |
| **No parentheses around a constructor pattern** | `area Circle r = ...` | `area (Circle r) = ...` |
| **`filter` on an infinite list** expecting it to stop | `filter (<10) [1..]` hangs | `takeWhile (<10) [1..]` |
| **`<-` with a pure value** in `do` | `n <- read s` | `let n = read s :: Int` |
| **Using the Prelude version instead of your own in recursion** | `myfilter p (x:xs) = ... filter p xs` | call `myfilter` (on a quiz, don't call the function you're implementing) |
| **Missing `Show`** when printing a custom type | `> Red` gives "No instance for Show" | add `deriving Show` |
| **`f . g x`** expecting a composition applied to `x` | parses as `f . (g x)` | `(f . g) x` |
| **Tabs** in source | layout errors | use spaces |

---

## 14. Errors and quirks in the course notes

These are worth knowing so they don't confuse you. If a quiz question hinges
on one of them, **ask the instructor**.

1. **Ch 3, `Int` range:** written as "−2⁶³ to −2⁶³−1". It should be
   **−2⁶³ to 2⁶³−1**.
2. **Ch 5, `fb_rule`:** returns `"Buzz"` for multiples of 3 and `"Fizz"` for
   multiples of 5. Standard FizzBuzz (and `practice.hs` #10) is **Fizz = 3,
   Buzz = 5**.
3. **Ch 5, `primes`:** uses `isPrime` but the function above it is named
   `is_prime`. It's just a typo.
4. **Ch 5, twin primes challenge:** mentions `primesUpto`, which isn't defined.
   Define it as `takeWhile (<= n) primes`.
5. **Ch 7, `myfilter`:** the recursive calls are to the built-in `filter`,
   not `myfilter`. On a quiz, recurse on your own function.
6. **Ch 7, foldl/foldr and infinite lists:** the notes say "`foldl` can work
   with infinite lists in some cases ... `foldr` cannot". **In real GHC it's
   the other way around.**
   - `foldr` *can* finish on an infinite list if `op` doesn't always need its
     second argument. For example, `foldr (\x acc -> x > 10 || acc) False [1..]`
     returns `True`, and `take 3 (foldr (:) [] [1..])` = `[1,2,3]`.
   - `foldl` **never** finishes on an infinite list, because it has to reach
     the end of the list before returning anything.
   - Know the notes' claim in case it's asked, but be aware of the real behaviour.
7. **Approval voting, point-free `count` with `where`:** the `where` is shown
   at column 0. It needs to be indented.
8. **Your `example.hs`:** `nthPrime n = primes !! n` is off by one, because
   `!!` is 0-indexed. The solution file uses `primes !! (n - 1)`, so
   `nthPrime 1 = 2`.
9. **Ch 7:** `none` says "then `true` is returned". In Haskell it's `True`
   (capitalized). That's leftover from Racket notes.

---

## 15. Practice map: what to drill

### 15.1 Practice files and where their solutions are

| File | Solutions | Notes |
|---|---|---|
| `haskell/practice.hs` (39 problems) | `haskell/practice_sol.hs` | the best match for the quiz style. Do all 39 |
| `haskell/example.hs` (lecture code) | `haskell/example_sol.hs` | redo the "fill in" parts from memory |
| Ch 4–7 practice question sheets | **[§16](#16-worked-solutions-to-the-in-notes-challenges)** of these notes | the "challenge" problems from the notes |
| `haskell/Haskell_problemset.md` (15 Qs) | **intentionally not solved here** | the instructor asks you to treat it as a **non-AI activity**, and says the quiz is mainly variations of it. Post your answers on the discussion board |

### 15.2 `practice.hs` problems by topic

| Topic | Problem numbers |
|---|---|
| Recursion on lists | 1–9 |
| Guards, if, patterns | 10–13 |
| Lambdas, sections, composition | 14–16, 21 |
| Implementing HOFs (filter/all/any) | 17–19 |
| foldr | 20 |
| Sorting | 22–25 |
| Laziness and infinite lists | 26–31 |
| Data types and Maybe | 32–36 |
| Predict, types, explain bugs | 37–39 |

### 15.3 `Haskell_problemset.md`: which section of these notes each question uses

(These are concept pointers only, no answers.)

| Q | Concept | Review |
|---|---|---|
| 1 | `take`/`drop`/`reverse`/`tail`/`zip` | §2.1, §5.9 |
| 2 | patterns / list functions | §2.7, §4.5, §6.3 |
| 3 | most general types | §11 |
| 4 | currying explanation | §3.6 |
| 5 | guarded equations (order!) | §4.3 |
| 6 | takeWhile/dropWhile | §7.4 |
| 7 | explain the bug | §3.10, §13 |
| 8 | sections vs lambdas | §4.8 |
| 9 | comprehensions with multiple generators and guards | §5.2–5.5 |
| 10 | comprehension guards with `mod` | §5.5 |
| 11 | numeric recursion with a base case | §6.1, §6.3 |
| 12 | point-free pipeline | §7.9 |
| 13 | foldr to a Bool | §7.6 |
| 14 | data declaration with wrap-around | §9.2 |
| 15 | comprehension over `['a'..'z']` and counting | §5.10, §8.3 |

### 15.4 Study plan

1. Read §1–§10 of these notes once, typing the examples into GHCi.
2. Do `practice.hs` **without looking**, then check with `practice_sol.hs`.
3. Do the in-notes challenges (Ch 4–8), then check §16.
4. Do `Haskell_problemset.md` by yourself.
5. On paper, without GHCi: trace `bits 3`, `isort [3,1,2]`,
   `foldr (-) 0 [1,2,3]`, `foldl (-) 0 [1,2,3]`, and `mysum [1,2,3]`.
6. Review §11 (types), §13 (bugs), and §17 (checklist) the night before.

---

## 16. Worked solutions to the in-notes challenges

> Try each one first! Expand only to check your answer.
> (All of these were checked with GHC 9.)

### Chapter 4: Defining functions

<details><summary><b>Explain the bug: <code>middle_bug1</code></b></summary>

`reverse tail reverse xs` is read as `((reverse tail) reverse) xs`, because
application is left-associative. That passes the *function* `tail` to
`reverse`, which is a type error. Fix it with parentheses:

```haskell
middle_bug1 (_:xs) = reverse (tail (reverse xs))
```
</details>

<details><summary><b>Challenge: <code>outside</code></b></summary>

```haskell
outside :: [a] -> (a, a)
outside []  = error "outside: list must have 2 or more elements"
outside [_] = error "outside: list must have 2 or more elements"
outside xs  = (head xs, last xs)
```
</details>

<details><summary><b>Challenge: <code>middle2</code> (no reverse)</b></summary>

```haskell
middle2 :: [a] -> [a]
middle2 []     = []
middle2 [_]    = []
middle2 (_:xs) = init xs              -- or: take (length xs - 1) xs
```
</details>

<details><summary><b>Challenge: <code>middle_test</code></b></summary>

```haskell
middle_test :: Eq a => ([a] -> [a]) -> ([a] -> [a]) -> [a] -> Bool
middle_test m1 m2 x = m1 x == m2 x
```
</details>

<details><summary><b>Challenges: <code>pluralize2</code>, <code>pluralize_test</code>, <code>pluralize3</code></b></summary>

```haskell
pluralize2 :: String -> String
pluralize2 s = if null s || last s == 's' then s else s ++ "s"

pluralize_test :: (String -> String) -> (String -> String) -> String -> Bool
pluralize_test p1 p2 s = p1 s == p2 s

pluralize3 :: String -> String
pluralize3 "" = ""
pluralize3 w | last w == 's' = w
             | last w == 'y' = init w ++ "ies"
             | otherwise     = w ++ "s"
```
</details>

<details><summary><b>Explain the bug: <code>sign_bug1</code></b></summary>

The function uses `<`, which needs `Ord`, but the signature only says `Num a`.
`Num` doesn't include `Ord` (or `Eq`). Fix the signature:
`sign_bug1 :: (Num a, Ord a) => a -> String`. (`Ord` includes `Eq`, so `==` is covered too.)
</details>

<details><summary><b>Challenge: <code>sign2</code> (if-then-else)</b></summary>

```haskell
sign2 :: (Num a, Ord a) => a -> [Char]
sign2 n = if n == 0 then "zero"
          else if n < 0 then "negative"
          else "positive"
```
</details>

<details><summary><b>Challenge: Heron's formula</b></summary>

```haskell
heron_area :: (Floating a, Ord a) => a -> a -> a -> a
heron_area a b c
  | a <= 0    = error "heron_area: a must be positive"
  | b <= 0    = error "heron_area: b must be positive"
  | c <= 0    = error "heron_area: c must be positive"
  | otherwise = sqrt (s * (s-a) * (s-b) * (s-c))
  where s = (a + b + c) / 2
-- heron_area 4 13 15 == 24.0
```
(`Double -> Double -> Double -> Double` is also fine if you don't need the most general type.)
</details>

<details><summary><b>Challenge: <code>coin2</code></b></summary>

```haskell
coin2 :: Int -> String
coin2 1  = "penny"
coin2 5  = "nickel"
coin2 10 = "dime"
coin2 25 = "quarter"
coin2 n  = show n ++ " is an unknown coin"   -- name the value instead of _
```
</details>

<details><summary><b>Explain the bug: <code>coin_bug1</code></b></summary>

Guards must be `Bool` expressions, but `1`, `5`, and so on are numbers. Write
`| n == 1 = "penny"`, `| n == 5 = "nickel"`, ..., or use literal patterns like `coin1`.
</details>

<details><summary><b>Explain the bug: <code>same_bug1</code></b></summary>

Two problems. (1) A variable can't appear twice in one pattern
(`same_bug1 a a`), so it's a compile error ("conflicting definitions").
(2) Even if it compiled, the `_ _` equation comes first and matches
everything, so it would always return `False`. Fix:

```haskell
same :: Int -> Int -> Bool
same a b = a == b
```
</details>

<details><summary><b>Challenge: <code>short_length</code></b></summary>

```haskell
short_length :: [a] -> Int
short_length []      = 0
short_length [_]     = 1
short_length [_,_]   = 2
short_length [_,_,_] = 3
short_length _       = -1
```
</details>

<details><summary><b>Challenge: consed-out "apple"</b></summary>

`'a' : 'p' : 'p' : 'l' : 'e' : []`
</details>

<details><summary><b>Explain the bug: <code>diff_heads_bug1</code></b></summary>

The third equation returns `False` for **any** two non-empty lists without
comparing the heads, and the fourth equation can never be reached. Comparing
also needs `Eq a`:

```haskell
diff_heads :: Eq a => [a] -> [a] -> Bool
diff_heads (x:_) (y:_) = x /= y
diff_heads _     _     = True
```
</details>

<details><summary><b>Challenges: reciprocals and fourth powers</b></summary>

```haskell
map (1/) [1,2,4,5]            -- [1.0,0.5,0.25,0.2]

h :: (Ord a, Num a, Enum a) => a -> a
h n | n <= 0    = error "h: n must be positive"
    | otherwise = sum (map (^4) [1..n])
-- h 2 == 17, h 3 == 98, h 100 == 2050333330
```
</details>

### Chapter 5: List comprehensions

<details><summary><b>Bit patterns of length 4 and <code>patterns4</code></b></summary>

```haskell
[(a,b,c,d) | a <- [0,1], b <- [0,1], c <- [0,1], d <- [0,1]]

patterns4 :: a -> a -> [(a, a, a, a)]
patterns4 s t = [(w,x,y,z) | w <- [s,t], x <- [s,t], y <- [s,t], z <- [s,t]]
```
</details>

<details><summary><b>Some sums 1 and 2</b></summary>

```haskell
[x + y | x <- [1..10], y <- [1..10]] :: [Int]
[(x, y, x + y) | x <- [1..10], y <- [1..10]] :: [(Int,Int,Int)]
```
</details>

<details><summary><b><code>sums_to</code></b></summary>

```haskell
sums_to :: Int -> [(Int, Int)]
sums_to n = [(a, b) | a <- [1..n], b <- [a..n], a + b == n,
                      a `mod` 5 /= 0, b `mod` 5 /= 0]
```
</details>

<details><summary><b><code>numPrimesUpto</code></b></summary>

```haskell
numPrimesUpto :: Int -> Int
numPrimesUpto n = length (takeWhile (<= n) primes)   -- 100 gives 25, 1000 gives 168
```
</details>

<details><summary><b><code>keys</code> and <code>values</code></b></summary>

```haskell
keys :: [(a, b)] -> [a]
keys table = [k | (k, _) <- table]

values :: [(a, b)] -> [b]
values table = [v | (_, v) <- table]
```
</details>

<details><summary><b><code>twinPrimesUpto</code></b></summary>

```haskell
primesUpto :: Int -> [Int]
primesUpto n = takeWhile (<= n) primes

twinPrimesUpto :: Int -> [(Int, Int)]
twinPrimesUpto n = [(p, q) | (p, q) <- zip ps (tail ps), q == p + 2]
  where ps = primesUpto n
```
</details>

### Chapter 6: Recursive functions

<details><summary><b><code>sqr_sum</code> and <code>odd_fact</code></b></summary>

```haskell
sqr_sum :: (Eq a, Num a) => a -> a      -- the literal pattern 1 needs Eq
sqr_sum 1 = 1
sqr_sum n = n * n + sqr_sum (n - 1)

odd_fact :: Integer -> Integer
odd_fact 1 = 1
odd_fact n | odd n     = n * odd_fact (n - 2)
           | otherwise = odd_fact (n - 1)
-- odd_fact 10 == 945, odd_fact 20 == 654729075
```
</details>

<details><summary><b><code>count</code> (recursive)</b></summary>

```haskell
count :: Eq a => a -> [a] -> Int
count _ []     = 0
count a (x:xs) | a == x    = 1 + count a xs
               | otherwise = count a xs
```
</details>

<details><summary><b>Selection sort: <code>remove</code> and <code>mymin</code></b></summary>

```haskell
remove :: Eq a => a -> [a] -> [a]          -- removes only the FIRST occurrence
remove _ []     = []
remove m (x:xs) | m == x    = xs
                | otherwise = x : remove m xs

mymin :: Ord a => [a] -> a
mymin [x]    = x
mymin (x:xs) = if x < m then x else m
  where m = mymin xs
```
</details>

<details><summary><b><code>is_unique</code> and <code>uniquify</code></b></summary>

```haskell
is_unique :: String -> Bool
is_unique (x:y:rest) = x /= y && is_unique (y:rest)
is_unique _          = True                 -- 0 or 1 characters

uniquify :: String -> String
uniquify (x:y:rest) | x == y    = uniquify (y:rest)       -- drop the duplicate
                    | otherwise = x : uniquify (y:rest)
uniquify s = s
-- uniquify "aaaabccddd" == "abcd"
```
(`Eq a => [a] -> Bool` and `Eq a => [a] -> [a]` are the most general types.)
</details>

### Chapter 7: Higher-order functions

<details><summary><b><code>doublemap</code>, <code>removeIf</code>, <code>none</code></b></summary>

```haskell
doublemap :: (a -> a) -> [a] -> [a]
doublemap f = map (f . f)

removeIf :: (a -> Bool) -> [a] -> [a]
removeIf p = filter (not . p)

none :: (a -> Bool) -> [a] -> Bool
none p xs = not (any p xs)
```
</details>

<details><summary><b><code>change_val</code></b></summary>

```haskell
change_val :: Eq a => (a -> b) -> a -> b -> (a -> b)
change_val f x y = \z -> if z == x then y else f z
```
</details>

<details><summary><b><code>fcount</code> with foldr</b></summary>

```haskell
fcount :: Int -> [Int] -> Int
fcount n lst = foldr (\x acc -> if x == n then acc + 1 else acc) 0 lst
```
</details>

<details><summary><b>Point-free <code>count</code></b></summary>

```haskell
count :: (a -> Bool) -> [a] -> Int
count p = length . filter p
-- fully point-free (harder to read): count = (length .) . filter
```
</details>

### Chapter 8: Declaring types and classes

<details><summary><b><code>safeInvert</code></b></summary>

```haskell
safeInvert :: Double -> Maybe Double
safeInvert 0 = Nothing
safeInvert x = Just (1 / x)
```
</details>

<details><summary><b>Explain the bug: <code>nat2int_bad</code></b></summary>

The second equation calls `nat2int_bad n` on the **same** `n`, so the input
never shrinks and it recurses forever on anything except `Zero`. It should peel
off one `Succ`:

```haskell
nat2int (Succ n) = 1 + nat2int n
```
</details>

<details><summary><b>Explain the bug: <code>bools_bug</code></b></summary>

`("0":)` tries to cons the **String** `"0"` onto each element, but the
elements are Strings (`[Char]`), so the thing being consed must be a
**Char**. That's a type error. Use `('0':)` and `('1':)`.
</details>

<details><summary><b><code>bools2</code> with <code>bools2 0 = []</code></b></summary>

If the base case at 0 becomes `[]`, the recursive case would map over an
empty list and everything would collapse to `[]`. So add a separate base case at 1:

```haskell
bools2 :: Int -> [String]
bools2 0 = []
bools2 1 = ["0", "1"]
bools2 n = map ('0':) bs ++ map ('1':) bs
  where bs = bools2 (n - 1)
```
</details>

---

## 17. Quiz-day checklist

- [ ] I can explain **pure function**, **lazy evaluation**, **type inference**,
      **currying**, **higher-order function**, **closure**, **point-free**,
      **total function**, **polymorphic** and **overloaded** type, and
      **class constraint**, each in 1–2 sentences.
- [ ] I know the edge cases of `head`/`tail`/`take`/`drop`/`!!`/`zip` on
      short or empty lists.
- [ ] `->` is right-associative, application is left-associative, and
      application binds tighter than any operator.
- [ ] Lists hold **one** type and any length. Tuples have **fixed** arity and mixed types.
- [ ] I can write the most general type, with **only** the constraints needed
      (`Eq`, `Ord`, `Num`, `Integral`, `Fractional`, `Show`).
- [ ] `div`/`mod` are for Ints, `/` is for fractional types, and
      `fromIntegral` converts between them.
- [ ] `if` always has `else`. Guards are top to bottom, with `otherwise` last.
      Pattern equations are top to bottom with the catch-all last.
- [ ] Sections: `(/2)` ≠ `(2/)`, and `(-1)` is a number.
- [ ] Comprehensions: later generators vary fastest, and guards are ANDed.
- [ ] Recursion: base case first, and the recursive call is on a smaller input (`xs`, `n-1`).
- [ ] I can write `map`/`filter`/`all`/`any`/`takeWhile`/`dropWhile` from scratch.
- [ ] `foldr` replaces `:` with `op` and `[]` with `v`. `op x acc`, where acc
      is the answer for the rest of the list.
- [ ] `foldr (-) 0 [1,2,3] = 2` and `foldl (-) 0 [1,2,3] = -6`.
- [ ] `(f . g) x = f (g x)`, so `g` runs first. Pipelines read right to left.
- [ ] `bits 0 = [""]`, not `[]`. `('0':)`, not `("0":)`.
- [ ] `type` is a synonym (can't be recursive). `data` makes a new type.
      Constructors are capitalized and are functions.
      `deriving (Eq, Show)`.
- [ ] `Maybe`: `Nothing` / `Just x`, and I handle every case by pattern matching.
- [ ] One equation per constructor for functions over `data` types.
- [ ] `do`: `x <- ioAction`, `let x = pureExpr`, `return ()` does nothing,
      loops use recursion, and numbers go through `show` before `++`.

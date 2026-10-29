# Tiny Lisp Intro — Study Notes

> Notes on all of [tiny_lisp_intro.md](tiny_lisp_intro.md). They cover:
> Overview, Data Types & Arithmetic, Logical Operators, Symbols, Predicates,
> Lists & Pairs, Special Forms, Recursive List Functions, Accumulators,
> `map`/`filter`/`all`, Folding, Sorting, Flatten & Deep Functions, Closures,
> Composition, Currying, Combinators, and the Symbolic Programming case study.
>
> 🎯 **Studying for the Tiny Lisp quiz?** Start with **§21 Quiz Prep**: rules,
> what you can and can't use, templates, and worked solutions to every practice
> and problem-set question.

---

## 0. Big Picture

- **Tiny Lisp** is a small Lisp dialect made for teaching.
- It is a **subset of Racket**, so every Tiny Lisp program is also a valid Racket program.
- The whole language is small enough to list in one place:

| Category | Members |
|---|---|
| Basic data types | symbols, numbers (integers, floats, rationals), booleans, lists, pairs |
| Arithmetic / comparison operators | `+` `-` `*` `/` `<=` `>=` `<` `>` `=` |
| Math functions | `sqrt`, `sin`, `cos` |
| Logical operators | `and`, `or`, `not` |
| Error handling | `error` |
| Predicates | `equal?`, `symbol?`, `number?`, `boolean?`, `list?`, `pair?`, `even?`, `odd?` (plus `empty?`) |
| List functions | `empty?`, `first`, `rest`, `cons`, `list` |
| Special forms | `quote`, `cond`, `else`, `let`, `let*`, `define`, `lambda` |

**Exam tip:** be able to sort any keyword into **function** or **special form**.
The difference comes down to *how arguments get evaluated* (see §6).

> 🎯 **Quiz:** this table is the **complete** list of what you may use without
> defining it yourself. `length`, `append`, `map`, `filter`, `foldr`, `member?`,
> `second`, `third`, `reverse`, `if`, `eq?` and `max` are **not** in Tiny Lisp.
> If you use one, you must write its definition on the quiz too. See **§21**.

---

## 1. Basic Data Types & Arithmetic

### 1.1 Prefix notation
- Every operation is written in **prefix** form: `(operator operand1 operand2 ...)`.
- The operator **always comes first**, inside the parentheses.

| Infix (math) | Tiny Lisp | Result |
|---|---|---|
| 1 + 2 | `(+ 1 2)` | `3` |
| 10 − 5 | `(- 10 5)` | `5` |
| 2 × 3 | `(* 2 3)` | `6` |
| 10 ÷ 2 | `(/ 10 2)` | `5` |
| 5 ≤ 10 | `(<= 5 10)` | `#t` |
| 10 ≥ 5 | `(>= 10 5)` | `#t` |

### 1.2 Operators take more than two operands
Arithmetic and comparison operators are **variadic**: they accept any number of arguments.

```lisp
> (+ 1 2 3)            ; 1 + 2 + 3
6
> (* 2 3 4)            ; 2 * 3 * 4
24
> (/ 100 2 2)          ; (100 / 2) / 2  — evaluated left to right
25
> (< 1 2 3 6 10 20)    ; strictly increasing?  1<2<3<6<10<20
#t
> (> 10 9 4 5)         ; strictly decreasing?  4 > 5 fails
#f
> (= 5 5 5)            ; all equal?
#t
> (= 5 5 6 5 5 5)      ; one 6 breaks it
#f
```

**Key idea:** with several arguments, a comparison like `(< a b c d)` means
`a < b` **and** `b < c` **and** `c < d`, so it checks the whole chain.
- `<` → strictly increasing
- `>` → strictly decreasing
- `=` → all the same

### 1.3 Rational numbers
- Tiny Lisp has exact **fractions** (rationals). `1/2` is a *literal* meaning one half.

```lisp
> (+ 1/2 1/3)
5/6
> (* 1/2 1/2)
1/4
```

- Dividing integers gives an exact rational, not a rounded decimal:

```lisp
> (/ 1 2)
1/2
> (/ 10 4)
5/2          ; reduced to lowest terms, not 2.5
```

**Literal vs. expression:**

| Code | What it is |
|---|---|
| `1/2` | a **literal** rational number (a value as written) |
| `(/ 1 2)` | an **expression**: a call to `/` with arguments `1` and `2` (it evaluates to `1/2`) |

### 1.4 Math functions: `sqrt`, `sin`, `cos`

```lisp
> (sqrt 2)
1.4142135623730951
> (sin 45)          ; 45 *radians*, not degrees
0.8509035245341184
> (cos 80)
-0.11038724383904756
```

- These return **floating-point** (inexact) numbers.
- The trig functions use **radians**.
- Floating-point rounding shows up: sin²(x) + cos²(x) should be exactly 1, but:

```lisp
> (+ (* (sin 19) (sin 19))
     (* (cos 19) (cos 19)))
0.9999999999999999
```

### 1.5 Formatting
- Line breaks and indentation **do not change the meaning**. Use them to make nested expressions readable.
- Line up arguments that belong to the same call, as in the example above.

---

## 2. Logical Operators

### 2.1 Booleans
- `#t` = true, `#f` = false.

### 2.2 `and`, `or`, `not`

```lisp
> (and #t #t)              → #t
> (and #t #f)              → #f
> (and (= 2 2) (< 4 10))   → #t

> (or #t #f)               → #t
> (or #f #f)               → #f
> (or (= 2 5) (< 4 10))    → #t

> (not #t)                 → #f
> (not (= 2 4))            → #t
```

- `and` and `or` take **any number** of operands:

```lisp
> (and #t #t #t)      → #t
> (or #f #f #t #f)    → #t
```

- `not` takes exactly **one** operand.

### 2.3 Short-circuit evaluation (important!)

| Operator | Evaluation rule |
|---|---|
| `(and e1 e2 ...)` | Evaluate left to right. **Stop at the first `#f`** and return `#f`. The remaining expressions are **not evaluated**. If none is `#f`, return `#t`. |
| `(or e1 e2 ...)` | Evaluate left to right. **Stop at the first `#t`** and return `#t`. The remaining expressions are **not evaluated**. If none is `#t`, return `#f`. |

`(error "oops!")` raises an error when it is evaluated, so it shows whether an
expression actually ran:

```lisp
> (and #f (error "oops!"))   ; stops at #f → error never runs
#f
> (or #t (error "oops!"))    ; stops at #t → error never runs
#t   ; (the source file prints #f here, but that is a typo: or returns #t)

> (and #t (error "oops!"))   ; #t isn't enough, so it keeps going → error runs
. . oops!
> (or #f (error "oops!"))    ; #f isn't enough, so it keeps going → error runs
. . oops!
```

> ⚠️ **Typos in the source:**
> 1. The `or` example shows `#f` as the result of `(or #t (error "oops!"))`. It should be `#t`.
> 2. The `or` rule says "does not evaluate the expressions after the first
>    *false* one". It should say "after the first **true** one".

### 2.4 Consequence: order matters
- `(and a b)` and `(and b a)` **can give different results**, and the same goes for `or`.
- Example: `(and #f (error "x"))` → `#f`, but `(and (error "x") #f)` → error.
- **Common use:** put a guard first so the risky check only runs when it is safe, e.g.
  `(and (number? n) (> n 0))`. If `n` is not a number, `>` is never called on it.

> 📝 **Racket nuance (beyond Tiny Lisp):** in full Racket, `and`/`or` return the
> actual value that decided the result, not only `#t`. For example, `(or #f 5)`
> → `5` and `(and 1 2)` → `2`. Tiny Lisp's description simplifies this to
> `#t`/`#f`.

> 📝 Because `and`/`or` don't always evaluate every argument, they behave like
> **special forms** rather than ordinary functions (see §6).

---

## 3. Symbols

### 3.1 What is a symbol?
- A **symbol** is a data value that represents a **name**.
- It is written with a leading single quote: `'cat`, `'hamster`, `'mouse`.
- Symbols **evaluate to themselves**:

```lisp
> 'cat
'cat
> 'hamster
'hamster
```

### 3.2 Comparing symbols
- Use `equal?` to check whether two symbols are the same:

```lisp
> (equal? 'cat 'cat)      → #t
> (equal? 'cat 'hamster)  → #f
```

### 3.3 Rules for symbols
| ✅ You can | ❌ You can't / shouldn't |
|---|---|
| Test equality with `equal?` | Compare order with `<`, `>`, `<=`, `>=` |
| Use them as names or tags (e.g. `'positive`, `'negative`) | Add or concatenate them |
| | Treat them as **strings** (no pulling out letters, no storing text) |

- Symbols are also called **atoms**.
- **Symbol vs. string:** a symbol is a single, indivisible name. A string is a sequence of characters. Don't mix them up.

---

## 4. Predicate Functions

### 4.1 Definition
- A **predicate** is a function that returns a **boolean** (`#t` or `#f`).
- By convention, predicate names **end in `?`**.

### 4.2 Built-in predicates

| Predicate | Returns `#t` when… | Examples |
|---|---|---|
| `(number? x)` | `x` is a number (integer, float, or rational) | `(number? 4)` → `#t`, `(number? 4.0)` → `#t`, `(number? 4/5)` → `#t`, `(number? +)` → `#f` (`+` is a **function**) |
| `(even? x)` | `x` is an even number | `(even? 4)` → `#t`, `(even? 5)` → `#f` |
| `(odd? x)` | `x` is an odd number | `(odd? 4)` → `#f`, `(odd? 5)` → `#t` |
| `(boolean? x)` | `x` is `#t` or `#f` | `(boolean? #t)` → `#t`, `(boolean? #f)` → `#t`, `(boolean? 4)` → `#f`, `(boolean? 'false)` → `#f` |
| `(symbol? x)` | `x` is a symbol | `(symbol? 'cat)` → `#t`, `(symbol? 4)` → `#f` |
| `(equal? x y ...)` | **all** arguments are equal (any number of args) | `(equal? 'cat 'dog)` → `#f`, `(equal? 4 4 4 (* 2 2))` → `#t` |
| `(empty? x)` | `x` is the empty list `'()` | see §5 |
| `(list? x)` | `x` is a list | see §5 |
| `(pair? x)` | `x` is a pair (a cons cell) | see §5 |

### 4.3 Gotchas
- `(number? +)` → `#f`: `+` is a **function value**, not a number.
- `(boolean? 'false)` → `#f`: `'false` is a **symbol** that happens to be spelled "false". Only `#t` and `#f` are booleans.
- `equal?` evaluates its arguments first, so `(* 2 2)` becomes `4` before the comparison.
- `(not (equal? 'cat 'dog))` → `#t` is the usual way to write "not equal".
- (The source writes `(even <expr>)`/`(odd <expr>)` without the `?`. The real names are `even?` and `odd?`.)

---

## 5. Lists

### 5.1 List literals
- A **list** is a sequence of **zero or more** elements, written inside parentheses.
- A **quote** `'` in front makes it a **list literal (data)** instead of a **function call (code)**.

```lisp
> (* 2 3 0)        ; code: call * on 2, 3, 0
0
> '(* 2 3 0)       ; data: a list of 4 elements: the symbol *, then 2, 3, 0
'(* 2 3 0)
```

```lisp
> '(carol has no hat today)
'(carol has no hat today)
> (carol has no hat today)
. . carol: undefined;
 cannot reference an identifier before its definition
```

- **Without the quote**, Lisp reads `(carol has no hat today)` as a call to the
  function `carol` with arguments `has`, `no`, `hat`, `today`. There is no
  function named `carol`, so it raises an error.
- **Core Lisp idea: code and data look the same** (homoiconicity). The quote is
  what decides whether a parenthesized form is run or kept as data.

### 5.2 Nesting
- Lists can hold any data, including **other lists**:

```lisp
> '(my lucky numbers are (2 3 and -4))
'(my lucky numbers are (2 3 and -4))
> '((()))
'((()))
```

- **Inner lists do not need their own quote.** The outer `'` quotes everything inside it.

### 5.3 Empty list and `empty?`
- `'()` is the **empty list**, with zero elements.

```lisp
> (empty? '())               → #t
> (empty? '(1 of the cats))  → #f
> (empty? 0)                 → #f   ; 0 is not a list
```

### 5.4 `list?`

```lisp
> (list? '())                → #t   ; the empty list IS a list
> (list? '(1 of the cats))   → #t
> (list? 56)                 → #f
> (list? (+ 2 3 4))          → #f   ; evaluates to 9, a number
```

### 5.5 `first` and `rest`

| Function | Returns | Example |
|---|---|---|
| `(first lst)` | the **first element** | `(first '(once upon a time))` → `'once` |
| `(rest lst)` | a **list** of every element **except** the first | `(rest '(once upon a time))` → `'(upon a time)` |

(In older Lisps these are called `car` and `cdr`.)

```lisp
> (first '(/ 50 2))   → '/        ; the SYMBOL /, not the division function
> (rest '(/ 50 2))    → '(50 2)
```

**Errors:** `first` and `rest` require a **non-empty list**:

```lisp
> (first (/ 50 2))
. . first: contract violation
  expected: (and/c list? (not/c empty?))
  given: 25
```

- `(/ 50 2)` is unquoted, so it **evaluates to 25**, a number, and `first` can't take a number.
- The contract `(and/c list? (not/c empty?))` means "must be a list **and** must not be empty". So `(first '())` is also an error.
- `rest` always returns a **list**: `(rest '(a))` → `'()`.

### 5.6 Building lists: `cons`
- `(cons x lst)` makes a **new** list with `x` added at the **front** of `lst`.

```lisp
> (cons 'the '(big cat))      → '(the big cat)
> (cons 4 '(1 2 3 4 5))       → '(4 1 2 3 4 5)
> (cons 'the '())             → '(the)          ; cons onto empty → one-element list
> (cons '(1 2) '(three four)) → '((1 2) three four)  ; a list as an ELEMENT
> (cons (- 10 2) '(a b c))    → '(8 a b c)      ; arguments are evaluated first
```

- `cons` adds **exactly one element**. When `x` is a list, it becomes a single nested element and is **not** spliced in.
- Relationship to remember, for any non-empty list `lst`:
  `(cons (first lst) (rest lst))` equals `lst`.

### 5.7 Building lists: `list`
- `(list e1 e2 ...)` **evaluates** every argument and puts the results into a new list.

```lisp
> (list 1 2 3)                     → '(1 2 3)
> (list 'result 'is (* 6 7))       → '(result is 42)   ; (* 6 7) gets computed
> (list 'a '(b c) (cons 'd '(e)))  → '(a (b c) (d e))
```

**`'( ... )` vs `(list ...)`:**

| | `'(result is (* 6 7))` | `(list 'result 'is (* 6 7))` |
|---|---|---|
| Inner expressions evaluated? | ❌ No, everything stays as data | ✅ Yes |
| Result | `'(result is (* 6 7))` | `'(result is 42)` |

**`cons` vs `list`:**

| | `cons` | `list` |
|---|---|---|
| # of args | exactly 2 (element, list) | any number |
| What it does | adds 1 element to the front of an existing list | builds a new list from all its args |
| `(cons 1 '(2 3))` vs `(list 1 '(2 3))` | `'(1 2 3)` | `'(1 (2 3))` |

### 5.8 Pairs and `pair?`
- A **pair** (cons cell) is the basic building block: it holds **two values**.
- Literal syntax uses a **dot**: `(<value1> . <value2>)`, e.g. `'(a . b)`.

```lisp
> (pair? '(1 2))       → #t
> (pair? '(a b c d))   → #t
> (pair? '(a . b))     → #t
> (pair? '())          → #f   ; the empty list is NOT a pair
> (pair? 5)            → #f
```

### 5.9 Lists are chains of pairs
A list is shorthand for nested pairs that **end in the empty list**:

```
(a b c ... z)   ≡   (a . (b . (c . (... . (z . ())))))
```

```lisp
> (pair? '(1 . (2 . (3 . ()))))   → #t
> (list? '(1 . (2 . (3 . ()))))   → #t    ; this is just '(1 2 3)
```

Picture for `'(1 2 3)`:

```
[1 | •]──▶[2 | •]──▶[3 | •]──▶ '()
 first     first     first
  rest ──▶  rest ──▶  rest ──▶
```

- Each box is a pair. The **left** part is the `first` and the **right** part is the `rest`.
- `cons` builds one box. `(cons 1 '(2 3))` is the pair `(1 . (2 3))`, which is the list `'(1 2 3)`.

**Lists vs. pairs:**

| Value | `list?` | `pair?` | Why |
|---|---|---|---|
| `'()` | `#t` | `#f` | empty list: a list with no pairs |
| `'(1 2 3)` | `#t` | `#t` | a chain of pairs ending in `'()` |
| `'(a . b)` | `#f` | `#t` | a pair whose rest is not a list (it doesn't end in `'()`) |
| `5` | `#f` | `#f` | not a list or a pair |

> 📝 The source never shows `(list? '(a . b))`, but in Racket it is `#f`.
> A **proper list** must end in `'()`.

---

## 6. Special Forms

### 6.1 What is a special form?
- It **looks like a function call**, `(name arg ...)`, but its arguments are
  **not evaluated the way a function's are**.
- **Normal function call rule:** evaluate **every** argument first, then call the function on the results.
- **Special form:** has **its own rule** for which parts get evaluated and when, or whether they are evaluated at all.
- This lets special forms do things ordinary functions can't, such as defining names, branching, making local variables, building functions, and quoting.

| Special form | Purpose |
|---|---|
| `define` | name a variable or function |
| `cond` (+ `else`) | multi-way if / else-if |
| `let` | local variables, bound in parallel |
| `let*` | local variables, bound in order |
| `lambda` | anonymous function |
| `quote` (`'`) | return an expression unevaluated |

**Why `cond` can't be a function:** a function would evaluate *every* branch
first, including `(error ...)` branches. `cond` evaluates only the branch it needs.

### 6.2 `define`: variables

```lisp
> (define pi 3.14159)
> pi
3.14159
> (* pi 2)
6.28318
```

- Form: `(define <name> <expr>)`. It evaluates `<expr>` and binds the result to `<name>`.
- `<name>` is **not evaluated**, which is why `define` is a special form.

**Variable vs. symbol:**

```lisp
> (define pi 3.14159)
> (list pi 'pi)
'(3.14159 pi)
```

| Code | Meaning | Evaluates to |
|---|---|---|
| `pi` | a **variable**: look up its value | `3.14159` |
| `'pi` | a **symbol**: the name itself as data | `'pi` |

### 6.3 `define`: functions
- Form: `(define (<fname> <param1> <param2> ...) <body>)`

```lisp
> (define (square x) (* x x))
> (square 2)
4

> (define (inc n) (+ n 1))
> (inc 2)
3
> (inc (square 4))      ; inner first: (square 4) = 16, then (inc 16)
17
```

- The first part `(square x)` is a template showing how the function is called.
- The **body's value** is the return value. There is no `return` keyword.
- Calling a function evaluates its arguments first, so in `(inc (square 4))`, `(square 4)` → 16 happens before `inc` is called.

### 6.4 `cond`: if / else-if chains

```lisp
(define (sign n)
  (cond [(not (number? n)) (error "not a number")]
        [(< n 0)           'negative]
        [(> n 0)           'positive]
        [else              'zero]
        ))

> (sign 4)     → 'positive
> (sign -4)    → 'negative
> (sign 0)     → 'zero
> (sign 'cat)  → . . not a number
```

**Structure:**
```
(cond [<test1> <value1>]
      [<test2> <value2>]
      ...
      [else    <default>])
```

- Each clause is `[<condition> <value>]`.
- **How it evaluates:**
  1. Check the conditions **top to bottom, in order**.
  2. At the **first** condition that is true, evaluate its `<value>` and return it.
  3. **Stop.** Later clauses are not checked.
- `else` is the **catch-all**: it runs only if every earlier condition was false. It works like writing `#t` as the condition.
- **Order matters.** In `sign`, the `(number? n)` check comes **first**. Otherwise `(< n 0)` would crash on `'cat` before the friendly error message.
- **Square brackets `[ ]`** are only for looks. Racket treats `[...]` the same as `(...)`. They're used in `cond` and `let` to make clauses easier to read.

### 6.5 `let`: local variables

```lisp
> (let [(x 1) (y 2)] (+ x y))
3
```

**General form:**
```lisp
(let [(<var1> <expr1>)
      (<var2> <expr2>)
      ...]
  <body>)
```

- Each `<varN>` is a **new local variable** bound to the value of `<exprN>`.
- `<body>` is evaluated with those variables in scope, and **its value is the value of the whole `let`**.
- The variables exist **only inside the `let`**.

Typical use is naming intermediate results inside a function:

```lisp
(define (dist x1 y1 x2 y2)
  (let [(dx (- x2 x1))
        (dy (- y2 y1))]
    (sqrt (+ (* dx dx) (* dy dy)))))

> (dist 2 2 4 3)      ; dx = 2, dy = 1, sqrt(4 + 1) = sqrt 5
2.23606797749979
```

- Benefits: no repeated computation (`(- x2 x1)` is computed once) and clearer code.

### 6.6 `let*`: sequential local variables
- `let*` binds variables **one at a time, in order**, so later expressions can use earlier variables.

```lisp
> (let* [(x 1) (y (+ x 1))] (* x y))   ; x = 1, y = 2 → 1 * 2
2
```

- With plain `let`, **the same code fails**:

```lisp
> (let [(x 1) (y (+ x 1))] (* x y))
. . x: undefined;
 cannot reference an identifier before its definition
```

| | `let` | `let*` |
|---|---|---|
| Binding style | all at once (in parallel) | one after another (in sequence) |
| Can `<expr2>` use `var1`? | ❌ No | ✅ Yes |
| Use when | bindings are independent | later bindings depend on earlier ones |

(`let*` is the same as nested `let`s:
`(let [(x 1)] (let [(y (+ x 1))] (* x y)))`.)

### 6.7 `lambda`: anonymous functions
- Form: `(lambda (<arg1> <arg2> ...) <body>)` creates a function **without a name**.

Give it a name with `define`:
```lisp
> (define sq (lambda (x) (* x x)))
> (sq 2)   → 4
> (sq 3)   → 9
```

Or call it directly where it is written:
```lisp
> ((lambda (x) (* x x)) 2)   → 4
> ((lambda (x) (* x x)) 3)   → 9
```

- In `((lambda ...) 2)`, the first element of the outer list is a **function value**, so the whole thing is a normal call.
- `(define (sq x) (* x x))` is **shorthand** for `(define sq (lambda (x) (* x x)))`. They mean the same thing.
- Use `lambda` for small, one-off functions where a name doesn't matter. This is very common with higher-order functions like `map` and `filter`, which come later.
- **Functions are values**: they can be stored in variables, passed around, and called.

### 6.8 `quote`: don't evaluate
- `(quote <expr>)` returns `<expr>` **exactly as written, without evaluating it**.
- `'x` is **shorthand** for `(quote x)`.

```lisp
> (quote x)                   → 'x
> (quote (1 2 3))             → '(1 2 3)
> (quote (first '(a b c)))    → '(first '(a b c))   ; first is NOT called
```

- The last example shows that the code `(first ...)` is returned as a **list of data** and never runs.
- This is what makes list literals and symbols work. Without `quote`, Lisp would try to evaluate every parenthesized form as a call and every name as a variable.


---

## 7. Recursive List Functions ("Functions to Know")

### 7.0 The recursion recipe
Every function in this section follows the same template:

```lisp
(define (f L)
  (cond [(empty? L) <base-case-value>]          ; 1. base case: empty list
        [<test on (first L)> <...>]             ; 2. optional extra cases
        [else <combine (first L) with (f (rest L))>]))  ; 3. recursive case
```

- **Base case:** the answer for `'()`. Get this right first. It is usually `0`, `1`, `'()`, `#t` or `#f`.
- **Recursive case:** assume `(f (rest L))` already works ("trust the recursion"), then work out how to combine it with `(first L)`.
- Each call is on a **shorter** list, so the recursion always reaches `'()` and stops.

| Function | Base case (`'()`) | Recursive step |
|---|---|---|
| `length` | `0` | `(+ 1 (length (rest L)))` |
| `sum` | `0` | `(+ (first L) (sum (rest L)))` |
| `product` | `1` | `(* (first L) (product (rest L)))` |
| `member?` | `#f` | `#t` if first matches, else recurse |
| `count` | `0` | `+1` if first matches, then recurse |
| `last` | error | if `(rest L)` is empty return `(first L)`, else recurse |
| `nth` | error | if `n = 0` return `(first L)`, else `(nth (- n 1) (rest L))` |
| `remove-all` | `'()` | skip first if it matches, else `cons` it on |
| `append A B` | `B` | `(cons (first A) (append (rest A) B))` |
| `concat` | `'()` | `(append (first LoL) (concat (rest LoL)))` |
| `reverse` | `'()` | `(append (reverse (rest L)) (list (first L)))` |

> 📝 The base case value is the **identity** of the combining operation:
> `0` for `+` (x + 0 = x), `1` for `*` (x · 1 = x), `'()` for `cons`/`append`.
> That is why `(product '())` is `1`, not `0`.

### 7.1 `length`

```lisp
(define (length L)
  (cond [(empty? L) 0]
        [else (+ 1 (length (rest L)))]))

> (length '())                                      → 0
> (length '(a b c))                                 → 3
> (length '(the (quick brown) fox (jumped over)))   → 4
```

- **Idea:** empty → 0; otherwise 1 + length of the rest.
- It only counts **top-level** elements. `(quick brown)` is **one** element, so the answer is 4, not 6.

### 7.2 `sum` and `product`

```lisp
(define (sum L)
  (cond [(empty? L) 0]
        [else (+ (first L) (sum (rest L)))]))

> (sum '())          → 0
> (sum '(5 2))       → 7
> (sum '(10 4 -2))   → 12

(define (product L)
  (cond [(empty? L) 1]                          ; 1, not 0!
        [else (* (first L) (product (rest L)))]))

> (product '())          → 1
> (product '(2 6 10))    → 120
```

- Same shape as `length`; only the base case and the operator change.
- If `product` used base case `0`, every result would be `0`.

### 7.3 `member?`

```lisp
(define (member? x L)
  (cond [(empty? L)            #f]   ; ran out → not found
        [(equal? x (first L))  #t]   ; found it → stop early
        [else (member? x (rest L))]))

> (member? 'cat '())                      → #f
> (member? 'cat '(cat))                   → #t
> (member? 'cat '(dog mouse bird))        → #f
> (member? 'cat '(my pets (cat dog bird)))→ #f   ; shallow: doesn't look inside sublists
```

**Without `cond`**, using `and`/`or` (short-circuiting does the work):

```lisp
(define (member? x L)
  (and (not (empty? L))
       (or (equal? x (first L))
           (member? x (rest L)))))
```

- Read it as: "`x` is in `L` if `L` is non-empty **and** (`x` is the first element **or** `x` is in the rest)".
- `and` stops at `#f` when `L` is empty, so `first` is never called on `'()`.
- `or` stops at `#t` as soon as `x` is found, so it doesn't search the rest.

### 7.4 `count`

```lisp
(define (count x L)
  (cond [(empty? L)           0]
        [(equal? x (first L)) (+ 1 (count x (rest L)))]   ; match → +1 and keep going
        [else                 (count x (rest L))]))       ; no match → just keep going

> (count 'cat '())                   → 0
> (count 'cat '(cat))                → 1
> (count 'cat '(dog mouse bird))     → 0
> (count 'cat '(my cat (is a cat)))  → 1   ; the cat in the sublist isn't counted
```

- **`member?` vs `count`:** `member?` stops at the first match. `count` must look at the whole list.

### 7.5 `last`

```lisp
(define (last L)
  (cond [(empty? L)        (error "last: empty list")]
        [(empty? (rest L)) (first L)]     ; exactly one element left
        [else              (last (rest L))]))

> (last '())                                → . . last: empty list
> (last '(call for bubble gum))             → 'gum
> (last '(the big brown dog (ate an apple)))→ '(ate an apple)
```

- There is no sensible answer for `'()`, so the base case **raises an error**.
- `(empty? (rest L))` is the usual way to test "this list has exactly one element".
- The last element can itself be a list.

### 7.6 `nth` (zero-based indexing)

```lisp
(define (nth n L)
  (cond [(empty? L) (error "nth: index out of range")]
        [(< n 0)    (error "nth: negative index")]
        [(= n 0)    (first L)]
        [else       (nth (- n 1) (rest L))]))   ; shrink BOTH n and L

> (nth 0 '(a b c))  → 'a
> (nth 1 '(a b c))  → 'b
> (nth 2 '(a b c))  → 'c
> (nth 3 '(a b c))  → . . nth: index out of range
```

- Recurses on **two** things at once: `n` counts down while `L` gets shorter.
- **`O(n)` time.** Lists aren't arrays: getting to index `n` means walking `n` pairs. Don't call `nth` in a loop over a big list.

### 7.7 `remove-all`

```lisp
(define (remove-all x L)
  (cond [(empty? L)           '()]
        [(equal? x (first L)) (remove-all x (rest L))]                 ; drop it
        [else                 (cons (first L) (remove-all x (rest L)))]))  ; keep it

> (remove-all 'dust '(dirt dust dust dirt (dirt dust)))  → '(dirt dirt (dirt dust))
> (remove-all 'cat '())                                  → '()
> (remove-all 'cat '(cat cat mouse cat))                 → '(mouse)
```

- Returns a **new** list. The original list is unchanged; nothing is ever mutated.
- Shallow: the `dust` inside `(dirt dust)` stays.
- (The source's description calls it `(remove x L)`, but the code names it `remove-all`.)

### 7.8 `append`

```lisp
(define (append A B)
  (cond [(empty? A) B]
        [else (cons (first A) (append (rest A) B))]))

> (append '(once up) '(a time))  → '(once up a time)
> (append '(+ 2 3) '(w x y z))   → '(+ 2 3 w x y z)
```

**Trace:**
```
(append '(1 2) '(3 4))
= (cons 1 (append '(2) '(3 4)))
= (cons 1 (cons 2 (append '() '(3 4))))
= (cons 1 (cons 2 '(3 4)))
= '(1 2 3 4)
```

- It only recurses on **`A`**; `B` is reused as-is at the end.
- **Running time: `O(length of A)`**, i.e. linear. The length of `B` doesn't matter.
- ⚠️ Calling `append` **repeatedly** (e.g. once per element) adds up to **quadratic** time.

**`cons` vs `list` vs `append`:**

| Call | Result |
|---|---|
| `(cons '(1 2) '(3 4))` | `'((1 2) 3 4)`: adds one element |
| `(list '(1 2) '(3 4))` | `'((1 2) (3 4))`: wraps both |
| `(append '(1 2) '(3 4))` | `'(1 2 3 4)`: joins them |

### 7.9 `concat` (a.k.a. `append*`, `append-all`)

```lisp
(define (concat list-of-lists)
  (cond [(empty? list-of-lists) '()]
        [else (append (first list-of-lists)
                      (concat (rest list-of-lists)))]))

> (concat '((1) (two three four) (five) (6 7)))     → '(1 two three four five 6 7)
> (concat '((1 2) (three four five) (six) (7 8)))   → '(1 2 three four five six 7 8)
> (concat (list '(a b c) '() '(d e (f) g)))         → '(a b c d e (f) g)
```

- Flattens **one level** only: `(f)` stays a list.
- Empty inner lists just vanish.

### 7.10 `reverse` (naive, quadratic)

```lisp
(define (reverse L)
  (cond [(empty? L) '()]
        [else (append (reverse (rest L))
                      (list (first L)))]))   ; put first at the END

> (reverse '(a b c))                → '(c b a)
> (reverse '(this (is a) (big test)))→ '((big test) (is a) this)   ; sublists not reversed
```

**Why it's quadratic:**
```
(reverse '(1 2 3))
= (append (reverse '(2 3)) '(1))
= (append (append (reverse '(3)) '(2)) '(1))
= (append (append (append '() '(3)) '(2)) '(1))
= (append (append '(3) '(2)) '(1))
= (append '(3 2) '(1))
= '(3 2 1)
```

- Each level calls `append` on a list of length 0, 1, 2, …, n−1.
- Total work ≈ 0 + 1 + … + (n−1) = n(n−1)/2 → **O(n²)**.
- `(list (first L))` is needed because `append` joins two **lists**; `(first L)` alone is just an element.

---

## 8. Accumulators

### 8.1 The idea
- An **accumulator** is an extra parameter that holds the **result so far**.
- Each recursive call updates it. When the list is empty, the accumulator **is** the answer.
- Because of the extra parameter, you usually write a **helper** (`*-acc`) and a **wrapper** that the user calls, which passes the starting accumulator.

```lisp
(define (f-acc L acc)
  (cond [(empty? L) acc]                          ; done: answer is in acc
        [else (f-acc (rest L) <update acc with (first L)>)]))

(define (f L) (f-acc L <initial acc>))           ; wrapper
```

### 8.2 `reverse` with an accumulator (linear)

```lisp
(define (reverse-acc L acc)
  (cond [(empty? L) acc]
        [else (reverse-acc (rest L)
                           (cons (first L) acc))]))

(define (reverse2 L)
  (reverse-acc L '()))
```

Trace:
```
(reverse2 '(1 2 3))
= (reverse-acc '(1 2 3) '())
= (reverse-acc '(2 3)   '(1))
= (reverse-acc '(3)     '(2 1))
= (reverse-acc '()      '(3 2 1))
= '(3 2 1)
```

- Taking from the front of `L` and `cons`ing onto the front of `acc` reverses the order **for free**.
- No `append`; every step is constant time → **O(n)**.
- The cost: a second parameter, so you need a helper function.

### 8.3 `length` and `sum` with accumulators

```lisp
(define (length-acc L acc)
  (cond [(empty? L) acc]
        [else (length-acc (rest L) (+ acc 1))]))
(define (length2 L) (length-acc L 0))

(define (sum-acc L acc)
  (cond [(empty? L) acc]
        [else (sum-acc (rest L) (+ acc (first L)))]))
(define (sum2 L) (sum-acc L 0))
```

**Compare the traces.** Without an accumulator, the expression grows and then shrinks:
```
(sum '(4 5 6))
= (+ 4 (sum '(5 6)))
= (+ 4 (+ 5 (sum '(6))))
= (+ 4 (+ 5 (+ 6 (sum '()))))
= (+ 4 (+ 5 (+ 6 0)))        ; ← the expression is at its biggest here
= (+ 4 (+ 5 6))
= (+ 4 11)
= 15
```

With an accumulator, the calls stay the same size:
```
(sum2 '(4 5 6))
= (sum-acc '(4 5 6) 0)
= (sum-acc '(5 6)   4)
= (sum-acc '(6)     9)
= (sum-acc '()      15)
= 15
```

| | Plain recursion (`sum`, `length`) | Accumulator (`sum2`, `length2`) |
|---|---|---|
| Time | O(n) | O(n), about the same |
| Space | O(n): pending `(+ 4 (+ 5 ...))` operations pile up | O(1) extra: nothing is left waiting |
| Recursive call is the last thing done? | ❌ No: `+` still has to run after it returns | ✅ Yes (**tail call**) |

- For `reverse`, the accumulator improves **time** (O(n²) → O(n)).
- For `length`/`sum`, it improves **space**, not time.

### 8.4 Example: `range` (from earlier in this session)

```lisp
;; counting up with a helper
(define (range-from i n)
  (cond [(>= i n) '()]
        [else (cons i (range-from (+ i 1) n))]))
(define (range n) (range-from 0 n))

;; counting down with an accumulator
(define (range-acc n acc)
  (cond [(<= n 0) acc]
        [else (range-acc (- n 1) (cons (- n 1) acc))]))

> (range 5) → '(0 1 2 3 4)
```

---

## 9. Higher-Order Functions: `map`, `filter`, `all`

A **higher-order function** takes a function as an argument and/or returns a function.
This works because functions are ordinary values (§6.7).

### 9.1 `map`: transform every element

```lisp
(define (map fn L)
  (cond [(empty? L) '()]
        [else (cons (fn (first L))
                    (map fn (rest L)))]))

> (map square '(1 2 3))               → '(1 4 9)
> (map (lambda (x) (+ x 1)) '(1 2 3)) → '(2 3 4)
```

- `fn` takes **one** input. It is often written as a `lambda`.
- The output **always has the same length** as `L`. `map` can't add or drop elements.
- Running time: `fn` runs once per element, so it is n × (cost of `fn`). It is linear if `fn` is O(1) and quadratic if `fn` is O(n).

**Python equivalent:**
```
[x * x for x in [1, 2, 3]]          ⇔   (map (lambda (x) (* x x)) '(1 2 3))
```

### 9.2 `filter`: keep the elements that pass a test

```lisp
(define (filter pred? L)
  (cond [(empty? L) '()]
        [(pred? (first L))                       ; passes → keep it
         (cons (first L) (filter pred? (rest L)))]
        [else (filter pred? (rest L))]))         ; fails → drop it

> (filter even? '(1 2 3 4 5))                  → '(2 4)
> (filter (lambda (x) (> x 3)) '(1 2 3 4 5))   → '(4 5)
```

- `pred?` takes one input and returns `#t`/`#f`.
- The output is the **same length or shorter**, and keeps the **original order**.
- Running time is the same reasoning as `map`.

**`remove-all` rewritten with `filter`:** keep everything that is *not* equal to `x`.
```lisp
(define (remove-all x L)
  (filter (lambda (y) (not (equal? y x))) L))
```
- The `lambda` uses `x` from the surrounding function. This is a **closure** (§12).

**`map` + `filter` together = a Python comprehension with an `if`:**
```
[x * x for x in [1, 2, 3, 4, 5] if x % 2 == 0]
⇔
(map (lambda (x) (* x x))
     (filter even? '(1 2 3 4 5)))      → '(4 16)
```
- Filter first, then map. Read it inside-out.

### 9.3 `all`: does every element pass?

```lisp
(define (all pred? L)
  (cond [(empty? L) #t]                      ; vacuously true
        [else (and (pred? (first L))
                   (all pred? (rest L)))]))

> (all even? '(2 4 6))            → #t
> (all symbol? '(two 4 five))     → #f
> (all even? '())                 → #t
```

- **Why is `(all p '())` `#t`?** "All" means "no element fails", and an empty list has no element that fails. This is called **vacuous truth**.
- `and` **short-circuits**, so it stops at the first failing element.

**Version built from `filter`:**
```lisp
(define (all pred? L)
  (empty? (filter (lambda (x) (not (pred? x))) L)))   ; "no failures"
```

| | Recursive `all` | `filter`-based `all` |
|---|---|---|
| Stops early on first `#f`? | ✅ Yes | ❌ No, it checks **every** element |
| Speed | often faster | always does n checks |
| Readability | needs recursion | built from simple parts with no explicit recursion |

---

## 10. Folding (`foldr`)

### 10.1 From "consed-out form" to fold
Any list can be written as nested `cons` calls. This is its **consed-out form**:

```
'(a b c d) = (cons 'a (cons 'b (cons 'c (cons 'd '()))))
```

Swap `cons` for another **binary** function, and swap `'()` for a matching starting value:

| Replace `cons` with | Replace `'()` with | Expression for `'(1 2 3 4)` | Result |
|---|---|---|---|
| `cons` | `'()` | `(cons 1 (cons 2 (cons 3 (cons 4 '()))))` | `'(1 2 3 4)` (copy) |
| `+` | `0` | `(+ 1 (+ 2 (+ 3 (+ 4 0))))` | `10` (sum) |
| `*` | `1` | `(* 1 (* 2 (* 3 (* 4 1))))` | `24` (product) |

General pattern, a **right fold** (the brackets nest to the right):
```
(foldr op init '(a b c d))  =  (op a (op b (op c (op d init))))
```

### 10.2 Implementation

```lisp
(define (foldr op init L)
  (cond [(empty? L) init]
        [else (op (first L)
                  (foldr op init (rest L)))]))

> (foldr + 0 '(1 2 3 4))   → 10
> (foldr * 1 '(1 2 3 4))   → 24
> (foldr - 0 '(1 2 3 4))   → -2
```

**Why `-2`?** `(- 1 (- 2 (- 3 (- 4 0))))` = 1 − (2 − (3 − 4)) = 1 − (2 − (−1)) = 1 − 3 = **−2**.
The bracketing matters for operations like `-` that aren't associative.

### 10.3 The folding function `(lambda (next acc) ...)`
- `op` always takes **two** arguments:
  - `next`: the current element of the list.
  - `acc`: the result of folding everything **to the right** of it.
- `init` is the value of `acc` for the last element. It is also the answer for an empty list.
- **To design a fold, ask:** "If I already have the answer for the rest of the list (`acc`), how do I add `next` to it?"

### 10.4 Common functions as folds

| Function | `op` | `init` |
|---|---|---|
| `sum` | `+` | `0` |
| `product` | `*` | `1` |
| `length` | `(lambda (next acc) (+ acc 1))` | `0` |
| `member? x` | `(lambda (next acc) (or (equal? next x) acc))` | `#f` |
| `map f` | `(lambda (next acc) (cons (f next) acc))` | `'()` |
| `filter p?` | `(lambda (next acc) (cond [(p? next) (cons next acc)] [else acc]))` | `'()` |
| `append A B` | `cons` | `B` (fold over `A`) |
| `insertion-sort` | `insert-sorted` | `'()` |
| `compose-all` | `compose` | identity `(lambda (x) x)` |

**`sum` as a fold:**
```lisp
(define (sum L) (foldr + 0 L))
```
```
(sum '(1 2 3 4))
= (foldr + 0 '(1 2 3 4))
= (+ 1 (foldr + 0 '(2 3 4)))
= (+ 1 (+ 2 (foldr + 0 '(3 4))))
= (+ 1 (+ 2 (+ 3 (foldr + 0 '(4)))))
= (+ 1 (+ 2 (+ 3 (+ 4 0))))      ; foldr builds this expression left to right...
= (+ 1 (+ 2 (+ 3 4)))            ; ...then it's evaluated from the inside out
= (+ 1 (+ 2 7))
= (+ 1 9)
= 10
```

**`length` as a fold.** `next` is **ignored**; only the count matters:
```lisp
(define (length L)
  (foldr (lambda (next acc) (+ acc 1)) 0 L))
```
```
(foldr op 0 '(a b c))
= (op a (op b (op c 0)))
= (op a (op b (+ 0 1)))   ; c is dropped because op ignores next
= (op a (op b 1))
= (op a 2)
= 3
```

**`member?` as a fold:**
```lisp
(define (member? x L)
  (foldr (lambda (next acc) (or (equal? next x) acc)) #f L))
```
```
(member? 3 '(1 2 3 4))
= (op 1 (op 2 (op 3 (op 4 #f))))
= (op 1 (op 2 (op 3 #f)))    ; 4 ≠ 3 → acc stays #f
= (op 1 (op 2 #t))           ; 3 = 3 → #t
= (op 1 #t)
= #t
```
- ⚠️ Unlike the recursive `member?`, the fold version **visits every element**. `foldr` first recurses all the way to the end of the list, and only then evaluates `op` from right to left.
- The source code uses `eq?` here, but `eq?` isn't in Tiny Lisp, and the trace's comment uses `equal?`. Use `equal?`.

**`map` and `filter` as folds:**
```lisp
(define (map f L)
  (foldr (lambda (next acc) (cons (f next) acc)) '() L))

> (map list '(a b c d))   → '((a) (b) (c) (d))

(define (filter pred? L)
  (foldr (lambda (next acc)
           (cond [(pred? next) (cons next acc)]   ; keep: push onto acc
                 [else acc]))                     ; skip: acc unchanged
         '()
         L))

> (filter even? '(1 2 3 4))   → '(2 4)
```

**`append` as a fold.** Rebuild `A` with `B` in place of `'()`:
```lisp
(define (append A B) (foldr cons B A))
```
```
(append '(1 2 3) '(a b))
= (foldr cons '(a b) '(1 2 3))
= (cons 1 (cons 2 (cons 3 '(a b))))
= (cons 1 (cons 2 '(3 a b)))
= (cons 1 '(2 3 a b))          ; (the source has a typo: "const")
= '(1 2 3 a b)
```

---

## 11. Sorting

### 11.1 Insertion sort (a fold)

**Helper:** `(insert-sorted x L)` puts `x` into the right place in an **already sorted** list `L`.

```lisp
(define (insert-sorted x L)
  (cond [(empty? L)        (list x)]                      ; nowhere else to go
        [(<= x (first L))  (cons x L)]                    ; belongs at the front
        [else (cons (first L) (insert-sorted x (rest L)))]))  ; keep looking

> (insert-sorted 3 '(1 2 4 5))   → '(1 2 3 4 5)
```

**Sort = fold `insert-sorted` over the list, starting from `'()`:**
```lisp
(define (insertion-sort L)
  (foldr insert-sorted '() L))

> (insertion-sort '(3 1 4 2 5))   → '(1 2 3 4 5)
```

- `acc` is always a sorted list, and each `next` is inserted into it.
- `(foldr insert-sorted '() '(3 1 4))` = `(insert-sorted 3 (insert-sorted 1 (insert-sorted 4 '())))`.
- `insert-sorted` is O(n), and it runs n times → **O(n²)** worst case.

### 11.2 Quicksort (with `filter`)

```lisp
(define (quicksort L)
  (cond [(<= (length L) 1) L]                    ; 0 or 1 element: already sorted
        [else
         (let* [(pivot  (first L))
                (smalls (filter (lambda (n) (< n pivot))  (rest L)))
                (bigs   (filter (lambda (n) (>= n pivot)) (rest L)))]
           (concat (list (quicksort smalls)
                         (list pivot)            ; pivot wrapped in a list for concat
                         (quicksort bigs))))]))

> (quicksort '(9 3 2 0 8 7 3))   → '(0 2 3 3 7 8 9)
```

- **Steps:** pick the pivot (the first element) → split the rest into `< pivot` and `>= pivot` → sort each part recursively → join smalls ++ [pivot] ++ bigs.
- Use `>=` in **one** of the filters so duplicates of the pivot (like the second `3`) aren't lost.
- Filter over `(rest L)`, not `L`. Otherwise the pivot is counted twice and the recursion may never end.
- The lambdas use `pivot` from the surrounding `let*`, so they are closures.

---

## 12. Flattening & Deep Functions

### 12.1 `flatten`
Removes **all** nesting and keeps the non-list elements in their original order.

```lisp
(define (flatten L)
  (cond [(empty? L) '()]
        [(list? (first L))                          ; first is a sublist → flatten it too
         (append (flatten (first L)) (flatten (rest L)))]
        [else
         (cons (first L) (flatten (rest L)))]))      ; first is an atom → keep it

> (flatten '((a) ((c d (e f)) g) h))    → '(a c d e f g h)
> (flatten '((1 2) (3 4) 5))            → '(1 2 3 4 5)
> (flatten '(define (x y) (+ x y)))     → '(define x y + x y)
```

- This is **tree recursion**: it recurses on **both** `first` and `rest`, not just on `rest`.
- **`concat` vs `flatten`:** `concat` removes **one** level of nesting; `flatten` removes **all** of them.

**Version with `let*`**, to avoid writing `(first L)` and `(rest L)` again and again:
```lisp
(define (flatten L)
  (cond [(empty? L) '()]
        [else
         (let* [(head (first L))
                (tail (rest L))
                (flat-tail (flatten tail))]
           (cond [(list? head) (append (flatten head) flat-tail)]
                 [else         (cons head flat-tail)]))]))
```

**Version with `foldr`:**
```lisp
(define (flatten L)
  (foldr (lambda (next acc)
           (cond [(list? next) (append (flatten next) acc)]   ; sublist: flatten, then join
                 [else         (cons next acc)]))             ; atom: push
         '()
         L))
```

### 12.2 Deep functions
A **deep** function also goes **into nested sublists**. A **shallow** function looks at top-level elements only.

**Easy case: flatten first, then reuse the shallow version.**
```lisp
(define (deep-sum L)     (sum (flatten L)))
(define (deep-member? x L) (member? x (flatten L)))

> (deep-sum '((1 ((2)) 3) (4 5) 6))          → 21
> (deep-member? 2 '((1 ((2)) 3) (4 5) 6))    → #t
```

**Hard case: the nesting must be kept.** `flatten` throws the structure away, so it can't be used here.

```lisp
(define (deep-map f L)
  (foldr (lambda (next acc)
           (cons (cond [(list? next) (deep-map f next)]   ; sublist → deep-map it (keep it a list)
                       [else         (f next)])           ; atom → apply f
                 acc))
         '()
         L))

> (deep-map square '((1 2) (3 4) 5))                    → '((1 4) (9 16) 25)
> (deep-map (lambda (n) (* n n)) '(1 ((2 3) 4) ((5))))  → '(1 ((4 9) 16) ((25)))
```

| | Uses `flatten`? | Keeps the structure? |
|---|---|---|
| `deep-sum`, `deep-member?` | ✅ can | ❌ not needed (returns a single value) |
| `deep-map` | ❌ can't | ✅ must |

---

## 13. Closures

### 13.1 Definition
A **closure** = a **function** + an **environment** (the variables it can see and their values).

```lisp
(define (f n) (+ n 1))          ; a plain function: it only uses its own parameter
```

```lisp
(define (make-adder n)
  (lambda (x) (+ n x)))         ; n comes from OUTSIDE the lambda

(define g (make-adder 1))       ; g is a closure that remembers n = 1

> (g 5)   → 6
```

- In `(lambda (x) (+ n x))`, `n` is a **free variable**: it is used inside the function but not declared there.
- On its own, that lambda **can't be evaluated**, because nothing says what `n` is.
- `make-adder` returns the lambda **together with** the binding `n = 1`. That pair is the closure.
- Each call makes a new closure: `(make-adder 10)` remembers `n = 10`, and it doesn't affect `g`.

### 13.2 "Let over lambda"
A useful way to picture a closure: a `let` wrapped around a `lambda`.

```lisp
(define g1
  (let ([n 1])        ; environment
    (lambda (x)       ; function
      (+ n x))))

> (g1 5)   → 6
```

### 13.3 Free vs bound variables

| In `(lambda (x) (+ n x))` | |
|---|---|
| `x` | **bound**: it is a parameter of this lambda |
| `n` | **free**: it comes from an outer scope |

- Any language that allows functions inside functions has to decide what free variables mean.
- **Closures** are the common answer: they capture the surrounding bindings.
- The alternative, banning returned functions that have free variables, makes the language much less flexible.

> 📝 You've used closures already: the `lambda`s inside `remove-all` (which uses `x`),
> `quicksort` (`pivot`), the fold-based `member?` (`x`) and `map` (`f`) all capture outside variables.

---

## 14. Function Composition

### 14.1 Math recap
f(x) = x², g(x) = 2x + 1

(f ∘ g)(x) = f(g(x)) = (2x + 1)² = 4x² + 4x + 1

- **f ∘ g means "do g first, then f".** It reads right to left.

### 14.2 In code

```lisp
(define (f x) (* x x))
(define (g x) (+ (* 2 x) 1))
(define (h x) (f (g x)))         ; compose by hand

> (f (g 2))  → 25     ; g(2) = 5, f(5) = 25
> (h 2)      → 25
```

**A `compose` function**, which takes two functions and returns a new one:
```lisp
(define (compose f g)
  (lambda (x) (f (g x))))        ; closure over f and g

(define h (compose f g))
> (h 2) → 25
```

### 14.3 Point-free style
You can define a function **without naming its argument**:

```lisp
(define second (compose first rest))   ; (first (rest lst))

> (second '(big red apple))   → 'red
```
- `second` takes a list, but no `lst` parameter appears anywhere. The argument is **implicit**.

### 14.4 `twice`
```lisp
(define (twice f) (compose f f))       ; f ∘ f

(define garnish (twice (lambda (x) (cons 'cheese x))))

> (garnish '(sauce crust))   → '(cheese cheese sauce crust)
```

### 14.5 Composing many functions: `compose-all`
- Goal: `(compose-all (list f1 f2 ... fn))` returns `x ↦ (f1 (f2 (... (fn x))))`.
- `h ∘ g ∘ f` = `h ∘ (g ∘ f)` nests to the right, which is a **right fold** with `compose` as `op`.
- **What is `init`?** It has to be the **identity function** I(x) = x, because f ∘ I = f. It plays the same role that `0` plays for `+` and `1` plays for `*`.

```lisp
(define (compose-all fns)
  (foldr compose
         (lambda (x) x)      ; identity
         fns))

(define (f x) (append x (list 'f)))
(define (g x) (append x (list 'g)))
(define (h x) (append x (list 'h)))

(define fgh (compose-all (list f g h)))
> (fgh '(test))   → '(test h g f)      ; h runs FIRST: the order is reversed
```

**`pipeline`** applies the functions in the order they are listed:
```lisp
(define (pipeline fns)
  (compose-all (reverse fns)))

(define seq2 (pipeline (list f g h)))
> (seq2 '(test))   → '(test f g h)
```

> ⚠️ **Typos in the source:** the example defines `fgh` but calls `seq1`, and it
> calls `(pipeline f g h)` without `list`. `pipeline` takes **one list**, so it
> must be `(pipeline (list f g h))`. (Checked in Racket.)

> 📝 Racket has a built-in `compose` that takes any number of functions, but it isn't in Tiny Lisp.

---

## 15. Currying

### 15.1 The idea
**Currying** turns a function of several inputs into a **chain of one-input functions**.

```lisp
(define add_a              ; uncurried: takes both inputs at once
  (lambda (x y) (+ x y)))
> (add_a 3 4)     → 7

(define add_b              ; curried: one input at a time
  (lambda (x)
    (lambda (y) (+ x y))))
> ((add_b 3) 4)   → 7      ; note the double parentheses
```

- `(add_b 3)` returns a **function** (a closure with `x = 3`) that is waiting for `y`.
- **Partial application:** giving only some of the inputs produces a useful new function:
  `(define add5 (add_b 5))` and then `(add5 10)` → `15`.

| | Uncurried `(f x y)` | Curried `((f x) y)` |
|---|---|---|
| Call | `(add_a 3 4)` | `((add_b 3) 4)` |
| Give one input | ❌ error | ✅ returns a function |

### 15.2 `curry2` / `uncurry2`
Tiny Lisp functions are **uncurried by default**. These helpers convert between the two styles:

```lisp
;; uncurried 2-arg f → curried
(define (curry2 f)
  (lambda (x)
    (lambda (y)
      (f x y))))

;; curried 2-arg f → uncurried
(define (uncurry2 f)
  (lambda (x y)
    ((f x) y)))
```

**Expanding `((curry2 +) 5)`:**
```
(curry2 +)        = (lambda (x) (lambda (y) (+ x y)))
((curry2 +) 5)    = (lambda (y) (+ 5 y))
(((curry2 +) 5) 3)= 8
```

**Examples:**
```lisp
(define add5 ((curry2 +) 5))
> (add5 3)   → 8

(define keep-odds ((curry2 filter) odd?))
> (keep-odds '(1 2 3 4 5))   → '(1 3 5)

(define c_+      (curry2 +))
(define c_cons   (curry2 cons))
(define c_filter (curry2 filter))

(define inc        (c_+ 1))              ; adds 1
(define f          (c_filter odd?))      ; keeps the odd numbers
(define add-cherry (c_cons 'cherry))     ; (add-cherry '(pie)) → '(cherry pie)
```

- **Argument order matters:** `curry2` fixes the **first** argument. That works well for `filter`/`map`, whose function comes first, and for `cons`, whose element comes first.
- `uncurry2` is rarely needed in Tiny Lisp, because functions are already uncurried.

---

## 16. Combinators

### 16.1 What is a combinator?
- A small **higher-order** function that is **pure**:
  - **no side effects** (no changing globals, printing, file I/O, …)
  - **the same input always gives the same output**
- Combinators can be combined to build other functions. They matter in theoretical CS (combinatory logic, lambda calculus).

| Name | Definition | What it does |
|---|---|---|
| **I** (identity) | `(define (I x) x)` | returns its input |
| **M** (mockingbird) | `(define (M x) (x x))` | calls `x` on itself |
| **K** (constant) | `(define (K x) (lambda (y) x))` | makes a function that always returns `x` |
| **S3** | `(define (S3 x y z) ((x z) (y z)))` | applies `x z` to `y z` |
| **S** | curried `S3` | same thing, one argument at a time |

### 16.2 I: identity

```lisp
(define (I x) x)

> (I 4)          → 4
> (I '(a b c))   → '(a b c)
> (I I)          → #<procedure:I>     ; functions are values too
```

- It does no computation, but it is the **identity element for composition**: f ∘ I = I ∘ f = f.
- That is exactly why it is `init` in `compose-all` (§14.5).

### 16.3 M: self-application

```lisp
(define (M x) (x x))

> (M list)      → '(#<procedure:list>)   ; (list list)
> (M symbol?)   → #f                     ; (symbol? symbol?): a function is not a symbol
> (M I)         → #<procedure:I>         ; (I I)
> (M 4)         → . . application: not a procedure ...   ; (4 4): 4 can't be called
```

**`(M M)` loops forever:**
```
(M M) → substitute M for x in (x x) → (M M) → (M M) → ...
```

As raw lambdas:
```lisp
((lambda (x) (x x)) (lambda (x) (x x)))   ; Ω (omega): never returns a value
```

- It has **no loop and no named recursion**, yet it still never terminates.
- **Lesson:** function application alone is powerful enough to cause non-termination.

### 16.4 K: constant functions

```lisp
(define (K x) (lambda (y) x))      ; y is ignored

> ((K 'pizza) 'ignored)    → 'pizza
> (map (K 5) '(a b c d))   → '(5 5 5 5)
```

- `(K x)` is a closure that remembers `x`.
- It is handy with `map` to replace every element with the same value.

### 16.5 S: generalized composition

```lisp
(define (S3 x y z)
  ((x z) (y z)))
```

- `x` and `y` are functions, and `z` is passed to **both**.
- `(x z)` must **return a function**, which is then applied to `(y z)`.

```lisp
(define (make-add a) (lambda (n) (+ n a)))
(define (times2 n) (* 2 n))

> (S3 make-add times2 3)   → 9
```
Step by step:
```
(S3 make-add times2 3)
= ((make-add 3) (times2 3))
= ((make-add 3) 6)
= ((lambda (n) (+ n 3)) 6)
= (+ 6 3)
= 9
```

- Compare it to composition: `(compose x y)` gives `x(y(z))`, while `S` gives `x(z)(y(z))`. In other words, `S` also gives `x` a copy of the original input.

**Curried `S`:**
```lisp
(define S
  (lambda (x)
    (lambda (y)
      (lambda (z)
        ((x z) (y z))))))
```
- `S` takes its 3 arguments **one at a time**: `(((S x) y) z)`.

### 16.6 I = S K K

```lisp
(define (I a) (((S K) K) a))
```

Why it works, using `'a` as the input:
```
(((S K) K) 'a)
= ((K 'a) (K 'a))      ; definition of S, with x = K, y = K, z = 'a
= 'a                   ; (K 'a) is a constant function that returns 'a, whatever it's given
```
So `((S K) K)` behaves exactly like the identity function.

> ⚠️ **Typo in the source:** it writes `(S K K)` and says `S` "can be passed 0,
> 1, 2, or 3 arguments". In Racket the curried `S` takes **exactly one argument
> per call**, so `(S K K)` raises `S: arity mismatch; expected: 1 given: 2`
> (checked in Racket). Write `((S K) K)`. "S K K" is the standard **combinatory
> logic** notation, where application is curried automatically.

### 16.7 Completeness of S and K
- **S and K alone can express any pure function.** Every computable function can be built from them, so they work like an "assembly language" for pure functions.
- I can be built from them (`I = S K K`), and so can everything else.
- (The proof isn't covered. See the Wikipedia page on combinatory logic, *Completeness of the S-K basis*.)

---

## 17. Case Study: Symbolic Programming

### 17.1 What is symbolic programming?
- Computing with **symbols and expressions** instead of numbers. For example, doing algebra on `x` and `y` instead of on `3` and `4`.
- This was one of Lisp's **original** uses, and Lisp is still good at it, because:
  - expressions are just **nested lists of symbols** (§5), so they are easy to build and take apart with `first`, `rest`, `list`;
  - **quoting** (§6.8) lets you write an expression as data without running it;
  - **recursion** (§7) matches the nested shape of expressions.
- The case study builds a small **language** (propositional logic) and writes programs that **check**, **evaluate**, **compile** and **simplify** expressions in it.

### 17.2 The language: literal propositional logic
Example expressions:
```lisp
'(t and (not f))
'((f or f) and ((not t) and f))
```

- `t` and `f` are **symbols** meaning true and false in *our* language.
- They are **not** Tiny Lisp's booleans `#t`/`#f`. Our language is separate from Tiny Lisp; Tiny Lisp is only the tool we use to process it.
- Binary operators use **infix** form `(e1 op e2)`, unlike Lisp's prefix form. `not` is written prefix: `(not e)`.

**Grammar (what counts as a valid expression):**

| Form | Valid when |
|---|---|
| `t` | always (true literal) |
| `f` | always (false literal) |
| `(not e)` | `e` is valid |
| `(e1 and e2)` | `e1` and `e2` are valid |
| `(e1 or e2)` | `e1` and `e2` are valid |
| `(e1 nand e2)` | `e1` and `e2` are valid |
| `(e1 implies e2)` | `e1` and `e2` are valid |
| `(e1 iff e2)` | `e1` and `e2` are valid |

- The definition is **recursive**: valid expressions are built from smaller valid expressions. So the functions that process them are recursive too.
- (The source's list leaves out `nand`, but its code accepts `nand`, so it's included here.)

**Truth table for the operators:**

| p | q | `(not p)` | `(p and q)` | `(p or q)` | `(p nand q)` | `(p implies q)` | `(p iff q)` |
|---|---|---|---|---|---|---|---|
| t | t | f | t | t | f | t | t |
| t | f | f | f | t | t | f | f |
| f | t | t | f | t | t | t | f |
| f | f | t | f | f | t | t | t |

- `nand` = "not and": false only when **both** are true.
- `implies` is false **only** when p is true and q is false.
- `iff` ("if and only if") is true when p and q have the **same** value.

### 17.3 Helper functions: recognizing pieces
A **recognizer** is a predicate that answers "is this the kind of thing I'm looking for?".

**Literals:**
```lisp
(define (is-true? e)  (equal? e 't))
(define (is-false? e) (equal? e 'f))

(define (is-literal? e)
  (or (is-false? e)
      (is-true? e)))
```

**General helpers:**
```lisp
(define (length lst)
  (cond [(empty? lst) 0]
        [else (+ 1 (length (rest lst)))]))

(define (second lst) (first (rest lst)))

;; #t iff lst is a list of length n
(define (nlist? n lst)
  (and (list? lst)
       (= n (length lst))))
```
- `nlist?` checks `list?` **first**. Because `and` short-circuits (§2.3), `length` is never called on a symbol like `'t`.
- The code also uses `third`, which the source never defines. Add it: `(define (third lst) (first (rest (rest lst))))`.

**`not` expressions**: a 2-element list whose first element is the symbol `not`:
```lisp
;; (not expr)
(define (is-not? e)
  (and (nlist? 2 e)
       (equal? 'not (first e))))
```

**Binary expressions** `(p op q)`: a 3-element list whose **middle** element is the operator:
```lisp
(define (is-bin-op? e op)
  (and (nlist? 3 e)
       (equal? op (second e))))

(define (is-and? e)     (is-bin-op? e 'and))       ; (p and q)
(define (is-or? e)      (is-bin-op? e 'or))        ; (p or q)
(define (is-nand? e)    (is-bin-op? e 'nand))      ; (p nand q)
(define (is-implies? e) (is-bin-op? e 'implies))   ; (p implies q)
(define (is-iff? e)     (is-bin-op? e 'iff))       ; (p iff q)
```
- `is-bin-op?` takes the operator as a **parameter**, so five recognizers come from one function. (This is the same idea as partial application in §15.)
- The operator is the **`second`** element because the language is infix.

**Where each part of an expression lives:**

| Expression | `(first e)` | `(second e)` | `(third e)` |
|---|---|---|---|
| `(not p)` | `'not` | `p` (the operand) | (none) |
| `(p and q)` | `p` (left operand) | `'and` (the operator) | `q` (right operand) |

> ⚠️ **Typo in the source:** the helper is defined as `is-implies` (no `?`), but
> `is-expr?` and `eval-prop-bool` call `is-implies?`. Name it `is-implies?`.

- These recognizers are **not recursive**. They only check the **top-level shape**. For example, `(is-and? '(x and y))` → `#t` even though `x` and `y` aren't valid sub-expressions.

### 17.4 The full recognizer: `is-expr?`
This one **is** recursive. It checks the top-level shape **and** every sub-expression:

```lisp
(define (is-expr? e)
  (cond
    [(is-literal? e) #t]                          ; base case: t or f
    [(is-not? e)     (is-expr? (second e))]       ; check the operand
    [(or (is-and? e)
         (is-or? e)
         (is-nand? e)
         (is-implies? e)
         (is-iff? e))
     (and (is-expr? (first e))                    ; check both sides
          (is-expr? (third e)))]
    [else #f]))                                   ; anything else is invalid

> (is-expr? '(t and (not f)))                  → #t
> (is-expr? '((f or f) and ((not t) and f)))   → #t
> (is-expr? '((f or a) and t))                 → #f   ; 'a isn't a literal
```

Extra cases (checked in Racket):
```lisp
> (is-expr? 't)                → #t   ; a bare literal is an expression
> (is-expr? '(t and f and t))  → #f   ; 5 elements, not 3: no chaining
> (is-expr? '(not t f))        → #f   ; not takes exactly 1 operand
```

**Trace of `(is-expr? '(t and (not f)))`:**
```
(is-expr? '(t and (not f)))        ; is-and? → check both sides
= (and (is-expr? 't)               ; literal → #t
       (is-expr? '(not f)))        ; is-not? → check operand
= (and #t (is-expr? 'f))           ; literal → #t
= #t
```

- **The shape of the code follows the shape of the grammar:** one `cond` clause per grammar rule. Recursion happens exactly where the grammar has a sub-expression `e`.
- Every function after this one uses the same pattern.

### 17.5 Evaluating expressions: `eval-prop`
Every valid expression evaluates to `t` or `f`. This is done in **two layers**:

```lisp
;; returns a Racket boolean: #t or #f
(define (eval-prop-bool e)
  (cond
    [(is-false? e) #f]
    [(is-true? e)  #t]
    [(is-not? e)
     (not (eval-prop-bool (second e)))]
    [(is-and? e)
     (and (eval-prop-bool (first e))
          (eval-prop-bool (third e)))]
    [(is-or? e)
     (or (eval-prop-bool (first e))
         (eval-prop-bool (third e)))]
    [(is-nand? e)
     (not (and (eval-prop-bool (first e))
               (eval-prop-bool (third e))))]
    [(is-implies? e)                                ; p → q  ≡  (not p) or q
     (or (not (eval-prop-bool (first e)))
         (eval-prop-bool (third e)))]
    [(is-iff? e)                                    ; p ↔ q  ≡  p and q are equal
     (equal? (eval-prop-bool (first e))
             (eval-prop-bool (third e)))]
    [else #f]))

;; converts back to our language's symbols: 't or 'f
(define (eval-prop e)
  (cond [(eval-prop-bool e) 't]
        [else 'f]))

> (eval-prop '((not t) and (t or (not f))))   → 'f
```

**Why two functions?**
- `eval-prop-bool` works with Racket's `#t`/`#f` so it can **reuse** Racket's built-in `and`, `or`, `not` and `equal?`.
- Otherwise we'd have to write our own `and`/`or`/`not` that work on the symbols `'t`/`'f`.
- `eval-prop` is a thin **wrapper** that turns the answer back into a symbol of our language. (This is the same helper + wrapper pattern as §8.)

**Trace of `(eval-prop '((not t) and (t or (not f))))`:**
```
left side:  (not t)  → (not #t) → #f
and short-circuits at #f, so the right side (t or (not f)) is never evaluated
→ eval-prop-bool returns #f → eval-prop returns 'f
```

**More examples (checked in Racket):**
```lisp
> (eval-prop '(f implies f))       → 't    ; false implies anything is true
> (eval-prop '(t nand t))          → 'f
> (eval-prop '(t iff (not f)))     → 't
> (eval-prop-bool '(t xor f))      → #f    ; unknown operator falls into else
```

- ⚠️ The `else` clause returns `#f` for **invalid** input instead of raising an error. So `(eval-prop '(t xor f))` quietly gives `'f`. Check the input with `is-expr?` first if that matters.
- **This is an interpreter:** it takes a program written in our language (an expression) and computes its value.

### 17.6 Compiling to `nand`-only: `to-nand`
**Fact:** every propositional expression can be rewritten using **only `nand`**. `nand` is "functionally complete", which matters in circuit design, where NAND gates are the basic building block.

**Rewrite rules:**

| Original | `nand`-only equivalent | Why |
|---|---|---|
| `(not p)` | `(p nand p)` | not (p and p) = not p |
| `(p and q)` | `((p nand q) nand (p nand q))` | that is `not (p nand q)`, which is `p and q` |
| `(p or q)` | `((p nand p) nand (q nand q))` | `(not p) nand (not q)`, which is `p or q` by De Morgan's law |

**Exercise left in the source:** `implies` and `iff` aren't handled. Rewrite them first using these equivalences, then apply the rules above:
- `(p implies q)` ≡ `((not p) or q)`
- `(p iff q)` ≡ `((p and q) or ((not p) and (not q)))`

**Variables:** `to-nand` also accepts **any symbol** (like `p` or `q`), not just `t`/`f`. It never evaluates anything. It only **rewrites the shape** of the expression.

```lisp
;; Converts e to a nand-only expression.
;; Assumes e is valid and contains no implies/iff. Variables can be any symbol.
(define (to-nand e)
  (cond [(symbol? e) e]                           ; t, f, p, q, ...: unchanged
        [(is-not? e)                              ; (not p) = (p nand p)
         (let ([second-nand (to-nand (second e))])
           (make-nand second-nand second-nand))]
        [(is-and? e)                              ; (p and q) = ((p nand q) nand (p nand q))
         (let ([p (to-nand (first e))]
               [q (to-nand (third e))])
           (make-nand (make-nand p q)
                      (make-nand p q)))]
        [(is-or? e)                               ; (p or q) = ((p nand p) nand (q nand q))
         (let ([p (to-nand (first e))]
               [q (to-nand (third e))])
           (make-nand (make-nand p p)
                      (make-nand q q)))]
        [else (error "to-nand: unknown expression")]))
```

> ⚠️ **Missing helper in the source:** `make-nand` is used but never defined. It
> builds a `nand` expression:
> ```lisp
> (define (make-nand p q) (list p 'nand q))
> ```
> Use `list` here, not a quoted list: `'(p nand q)` would give the literal symbols
> `p` and `q`, not the values of the variables `p` and `q`. (See §5.7.)

**Key points:**
- The sub-expressions are converted **first** (recursively), and `let` stores them so they aren't converted twice.
- The base case is `symbol?`, not `is-literal?`, so variables are allowed.
- The output can be **much bigger** than the input, because each `and`/`or` duplicates its sub-expressions.

**Examples (checked in Racket):**
```lisp
> (to-nand '(not p))
'(p nand p)

> (to-nand '(p and q))
'((p nand q) nand (p nand q))

> (to-nand '((p and q) or ((not p) or q)))
'((((p nand q) nand (p nand q)) nand ((p nand q) nand (p nand q)))
  nand
  ((((p nand p) nand (p nand p)) nand (q nand q))
   nand
   (((p nand p) nand (p nand p)) nand (q nand q))))
```

**Check that the meaning is kept:** compile, then evaluate:
```lisp
> (eval-prop (to-nand '(t or f)))   → 't   ; same as (eval-prop '(t or f))
> (eval-prop (to-nand '(not t)))    → 'f
```

- **This is a compiler:** it translates a program from one language (full propositional logic) into another (nand-only logic) without changing its meaning.

| | Interpreter (`eval-prop`) | Compiler (`to-nand`) |
|---|---|---|
| Input | expression | expression |
| Output | a **value** (`'t`/`'f`) | a new **expression** |
| Variables like `p` allowed? | ❌ no (needs `t`/`f`) | ✅ yes (only rewrites the shape) |

### 17.7 Simplifying: double negation elimination
**Rule:** `(not (not p))` ≡ `p`.

```lisp
;; (not (not expr)) ==> expr
(define (simplify e)
  (cond [(symbol? e) e]
        [(and (is-not? e)                       ; e = (not (not p))
              (is-not? (second e)))
         (simplify (second (second e)))]        ; drop both nots, keep simplifying p
        [(is-not? e)                            ; e = (not p): keep the not
         (list 'not (simplify (second e)))]
        [(is-and? e)                            ; rebuild with simplified parts
         (list (simplify (first e)) 'and (simplify (third e)))]
        [(is-or? e)
         (list (simplify (first e)) 'or (simplify (third e)))]
        [else (error "simplify: unknown expression")]))

> (simplify '((not (not t)) and (not (not t))))   → '(t and t)
> (simplify '(t or ((not (not f)) and t)))        → '(t or (f and t))
```

**Key points:**
- **Clause order matters** (§6.4). The double-`not` clause must come **before** the single-`not` clause. Otherwise every `not` would match the single-`not` case first and nothing would be removed.
- `(second (second e))` digs out the `p` in `(not (not p))`: the first `second` gives `(not p)`, and the second one gives `p`.
- It calls `simplify` **again** on the result, so stacked negations are all removed:

```lisp
> (simplify '(not (not (not p))))         → '(not p)   ; odd count → one not left
> (simplify '(not (not (not (not q)))))   → 'q         ; even count → none left
```

- Like `map` (§9.1), it **rebuilds** the expression with `list`, keeping its structure and only changing what the rule targets. The original is not modified.
- Only `not`, `and`, `or` are handled. `nand`/`implies`/`iff` raise an error, so you'd need to add a clause for each.

**Other simplifications you could add** (each is one more `cond` clause):

| Rule | Simplifies to |
|---|---|
| `(t and e)` | `e` |
| `(f and e)` | `f` |
| `(t or e)` | `t` |
| `(f or e)` | `e` |
| `(not t)` / `(not f)` | `f` / `t` |

> ⚠️ **Error in the source:** it says "`(f and e)` is logically equivalent to
> `e`". That's wrong: `(f and e)` is always `f`. The rule it means is
> `(t and e)` ≡ `e`.

### 17.8 The big pattern
Every function in this case study has the **same structure**:

```lisp
(define (process e)
  (cond [<base: symbol or literal> ...]
        [(is-not? e) ... (process (second e)) ...]
        [(is-and? e) ... (process (first e)) ... (process (third e)) ...]
        [(is-or? e)  ... (process (first e)) ... (process (third e)) ...]
        ...
        [else <#f or error>]))
```

| Function | Kind | Returns | Base case |
|---|---|---|---|
| `is-expr?` | recognizer | `#t`/`#f` | `is-literal?` → `#t` |
| `eval-prop-bool` / `eval-prop` | interpreter | `#t`/`#f` / `'t`/`'f` | `t` → `#t`, `f` → `#f` |
| `to-nand` | compiler | new expression | `symbol?` → unchanged |
| `simplify` | optimizer / rewriter | new expression | `symbol?` → unchanged |

- **One `cond` clause per grammar rule. Recurse wherever the grammar has a sub-expression.** That's the core skill for any symbolic programming question.

---

## 18. Quick-Reference Cheat Sheet

```lisp
;; arithmetic / comparison (variadic, prefix)
(+ 1 2 3)   (- 10 5)   (* 2 3 4)   (/ 100 2 2)   (/ 1 2) → 1/2
(< 1 2 3)   (= 5 5 5)  (<= a b)    (>= a b)
(sqrt x)    (sin x)    (cos x)       ; radians, float results

;; logic (and/or short-circuit)
(and e ...)   (or e ...)   (not e)

;; errors
(error "message")

;; predicates
(number? x) (symbol? x) (boolean? x) (list? x) (pair? x)
(empty? x)  (even? n)   (odd? n)     (equal? x y ...)

;; lists
'(a b c)   '()   (first lst)   (rest lst)   (cons x lst)   (list e ...)
'(a . b)   ; a pair;  (a b c) ≡ (a . (b . (c . ())))

;; special forms
(define name expr)
(define (f x y) body)
(cond [test value] ... [else default])
(let  [(x e1) (y e2)] body)    ; parallel
(let* [(x e1) (y e2)] body)    ; sequential
(lambda (x y) body)
(quote e)  ≡  'e

;; recursion template
(define (f L)
  (cond [(empty? L) base]
        [else (combine (first L) (f (rest L)))]))

;; accumulator template
(define (f-acc L acc)
  (cond [(empty? L) acc]
        [else (f-acc (rest L) (update acc (first L)))]))
(define (f L) (f-acc L init))

;; higher-order
(map fn L)              ; same length, each element transformed
(filter pred? L)        ; same or shorter, order kept
(all pred? L)           ; #t for '()
(foldr op init L)       ; (op a (op b (op c init)))

;; closures / composition / currying
(define (make-adder n) (lambda (x) (+ n x)))
(define (compose f g) (lambda (x) (f (g x))))     ; g first, then f
(define (curry2 f) (lambda (x) (lambda (y) (f x y))))
(define (uncurry2 f) (lambda (x y) ((f x) y)))

;; combinators
(define (I x) x)
(define (K x) (lambda (y) x))
(define (M x) (x x))                              ; (M M) loops forever
(define S (lambda (x) (lambda (y) (lambda (z) ((x z) (y z))))))
;; ((S K) K) ≡ I

;; symbolic programming: one cond clause per grammar rule
(define (is-bin-op? e op) (and (nlist? 3 e) (equal? op (second e))))  ; (p op q)
(define (is-not? e) (and (nlist? 2 e) (equal? 'not (first e))))     ; (not p)
(define (make-nand p q) (list p 'nand q))
;; (not p) = (p nand p)
;; (p and q) = ((p nand q) nand (p nand q))
;; (p or q)  = ((p nand p) nand (q nand q))
;; (not (not p)) = p
```

### Big-O summary

| Function | Time | Note |
|---|---|---|
| `first`, `rest`, `cons`, `empty?` | O(1) | |
| `length`, `sum`, `member?`, `count`, `last` | O(n) | |
| `nth n L` | O(n) | not O(1) like an array |
| `append A B` | O(len A) | `B` isn't copied |
| `reverse` (naive) | **O(n²)** | repeated `append` |
| `reverse2` (accumulator) | O(n) | |
| `map`/`filter`/`all` | n × cost of `fn` | |
| insertion sort | O(n²) | |

---

## 19. Common Mistakes / Gotchas Checklist

**Basics**
- [ ] Forgetting the `'` on a list literal → it gets run as a function call ("undefined" error).
- [ ] Mixing up a **variable** (`pi`) with a **symbol** (`'pi`).
- [ ] Calling `first`/`rest` on a non-list or on `'()` → contract violation.
- [ ] Expecting `(/ 10 4)` to give `2.5`. It gives the exact rational `5/2`.
- [ ] Assuming trig functions use degrees. They use radians.
- [ ] Thinking `(and a b)` ≡ `(and b a)`. Short-circuiting makes order matter.
- [ ] Using `let` when a later binding depends on an earlier one. Use `let*`.
- [ ] Expecting `(cons '(1 2) '(3))` to give `'(1 2 3)`. It gives `'((1 2) 3)`. Use `append`.
- [ ] Thinking `'()` is a pair. It is a list but **not** a pair.
- [ ] Thinking `'false` is a boolean. It is a symbol. Only `#t`/`#f` are booleans.
- [ ] Trying to compare symbols with `<` or concatenate them. Only `equal?` works.
- [ ] Putting the `else` clause (or a general test) before a specific test in `cond`. The first true clause wins.

**Recursion & accumulators**
- [ ] Wrong base case: e.g. `0` for `product` (it should be `1`).
- [ ] Recursing on `L` instead of `(rest L)` → infinite recursion.
- [ ] Forgetting that the basic functions are **shallow**: `member?`, `count` and `remove-all` don't look inside sublists.
- [ ] `(append (reverse (rest L)) (first L))`: the second argument must be a **list**, so use `(list (first L))`.
- [ ] Using naive `reverse` (or `append` in a loop) on big lists, which is O(n²).
- [ ] Forgetting the wrapper's starting accumulator (`'()` for reverse, `0` for sum/length).

**Higher-order functions & folds**
- [ ] Expecting `map` to drop elements. It can't; use `filter`.
- [ ] Mixing up the order of `foldr`'s arguments. It's `(foldr op init L)`, and `op` is `(lambda (next acc) ...)`.
- [ ] Assuming `foldr` works left to right for `-`: `(foldr - 0 '(1 2 3 4))` is `-2`, not `-10`.
- [ ] Expecting the fold-based `member?`/filter-based `all` to stop early. They don't.
- [ ] Forgetting that `(all p '())` → `#t`.

**Functions as values**
- [ ] `compose` order: `(compose f g)` runs **g first**.
- [ ] `compose-all` applies functions **right to left**; use `pipeline` for left-to-right order.
- [ ] Forgetting `list` when calling `compose-all`/`pipeline`: they take **one list** of functions.
- [ ] Calling a curried function like an uncurried one: `(add_b 3 4)` is an error; use `((add_b 3) 4)`.
- [ ] Passing several arguments to curried `S` at once. Use `((S K) K)`, not `(S K K)`.

**Symbolic programming**
- [ ] Mixing up our language's `'t`/`'f` (symbols) with Racket's `#t`/`#f` (booleans).
- [ ] Looking for the operator in `(first e)`. The language is infix, so it's `(second e)`.
- [ ] Calling `length` before checking `list?`. `nlist?` puts `list?` first so `and` short-circuits.
- [ ] Building a new expression with a quote, `'(p nand q)`, instead of `(list p 'nand q)`. The quote gives the literal symbols, not the variables' values.
- [ ] Putting the single-`not` clause before the double-`not` clause in `simplify`.
- [ ] Forgetting to recurse on sub-expressions: shape recognizers like `is-and?` alone don't validate the whole expression.
- [ ] Forgetting the helpers the source leaves out: `third`, `make-nand`, and the `?` in `is-implies?`.

---

## 20. Self-Test Questions

**Part A: Basics (§1–6)**
1. What does `(< 1 3 2)` return? Why?
2. What does `(/ 6 4)` return?
3. What does `(or (= 1 1) (error "boom"))` return? What about `(or (error "boom") (= 1 1))`?
4. What is the difference between `'(+ 1 2)` and `(+ 1 2)`?
5. What does `(first '((a b) c))` return? And `(rest '((a b) c))`?
6. What do `(cons 'a '())`, `(cons '() '())`, and `(list '() '())` return?
7. Rewrite `'(1 2 3)` in dotted-pair notation.
8. What are `(list? '(a . b))` and `(pair? '())`?
9. Why is `cond` a special form and not a function?
10. Will `(let [(a 2) (b (* a 3))] b)` work? How would you fix it?
11. Rewrite `(define (add1 n) (+ n 1))` using `lambda`.
12. What does `(quote (quote x))` evaluate to?

**Part B: Recursion & accumulators (§7–8)**

13. Why is the base case of `product` equal to `1`?
14. What does `(length '((a b) (c d e) f))` return?
15. What does `(append '((1)) '(2 (3)))` return?
16. Write the trace of `(reverse2 '(a b c))`.
17. Why is naive `reverse` O(n²) but `reverse2` O(n)?
18. What does an accumulator improve for `sum`: time or space? And for `reverse`?
19. Write `(count-evens L)` recursively.

**Part C: Higher-order functions & folds (§9–12)**

20. What do `(map (lambda (x) (list x x)) '(1 2))` and `(filter symbol? '(a 1 b 2))` return?
21. What does `(all odd? '())` return, and why?
22. Expand `(foldr cons '() '(1 2 3))`. What does it return?
23. Evaluate `(foldr - 0 '(10 4 1))`.
24. Write `product` as a fold.
25. Write `count` (count occurrences of `x`) as a fold.
26. Why does `quicksort` filter `(rest L)` instead of `L`?
27. What do `(flatten '(1 (2 (3)) ()))` and `(concat '(1 (2 (3)) ()))` return?
28. Why can't `deep-map` be written as `(map f (flatten L))`?

**Part D: Closures, composition, currying, combinators (§13–16)**

29. In `(lambda (y) (* x y))`, which variable is free and which is bound?
30. What does `((make-adder 10) 5)` return? Does `(make-adder 10)` change `g` from §13?
31. What do `((compose list first) '(a b c))` and `((compose first list) '(a b c))` return?
32. Define `third` in point-free style with `compose`.
33. What does `((compose-all (list (lambda (x) (* x 2)) (lambda (x) (+ x 1)))) 5)` return?
34. Write a curried `mul` and use it to define `triple`.
35. What does `(map (K 'x) '(1 2 3))` return?
36. What happens when you evaluate `(M M)`? Why?
37. Evaluate `(S3 K K 7)` step by step.

**Part E: Symbolic programming (§17)**

38. Why are `t` and `f` symbols instead of `#t` and `#f`?
39. What do `(is-and? '(x and y))` and `(is-expr? '(x and y))` return? Why are they different?
40. What does `(is-expr? '(not (t or f) t))` return?
41. Evaluate `(eval-prop '((t implies f) or (not (f iff f))))` by hand.
42. Why does `eval-prop-bool` return `#t`/`#f` instead of `'t`/`'f`?
43. What does `(to-nand '(not (not p)))` return?
44. In `simplify`, what goes wrong if the `(is-not? e)` clause comes before the double-negation clause?
45. What does `(simplify '((not (not p)) or (not q)))` return?
46. Add a clause to `simplify` for the rule `(t and e)` ≡ `e`.
47. Extend `to-nand` to handle `implies`.
48. Which functions in §17 are interpreters and which are compilers? What's the difference?

<details>
<summary>Answers</summary>

**Part A**
1. `#f`: `<` checks that the whole chain is strictly increasing, and 3 < 2 fails.
2. `3/2`
3. `#t` (it short-circuits, so the error never runs). The second one raises the error "boom", because `(error ...)` is evaluated first.
4. `'(+ 1 2)` is a list of 3 elements (the symbol `+`, then 1, then 2). `(+ 1 2)` is a call that evaluates to `3`.
5. `'(a b)` and `'(c)`
6. `'(a)`, `'(())`, `'(() ())`
7. `'(1 . (2 . (3 . ())))`
8. `#f` and `#f`
9. A function evaluates all of its arguments first. `cond` must evaluate only the conditions it needs and only the matching branch. For example, it must skip `(error ...)` branches that don't apply.
10. No: `a` is not visible while `b`'s expression is evaluated in a plain `let`. Use `let*`, which gives `6`.
11. `(define add1 (lambda (n) (+ n 1)))`
12. `''x`, i.e. the list `'(quote x)`. The outer quote stops the inner quote from being evaluated.

**Part B**

13. `1` is the identity for `*`: multiplying by it changes nothing. A base case of `0` would make every product `0`.
14. `3`. It counts only top-level elements.
15. `'((1) 2 (3))`
16. `(reverse-acc '(a b c) '())` → `(reverse-acc '(b c) '(a))` → `(reverse-acc '(c) '(b a))` → `(reverse-acc '() '(c b a))` → `'(c b a)`
17. Naive `reverse` calls `append` (which is O(n)) at every level: 0 + 1 + … + (n−1) = O(n²). `reverse2` only `cons`es (O(1)) n times.
18. For `sum`: **space**. Both are O(n) time, but `sum2` has no pending `+` operations. For `reverse`: **time** (O(n²) → O(n)).
19. ```lisp
    (define (count-evens L)
      (cond [(empty? L) 0]
            [(even? (first L)) (+ 1 (count-evens (rest L)))]
            [else (count-evens (rest L))]))
    ```

**Part C**

20. `'((1 1) (2 2))` and `'(a b)`
21. `#t`: no element fails, so it is vacuously true.
22. `(cons 1 (cons 2 (cons 3 '())))` → `'(1 2 3)`, a copy of the list.
23. `(- 10 (- 4 (- 1 0)))` = 10 − (4 − 1) = 10 − 3 = `7`
24. `(define (product L) (foldr * 1 L))`
25. ```lisp
    (define (count x L)
      (foldr (lambda (next acc) (cond [(equal? next x) (+ acc 1)]
                                      [else acc]))
             0 L))
    ```
26. So the pivot isn't included again in `bigs`. If it were, it would be duplicated, and a list could keep producing the same `bigs` forever.
27. `'(1 2 3)`. `concat` raises an error, because `1` isn't a list and `append` needs list arguments; `concat` is meant only for a list **of lists**.
28. `flatten` destroys the nesting, but `deep-map` must **keep** the shape: `'((1 4) (9 16) 25)`, not `'(1 4 9 16 25)`.

**Part D**

29. `x` is free; `y` is bound.
30. `15`. No: each call to `make-adder` creates a **new** closure with its own `n`.
31. `'(a)` (first gives `'a`, then list wraps it) and `'(a b c)` (list gives `'((a b c))`, then first unwraps it).
32. `(define third (compose first (compose rest rest)))`
33. `12`. The functions are applied right to left: (5 + 1) = 6, then 6 × 2 = 12.
34. `(define mul (lambda (x) (lambda (y) (* x y))))` and `(define triple (mul 3))`, so `(triple 4)` → `12`.
35. `'(x x x)`
36. It loops forever: `(M M)` → `(M M)` → …, because M applies its argument to itself, and the argument is M again.
37. `(S3 K K 7)` = `((K 7) (K 7))` = `7`, because `(K 7)` returns 7 whatever it is given. This is why S K K is the identity.

**Part E**

38. Our propositional language is a separate language that Tiny Lisp *processes*. Its expressions are data (quoted lists of symbols), so true and false are written as the symbols `t` and `f`.
39. `#t` and `#f`. `is-and?` only checks the top-level shape (3 elements, `and` in the middle). `is-expr?` also checks each side recursively, and `x` isn't a literal.
40. `#f`: it has 3 elements, so `is-not?` (which needs exactly 2) fails, and its middle element is `(t or f)`, which isn't an operator symbol.
41. `(t implies f)` → f. `(f iff f)` → t, so `(not (f iff f))` → f. Then `(f or f)` → `'f`.
42. So it can reuse Racket's built-in `and`, `or`, `not` and `equal?`, which work on `#t`/`#f`. `eval-prop` converts the answer back to `'t`/`'f`.
43. `'((p nand p) nand (p nand p))`. The inner `(not p)` becomes `(p nand p)`, and the outer `not` makes a `nand` of that result with itself. `to-nand` doesn't simplify.
44. Every `not`, including `(not (not p))`, matches the single-`not` clause first, so the double negation is never removed. It returns `'(not (not p))` unchanged.
45. `'(p or (not q))`
46. Put this clause before the general `is-and?` clause:
    ```lisp
    [(and (is-and? e) (is-true? (first e)))
     (simplify (third e))]
    ```
47. ```lisp
    [(is-implies? e)        ; (p implies q) = ((not p) or q)
     (to-nand (list (list 'not (first e)) 'or (third e)))]
    ```
    It rewrites to `or`/`not` first, then lets the existing rules convert it.
48. `eval-prop` is an **interpreter**: it computes a value. `to-nand` (and `simplify`) are **compilers/rewriters**: they output a new expression in a (possibly different) language with the same meaning.

</details>

---

## 21. Quiz Prep (Tiny Lisp Quiz)

### 21.1 The quiz at a glance

| | |
|---|---|
| **Format** | written on **paper**, in class, during the usual lecture time and room |
| **Time** | **30 minutes**, no breaks |
| **Allowed** | pen/pencil and eraser only. **Closed book**: no notes, cheat sheet, computer or calculator |
| **Bring** | your **SFU ID** |
| **Question style** | any type, but expect them to be **similar to the practice questions** ([tiny_lisp_practice.md](tiny_lisp_practice.md), [Racket_problemset.md](Racket_problemset.md)) |
| **During the quiz** | content questions won't be answered, so read each question carefully |

**Scope:**

| ✅ On the quiz | ❌ Not on the quiz |
|---|---|
| Everything in §1–16 | **Macros** (problem set Q10, and Q9 `if-to-cond`) |
| Symbolic processing of propositional logic (§17): the **concepts and key ideas** | Memorizing the exact logic rules (e.g. the `nand` rewrite formulas) |
| Writing code **in Tiny Lisp only** | Racket built-ins that Tiny Lisp doesn't have |

### 21.2 The #1 rule: only Tiny Lisp

> **You can't use a function that isn't already in Tiny Lisp unless you write
> its full definition yourself.**

**What Tiny Lisp gives you** (checked against [tiny-lisp/main.rkt](tiny-lisp/main.rkt). Anything else is an "unbound identifier"):

| Category | Available |
|---|---|
| Special forms | `quote` (`'`), `cond`, `else`, `let`, `let*`, `define`, `lambda`, `and`, `or` |
| Arithmetic / comparison | `+` `-` `*` `/` `<` `>` `<=` `>=` `=` |
| Math | `sqrt` `sin` `cos` |
| Logic / errors | `not`, `error` |
| Predicates | `equal?` `symbol?` `number?` `boolean?` `list?` `pair?` `even?` `odd?` `empty?` |
| Lists | `cons` `list` `first` `rest` |

**Commonly used by mistake, and what to do instead:**

| ❌ Not in Tiny Lisp | ✅ Do this instead |
|---|---|
| `if` | `(cond [test a] [else b])` |
| `length`, `append`, `reverse` | define them yourself (§21.4) |
| `map`, `filter`, `foldr`/`fold-right`, `member`/`member?` | define them yourself (§21.4) |
| `second`, `third` | `(first (rest L))`, `(first (rest (rest L)))`, or define them |
| `max`, `min`, `abs` | `cond` with `>` / `<` |
| `eq?`, `eqv?`, `=` on symbols | `equal?` (works on symbols, numbers and lists) |
| `null?`, `empty` | `empty?`, `'()` |
| `car`, `cdr` | `first`, `rest` |
| `else` outside `cond` | only valid as the last `cond` clause |
| `set!`, loops, `for` | recursion |
| strings, `printf`, `display` | symbols / return values |

> 💡 **Time tip:** if a question needs `member?` or `append`, write the short
> definition at the top of your answer (it takes about 30 seconds), then use it.
> Check whether the question **forbids** a particular helper (e.g. "don't call
> `count`" or "using just one call to `fold-right`").

### 21.3 How to answer a coding question on paper

1. **Read the examples first.** Note what the empty-list case returns and any edge cases (empty list, one element, not found, nested lists).
2. **Write the recursive idea in 2–3 bullets** (the practice sheet asks for this). For example:
   - return 0 if the list is empty
   - otherwise, return 1 plus the length of the rest
3. **Base case first.** What is the answer for `'()`? (Usually `0`, `1`, `'()`, `#t`, `#f`, `-1`, or an `error`.)
4. **Recursive case:** assume `(f (rest L))` works. How do you combine it with `(first L)`?
5. **Write the `cond`.** Put **specific cases before general ones**, and finish with `else`.
6. **Hand-trace one example** in the margin. It catches off-by-one and base-case mistakes.
7. **Check your parentheses.** Line up each `cond` clause on its own line in `[ ]` brackets. Count the closing parens at the end of a `define`.

**Paper-writing habits that avoid mistakes:**
- One `cond` clause per line, in `[ ]` brackets.
- Use `let` for anything you'd otherwise compute twice. On paper this also cuts down on parentheses.
- Quote symbols in data (`'error`, `'cons`), but **not** variables.
- `define` with a function: `(define (f x) body)`, not `(define f (x) body)`.

### 21.4 Helper definitions to memorize (write these from memory)
Practice until you can write each one in under 30 seconds:

```lisp
(define (length L)
  (cond [(empty? L) 0]
        [else (+ 1 (length (rest L)))]))

(define (member? x L)
  (cond [(empty? L) #f]
        [(equal? x (first L)) #t]
        [else (member? x (rest L))]))

(define (append A B)
  (cond [(empty? A) B]
        [else (cons (first A) (append (rest A) B))]))

(define (reverse-acc L acc)
  (cond [(empty? L) acc]
        [else (reverse-acc (rest L) (cons (first L) acc))]))
(define (reverse L) (reverse-acc L '()))

(define (second L) (first (rest L)))
(define (third L)  (first (rest (rest L))))

(define (map f L)
  (cond [(empty? L) '()]
        [else (cons (f (first L)) (map f (rest L)))]))

(define (filter pred? L)
  (cond [(empty? L) '()]
        [(pred? (first L)) (cons (first L) (filter pred? (rest L)))]
        [else (filter pred? (rest L))]))

(define (foldr op init L)
  (cond [(empty? L) init]
        [else (op (first L) (foldr op init (rest L)))]))
```

### 21.5 Problem patterns (most quiz questions are one of these)

| Pattern | Base case | Recursive step | Examples |
|---|---|---|---|
| **Count** | `0` | `(+ 1 (f (rest L)))` if it matches, else `(f (rest L))` | `count-evens`, `count`, `length` |
| **Search (yes/no)** | `#f` | `#t` if first matches, else recurse | `member?`, `any?` |
| **Check all** | `#t` | `(and <test first> (f (rest L)))` | `all`, `my-subset?`, `sorted?` |
| **Build / keep** | `'()` | `(cons <first or f(first)> (f (rest L)))`, or skip | `map`, `filter`, `remove-all`, `remove-duplicates` |
| **Search (position)** | `-1` | `0` if found; else `+1` to the recursive result **unless it's −1** | `index-of` |
| **Best so far** | one-element list → `(first L)`; `'()` → `error` | compare `(first L)` with the result for the rest | `max-of`, `last` |
| **Two lists at once** | stop when **either** list is empty | use both `first`s, recurse on both `rest`s | `zip`, `append` (one list) |
| **Adjacent pairs** | `'()` **or one element** → `#t` | compare `(first L)` with `(first (rest L))` | `sorted?` |
| **Counting number** | `n` reached | `(cons i (f (+ i 1) n))` with a helper | `range` |
| **Tree / deep** | `'()` | if `(first L)` is a list, recurse **into it and** into the rest | `flatten`, `deep-count`, `make-consed`, `deep-map` |
| **Accumulator** | return `acc` | update `acc`, recurse on rest; wrapper passes initial `acc` | `reverse2`, `sum2`, `range` |
| **Expression tree** | number/symbol → itself | `cond` per operator; recurse on `first` and `third` | `evaluate`, `eval-prop`, `simplify` |

### 21.6 Worked solutions: group practice ([tiny_lisp_practice.md](tiny_lisp_practice.md))
All tested in `#lang tiny-lisp`. The practice sheet says to use **plain recursion only**, with no filter/fold.

**Problem 1: `count-evens`**
- 0 if empty
- if first is even → 1 + count of rest
- otherwise → count of rest

```lisp
(define (count-evens L)
  (cond [(empty? L) 0]
        [(even? (first L)) (+ 1 (count-evens (rest L)))]
        [else (count-evens (rest L))]))

> (count-evens '(1 2 3 4 6))   → 3
```

**Problem 2: `max-of`**
- error if empty
- one element → that element
- otherwise → the bigger of `(first L)` and the max of the rest

```lisp
(define (max-of L)
  (cond [(empty? L) (error "max-of: empty list")]
        [(empty? (rest L)) (first L)]
        [else (let ([m (max-of (rest L))])
                (cond [(> (first L) m) (first L)]
                      [else m]))]))

> (max-of '(3 9 2 7))   → 9
> (max-of '(-4 -1 -8))  → -1
```
- ⚠️ Tiny Lisp has no `max`, so compare with `cond`.
- ⚠️ Use `let` to compute `(max-of (rest L))` **once**. Writing it in both the test and the result calls it twice at every level, which takes **exponential** time.
- The one-element base case is needed because there is no sensible answer for `'()` to compare against.

**Problem 3: `zip`**
- `'()` if **either** list is empty
- otherwise → `(list firstA firstB)` consed onto the zip of the rests

```lisp
(define (zip A B)
  (cond [(or (empty? A) (empty? B)) '()]
        [else (cons (list (first A) (first B))
                    (zip (rest A) (rest B)))]))

> (zip '(a b c) '(1 2 3))  → '((a 1) (b 2) (c 3))
> (zip '(a b c) '(1))      → '((a 1))
```
- Use `list` (not `cons`) to make each pair: `(cons 'a 1)` would give the dotted pair `'(a . 1)`.

**Problem 4: `sorted?`**
- `'()` or one element → `#t`
- otherwise → first ≤ second **and** the rest is sorted

```lisp
(define (sorted? L)
  (cond [(empty? L) #t]
        [(empty? (rest L)) #t]
        [else (and (<= (first L) (first (rest L)))
                   (sorted? (rest L)))]))

> (sorted? '(1 2 2 5))  → #t
> (sorted? '(1 2 3 0))  → #f
```
- Use `<=`, not `<`, because duplicates are allowed.
- Recurse on `(rest L)` (overlapping pairs), **not** `(rest (rest L))`, which would skip comparisons.

**Problem 5: `range`**
```lisp
(define (range-from i n)
  (cond [(>= i n) '()]
        [else (cons i (range-from (+ i 1) n))]))
(define (range n) (range-from 0 n))

> (range 5)  → '(0 1 2 3 4)
```
- A helper is needed to carry the current number `i`. The accumulator version is in §8.4.

### 21.7 Worked solutions: problem set ([Racket_problemset.md](Racket_problemset.md))
All tested in `#lang tiny-lisp`. Helpers like `member?` are defined in full, as the quiz requires.

**Q1: `index-of`**
- −1 if empty
- 0 if the first element is `x`
- otherwise → 1 + index in the rest, **but** keep −1 if it wasn't found

```lisp
(define (index-of x lst)
  (cond [(empty? lst) -1]
        [(equal? x (first lst)) 0]
        [else (let ([i (index-of x (rest lst))])
                (cond [(= i -1) -1]
                      [else (+ i 1)]))]))

> (index-of 'a '(0 1 2 a a))            → 3
> (index-of 'a '(one two three four))   → -1
```
- ⚠️ **Trap:** `[else (+ 1 (index-of x (rest lst)))]` is wrong when `x` isn't in the list. The −1 from the end gets `+1` added at every level, e.g. `-1 + 4 = 3`.

**Alternative with an accumulator**, which avoids the trap:
```lisp
(define (index-from x lst i)
  (cond [(empty? lst) -1]
        [(equal? x (first lst)) i]
        [else (index-from x (rest lst) (+ i 1))]))
(define (index-of x lst) (index-from x lst 0))
```

**Q2: `my-subset?`**
- `'()` is a subset of anything → `#t`
- otherwise → first is a member of `lst2` **and** the rest is a subset

```lisp
(define (member? x L)
  (cond [(empty? L) #f]
        [(equal? x (first L)) #t]
        [else (member? x (rest L))]))

(define (my-subset? A B)
  (cond [(empty? A) #t]
        [else (and (member? (first A) B)
                   (my-subset? (rest A) B))]))

> (my-subset? '(2 1 1) '(1 2))                      → #t
> (my-subset? '(a d (3 1)) '(1 a (3 d)))            → #f   ; d isn't top-level in B
> (my-subset? '((1) (2 2)) '((3 3 3) a (2 2) (1)))  → #t   ; equal? compares whole lists
```
- Recurse on `A` only. `B` stays the same.
- `equal?` compares lists **structurally**, so `(equal? '(1) '(1))` → `#t`.

**Q3: `my-remove-duplicates`**
- `'()` if empty
- if the first element appears again in the rest → drop it (a later copy will be kept)
- otherwise → keep it

```lisp
(define (my-remove-duplicates L)
  (cond [(empty? L) '()]
        [(member? (first L) (rest L)) (my-remove-duplicates (rest L))]
        [else (cons (first L) (my-remove-duplicates (rest L)))]))

> (my-remove-duplicates '(1 2 3 2))              → '(1 3 2)
> (my-remove-duplicates '(up up and a way way))  → '(up and a way)
```
- This keeps the **last** copy of each element, which matches the expected `'(1 3 2)`. The question says order doesn't matter anyway.
- Remember to include the definition of `member?`.

**Q4: `make-consed`**
- not a list → return it unchanged
- `'()` → `'()`
- otherwise → `(list 'cons <consed first> <consed rest>)`

```lisp
(define (make-consed x)
  (cond [(not (list? x)) x]
        [(empty? x) '()]
        [else (list 'cons
                    (make-consed (first x))
                    (make-consed (rest x)))]))

> (make-consed '(a b c))      → '(cons a (cons b (cons c ())))
> (make-consed '((a b) c d))  → '(cons (cons a (cons b ())) (cons c (cons d ())))
```
- This is **tree recursion**: it recurses on **both** `first` (which may be a nested list) and `rest`.
- It is **symbolic**: it **builds code as data**. `'cons` is quoted because we want the *symbol* `cons` in the output, not to call the function.
- Use `(list 'cons A B)`, which makes a 3-element list. `(cons 'cons ...)` would give the wrong shape.
- Check `(not (list? x))` **first**, so `first`/`rest` are never called on a symbol.

**Q5: `my-map`, `my-filter`, `my-fold-right`**
```lisp
(define (my-map f lst)
  (cond [(empty? lst) '()]
        [else (cons (f (first lst)) (my-map f (rest lst)))]))

(define (my-filter pred? lst)
  (cond [(empty? lst) '()]
        [(pred? (first lst)) (cons (first lst) (my-filter pred? (rest lst)))]
        [else (my-filter pred? (rest lst))]))

(define (my-fold-right f init lst)
  (cond [(empty? lst) init]
        [else (f (first lst) (my-fold-right f init (rest lst)))]))

> (my-map (lambda (x) (* x x)) '(1 2 3))  → '(1 4 9)
> (my-filter even? '(1 2 3 4))            → '(2 4)
> (my-fold-right + 0 '(1 2 3))            → 6
```

**Q6: `my-filter` with one call to `fold-right`**
```lisp
(define (my-filter pred? lst)
  (my-fold-right (lambda (next acc)
                   (cond [(pred? next) (cons next acc)]   ; keep: push onto acc
                         [else acc]))                     ; skip: acc unchanged
                 '()
                 lst))

> (my-filter odd? '(1 2 3 4 5))  → '(1 3 5)
```
- The key is the folding function `(lambda (next acc) ...)`: `acc` is the already-filtered rest of the list.
- Write out `my-fold-right` as well, since it isn't built into Tiny Lisp.

**Q7: currying (explanation + code)**

*Model answer:* **Currying** turns a function that takes several arguments into a chain of functions that each take **one** argument. A curried 2-argument function takes `x` and returns a new function that takes `y` and computes the result. This lets you supply only the first argument to get a useful specialized function (partial application).

```lisp
(define (curry2 f)
  (lambda (x)
    (lambda (y)
      (f x y))))

(define add5 ((curry2 +) 5))   ; partially applied: waiting for y
> (add5 3)              → 8
> (((curry2 +) 5) 3)    → 8
```

**Q8: combinators**
```lisp
(define (I x) x)                     ; identity
(define (M x) (x x))                 ; self-application; (M M) loops forever
(define (K x) (lambda (y) x))        ; constant function
(define S                            ; curried S
  (lambda (x)
    (lambda (y)
      (lambda (z)
        ((x z) (y z))))))

;; b) I in terms of S and K
(define (I a) (((S K) K) a))
```
*Why it works:* `(((S K) K) a)` = `((K a) (K a))` = `a`, because `(K a)` returns `a` whatever it is given.
- ⚠️ Write `((S K) K)`, not `(S K K)`. The curried `S` takes one argument per call (§16.6).

**Q9: `evaluate` (an interpreter for infix arithmetic)**
- a number → itself
- otherwise → evaluate the left side (`first`) and the right side (`third`), then apply the operator (`second`)
- division by 0 → `'error`

```lisp
(define (second L) (first (rest L)))
(define (third L)  (first (rest (rest L))))

(define (evaluate e)
  (cond [(number? e) e]
        [else
         (let* ([x  (evaluate (first e))]
                [op (second e)]
                [y  (evaluate (third e))])
           (cond [(or (equal? x 'error) (equal? y 'error)) 'error]
                 [(equal? op '+) (+ x y)]
                 [(equal? op '-) (- x y)]
                 [(equal? op '*) (* x y)]
                 [(equal? op '/) (cond [(= y 0) 'error]
                                       [else (/ x y)])]
                 [else (error "evaluate: unknown operator")]))]))

> (evaluate '((1 + 2) * (3 - 4)))  → -3
> (evaluate '((5 - 1) / 0))        → 'error
> (evaluate '((1 / 0) + 2))        → 'error   ; errors propagate upward
```
- This is the **same pattern as `eval-prop`** (§17.5): one `cond` clause per grammar rule, and recursion on the sub-expressions.
- Compare `op` with `equal?` against **quoted** symbols (`'+`): inside the data, `+` is a symbol, not the function.
- The error-propagation line is extra safety. Without it, `(+ 'error 2)` would crash.
- If you skip the `let*`, you need to write `(evaluate (first e))` in every clause. That works, but it's longer and easier to get wrong on paper.

### 21.8 Extra drills (similar variations)
Try each one on paper first. All answers were tested in `#lang tiny-lisp`.

1. `(any? pred? L)`: `#t` if **some** element satisfies `pred?`. `(any? even? '(1 3 4))` → `#t`, `(any? even? '())` → `#f`.
2. `(remove-first x L)`: remove only the **first** occurrence. `(remove-first 'a '(b a c a))` → `'(b c a)`.
3. `(deep-count x L)`: count `x` at any depth. `(deep-count 'a '(a (b a) ((a))))` → `3`.
4. `(intersect A B)`: the elements of `A` that are also in `B`, using `filter`. `(intersect '(1 2 3 4) '(4 2 9))` → `'(2 4)`.
5. Max of a non-empty list using one `foldr`.
6. `(flatten L)` without using any built-ins. `(flatten '(1 (2 (3)) ()))` → `'(1 2 3)`.
7. `reverse` in linear time.
8. Trace `(foldr - 0 '(5 3 1))`.

<details>
<summary>Answers</summary>

```lisp
;; 1
(define (any? pred? L)
  (cond [(empty? L) #f]
        [else (or (pred? (first L)) (any? pred? (rest L)))]))

;; 2
(define (remove-first x L)
  (cond [(empty? L) '()]
        [(equal? x (first L)) (rest L)]            ; stop here: keep the rest as-is
        [else (cons (first L) (remove-first x (rest L)))]))

;; 3
(define (deep-count x L)
  (cond [(empty? L) 0]
        [(list? (first L)) (+ (deep-count x (first L))
                              (deep-count x (rest L)))]
        [(equal? x (first L)) (+ 1 (deep-count x (rest L)))]
        [else (deep-count x (rest L))]))

;; 4  (also write out filter and member?)
(define (intersect A B)
  (filter (lambda (x) (member? x B)) A))

;; 5  (also write out foldr)
(define (list-max L)
  (foldr (lambda (next acc) (cond [(> next acc) next] [else acc]))
         (first L)
         (rest L)))

;; 6  (also write out append)
(define (flatten L)
  (cond [(empty? L) '()]
        [(list? (first L)) (append (flatten (first L)) (flatten (rest L)))]
        [else (cons (first L) (flatten (rest L)))]))

;; 7
(define (reverse-acc L acc)
  (cond [(empty? L) acc]
        [else (reverse-acc (rest L) (cons (first L) acc))]))
(define (reverse L) (reverse-acc L '()))
```

8. `(- 5 (- 3 (- 1 0)))` = 5 − (3 − 1) = 5 − 2 = `3`

</details>

### 21.9 Short-answer concept questions (model answers)
Practice saying each one in 1–3 sentences.

| Question | Model answer |
|---|---|
| What is a **special form**? Give an example. | An expression that looks like a function call but doesn't evaluate all of its arguments first. Example: `cond` evaluates only the clause it needs; `define` doesn't evaluate the name; `quote` evaluates nothing. |
| Why can't `and`/`or` be ordinary functions? | They **short-circuit**: they stop evaluating once the answer is known. A function would evaluate every argument first. |
| Symbol vs variable? | `'pi` is a symbol (data, evaluates to itself); `pi` is a variable (it is looked up to get its value). |
| What does `'` / `quote` do? | Returns its expression **unevaluated**, as data. |
| Difference between `cons`, `list`, `append`? | `cons` adds one element to the front; `list` wraps all its arguments into a new list; `append` joins two lists. |
| What is an **accumulator**, and why use one? | An extra parameter that holds the result so far. It can make functions faster (`reverse`: O(n²) → O(n)) or save memory (`sum`, `length`: no pending operations). It needs a helper/wrapper function. |
| Why is naive `reverse` quadratic? | It calls `append` (O(n)) at each of the n levels: 0 + 1 + … + (n−1) = O(n²). |
| What does `foldr` do? | `(foldr op init '(a b c))` = `(op a (op b (op c init)))`. It replaces each `cons` with `op` and `'()` with `init`. |
| What is a **closure**? | A function together with the environment (variable bindings) it was created in, so it can use **free variables** from outside, e.g. `(make-adder 1)` remembers `n = 1`. |
| What is a **free variable**? | A variable used in a function but not defined in it (not a parameter or a local). |
| What is **currying**? | Turning a multi-argument function into a chain of one-argument functions, so it can be partially applied: `((curry2 +) 5)`. |
| What does `(compose f g)` do? | Returns a function that does `g` first, then `f`: `(f (g x))`. |
| What are combinators? Why are S and K interesting? | Small pure higher-order functions. S and K alone can express **any** pure function (I = S K K). |
| What happens with `(M M)`? | An infinite loop with no explicit recursion: `(M M)` → `(M M)` → … |
| What is a **pure function**? | It has no side effects, and the same input always gives the same output. |
| What is **symbolic programming**? | Computing on expressions made of symbols (e.g. logic or algebra formulas) instead of on numbers. In Lisp, code and data are both lists, so this is natural. |
| Why are `t`/`f` symbols, not `#t`/`#f`? | The logic language is separate from Tiny Lisp. Its expressions are quoted data that Tiny Lisp processes. |
| What is a **recognizer**? | A predicate that checks whether something is a valid expression (or a particular form, like `is-and?`). |
| Interpreter vs compiler? | An interpreter (`eval-prop`, `evaluate`) computes a **value**. A compiler (`to-nand`) translates an expression into another **expression** with the same meaning. |
| How are the symbolic functions structured? | One `cond` clause per grammar rule, recursing on sub-expressions (`second` for `not`; `first` and `third` for binary operators). |

### 21.10 Night-before checklist
- [ ] Can I write `length`, `member?`, `append`, `reverse` (accumulator), `map`, `filter`, `foldr` from memory?
- [ ] Can I solve every question in §21.6 and §21.7 on a blank sheet **without looking**?
- [ ] Do I remember that there's **no `if`**, only `cond`?
- [ ] Do I remember that **`second`/`third`/`length`/`append`/`member?` must be defined** if I use them?
- [ ] Can I trace `foldr`, `append`, naive `reverse`, and `reverse-acc` by hand?
- [ ] Can I explain closures, currying, composition, combinators, and special forms in 1–2 sentences?
- [ ] Can I define `I`, `M`, `K`, curried `S`, and `I = ((S K) K)`?
- [ ] Can I write an expression evaluator (`evaluate` / `eval-prop` style) from a grammar?
- [ ] Do I know what `(cons '(1 2) '(3))`, `(list '(1 2) '(3))`, and `(append '(1 2) '(3))` each return?
- [ ] Have I timed myself? 30 minutes goes fast, so aim for about 5 minutes per coding question.
- [ ] SFU ID, pen/pencil and eraser packed. Use the washroom before the quiz.

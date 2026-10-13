# Tiny Lisp Intro — Study Notes

> Notes on [tiny_lisp_intro.md](tiny_lisp_intro.md), from the start through
> **Special Forms**. They cover: Overview, Data Types & Arithmetic, Logical
> Operators, Symbols, Predicates, Lists & Pairs, and Special Forms.

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

## 7. Quick-Reference Cheat Sheet

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
```

---

## 8. Common Mistakes / Gotchas Checklist

- [ ] Forgetting the `'` on a list literal → it gets run as a function call ("undefined" error).
- [ ] Mixing up a **variable** (`pi`) with a **symbol** (`'pi`).
- [ ] Calling `first`/`rest` on a non-list or on `'()` → contract violation.
- [ ] Expecting `(/ 10 4)` to give `2.5`. It gives the exact rational `5/2`.
- [ ] Assuming trig functions use degrees. They use radians.
- [ ] Thinking `(and a b)` ≡ `(and b a)`. Short-circuiting makes order matter.
- [ ] Using `let` when a later binding depends on an earlier one. Use `let*`.
- [ ] Expecting `(cons '(1 2) '(3))` to give `'(1 2 3)`. It gives `'((1 2) 3)`.
- [ ] Thinking `'()` is a pair. It is a list but **not** a pair.
- [ ] Thinking `'false` is a boolean. It is a symbol. Only `#t`/`#f` are booleans.
- [ ] Trying to compare symbols with `<` or concatenate them. Only `equal?` works.
- [ ] Putting the `else` clause (or a general test) before a specific test in `cond`. The first true clause wins.

---

## 9. Self-Test Questions

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

<details>
<summary>Answers</summary>

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

</details>

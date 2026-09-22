# abc_puzzle_sol.py

#
# Find all 3-digit numbers ABC such that
#
# - A, B, and C are all different digits (and A is not 0)
# - ABC + CBA is a number whose digits are all the same
# - A and B are not 0 (to avoid leading zeros)
# - ABC < CBA
#
# For example: 123 + 321 = 444
#

# Solution 1: use for-loops (and no comprehensions)
def sol_for_loops():
    solutions = []
    for A in range(1,10):
        for B in range(1,10):
            for C in range(0,10):
                ABC = int(f"{A}{B}{C}")
                CBA = int(f"{C}{B}{A}")
                result = ABC + CBA
                num_str = str(result)
                if (len(set(num_str)) == 1) and (ABC < CBA):
                    solutions.append(ABC)

    print(solutions)

# Solution 2: use a single list comprehension (no walrus operator)
def sol_list_comprehension():
    solutions = [(A, B, C) for A in range(1,10)
                           for B in range(1,10)
                           for C in range(0,10)
                           if int(f"{A}{B}{C}") < int(f"{C}{B}{A}")
                           if (len(set(str(int(f"{A}{B}{C}") + int(f"{C}{B}{A}"))))) == 1]
    print(solutions)

# Solution 3: use a single list comprehension and the walrus operator
def sol_walrus():
    solutions = [(A, B, C) for A in range(1,10)
                           for B in range(1,10)
                           for C in range(0,10)
                           if (ABC := int(f"{A}{B}{C}")) < (CBA := int(f"{C}{B}{A}"))
                           if len(set(str(ABC + CBA))) == 1]
    print(solutions)

sol_for_loops()
sol_list_comprehension()
sol_walrus()
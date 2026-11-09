-- example.hs

-- returns the product of a list
-- e.g. myproduct [1,2,3] = 6

myproduct []     = 1                  -- rule 1 (base case)
myproduct (n:ns) = n * (myproduct ns) -- rule 2 (recursive case)

-- returns n! = 1 * 2 * ... * n
-- e.g. factorial 4 = 24

factorial n = myproduct [1..n] -- factorial n -> n! = 1 * ... * n

-- returns the sum of a list
-- e.g. mysum [1,2,3] = 6

mysum []     = 0
mysum (n:ns) = n + (mysum ns)

-- returns the average of a list
-- e.g. average [1,2,3] = 2

-- returns the first element of a list
-- e.g. myhead [1,2,3] = 1

-- returns all but the first element of a list
-- e.g. mytail [1,2,3] = [2,3]

-- returns the last element of a list
-- e.g. mylast [1,2,3] = 3

-- returns the first and last element of a list
-- e.g. ends [1,2,3] = [1,3]

-- returns the length of a list
-- e.g. mylength [1,2,3] = 3

-- returns the reverse of a list
-- e.g. myreverse [1,2,3] = [3,2,1]

-- returns the lst with the last element removed
-- e.g. myinit [1,2,3] = [1,2]

-- returns the middle elements of a list; the middle of the empty list is the
-- empty list 
-- e.g. middle [1,2,3,4,5] = [2,3,4]

-- returns the the string + "s"; if the string ends in "s", returned unchanged; the
-- plural of the empty string is the empty string
-- e.g. pluralize "cat" = "cats", pluralize "cats" = "cats"

-- returns the sign of a number: "zero", "positive", or "negative"  
-- e.g. sign 0 = "zero", sign 1 = "positive", sign (-1) = "negative"


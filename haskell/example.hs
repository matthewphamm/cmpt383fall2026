-- example.hs

-- returns the product of a list
-- e.g. myproduct [1,2,3] = 6
myproduct :: Num a => [a] -> a  -- type signature
myproduct []     = 1                -- rule 1 (base case)
myproduct (n:ns) = n * myproduct ns -- rule 2 (recursive case)

-- returns n! = 1 * 2 * ... * n
-- e.g. factorial 4 = 24

factorial n = myproduct [1..n]

-- returns the sum of a list
-- e.g. mysum [1,2,3] = 6
mysum []     = 0
mysum (n:ns) = n + mysum ns


-- returns the first element of a list
-- e.g. myhead [1,2,3] = 1
myhead :: [a] -> a
myhead []    = undefined
myhead (x:_) = x   -- _ is anonymous variable

-- returns all but the first element of a list
-- e.g. mytail [1,2,3] = [2,3]
mytail :: [a] -> [a]
mytail []     = undefined
mytail (_:xs) = xs


-- returns the last element of a list
-- e.g. mylast [1,2,3] = 3
mylast :: [a] -> a
mylast []     = undefined
mylast [x]    = x
mylast (_:xs) = mylast xs


-- returns the first and last element of a list
-- e.g. ends [1,2,3] = [1,3]
ends :: [a] -> [a]
ends []           = undefined
ends [x]          = [x, x]
ends (first:rest) = [first, mylast rest]
--ends xs  = [myhead xs, mylast xs]

-- returns the length of a list
-- e.g. mylength [1,2,3] = 3
mylength []     = 0
mylength (x:xs) = 1 + mylength xs

-- returns the average of a list
-- e.g. average [1,2,3] = 2
average ns = mysum ns / mylength ns

-- returns the reverse of a list
-- e.g. myreverse [1,2,3] = [3,2,1]
myreverse []     = []
myreverse (x:xs) = myreverse xs ++ [x]

-- returns the lst with the last element removed
-- e.g. myinit [1,2,3] = [1,2]
myinit [] = undefined
myinit [x]    = []
myinit (x:xs) = x : myinit xs
-- myinit xs = reverse (mytail (reverse xs))

-- returns the middle elements of a list; the middle of the empty list is the
-- empty list 
-- e.g. middle [1,2,3,4,5] = [2,3,4]
middle []     = []
middle (_:xs) = myinit xs

-- returns the the string + "s"; if the string ends in "s", returned unchanged; the
-- plural of the empty string is the empty string
-- e.g. pluralize "cat" = "cats", pluralize "cats" = "cats"
pluralize "" = ""
pluralize s  = if mylast s == 's'
               then s
               else s ++ "s"

-- returns the sign of a number: "zero", "positive", or "negative"  
-- e.g. sign 0 = "zero", sign 1 = "positive", sign (-1) = "negative"
-- sign 0 = "zero"
-- sign x = if x < 0
--          then "negative"
--          else "positive"
sign n | n == 0    = "zero"  -- guarded equation
       | n > 0     = "positive"
       | otherwise = "negative"

myand True True   = True
myand False True  = False
myand True False  = False
myand False False = False

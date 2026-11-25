-- mylist.hs

-- List a is a recursive data representing a list of values of type a
data List a = Nil | Cons a (List a)
    deriving (Eq, Show)

nums :: List Int
nums = Cons 5 (Cons 2 (Cons 6 Nil))

names :: List String
names = Cons "cat" (Cons "dog" (Cons "bird" (Cons "cow" Nil)))

-- get the first element of a list
first :: List a -> a
first Nil        = undefined
first (Cons x _) = x

-- get the rest of a mylist
rest :: List a -> List a
rest Nil         = undefined
rest (Cons _ xs) = xs

-- get the length of a mylist
len :: List a -> Int
len Nil         = 0
len (Cons x xs) = 1 + len xs

-- mysum lst returns the sum of a List of Ints
mysum :: List Int -> Int
mysum Nil         = 0
mysum (Cons x xs) = x + mysum xs

-- mymap f lst returns a new List with f applied to each element of lst
mymap :: (a -> b) -> List a -> List b
mymap _ Nil         = Nil
mymap f (Cons x xs) = Cons (f x) (mymap f xs)

-- toString lst converts a List to a String in a simple way (could be improved)
-- basically the show call

toString :: (Show a, Eq a) => List a -> String
toString Nil         = ""
-- toString (Cons x xs) = show x ++ " " ++ toString xs
toString (Cons x xs) | len xs == 0 = show x
                     | otherwise   = show x ++ ", " ++ toString xs

-- convert a regular Haskell list to a mylist
to_List :: [a] -> List a
to_List = foldr Cons Nil

-- convert a mylist to a regular Haskell list (using recursion)
to_hlist :: List a -> [a]
to_hlist Nil         = []
to_hlist (Cons x xs) = x : (to_hlist xs)

-- old right for a mylist
foldright :: (a -> b -> b) -> b -> List a -> b
foldright _  init Nil         = init
foldright op init (Cons x xs) = x `op` (foldright op init xs)

-- convert a mylist to a regular Haskell list (using fold right)
to_hlist' :: List a -> [a]
to_hlist' = foldright (:) []

-- write filter as a List
myfilter :: (a -> Bool) -> List a -> List a
myfilter _ Nil         = Nil
myfilter f (Cons x xs) | f x       = Cons x (myfilter f xs)
                       | otherwise = myfilter f xs
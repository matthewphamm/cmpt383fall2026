# Quiz Python Question 4
def enum_rev(L):
    index = len(L) - 1
    for element in L[::-1]:    # I wrote L[-1:]
        yield(element, index)
        index -= 1

lst = ["cup", "bar", "hat", "bat"]
for value in enum_rev(lst):
    print(value)
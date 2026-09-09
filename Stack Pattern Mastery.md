# Stack Pattern Mastery

LeetCode problem list: https://leetcode.com/problem-list/stack/

A practical notes document for studying Stack problems and their major sub-patterns on LeetCode.

> A stack is the right abstraction when the most recently opened, added, or unresolved item must be handled first. Stack problems often appear as nesting validation, monotonic next-greater queries, expression parsing, greedy deletion, or simulation.

---

## 1. What is the Stack pattern?

Use a stack when:
- the latest unmatched item must be resolved first
- the problem contains nested brackets, expressions, or paths
- an element waits for a future larger or smaller element
- you need to undo, backtrack, or remove adjacent pairs
- a greedy choice must remove previously selected values
- a recursive structure can be simulated iteratively

Typical idea:
- push unresolved values or states
- inspect the top before adding or removing
- pop when the current item resolves the top
- preserve an invariant about what remains unresolved

The central invariant is:

> The stack contains exactly the unresolved candidates in the order they must be handled.

---

## 2. Sub-pattern map

### A. Matching, nesting, and cancellation

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [20. Valid Parentheses](https://leetcode.com/problems/valid-parentheses/) | Easy | Match each closing bracket with the latest opening bracket. |
| [32. Longest Valid Parentheses](https://leetcode.com/problems/longest-valid-parentheses/) | Hard | Stack stores unmatched boundary indices. |
| [678. Valid Parenthesis String](https://leetcode.com/problems/valid-parenthesis-string/) | Medium | Track possible open-parenthesis ranges. |
| [1541. Minimum Insertions to Balance a Parentheses String](https://leetcode.com/problems/minimum-insertions-to-balance-a-parentheses-string/) | Medium | Greedily resolve unmatched parentheses. |
| [921. Minimum Add to Make Parentheses Valid](https://leetcode.com/problems/minimum-add-to-make-parentheses-valid/) | Medium | Count unresolved opening and closing brackets. |

#### Solution: [20. Valid Parentheses](https://leetcode.com/problems/valid-parentheses/) - Easy

```python
class Solution:
    def isValid(self, s):
        pairs = {')': '(', ']': '[', '}': '{'}
        stack = []

        for character in s:
            if character in pairs:
                if not stack or stack.pop() != pairs[character]:
                    return False
            else:
                stack.append(character)

        return not stack
```

Why it works: a closing bracket must match the most recently opened unmatched bracket, which is exactly stack behavior.

#### Solution: [32. Longest Valid Parentheses](https://leetcode.com/problems/longest-valid-parentheses/) - Hard

```python
class Solution:
    def longestValidParentheses(self, s):
        stack = [-1]
        best = 0

        for index, character in enumerate(s):
            if character == '(':
                stack.append(index)
            else:
                stack.pop()
                if not stack:
                    stack.append(index)
                else:
                    best = max(best, index - stack[-1])

        return best
```

Why it works: the stack stores indices that can serve as boundaries before the current valid region.

#### Solution: [678. Valid Parenthesis String](https://leetcode.com/problems/valid-parenthesis-string/) - Medium

```python
class Solution:
    def checkValidString(self, s):
        minimum_open = 0
        maximum_open = 0

        for character in s:
            if character == '(':
                minimum_open += 1
                maximum_open += 1
            elif character == ')':
                minimum_open = max(0, minimum_open - 1)
                maximum_open -= 1
            else:
                minimum_open = max(0, minimum_open - 1)
                maximum_open += 1

            if maximum_open < 0:
                return False

        return minimum_open == 0
```

Why it works: maintain the smallest and largest possible number of unmatched opens after treating each star optimally or pessimistically.

#### Solution: [921. Minimum Add to Make Parentheses Valid](https://leetcode.com/problems/minimum-add-to-make-parentheses-valid/) - Medium

```python
class Solution:
    def minAddToMakeValid(self, s):
        open_count = 0
        additions = 0

        for character in s:
            if character == '(':
                open_count += 1
            elif open_count:
                open_count -= 1
            else:
                additions += 1

        return additions + open_count
```

Why it works: every unmatched closing bracket needs an opening insertion, and every remaining opening bracket needs a closing insertion.

#### Solution: [1541. Minimum Insertions to Balance a Parentheses String](https://leetcode.com/problems/minimum-insertions-to-balance-a-parentheses-string/) - Medium

```python
class Solution:
    def minInsertions(self, s):
        open_count = 0
        insertions = 0
        index = 0

        while index < len(s):
            if s[index] == '(':
                open_count += 1
            else:
                if index + 1 < len(s) and s[index + 1] == ')':
                    index += 1
                else:
                    insertions += 1

                if open_count:
                    open_count -= 1
                else:
                    insertions += 1
            index += 1

        return insertions + 2 * open_count
```

Why it works: every opening bracket requires two closing brackets, while a lone closing bracket needs one inserted partner.

---

### B. Monotonic increasing and decreasing stacks

Core idea: keep unresolved elements in sorted order so each element is pushed and popped at most once.

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [496. Next Greater Element I](https://leetcode.com/problems/next-greater-element-i/) | Easy | Decreasing stack resolves next greater values. |
| [503. Next Greater Element II](https://leetcode.com/problems/next-greater-element-ii/) | Medium | Circular next-greater scan. |
| [739. Daily Temperatures](https://leetcode.com/problems/daily-temperatures/) | Medium | Indices wait for a warmer future day. |
| [901. Online Stock Span](https://leetcode.com/problems/online-stock-span/) | Medium | Collapse dominated previous prices. |
| [84. Largest Rectangle in Histogram](https://leetcode.com/problems/largest-rectangle-in-histogram/) | Hard | Increasing stack finds maximal widths. |
| [85. Maximal Rectangle](https://leetcode.com/problems/maximal-rectangle/) | Hard | Apply histogram stack row by row. |
| [907. Sum of Subarray Minimums](https://leetcode.com/problems/sum-of-subarray-minimums/) | Medium | Count ranges where each value is the minimum. |

#### Solution: [496. Next Greater Element I](https://leetcode.com/problems/next-greater-element-i/) - Easy

```python
class Solution:
    def nextGreaterElement(self, nums1, nums2):
        next_greater = {}
        stack = []

        for value in nums2:
            while stack and stack[-1] < value:
                next_greater[stack.pop()] = value
            stack.append(value)

        return [next_greater.get(value, -1) for value in nums1]
```

Why it works: values remain on the stack until a larger value arrives and resolves them.

#### Solution: [503. Next Greater Element II](https://leetcode.com/problems/next-greater-element-ii/) - Medium

```python
class Solution:
    def nextGreaterElements(self, nums):
        result = [-1] * len(nums)
        stack = []

        for index in range(2 * len(nums)):
            current_index = index % len(nums)
            while stack and nums[stack[-1]] < nums[current_index]:
                result[stack.pop()] = nums[current_index]
            if index < len(nums):
                stack.append(current_index)

        return result
```

Why it works: scanning two copies simulates circular wraparound while the stack stores indices still waiting for a larger value.

#### Solution: [739. Daily Temperatures](https://leetcode.com/problems/daily-temperatures/) - Medium

```python
class Solution:
    def dailyTemperatures(self, temperatures):
        answer = [0] * len(temperatures)
        stack = []

        for today, temperature in enumerate(temperatures):
            while stack and temperatures[stack[-1]] < temperature:
                previous = stack.pop()
                answer[previous] = today - previous
            stack.append(today)

        return answer
```

Why it works: unresolved colder days stay on the stack until the current warmer day answers them.

#### Solution: [901. Online Stock Span](https://leetcode.com/problems/online-stock-span/) - Medium

```python
class StockSpanner:
    def __init__(self):
        self.stack = []

    def next(self, price):
        span = 1
        while self.stack and self.stack[-1][0] <= price:
            span += self.stack.pop()[1]
        self.stack.append((price, span))
        return span
```

Why it works: any previous price no greater than the current price can be merged into the current span.

#### Solution: [84. Largest Rectangle in Histogram](https://leetcode.com/problems/largest-rectangle-in-histogram/) - Hard

```python
class Solution:
    def largestRectangleArea(self, heights):
        stack = []
        best = 0
        extended = heights + [0]

        for right, height in enumerate(extended):
            while stack and extended[stack[-1]] > height:
                bar = stack.pop()
                left = stack[-1] + 1 if stack else 0
                width = right - left
                best = max(best, extended[bar] * width)
            stack.append(right)

        return best
```

Why it works: when a shorter bar appears, every taller bar popped from the stack has found its first smaller boundary on the right.

#### Solution: [85. Maximal Rectangle](https://leetcode.com/problems/maximal-rectangle/) - Hard

```python
class Solution:
    def maximalRectangle(self, matrix):
        if not matrix:
            return 0

        heights = [0] * len(matrix[0])
        best = 0

        for row in matrix:
            for column, value in enumerate(row):
                heights[column] = heights[column] + 1 if value == '1' else 0
            best = max(best, self.largestRectangleArea(heights))

        return best

    def largestRectangleArea(self, heights):
        stack = []
        best = 0

        for right in range(len(heights) + 1):
            height = heights[right] if right < len(heights) else 0
            while stack and heights[stack[-1]] > height:
                bar = stack.pop()
                left = stack[-1] + 1 if stack else 0
                best = max(best, heights[bar] * (right - left))
            stack.append(right)

        return best
```

Why it works: each matrix row becomes a histogram of consecutive ones, and the histogram stack computes its largest rectangle.

#### Solution: [907. Sum of Subarray Minimums](https://leetcode.com/problems/sum-of-subarray-minimums/) - Medium

```python
class Solution:
    def sumSubarrayMins(self, arr):
        modulo = 10**9 + 7
        stack = []
        answer = 0

        for index in range(len(arr) + 1):
            current = arr[index] if index < len(arr) else 0
            while stack and arr[stack[-1]] > current:
                minimum_index = stack.pop()
                left_count = minimum_index - (stack[-1] if stack else -1)
                right_count = index - minimum_index
                answer += arr[minimum_index] * left_count * right_count
            stack.append(index)

        return answer % modulo
```

Why it works: count how many choices of left and right boundaries make each element the unique minimum using monotonic boundaries.

---

### C. Expression parsing and evaluation

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [150. Evaluate Reverse Polish Notation](https://leetcode.com/problems/evaluate-reverse-polish-notation/) | Medium | Operands wait for the next operator. |
| [224. Basic Calculator](https://leetcode.com/problems/basic-calculator/) | Hard | Stack stores nested expression signs and totals. |
| [227. Basic Calculator II](https://leetcode.com/problems/basic-calculator-ii/) | Medium | Stack handles multiplication and division precedence. |
| [394. Decode String](https://leetcode.com/problems/decode-string/) | Medium | Stack stores nested repeat contexts. |
| [71. Simplify Path](https://leetcode.com/problems/simplify-path/) | Medium | Stack models directory navigation. |

#### Solution: [150. Evaluate Reverse Polish Notation](https://leetcode.com/problems/evaluate-reverse-polish-notation/) - Medium

```python
class Solution:
    def evalRPN(self, tokens):
        stack = []

        for token in tokens:
            if token not in {'+', '-', '*', '/'}:
                stack.append(int(token))
                continue

            right = stack.pop()
            left = stack.pop()
            if token == '+':
                stack.append(left + right)
            elif token == '-':
                stack.append(left - right)
            elif token == '*':
                stack.append(left * right)
            else:
                stack.append(int(left / right))

        return stack[-1]
```

Why it works: each operator consumes the two most recent operands and pushes the resulting value back for later operators.

#### Solution: [224. Basic Calculator](https://leetcode.com/problems/basic-calculator/) - Hard

```python
class Solution:
    def calculate(self, s):
        stack = []
        total = 0
        number = 0
        sign = 1

        for character in s:
            if character.isdigit():
                number = number * 10 + int(character)
            elif character in '+-':
                total += sign * number
                number = 0
                sign = 1 if character == '+' else -1
            elif character == '(':
                stack.append(total)
                stack.append(sign)
                total = 0
                sign = 1
            elif character == ')':
                total += sign * number
                number = 0
                total *= stack.pop()
                total += stack.pop()

        return total + sign * number
```

Why it works: when an opening parenthesis appears, save the outer total and sign; on closing, evaluate the nested expression and merge it back.

#### Solution: [227. Basic Calculator II](https://leetcode.com/problems/basic-calculator-ii/) - Medium

```python
class Solution:
    def calculate(self, s):
        stack = []
        number = 0
        operator = '+'

        for index, character in enumerate(s + '+'):
            if character.isdigit():
                number = number * 10 + int(character)
                continue
            if character == ' ':
                continue

            if operator == '+':
                stack.append(number)
            elif operator == '-':
                stack.append(-number)
            elif operator == '*':
                stack.append(stack.pop() * number)
            else:
                stack.append(int(stack.pop() / number))

            number = 0
            operator = character

        return sum(stack)
```

Why it works: addition and subtraction can wait in the stack, while multiplication and division immediately combine with the previous term.

#### Solution: [394. Decode String](https://leetcode.com/problems/decode-string/) - Medium

```python
class Solution:
    def decodeString(self, s):
        stack = []
        number = 0
        current = ''

        for character in s:
            if character.isdigit():
                number = number * 10 + int(character)
            elif character == '[':
                stack.append((current, number))
                current = ''
                number = 0
            elif character == ']':
                previous, repeat = stack.pop()
                current = previous + current * repeat
            else:
                current += character

        return current
```

Why it works: each opening bracket saves the current outer text and repeat count; closing expands the completed inner text and restores the outer context.

#### Solution: [71. Simplify Path](https://leetcode.com/problems/simplify-path/) - Medium

```python
class Solution:
    def simplifyPath(self, path):
        stack = []
        for part in path.split('/'):
            if part in {'', '.'}:
                continue
            if part == '..':
                if stack:
                    stack.pop()
            else:
                stack.append(part)
        return '/' + '/'.join(stack)
```

Why it works: directory names push onto the path, while `..` removes the most recent directory.

---

### D. Greedy stack deletion and lexicographic construction

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [402. Remove K Digits](https://leetcode.com/problems/remove-k-digits/) | Medium | Pop larger previous digits to minimize the number. |
| [316. Remove Duplicate Letters](https://leetcode.com/problems/remove-duplicate-letters/) | Medium | Monotonic lexicographic stack with future-frequency checks. |
| [1081. Smallest Subsequence of Distinct Characters](https://leetcode.com/problems/smallest-subsequence-of-distinct-characters/) | Medium | Same greedy stack principle as 316. |
| [456. 132 Pattern](https://leetcode.com/problems/132-pattern/) | Medium | Reverse monotonic stack detects a three-value pattern. |
| [921. Minimum Add to Make Parentheses Valid](https://leetcode.com/problems/minimum-add-to-make-parentheses-valid/) | Medium | Greedy unmatched-count cancellation. |

#### Solution: [402. Remove K Digits](https://leetcode.com/problems/remove-k-digits/) - Medium

```python
class Solution:
    def removeKdigits(self, num, k):
        stack = []

        for digit in num:
            while k and stack and stack[-1] > digit:
                stack.pop()
                k -= 1
            stack.append(digit)

        if k:
            stack = stack[:-k]

        return ''.join(stack).lstrip('0') or '0'
```

Why it works: removing a larger digit before a smaller incoming digit improves the number most significantly from the left.

#### Solution: [316. Remove Duplicate Letters](https://leetcode.com/problems/remove-duplicate-letters/) - Medium

```python
class Solution:
    def removeDuplicateLetters(self, s):
        remaining = {character: s.count(character) for character in set(s)}
        stack = []
        used = set()

        for character in s:
            remaining[character] -= 1
            if character in used:
                continue

            while (stack and stack[-1] > character
                   and remaining[stack[-1]] > 0):
                used.remove(stack.pop())

            stack.append(character)
            used.add(character)

        return ''.join(stack)
```

Why it works: pop a larger character only when it appears again later, preserving one copy while making the result lexicographically smaller.

#### Solution: [1081. Smallest Subsequence of Distinct Characters](https://leetcode.com/problems/smallest-subsequence-of-distinct-characters/) - Medium

```python
class Solution:
    def smallestSubsequence(self, s):
        remaining = {character: s.count(character) for character in set(s)}
        stack = []
        used = set()

        for character in s:
            remaining[character] -= 1
            if character in used:
                continue
            while stack and stack[-1] > character and remaining[stack[-1]]:
                used.remove(stack.pop())
            stack.append(character)
            used.add(character)

        return ''.join(stack)
```

Why it works: this is the same future-availability invariant as Remove Duplicate Letters, expressed with the problem's different method name.

#### Solution: [456. 132 Pattern](https://leetcode.com/problems/132-pattern/) - Medium

```python
class Solution:
    def find132pattern(self, nums):
        stack = []
        middle = float('-inf')

        for value in reversed(nums):
            if value < middle:
                return True
            while stack and stack[-1] < value:
                middle = stack.pop()
            stack.append(value)

        return False
```

Why it works: the stack stores possible high values while `middle` records the best candidate for the 2 in a 1-3-2 pattern.

---

### E. Stack simulation, traversal, and design

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [155. Min Stack](https://leetcode.com/problems/min-stack/) | Medium | Store each value with the minimum below it. |
| [225. Implement Stack using Queues](https://leetcode.com/problems/implement-stack-using-queues/) | Easy | Data-structure simulation. |
| [232. Implement Queue using Stacks](https://leetcode.com/problems/implement-queue-using-stacks/) | Easy | Two-stack amortized queue. |
| [388. Longest Absolute File Path](https://leetcode.com/problems/longest-absolute-file-path/) | Medium | Stack stores cumulative directory lengths. |
| [636. Exclusive Time of Functions](https://leetcode.com/problems/exclusive-time-of-functions/) | Medium | Stack tracks nested call frames. |
| [735. Asteroid Collision](https://leetcode.com/problems/asteroid-collision/) | Medium | Resolve collisions against the latest surviving asteroid. |

#### Solution: [155. Min Stack](https://leetcode.com/problems/min-stack/) - Medium

```python
class MinStack:
    def __init__(self):
        self.stack = []

    def push(self, val):
        current_min = min(val, self.stack[-1][1]) if self.stack else val
        self.stack.append((val, current_min))

    def pop(self):
        self.stack.pop()

    def top(self):
        return self.stack[-1][0]

    def getMin(self):
        return self.stack[-1][1]
```

Why it works: each entry stores the minimum for the entire stack below and including that entry, so getMin is O(1).

#### Solution: [225. Implement Stack using Queues](https://leetcode.com/problems/implement-stack-using-queues/) - Easy

```python
from collections import deque

class MyStack:
    def __init__(self):
        self.queue = deque()

    def push(self, x):
        self.queue.append(x)
        for _ in range(len(self.queue) - 1):
            self.queue.append(self.queue.popleft())

    def pop(self):
        return self.queue.popleft()

    def top(self):
        return self.queue[0]

    def empty(self):
        return not self.queue
```

Why it works: rotate the queue after each push so the newest item is always at the front, giving stack order.

#### Solution: [232. Implement Queue using Stacks](https://leetcode.com/problems/implement-queue-using-stacks/) - Easy

```python
class MyQueue:
    def __init__(self):
        self.in_stack = []
        self.out_stack = []

    def _move(self):
        if not self.out_stack:
            while self.in_stack:
                self.out_stack.append(self.in_stack.pop())

    def push(self, x):
        self.in_stack.append(x)

    def pop(self):
        self._move()
        return self.out_stack.pop()

    def peek(self):
        self._move()
        return self.out_stack[-1]

    def empty(self):
        return not self.in_stack and not self.out_stack
```

Why it works: the input stack receives new values, and the output stack reverses them only when needed, giving amortized O(1) operations.

#### Solution: [388. Longest Absolute File Path](https://leetcode.com/problems/longest-absolute-file-path/) - Medium

```python
class Solution:
    def lengthLongestPath(self, input):
        lengths = {0: 0}
        best = 0

        for line in input.split('\n'):
            depth = line.count('\t')
            name = line.lstrip('\t')
            lengths[depth + 1] = lengths[depth] + len(name) + 1
            if '.' in name:
                best = max(best, lengths[depth + 1] - 1)

        return best
```

Why it works: the length at each depth is the parent path length plus the current name and separator; files terminate a path.

#### Solution: [636. Exclusive Time of Functions](https://leetcode.com/problems/exclusive-time-of-functions/) - Medium

```python
class Solution:
    def exclusiveTime(self, n, logs):
        answer = [0] * n
        stack = []
        previous_time = 0

        for log in logs:
            function_id, event, timestamp = log.split(':')
            function_id = int(function_id)
            timestamp = int(timestamp)

            if event == 'start':
                if stack:
                    answer[stack[-1]] += timestamp - previous_time
                stack.append(function_id)
                previous_time = timestamp
            else:
                answer[stack.pop()] += timestamp - previous_time + 1
                previous_time = timestamp + 1

        return answer
```

Why it works: the stack identifies the currently running nested function, while previous_time marks the first not-yet-accounted timestamp.

#### Solution: [735. Asteroid Collision](https://leetcode.com/problems/asteroid-collision/) - Medium

```python
class Solution:
    def asteroidCollision(self, asteroids):
        stack = []

        for asteroid in asteroids:
            alive = True
            while alive and asteroid < 0 and stack and stack[-1] > 0:
                if stack[-1] < -asteroid:
                    stack.pop()
                elif stack[-1] == -asteroid:
                    stack.pop()
                    alive = False
                else:
                    alive = False
            if alive:
                stack.append(asteroid)

        return stack
```

Why it works: only a positive asteroid on the stack can collide with an incoming negative asteroid, and collisions always involve the latest survivor.

---

## 3. Quick pattern recognition guide

### Use a stack for nesting when you see:
- parentheses, brackets, or nested structures
- latest opening item must match the next closing item
- undoing or cancelling adjacent items

### Use a monotonic stack when you see:
- next greater or next smaller element
- nearest greater or smaller boundary
- histogram rectangles
- an item waiting for a future value to resolve it

### Use a stack for parsing when you see:
- reverse Polish notation
- nested parentheses or encoded strings
- operator precedence
- directory navigation

### Use a greedy stack when you see:
- remove k digits
- lexicographically smallest subsequence
- remove duplicate characters while preserving order

---

## 4. Core templates

### Matching brackets

```python
stack = []
for character in text:
    if character in opening:
        stack.append(character)
    elif not stack or stack.pop() != matching_opening[character]:
        return False
return not stack
```

### Next greater element

```python
stack = []
for index, value in enumerate(nums):
    while stack and nums[stack[-1]] < value:
        answer[stack.pop()] = value
    stack.append(index)
```

### Histogram boundary stack

```python
for right, height in enumerate(heights + [0]):
    while stack and heights[stack[-1]] > height:
        bar = stack.pop()
        left = stack[-1] + 1 if stack else 0
        update_area(bar, left, right)
    stack.append(right)
```

### Greedy deletion

```python
for value in values:
    while removals and stack and stack[-1] > value:
        stack.pop()
        removals -= 1
    stack.append(value)
```

---

## 5. Practice order

1. [20. Valid Parentheses](https://leetcode.com/problems/valid-parentheses/)
2. [496. Next Greater Element I](https://leetcode.com/problems/next-greater-element-i/)
3. [739. Daily Temperatures](https://leetcode.com/problems/daily-temperatures/)
4. [155. Min Stack](https://leetcode.com/problems/min-stack/)
5. [150. Evaluate Reverse Polish Notation](https://leetcode.com/problems/evaluate-reverse-polish-notation/)
6. [394. Decode String](https://leetcode.com/problems/decode-string/)
7. [402. Remove K Digits](https://leetcode.com/problems/remove-k-digits/)
8. [84. Largest Rectangle in Histogram](https://leetcode.com/problems/largest-rectangle-in-histogram/)
9. [32. Longest Valid Parentheses](https://leetcode.com/problems/longest-valid-parentheses/)
10. [735. Asteroid Collision](https://leetcode.com/problems/asteroid-collision/)

---

## 6. Cheat sheet

- Matching: push openings, pop only the matching closing bracket.
- Monotonic increasing stack: useful for next smaller values and histogram widths.
- Monotonic decreasing stack: useful for next greater values.
- Parsing: push the context before entering a nested structure.
- Greedy deletion: pop while the previous choice is worse and can be replaced later.
- Design: store extra state with each stack entry when O(1) queries are required.
- Traversal: the stack represents active unresolved frames.

---

## 7. Interview trigger

Reach for a Stack when the statement includes:

- balanced brackets or nested expressions
- next greater/smaller element
- nearest boundary
- undo, cancel, remove adjacent pairs
- evaluate or decode nested syntax
- largest rectangle or span

Before coding, define exactly what each stack entry means and what event causes it to be popped.

---

## 8. Common mistakes

- popping without checking whether the stack is empty
- storing values when indices are required for distances or widths
- forgetting the sentinel index in parentheses problems
- using the wrong strictness for equal values in monotonic stacks
- forgetting circular wraparound in next-greater problems
- removing a greedy value that never appears again
- losing the previous timestamp while simulating nested calls

---

## 9. Current coverage

Every problem currently listed in the Stack sub-pattern tables and practice order has a direct solution above.

Current mapped inventory:

- 27 unique Stack problems
- 27 direct solutions
- 0 unsolved entries in the current file

The attached Stack export is now represented in the backlog below. Existing solved problems are excluded from that backlog.

---

## 10. Remaining problems from the attached Stack list

These 152 problems were present in the attachment but do not yet have direct solutions above. They are listed here as the next solution backlog. Existing solved problems are intentionally excluded.

- [42. Trapping Rain Water](https://leetcode.com/problems/trapping-rain-water/) - Hard
- [94. Binary Tree Inorder Traversal](https://leetcode.com/problems/binary-tree-inorder-traversal/) - Easy
- [114. Flatten Binary Tree to Linked List](https://leetcode.com/problems/flatten-binary-tree-to-linked-list/) - Medium
- [143. Reorder List](https://leetcode.com/problems/reorder-list/) - Medium
- [144. Binary Tree Preorder Traversal](https://leetcode.com/problems/binary-tree-preorder-traversal/) - Easy
- [145. Binary Tree Postorder Traversal](https://leetcode.com/problems/binary-tree-postorder-traversal/) - Easy
- [173. Binary Search Tree Iterator](https://leetcode.com/problems/binary-search-tree-iterator/) - Medium
- [234. Palindrome Linked List](https://leetcode.com/problems/palindrome-linked-list/) - Easy
- [255. Verify Preorder Sequence in Binary Search Tree](https://leetcode.com/problems/verify-preorder-sequence-in-binary-search-tree/) - Medium
- [272. Closest Binary Search Tree Value II](https://leetcode.com/problems/closest-binary-search-tree-value-ii/) - Hard
- [321. Create Maximum Number](https://leetcode.com/problems/create-maximum-number/) - Hard
- [331. Verify Preorder Serialization of a Binary Tree](https://leetcode.com/problems/verify-preorder-serialization-of-a-binary-tree/) - Medium
- [341. Flatten Nested List Iterator](https://leetcode.com/problems/flatten-nested-list-iterator/) - Medium
- [364. Nested List Weight Sum II](https://leetcode.com/problems/nested-list-weight-sum-ii/) - Medium
- [385. Mini Parser](https://leetcode.com/problems/mini-parser/) - Medium
- [426. Convert Binary Search Tree to Sorted Doubly Linked List](https://leetcode.com/problems/convert-binary-search-tree-to-sorted-doubly-linked-list/) - Medium
- [439. Ternary Expression Parser](https://leetcode.com/problems/ternary-expression-parser/) - Medium
- [445. Add Two Numbers II](https://leetcode.com/problems/add-two-numbers-ii/) - Medium
- [484. Find Permutation](https://leetcode.com/problems/find-permutation/) - Medium
- [488. Zuma Game](https://leetcode.com/problems/zuma-game/) - Hard
- [536. Construct Binary Tree from String](https://leetcode.com/problems/construct-binary-tree-from-string/) - Medium
- [581. Shortest Unsorted Continuous Subarray](https://leetcode.com/problems/shortest-unsorted-continuous-subarray/) - Medium
- [589. N-ary Tree Preorder Traversal](https://leetcode.com/problems/n-ary-tree-preorder-traversal/) - Easy
- [590. N-ary Tree Postorder Traversal](https://leetcode.com/problems/n-ary-tree-postorder-traversal/) - Easy
- [591. Tag Validator](https://leetcode.com/problems/tag-validator/) - Hard
- [654. Maximum Binary Tree](https://leetcode.com/problems/maximum-binary-tree/) - Medium
- [682. Baseball Game](https://leetcode.com/problems/baseball-game/) - Easy
- [716. Max Stack](https://leetcode.com/problems/max-stack/) - Hard
- [726. Number of Atoms](https://leetcode.com/problems/number-of-atoms/) - Hard
- [736. Parse Lisp Expression](https://leetcode.com/problems/parse-lisp-expression/) - Hard
- [768. Max Chunks To Make Sorted II](https://leetcode.com/problems/max-chunks-to-make-sorted-ii/) - Hard
- [769. Max Chunks To Make Sorted](https://leetcode.com/problems/max-chunks-to-make-sorted/) - Medium
- [770. Basic Calculator IV](https://leetcode.com/problems/basic-calculator-iv/) - Hard
- [772. Basic Calculator III](https://leetcode.com/problems/basic-calculator-iii/) - Hard
- [844. Backspace String Compare](https://leetcode.com/problems/backspace-string-compare/) - Easy
- [853. Car Fleet](https://leetcode.com/problems/car-fleet/) - Medium
- [856. Score of Parentheses](https://leetcode.com/problems/score-of-parentheses/) - Medium
- [880. Decoded String at Index](https://leetcode.com/problems/decoded-string-at-index/) - Medium
- [895. Maximum Frequency Stack](https://leetcode.com/problems/maximum-frequency-stack/) - Hard
- [897. Increasing Order Search Tree](https://leetcode.com/problems/increasing-order-search-tree/) - Easy
- [936. Stamping The Sequence](https://leetcode.com/problems/stamping-the-sequence/) - Hard
- [946. Validate Stack Sequences](https://leetcode.com/problems/validate-stack-sequences/) - Medium
- [962. Maximum Width Ramp](https://leetcode.com/problems/maximum-width-ramp/) - Medium
- [975. Odd Even Jump](https://leetcode.com/problems/odd-even-jump/) - Hard
- [1003. Check If Word Is Valid After Substitutions](https://leetcode.com/problems/check-if-word-is-valid-after-substitutions/) - Medium
- [1006. Clumsy Factorial](https://leetcode.com/problems/clumsy-factorial/) - Medium
- [1008. Construct Binary Search Tree from Preorder Traversal](https://leetcode.com/problems/construct-binary-search-tree-from-preorder-traversal/) - Medium
- [1019. Next Greater Node In Linked List](https://leetcode.com/problems/next-greater-node-in-linked-list/) - Medium
- [1021. Remove Outermost Parentheses](https://leetcode.com/problems/remove-outermost-parentheses/) - Easy
- [1047. Remove All Adjacent Duplicates In String](https://leetcode.com/problems/remove-all-adjacent-duplicates-in-string/) - Easy
- [1063. Number of Valid Subarrays](https://leetcode.com/problems/number-of-valid-subarrays/) - Hard
- [1087. Brace Expansion](https://leetcode.com/problems/brace-expansion/) - Medium
- [1096. Brace Expansion II](https://leetcode.com/problems/brace-expansion-ii/) - Hard
- [1106. Parsing A Boolean Expression](https://leetcode.com/problems/parsing-a-boolean-expression/) - Hard
- [1111. Maximum Nesting Depth of Two Valid Parentheses Strings](https://leetcode.com/problems/maximum-nesting-depth-of-two-valid-parentheses-strings/) - Medium
- [1124. Longest Well-Performing Interval](https://leetcode.com/problems/longest-well-performing-interval/) - Medium
- [1130. Minimum Cost Tree From Leaf Values](https://leetcode.com/problems/minimum-cost-tree-from-leaf-values/) - Medium
- [1172. Dinner Plate Stacks](https://leetcode.com/problems/dinner-plate-stacks/) - Hard
- [1190. Reverse Substrings Between Each Pair of Parentheses](https://leetcode.com/problems/reverse-substrings-between-each-pair-of-parentheses/) - Medium
- [1209. Remove All Adjacent Duplicates in String II](https://leetcode.com/problems/remove-all-adjacent-duplicates-in-string-ii/) - Medium
- [1214. Two Sum BSTs](https://leetcode.com/problems/two-sum-bsts/) - Medium
- [1249. Minimum Remove to Make Valid Parentheses](https://leetcode.com/problems/minimum-remove-to-make-valid-parentheses/) - Medium
- [1265. Print Immutable Linked List in Reverse](https://leetcode.com/problems/print-immutable-linked-list-in-reverse/) - Medium
- [1381. Design a Stack With Increment Operation](https://leetcode.com/problems/design-a-stack-with-increment-operation/) - Medium
- [1441. Build an Array With Stack Operations](https://leetcode.com/problems/build-an-array-with-stack-operations/) - Medium
- [1472. Design Browser History](https://leetcode.com/problems/design-browser-history/) - Medium
- [1475. Final Prices With a Special Discount in a Shop](https://leetcode.com/problems/final-prices-with-a-special-discount-in-a-shop/) - Easy
- [1504. Count Submatrices With All Ones](https://leetcode.com/problems/count-submatrices-with-all-ones/) - Medium
- [1526. Minimum Number of Increments on Subarrays to Form a Target Array](https://leetcode.com/problems/minimum-number-of-increments-on-subarrays-to-form-a-target-array/) - Hard
- [1544. Make The String Great](https://leetcode.com/problems/make-the-string-great/) - Easy
- [1574. Shortest Subarray to be Removed to Make Array Sorted](https://leetcode.com/problems/shortest-subarray-to-be-removed-to-make-array-sorted/) - Medium
- [1586. Binary Search Tree Iterator II](https://leetcode.com/problems/binary-search-tree-iterator-ii/) - Medium
- [1597. Build Binary Expression Tree From Infix Expression](https://leetcode.com/problems/build-binary-expression-tree-from-infix-expression/) - Hard
- [1598. Crawler Log Folder](https://leetcode.com/problems/crawler-log-folder/) - Easy
- [1614. Maximum Nesting Depth of the Parentheses](https://leetcode.com/problems/maximum-nesting-depth-of-the-parentheses/) - Easy
- [1628. Design an Expression Tree With Evaluate Function](https://leetcode.com/problems/design-an-expression-tree-with-evaluate-function/) - Medium
- [1653. Minimum Deletions to Make String Balanced](https://leetcode.com/problems/minimum-deletions-to-make-string-balanced/) - Medium
- [1673. Find the Most Competitive Subsequence](https://leetcode.com/problems/find-the-most-competitive-subsequence/) - Medium
- [1700. Number of Students Unable to Eat Lunch](https://leetcode.com/problems/number-of-students-unable-to-eat-lunch/) - Easy
- [1717. Maximum Score From Removing Substrings](https://leetcode.com/problems/maximum-score-from-removing-substrings/) - Medium
- [1762. Buildings With an Ocean View](https://leetcode.com/problems/buildings-with-an-ocean-view/) - Medium
- [1776. Car Fleet II](https://leetcode.com/problems/car-fleet-ii/) - Hard
- [1793. Maximum Score of a Good Subarray](https://leetcode.com/problems/maximum-score-of-a-good-subarray/) - Hard
- [1856. Maximum Subarray Min-Product](https://leetcode.com/problems/maximum-subarray-min-product/) - Medium
- [1896. Minimum Cost to Change the Final Value of Expression](https://leetcode.com/problems/minimum-cost-to-change-the-final-value-of-expression/) - Hard
- [1910. Remove All Occurrences of a Substring](https://leetcode.com/problems/remove-all-occurrences-of-a-substring/) - Medium
- [1944. Number of Visible People in a Queue](https://leetcode.com/problems/number-of-visible-people-in-a-queue/) - Hard
- [1950. Maximum of Minimum Values in All Subarrays](https://leetcode.com/problems/maximum-of-minimum-values-in-all-subarrays/) - Medium
- [1963. Minimum Number of Swaps to Make the String Balanced](https://leetcode.com/problems/minimum-number-of-swaps-to-make-the-string-balanced/) - Medium
- [1966. Binary Searchable Numbers in an Unsorted Array](https://leetcode.com/problems/binary-searchable-numbers-in-an-unsorted-array/) - Medium
- [1996. The Number of Weak Characters in the Game](https://leetcode.com/problems/the-number-of-weak-characters-in-the-game/) - Medium
- [2000. Reverse Prefix of Word](https://leetcode.com/problems/reverse-prefix-of-word/) - Easy
- [2019. The Score of Students Solving Math Expression](https://leetcode.com/problems/the-score-of-students-solving-math-expression/) - Hard
- [2030. Smallest K-Length Subsequence With Occurrences of a Letter](https://leetcode.com/problems/smallest-k-length-subsequence-with-occurrences-of-a-letter/) - Hard
- [2104. Sum of Subarray Ranges](https://leetcode.com/problems/sum-of-subarray-ranges/) - Medium
- [2116. Check if a Parentheses String Can Be Valid](https://leetcode.com/problems/check-if-a-parentheses-string-can-be-valid/) - Medium
- [2130. Maximum Twin Sum of a Linked List](https://leetcode.com/problems/maximum-twin-sum-of-a-linked-list/) - Medium
- [2197. Replace Non-Coprime Numbers in Array](https://leetcode.com/problems/replace-non-coprime-numbers-in-array/) - Hard
- [2211. Count Collisions on a Road](https://leetcode.com/problems/count-collisions-on-a-road/) - Medium
- [2216. Minimum Deletions to Make Array Beautiful](https://leetcode.com/problems/minimum-deletions-to-make-array-beautiful/) - Medium
- [2281. Sum of Total Strength of Wizards](https://leetcode.com/problems/sum-of-total-strength-of-wizards/) - Hard
- [2282. Number of People That Can Be Seen in a Grid](https://leetcode.com/problems/number-of-people-that-can-be-seen-in-a-grid/) - Medium
- [2289. Steps to Make Array Non-decreasing](https://leetcode.com/problems/steps-to-make-array-non-decreasing/) - Medium
- [2296. Design a Text Editor](https://leetcode.com/problems/design-a-text-editor/) - Hard
- [2297. Jump Game VIII](https://leetcode.com/problems/jump-game-viii/) - Medium
- [2334. Subarray With Elements Greater Than Varying Threshold](https://leetcode.com/problems/subarray-with-elements-greater-than-varying-threshold/) - Hard
- [2345. Finding the Number of Visible Mountains](https://leetcode.com/problems/finding-the-number-of-visible-mountains/) - Medium
- [2355. Maximum Number of Books You Can Take](https://leetcode.com/problems/maximum-number-of-books-you-can-take/) - Hard
- [2375. Construct Smallest Number From DI String](https://leetcode.com/problems/construct-smallest-number-from-di-string/) - Medium
- [2390. Removing Stars From a String](https://leetcode.com/problems/removing-stars-from-a-string/) - Medium
- [2434. Using a Robot to Print the Lexicographically Smallest String](https://leetcode.com/problems/using-a-robot-to-print-the-lexicographically-smallest-string/) - Medium
- [2454. Next Greater Element IV](https://leetcode.com/problems/next-greater-element-iv/) - Hard
- [2487. Remove Nodes From Linked List](https://leetcode.com/problems/remove-nodes-from-linked-list/) - Medium
- [2524. Maximum Frequency Score of a Subarray](https://leetcode.com/problems/maximum-frequency-score-of-a-subarray/) - Hard
- [2589. Minimum Time to Complete All Tasks](https://leetcode.com/problems/minimum-time-to-complete-all-tasks/) - Hard
- [2617. Minimum Number of Visited Cells in a Grid](https://leetcode.com/problems/minimum-number-of-visited-cells-in-a-grid/) - Hard
- [2645. Minimum Additions to Make Valid String](https://leetcode.com/problems/minimum-additions-to-make-valid-string/) - Medium
- [2696. Minimum String Length After Removing Substrings](https://leetcode.com/problems/minimum-string-length-after-removing-substrings/) - Easy
- [2736. Maximum Sum Queries](https://leetcode.com/problems/maximum-sum-queries/) - Hard
- [2751. Robot Collisions](https://leetcode.com/problems/robot-collisions/) - Hard
- [2764. Is Array a Preorder of Some ‌Binary Tree](https://leetcode.com/problems/is-array-a-preorder-of-some-binary-tree/) - Medium
- [2813. Maximum Elegance of a K-Length Subsequence](https://leetcode.com/problems/maximum-elegance-of-a-k-length-subsequence/) - Hard
- [2816. Double a Number Represented as a Linked List](https://leetcode.com/problems/double-a-number-represented-as-a-linked-list/) - Medium
- [2818. Apply Operations to Maximize Score](https://leetcode.com/problems/apply-operations-to-maximize-score/) - Hard
- [2832. Maximal Range That Each Element Is Maximum in It](https://leetcode.com/problems/maximal-range-that-each-element-is-maximum-in-it/) - Medium
- [2863. Maximum Length of Semi-Decreasing Subarrays](https://leetcode.com/problems/maximum-length-of-semi-decreasing-subarrays/) - Medium
- [2865. Beautiful Towers I](https://leetcode.com/problems/beautiful-towers-i/) - Medium
- [2866. Beautiful Towers II](https://leetcode.com/problems/beautiful-towers-ii/) - Medium
- [2940. Find Building Where Alice and Bob Can Meet](https://leetcode.com/problems/find-building-where-alice-and-bob-can-meet/) - Hard
- [2945. Find Maximum Non-decreasing Array Length](https://leetcode.com/problems/find-maximum-non-decreasing-array-length/) - Hard
- [3113. Find the Number of Subarrays Where Boundary Elements Are Maximum](https://leetcode.com/problems/find-the-number-of-subarrays-where-boundary-elements-are-maximum/) - Hard
- [3170. Lexicographically Minimum String After Removing Stars](https://leetcode.com/problems/lexicographically-minimum-string-after-removing-stars/) - Medium
- [3174. Clear Digits](https://leetcode.com/problems/clear-digits/) - Easy
- [3205. Maximum Array Hopping Score I](https://leetcode.com/problems/maximum-array-hopping-score-i/) - Medium
- [3221. Maximum Array Hopping Score II](https://leetcode.com/problems/maximum-array-hopping-score-ii/) - Medium
- [3229. Minimum Operations to Make Array Equal to Target](https://leetcode.com/problems/minimum-operations-to-make-array-equal-to-target/) - Hard
- [3359. Find Sorted Submatrices With Maximum Element at Most K](https://leetcode.com/problems/find-sorted-submatrices-with-maximum-element-at-most-k/) - Hard
- [3412. Find Mirror Score of a String](https://leetcode.com/problems/find-mirror-score-of-a-string/) - Medium
- [3420. Count Non-Decreasing Subarrays After K Operations](https://leetcode.com/problems/count-non-decreasing-subarrays-after-k-operations/) - Hard
- [3430. Maximum and Minimum Sums of at Most Size K Subarrays](https://leetcode.com/problems/maximum-and-minimum-sums-of-at-most-size-k-subarrays/) - Hard
- [3523. Make Array Non-decreasing](https://leetcode.com/problems/make-array-non-decreasing/) - Medium
- [3542. Minimum Operations to Convert All Elements to Zero](https://leetcode.com/problems/minimum-operations-to-convert-all-elements-to-zero/) - Medium
- [3555. Smallest Subarray to Sort in Every Sliding Window](https://leetcode.com/problems/smallest-subarray-to-sort-in-every-sliding-window/) - Medium
- [3561. Resulting String After Adjacent Removals](https://leetcode.com/problems/resulting-string-after-adjacent-removals/) - Medium
- [3638. Maximum Balanced Shipments](https://leetcode.com/problems/maximum-balanced-shipments/) - Medium
- [3676. Count Bowl Subarrays](https://leetcode.com/problems/count-bowl-subarrays/) - Medium
- [3703. Remove K-Balanced Substrings](https://leetcode.com/problems/remove-k-balanced-substrings/) - Medium
- [3746. Minimum String Length After Balanced Removals](https://leetcode.com/problems/minimum-string-length-after-balanced-removals/) - Medium
- [3749. Evaluate Valid Expressions](https://leetcode.com/problems/evaluate-valid-expressions/) - Hard
- [3816. Lexicographically Smallest String After Deleting Duplicate Characters](https://leetcode.com/problems/lexicographically-smallest-string-after-deleting-duplicate-characters/) - Hard
- [3834. Merge Adjacent Equal Elements](https://leetcode.com/problems/merge-adjacent-equal-elements/) - Medium
- [3878. Count Good Subarrays](https://leetcode.com/problems/count-good-subarrays/) - Hard
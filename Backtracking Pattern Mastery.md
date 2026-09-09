# Backtracking Pattern Mastery

LeetCode problem list: https://leetcode.com/problem-list/backtracking/

A practical notes document for studying Backtracking and its major sub-patterns on LeetCode.

> Backtracking explores a decision tree. At each step, choose an available option, recurse with that choice, and undo it before trying the next option. The quality of a backtracking solution comes from its state definition, pruning rules, and careful restoration of state.

---

## 1. What is the Backtracking pattern?

Use Backtracking when:
- the problem asks for all valid combinations, arrangements, or paths
- each decision creates multiple future choices
- a partial solution can be rejected early
- choices must be undone before trying another branch
- the answer is naturally represented as a search tree

Every Backtracking solution needs:
- a state describing the current partial answer
- a choice list
- a base case for a complete answer
- a validity or pruning rule
- an undo step

The central invariant is:

> The current path contains exactly the choices made from the root of the decision tree to this recursive call.

---

## 2. Sub-pattern map

### A. Subsets, combinations, and choose/skip recursion

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [77. Combinations](https://leetcode.com/problems/combinations/) | Medium | Choose k values without replacement. |
| [78. Subsets](https://leetcode.com/problems/subsets/) | Medium | Include/exclude every value. |
| [90. Subsets II](https://leetcode.com/problems/subsets-ii/) | Medium | Duplicate-aware subset generation. |
| [39. Combination Sum](https://leetcode.com/problems/combination-sum/) | Medium | Reuse candidates while reducing the remainder. |
| [40. Combination Sum II](https://leetcode.com/problems/combination-sum-ii/) | Medium | Use each candidate once and skip duplicates. |
| [216. Combination Sum III](https://leetcode.com/problems/combination-sum-iii/) | Medium | Fixed count and target pruning. |

#### Solution: [77. Combinations](https://leetcode.com/problems/combinations/) - Medium

```python
class Solution:
    def combine(self, n, k):
        result = []

        def backtrack(start, path):
            if len(path) == k:
                result.append(path[:])
                return
            for value in range(start, n + 1):
                path.append(value)
                backtrack(value + 1, path)
                path.pop()

        backtrack(1, [])
        return result
```

Why it works: each level chooses the next larger value, preventing duplicate combinations and preserving order.

#### Solution: [78. Subsets](https://leetcode.com/problems/subsets/) - Medium

```python
class Solution:
    def subsets(self, nums):
        result = []

        def backtrack(index, path):
            if index == len(nums):
                result.append(path[:])
                return
            backtrack(index + 1, path)
            path.append(nums[index])
            backtrack(index + 1, path)
            path.pop()

        backtrack(0, [])
        return result
```

Why it works: every element creates exactly two branches: exclude it or include it.

#### Solution: [90. Subsets II](https://leetcode.com/problems/subsets-ii/) - Medium

```python
class Solution:
    def subsetsWithDup(self, nums):
        nums.sort()
        result = []

        def backtrack(start, path):
            result.append(path[:])
            for index in range(start, len(nums)):
                if index > start and nums[index] == nums[index - 1]:
                    continue
                path.append(nums[index])
                backtrack(index + 1, path)
                path.pop()

        backtrack(0, [])
        return result
```

Why it works: sorting makes duplicates adjacent, and skipping equal values at the same depth removes duplicate branches.

#### Solution: [39. Combination Sum](https://leetcode.com/problems/combination-sum/) - Medium

```python
class Solution:
    def combinationSum(self, candidates, target):
        candidates.sort()
        result = []

        def backtrack(start, remaining, path):
            if remaining == 0:
                result.append(path[:])
                return
            for index in range(start, len(candidates)):
                value = candidates[index]
                if value > remaining:
                    break
                path.append(value)
                backtrack(index, remaining - value, path)
                path.pop()

        backtrack(0, target, [])
        return result
```

Why it works: passing the same index allows reuse, while the start index prevents duplicate orderings.

#### Solution: [40. Combination Sum II](https://leetcode.com/problems/combination-sum-ii/) - Medium

```python
class Solution:
    def combinationSum2(self, candidates, target):
        candidates.sort()
        result = []

        def backtrack(start, remaining, path):
            if remaining == 0:
                result.append(path[:])
                return
            for index in range(start, len(candidates)):
                if index > start and candidates[index] == candidates[index - 1]:
                    continue
                if candidates[index] > remaining:
                    break
                path.append(candidates[index])
                backtrack(index + 1, remaining - candidates[index], path)
                path.pop()

        backtrack(0, target, [])
        return result
```

Why it works: move to index + 1 after choosing a value so each input position is used once, and skip duplicate choices at one depth.

#### Solution: [216. Combination Sum III](https://leetcode.com/problems/combination-sum-iii/) - Medium

```python
class Solution:
    def combinationSum3(self, k, n):
        result = []

        def backtrack(start, remaining, path):
            if len(path) == k:
                if remaining == 0:
                    result.append(path[:])
                return
            for value in range(start, 10):
                if value > remaining:
                    break
                path.append(value)
                backtrack(value + 1, remaining - value, path)
                path.pop()

        backtrack(1, n, [])
        return result
```

Why it works: values are chosen in increasing order, and the recursion stops as soon as the fixed count is reached.

---

### B. Permutations and arrangement generation

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [46. Permutations](https://leetcode.com/problems/permutations/) | Medium | Choose every unused value at each depth. |
| [47. Permutations II](https://leetcode.com/problems/permutations-ii/) | Medium | Duplicate-aware permutations. |
| [31. Next Permutation](https://leetcode.com/problems/next-permutation/) | Medium | Construct the next lexicographic arrangement. |
| [60. Permutation Sequence](https://leetcode.com/problems/permutation-sequence/) | Hard | Select one permutation using factorial blocks. |
| [667. Beautiful Arrangement II](https://leetcode.com/problems/beautiful-arrangement-ii/) | Medium | Construct an arrangement satisfying difference constraints. |

#### Solution: [46. Permutations](https://leetcode.com/problems/permutations/) - Medium

```python
class Solution:
    def permute(self, nums):
        result = []

        def backtrack(path, used):
            if len(path) == len(nums):
                result.append(path[:])
                return
            for index, value in enumerate(nums):
                if used[index]:
                    continue
                used[index] = True
                path.append(value)
                backtrack(path, used)
                path.pop()
                used[index] = False

        backtrack([], [False] * len(nums))
        return result
```

Why it works: each depth fills one position with an unused number, and undoing the choice enables every ordering.

#### Solution: [47. Permutations II](https://leetcode.com/problems/permutations-ii/) - Medium

```python
class Solution:
    def permuteUnique(self, nums):
        nums.sort()
        result = []

        def backtrack(path, used):
            if len(path) == len(nums):
                result.append(path[:])
                return
            for index, value in enumerate(nums):
                if used[index] or (index > 0 and nums[index] == nums[index - 1] and not used[index - 1]):
                    continue
                used[index] = True
                path.append(value)
                backtrack(path, used)
                path.pop()
                used[index] = False

        backtrack([], [False] * len(nums))
        return result
```

Why it works: sorted duplicates are skipped only when they would begin equivalent branches at the same recursion depth.

#### Solution: [60. Permutation Sequence](https://leetcode.com/problems/permutation-sequence/) - Hard

```python
import math

class Solution:
    def getPermutation(self, n, k):
        numbers = list(range(1, n + 1))
        result = []
        k -= 1

        for remaining in range(n, 0, -1):
            block = math.factorial(remaining - 1)
            index, k = divmod(k, block)
            result.append(str(numbers.pop(index)))

        return ''.join(result)
```

Why it works: permutations sharing a prefix form factorial-sized blocks, so choose the correct block directly instead of generating all permutations.

---

### C. String partitioning and constrained construction

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [17. Letter Combinations of a Phone Number](https://leetcode.com/problems/letter-combinations-of-a-phone-number/) | Medium | Choose one character for each digit. |
| [22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/) | Medium | Add only choices that preserve validity. |
| [131. Palindrome Partitioning](https://leetcode.com/problems/palindrome-partitioning/) | Medium | Choose palindrome prefixes recursively. |
| [93. Restore IP Addresses](https://leetcode.com/problems/restore-ip-addresses/) | Medium | Build exactly four valid segments. |
| [140. Word Break II](https://leetcode.com/problems/word-break-ii/) | Hard | Try dictionary words and construct sentences. |
| [282. Expression Add Operators](https://leetcode.com/problems/expression-add-operators/) | Hard | Insert operators while tracking evaluation state. |

#### Solution: [17. Letter Combinations of a Phone Number](https://leetcode.com/problems/letter-combinations-of-a-phone-number/) - Medium

```python
class Solution:
    def letterCombinations(self, digits):
        if not digits:
            return []

        mapping = {
            '2': 'abc', '3': 'def', '4': 'ghi', '5': 'jkl',
            '6': 'mno', '7': 'pqrs', '8': 'tuv', '9': 'wxyz'
        }
        result = []

        def backtrack(index, path):
            if index == len(digits):
                result.append(''.join(path))
                return
            for character in mapping[digits[index]]:
                path.append(character)
                backtrack(index + 1, path)
                path.pop()

        backtrack(0, [])
        return result
```

Why it works: one recursion level corresponds to one digit, and each level tries every mapped character.

#### Solution: [22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/) - Medium

```python
class Solution:
    def generateParenthesis(self, n):
        result = []

        def backtrack(path, opened, closed):
            if len(path) == 2 * n:
                result.append(''.join(path))
                return
            if opened < n:
                path.append('(')
                backtrack(path, opened + 1, closed)
                path.pop()
            if closed < opened:
                path.append(')')
                backtrack(path, opened, closed + 1)
                path.pop()

        backtrack([], 0, 0)
        return result
```

Why it works: never place a closing bracket unless an unmatched opening bracket exists.

#### Solution: [131. Palindrome Partitioning](https://leetcode.com/problems/palindrome-partitioning/) - Medium

```python
class Solution:
    def partition(self, s):
        result = []

        def backtrack(start, path):
            if start == len(s):
                result.append(path[:])
                return
            for end in range(start, len(s)):
                piece = s[start:end + 1]
                if piece != piece[::-1]:
                    continue
                path.append(piece)
                backtrack(end + 1, path)
                path.pop()

        backtrack(0, [])
        return result
```

Why it works: at each position, choose every palindromic prefix and recursively partition the remaining suffix.

#### Solution: [93. Restore IP Addresses](https://leetcode.com/problems/restore-ip-addresses/) - Medium

```python
class Solution:
    def restoreIpAddresses(self, s):
        result = []

        def backtrack(index, path):
            remaining_parts = 4 - len(path)
            remaining_characters = len(s) - index
            if remaining_characters < remaining_parts or remaining_characters > 3 * remaining_parts:
                return
            if len(path) == 4:
                if index == len(s):
                    result.append('.'.join(path))
                return

            for end in range(index, min(index + 3, len(s))):
                piece = s[index:end + 1]
                if len(piece) > 1 and piece[0] == '0':
                    break
                if int(piece) > 255:
                    continue
                path.append(piece)
                backtrack(end + 1, path)
                path.pop()

        backtrack(0, [])
        return result
```

Why it works: build exactly four numeric parts and prune when the remaining characters cannot fill the remaining parts.

#### Solution: [140. Word Break II](https://leetcode.com/problems/word-break-ii/) - Hard

```python
from functools import lru_cache

class Solution:
    def wordBreak(self, s, wordDict):
        words = set(wordDict)

        @lru_cache(None)
        def build(start):
            if start == len(s):
                return ['']
            result = []
            for end in range(start + 1, len(s) + 1):
                word = s[start:end]
                if word not in words:
                    continue
                for suffix in build(end):
                    result.append(word if not suffix else word + ' ' + suffix)
            return result

        return build(0)
```

Why it works: try every dictionary word that matches the current prefix, then memoize all valid sentence completions of the remaining suffix.

---

### D. Grid, board, and graph backtracking

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [37. Sudoku Solver](https://leetcode.com/problems/sudoku-solver/) | Hard | Fill cells with constraint-based backtracking. |
| [51. N-Queens](https://leetcode.com/problems/n-queens/) | Hard | Place one queen per row with pruning. |
| [52. N-Queens II](https://leetcode.com/problems/n-queens-ii/) | Hard | Count valid queen placements. |
| [79. Word Search](https://leetcode.com/problems/word-search/) | Medium | Explore neighboring cells and undo visits. |
| [212. Word Search II](https://leetcode.com/problems/word-search-ii/) | Hard | Trie-guided board backtracking. |
| [980. Unique Paths III](https://leetcode.com/problems/unique-paths-iii/) | Hard | Visit every required grid cell exactly once. |
| [1255. Maximum Score Words Formed by Letters](https://leetcode.com/problems/maximum-score-words-formed-by-letters/) | Hard | Choose or skip words under letter constraints. |

#### Solution: [37. Sudoku Solver](https://leetcode.com/problems/sudoku-solver/) - Hard

```python
class Solution:
    def solveSudoku(self, board):
        def is_valid(row, column, value):
            for index in range(9):
                if board[row][index] == value or board[index][column] == value:
                    return False
                box_row = 3 * (row // 3) + index // 3
                box_column = 3 * (column // 3) + index % 3
                if board[box_row][box_column] == value:
                    return False
            return True

        def solve():
            for row in range(9):
                for column in range(9):
                    if board[row][column] != '.':
                        continue
                    for value in '123456789':
                        if is_valid(row, column, value):
                            board[row][column] = value
                            if solve():
                                return True
                            board[row][column] = '.'
                    return False
            return True

        solve()
```

Why it works: assign a valid digit, recurse to the next empty cell, and undo the digit if it leads to a contradiction.

#### Solution: [51. N-Queens](https://leetcode.com/problems/n-queens/) - Hard

```python
class Solution:
    def solveNQueens(self, n):
        result = []
        columns = set()
        diagonals = set()
        anti_diagonals = set()
        board = [['.'] * n for _ in range(n)]

        def backtrack(row):
            if row == n:
                result.append([''.join(line) for line in board])
                return
            for column in range(n):
                if column in columns or row - column in diagonals or row + column in anti_diagonals:
                    continue
                columns.add(column)
                diagonals.add(row - column)
                anti_diagonals.add(row + column)
                board[row][column] = 'Q'
                backtrack(row + 1)
                board[row][column] = '.'
                columns.remove(column)
                diagonals.remove(row - column)
                anti_diagonals.remove(row + column)

        backtrack(0)
        return result
```

Why it works: place one queen per row and reject columns or diagonals already occupied by earlier rows.

#### Solution: [52. N-Queens II](https://leetcode.com/problems/n-queens-ii/) - Hard

```python
class Solution:
    def totalNQueens(self, n):
        columns = set()
        diagonals = set()
        anti_diagonals = set()

        def count(row):
            if row == n:
                return 1
            answer = 0
            for column in range(n):
                if column in columns or row - column in diagonals or row + column in anti_diagonals:
                    continue
                columns.add(column)
                diagonals.add(row - column)
                anti_diagonals.add(row + column)
                answer += count(row + 1)
                columns.remove(column)
                diagonals.remove(row - column)
                anti_diagonals.remove(row + column)
            return answer

        return count(0)
```

Why it works: the recursion returns the number of valid completions for each row, summing all legal placements.

#### Solution: [79. Word Search](https://leetcode.com/problems/word-search/) - Medium

```python
class Solution:
    def exist(self, board, word):
        rows, columns = len(board), len(board[0])

        def search(row, column, index):
            if index == len(word):
                return True
            if not (0 <= row < rows and 0 <= column < columns):
                return False
            if board[row][column] != word[index]:
                return False

            saved = board[row][column]
            board[row][column] = '#'
            found = any(search(row + dr, column + dc, index + 1)
                        for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            board[row][column] = saved
            return found

        return any(search(row, column, 0)
                   for row in range(rows) for column in range(columns))
```

Why it works: temporarily mark each chosen cell, explore its neighbors, then restore it for other possible paths.

#### Solution: [980. Unique Paths III](https://leetcode.com/problems/unique-paths-iii/) - Hard

```python
class Solution:
    def uniquePathsIII(self, grid):
        rows, columns = len(grid), len(grid[0])
        empty = 0
        start = None

        for row in range(rows):
            for column in range(columns):
                if grid[row][column] != -1:
                    empty += 1
                if grid[row][column] == 1:
                    start = (row, column)

        def backtrack(row, column, remaining):
            if not (0 <= row < rows and 0 <= column < columns) or grid[row][column] == -1:
                return 0
            if grid[row][column] == 2:
                return int(remaining == 1)

            value = grid[row][column]
            grid[row][column] = -1
            answer = sum(backtrack(row + dr, column + dc, remaining - 1)
                         for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            grid[row][column] = value
            return answer

        return backtrack(start[0], start[1], empty)
```

Why it works: the remaining count ensures the path reaches the ending square only after visiting every non-obstacle cell exactly once.

#### Solution: [1255. Maximum Score Words Formed by Letters](https://leetcode.com/problems/maximum-score-words-formed-by-letters/) - Hard

```python
from collections import Counter

class Solution:
    def maxScoreWords(self, words, letters, score):
        available = Counter(letters)

        def backtrack(index):
            if index == len(words):
                return 0

            best = backtrack(index + 1)
            needed = Counter(words[index])
            if all(available[character] >= count for character, count in needed.items()):
                for character, count in needed.items():
                    available[character] -= count
                value = sum(score[ord(character) - ord('a')] for character in words[index])
                best = max(best, value + backtrack(index + 1))
                for character, count in needed.items():
                    available[character] += count
            return best

        return backtrack(0)
```

Why it works: each word creates include and exclude branches; letter counts are restored after exploring the include branch.

---

#### Solution: [212. Word Search II](https://leetcode.com/problems/word-search-ii/) - Hard

```python
class TrieNode:
    def __init__(self):
        self.children = {}
        self.word = None

class Solution:
    def findWords(self, board, words):
        root = TrieNode()
        for word in words:
            node = root
            for character in word:
                node = node.children.setdefault(character, TrieNode())
            node.word = word

        rows, columns = len(board), len(board[0])
        result = []

        def search(row, column, node):
            if not (0 <= row < rows and 0 <= column < columns):
                return
            character = board[row][column]
            if character == '#' or character not in node.children:
                return

            next_node = node.children[character]
            if next_node.word:
                result.append(next_node.word)
                next_node.word = None

            board[row][column] = '#'
            for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                search(row + dr, column + dc, next_node)
            board[row][column] = character

        for row in range(rows):
            for column in range(columns):
                search(row, column, root)
        return result
```

Why it works: a Trie shares common prefixes between words, while DFS backtracking explores only board paths matching a Trie branch.

#### Solution: [282. Expression Add Operators](https://leetcode.com/problems/expression-add-operators/) - Hard

```python
class Solution:
    def addOperators(self, num, target):
        result = []

        def backtrack(index, expression, value, previous):
            if index == len(num):
                if value == target:
                    result.append(expression)
                return

            for end in range(index, len(num)):
                if end > index and num[index] == '0':
                    break
                part = num[index:end + 1]
                current = int(part)
                if index == 0:
                    backtrack(end + 1, part, current, current)
                else:
                    backtrack(end + 1, expression + '+' + part, value + current, current)
                    backtrack(end + 1, expression + '-' + part, value - current, -current)
                    multiplied = previous * current
                    backtrack(end + 1, expression + '*' + part,
                              value - previous + multiplied, multiplied)

        backtrack(0, '', 0, 0)
        return result
```

Why it works: recursively choose the next number and operator, while `previous` lets multiplication replace the last term and preserve precedence.

#### Solution: [31. Next Permutation](https://leetcode.com/problems/next-permutation/) - Medium

```python
class Solution:
    def nextPermutation(self, nums):
        pivot = len(nums) - 2
        while pivot >= 0 and nums[pivot] >= nums[pivot + 1]:
            pivot -= 1

        if pivot >= 0:
            successor = len(nums) - 1
            while nums[successor] <= nums[pivot]:
                successor -= 1
            nums[pivot], nums[successor] = nums[successor], nums[pivot]

        left, right = pivot + 1, len(nums) - 1
        while left < right:
            nums[left], nums[right] = nums[right], nums[left]
            left += 1
            right -= 1
```

Why it works: find the longest descending suffix, swap its pivot with the next larger value, and reverse the suffix to minimize the remainder.

#### Solution: [667. Beautiful Arrangement II](https://leetcode.com/problems/beautiful-arrangement-ii/) - Medium

```python
class Solution:
    def constructArray(self, n, k):
        result = []
        left, right = 1, n

        while left <= right:
            if k > 1:
                if k % 2:
                    result.append(left)
                    left += 1
                else:
                    result.append(right)
                    right -= 1
                k -= 1
            else:
                result.append(left)
                left += 1

        return result
```

Why it works: alternate low and high endpoints to create k distinct adjacent differences, then append the remaining values in order.

---

## 3. Quick pattern recognition guide

### Use combinations/subsets when you see:
- choose k items
- include or exclude each element
- reuse or do not reuse candidates

### Use permutations when you see:
- arrange all values
- fill positions one at a time
- duplicate-aware ordering

### Use string partitioning when you see:
- split into valid pieces
- insert operators or separators
- construct every valid sentence

### Use board backtracking when you see:
- place objects under row, column, or diagonal constraints
- visit a path without reusing cells
- fill a grid while preserving local rules

---

## 4. Core templates

### Choose or skip

```python
def backtrack(index, path):
    if index == len(values):
        result.append(path[:])
        return
    backtrack(index + 1, path)
    path.append(values[index])
    backtrack(index + 1, path)
    path.pop()
```

### Combination generation

```python
def backtrack(start, path):
    if complete(path):
        result.append(path[:])
        return
    for index in range(start, len(values)):
        path.append(values[index])
        backtrack(index + 1, path)
        path.pop()
```

### Permutation generation

```python
def backtrack(path, used):
    if len(path) == len(values):
        result.append(path[:])
        return
    for index, value in enumerate(values):
        if used[index]:
            continue
        used[index] = True
        path.append(value)
        backtrack(path, used)
        path.pop()
        used[index] = False
```

### Constraint placement

```python
def place(row):
    if row == n:
        return 1
    answer = 0
    for column in range(n):
        if valid(row, column):
            mark(row, column)
            answer += place(row + 1)
            unmark(row, column)
    return answer
```

---

## 5. Practice order

1. [78. Subsets](https://leetcode.com/problems/subsets/)
2. [77. Combinations](https://leetcode.com/problems/combinations/)
3. [46. Permutations](https://leetcode.com/problems/permutations/)
4. [39. Combination Sum](https://leetcode.com/problems/combination-sum/)
5. [22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/)
6. [131. Palindrome Partitioning](https://leetcode.com/problems/palindrome-partitioning/)
7. [79. Word Search](https://leetcode.com/problems/word-search/)
8. [51. N-Queens](https://leetcode.com/problems/n-queens/)
9. [37. Sudoku Solver](https://leetcode.com/problems/sudoku-solver/)
10. [1255. Maximum Score Words Formed by Letters](https://leetcode.com/problems/maximum-score-words-formed-by-letters/)

---

## 6. Cheat sheet

- Choose/skip: two branches per item.
- Combination: move start forward to preserve order.
- Reuse: recurse with the same index.
- Permutation: track used positions.
- Duplicates: sort and skip equal choices at the same depth.
- Grid path: mark before recursion and restore after recursion.
- Pruning: reject impossible partial states as early as possible.
- Result storage: append a copy of the path, never the mutable path itself.

---

## 7. Interview trigger

Reach for Backtracking when the statement includes:

- return all valid configurations
- generate combinations, subsets, or permutations
- place items under constraints
- split a string into valid pieces
- explore a board path without reusing cells

Before coding, define the state, choices, base case, pruning rule, and undo operation.

---

## 8. Common mistakes

- forgetting to undo a choice after recursion
- appending the same mutable path object to results
- allowing duplicate branches after sorting
- pruning too late and exploring impossible states
- forgetting whether a candidate may be reused
- marking a grid cell but not restoring it
- confusing combinations, where order does not matter, with permutations, where it does

---

## 9. Current coverage

Every problem currently listed in the Backtracking sub-pattern tables and practice order has a direct solution above.

Current mapped inventory:

- 24 unique Backtracking problems
- 24 direct solutions
- 0 unsolved entries in the current file

The attached Backtracking export is now represented in the backlog below. Existing solved problems are excluded from that backlog.

---

## 10. Remaining problems from the attached Backtracking list

These 93 problems were present in the attachment but do not yet have direct solutions above. They are listed here as the next solution backlog. Existing solved problems are intentionally excluded.

- [89. Gray Code](https://leetcode.com/problems/gray-code/) - Medium
- [95. Unique Binary Search Trees II](https://leetcode.com/problems/unique-binary-search-trees-ii/) - Medium
- [113. Path Sum II](https://leetcode.com/problems/path-sum-ii/) - Medium
- [126. Word Ladder II](https://leetcode.com/problems/word-ladder-ii/) - Hard
- [254. Factor Combinations](https://leetcode.com/problems/factor-combinations/) - Medium
- [257. Binary Tree Paths](https://leetcode.com/problems/binary-tree-paths/) - Easy
- [267. Palindrome Permutation II](https://leetcode.com/problems/palindrome-permutation-ii/) - Medium
- [291. Word Pattern II](https://leetcode.com/problems/word-pattern-ii/) - Medium
- [294. Flip Game II](https://leetcode.com/problems/flip-game-ii/) - Medium
- [301. Remove Invalid Parentheses](https://leetcode.com/problems/remove-invalid-parentheses/) - Hard
- [306. Additive Number](https://leetcode.com/problems/additive-number/) - Medium
- [320. Generalized Abbreviation](https://leetcode.com/problems/generalized-abbreviation/) - Medium
- [351. Android Unlock Patterns](https://leetcode.com/problems/android-unlock-patterns/) - Medium
- [357. Count Numbers with Unique Digits](https://leetcode.com/problems/count-numbers-with-unique-digits/) - Medium
- [401. Binary Watch](https://leetcode.com/problems/binary-watch/) - Easy
- [411. Minimum Unique Word Abbreviation](https://leetcode.com/problems/minimum-unique-word-abbreviation/) - Hard
- [425. Word Squares](https://leetcode.com/problems/word-squares/) - Hard
- [465. Optimal Account Balancing](https://leetcode.com/problems/optimal-account-balancing/) - Hard
- [473. Matchsticks to Square](https://leetcode.com/problems/matchsticks-to-square/) - Medium
- [489. Robot Room Cleaner](https://leetcode.com/problems/robot-room-cleaner/) - Hard
- [491. Non-decreasing Subsequences](https://leetcode.com/problems/non-decreasing-subsequences/) - Medium
- [494. Target Sum](https://leetcode.com/problems/target-sum/) - Medium
- [526. Beautiful Arrangement](https://leetcode.com/problems/beautiful-arrangement/) - Medium
- [638. Shopping Offers](https://leetcode.com/problems/shopping-offers/) - Medium
- [679. 24 Game](https://leetcode.com/problems/24-game/) - Hard
- [681. Next Closest Time](https://leetcode.com/problems/next-closest-time/) - Medium
- [691. Stickers to Spell Word](https://leetcode.com/problems/stickers-to-spell-word/) - Hard
- [698. Partition to K Equal Sum Subsets](https://leetcode.com/problems/partition-to-k-equal-sum-subsets/) - Medium
- [756. Pyramid Transition Matrix](https://leetcode.com/problems/pyramid-transition-matrix/) - Medium
- [773. Sliding Puzzle](https://leetcode.com/problems/sliding-puzzle/) - Hard
- [784. Letter Case Permutation](https://leetcode.com/problems/letter-case-permutation/) - Medium
- [797. All Paths From Source to Target](https://leetcode.com/problems/all-paths-from-source-to-target/) - Medium
- [816. Ambiguous Coordinates](https://leetcode.com/problems/ambiguous-coordinates/) - Medium
- [842. Split Array into Fibonacci Sequence](https://leetcode.com/problems/split-array-into-fibonacci-sequence/) - Medium
- [949. Largest Time for Given Digits](https://leetcode.com/problems/largest-time-for-given-digits/) - Medium
- [967. Numbers With Same Consecutive Differences](https://leetcode.com/problems/numbers-with-same-consecutive-differences/) - Medium
- [988. Smallest String Starting From Leaf](https://leetcode.com/problems/smallest-string-starting-from-leaf/) - Medium
- [996. Number of Squareful Arrays](https://leetcode.com/problems/number-of-squareful-arrays/) - Hard
- [1066. Campus Bikes II](https://leetcode.com/problems/campus-bikes-ii/) - Medium
- [1079. Letter Tile Possibilities](https://leetcode.com/problems/letter-tile-possibilities/) - Medium
- [1087. Brace Expansion](https://leetcode.com/problems/brace-expansion/) - Medium
- [1088. Confusing Number II](https://leetcode.com/problems/confusing-number-ii/) - Hard
- [1096. Brace Expansion II](https://leetcode.com/problems/brace-expansion-ii/) - Hard
- [1215. Stepping Numbers](https://leetcode.com/problems/stepping-numbers/) - Medium
- [1219. Path with Maximum Gold](https://leetcode.com/problems/path-with-maximum-gold/) - Medium
- [1238. Circular Permutation in Binary Representation](https://leetcode.com/problems/circular-permutation-in-binary-representation/) - Medium
- [1239. Maximum Length of a Concatenated String with Unique Characters](https://leetcode.com/problems/maximum-length-of-a-concatenated-string-with-unique-characters/) - Medium
- [1240. Tiling a Rectangle with the Fewest Squares](https://leetcode.com/problems/tiling-a-rectangle-with-the-fewest-squares/) - Hard
- [1258. Synonymous Sentences](https://leetcode.com/problems/synonymous-sentences/) - Medium
- [1286. Iterator for Combination](https://leetcode.com/problems/iterator-for-combination/) - Medium
- [1307. Verbal Arithmetic Puzzle](https://leetcode.com/problems/verbal-arithmetic-puzzle/) - Hard
- [1415. The k-th Lexicographical String of All Happy Strings of Length n](https://leetcode.com/problems/the-k-th-lexicographical-string-of-all-happy-strings-of-length-n/) - Medium
- [1467. Probability of a Two Boxes Having The Same Number of Distinct Balls](https://leetcode.com/problems/probability-of-a-two-boxes-having-the-same-number-of-distinct-balls/) - Hard
- [1593. Split a String Into the Max Number of Unique Substrings](https://leetcode.com/problems/split-a-string-into-the-max-number-of-unique-substrings/) - Medium
- [1601. Maximum Number of Achievable Transfer Requests](https://leetcode.com/problems/maximum-number-of-achievable-transfer-requests/) - Hard
- [1655. Distribute Repeating Integers](https://leetcode.com/problems/distribute-repeating-integers/) - Hard
- [1718. Construct the Lexicographically Largest Valid Sequence](https://leetcode.com/problems/construct-the-lexicographically-largest-valid-sequence/) - Medium
- [1723. Find Minimum Time to Finish All Jobs](https://leetcode.com/problems/find-minimum-time-to-finish-all-jobs/) - Hard
- [1774. Closest Dessert Cost](https://leetcode.com/problems/closest-dessert-cost/) - Medium
- [1799. Maximize Score After N Operations](https://leetcode.com/problems/maximize-score-after-n-operations/) - Hard
- [1849. Splitting a String Into Descending Consecutive Values](https://leetcode.com/problems/splitting-a-string-into-descending-consecutive-values/) - Medium
- [1863. Sum of All Subset XOR Totals](https://leetcode.com/problems/sum-of-all-subset-xor-totals/) - Easy
- [1947. Maximum Compatibility Score Sum](https://leetcode.com/problems/maximum-compatibility-score-sum/) - Medium
- [1980. Find Unique Binary String](https://leetcode.com/problems/find-unique-binary-string/) - Medium
- [1986. Minimum Number of Work Sessions to Finish the Tasks](https://leetcode.com/problems/minimum-number-of-work-sessions-to-finish-the-tasks/) - Medium
- [2002. Maximum Product of the Length of Two Palindromic Subsequences](https://leetcode.com/problems/maximum-product-of-the-length-of-two-palindromic-subsequences/) - Medium
- [2014. Longest Subsequence Repeated k Times](https://leetcode.com/problems/longest-subsequence-repeated-k-times/) - Hard
- [2044. Count Number of Maximum Bitwise-OR Subsets](https://leetcode.com/problems/count-number-of-maximum-bitwise-or-subsets/) - Medium
- [2048. Next Greater Numerically Balanced Number](https://leetcode.com/problems/next-greater-numerically-balanced-number/) - Medium
- [2056. Number of Valid Move Combinations On Chessboard](https://leetcode.com/problems/number-of-valid-move-combinations-on-chessboard/) - Hard
- [2065. Maximum Path Quality of a Graph](https://leetcode.com/problems/maximum-path-quality-of-a-graph/) - Hard
- [2151. Maximum Good People Based on Statements](https://leetcode.com/problems/maximum-good-people-based-on-statements/) - Hard
- [2152. Minimum Number of Lines to Cover Points](https://leetcode.com/problems/minimum-number-of-lines-to-cover-points/) - Medium
- [2178. Maximum Split of Positive Even Integers](https://leetcode.com/problems/maximum-split-of-positive-even-integers/) - Medium
- [2212. Maximum Points in an Archery Competition](https://leetcode.com/problems/maximum-points-in-an-archery-competition/) - Medium
- [2305. Fair Distribution of Cookies](https://leetcode.com/problems/fair-distribution-of-cookies/) - Medium
- [2375. Construct Smallest Number From DI String](https://leetcode.com/problems/construct-smallest-number-from-di-string/) - Medium
- [2397. Maximum Rows Covered by Columns](https://leetcode.com/problems/maximum-rows-covered-by-columns/) - Medium
- [2597. The Number of Beautiful Subsets](https://leetcode.com/problems/the-number-of-beautiful-subsets/) - Medium
- [2664. The Knight’s Tour](https://leetcode.com/problems/the-knight-s-tour/) - Medium
- [2698. Find the Punishment Number of an Integer](https://leetcode.com/problems/find-the-punishment-number-of-an-integer/) - Medium
- [2708. Maximum Strength of a Group](https://leetcode.com/problems/maximum-strength-of-a-group/) - Medium
- [2767. Partition String Into Minimum Beautiful Substrings](https://leetcode.com/problems/partition-string-into-minimum-beautiful-substrings/) - Medium
- [2850. Minimum Moves to Spread Stones Over Grid](https://leetcode.com/problems/minimum-moves-to-spread-stones-over-grid/) - Medium
- [2992. Number of Self-Divisible Permutations](https://leetcode.com/problems/number-of-self-divisible-permutations/) - Medium
- [3211. Generate Binary Strings Without Adjacent Zeros](https://leetcode.com/problems/generate-binary-strings-without-adjacent-zeros/) - Medium
- [3348. Smallest Divisible Digit Product II](https://leetcode.com/problems/smallest-divisible-digit-product-ii/) - Hard
- [3376. Minimum Time to Break Locks I](https://leetcode.com/problems/minimum-time-to-break-locks-i/) - Medium
- [3437. Permutations III](https://leetcode.com/problems/permutations-iii/) - Medium
- [3646. Next Special Palindrome Number](https://leetcode.com/problems/next-special-palindrome-number/) - Hard
- [3669. Balanced K-Factor Decomposition](https://leetcode.com/problems/balanced-k-factor-decomposition/) - Medium
- [3799. Word Squares II](https://leetcode.com/problems/word-squares-ii/) - Medium
- [3955. Valid Binary Strings With Cost Limit](https://leetcode.com/problems/valid-binary-strings-with-cost-limit/) - Medium
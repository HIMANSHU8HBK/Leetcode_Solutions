# Recursion Pattern Mastery

LeetCode problem list: https://leetcode.com/problem-list/recursion/

A practical notes document for studying Recursion and its major sub-patterns on LeetCode.

> Recursion solves a problem by solving smaller instances of the same problem. The most important discipline is to define a correct base case, make measurable progress toward it, and trust the recursive call to solve the smaller instance.

---

## 1. What is the Recursion pattern?

Use recursion when:
- the input naturally contains smaller copies of itself
- a tree or nested structure must be explored
- every choice creates smaller remaining choices
- backtracking must undo a choice after exploring it
- divide-and-conquer splits the problem into independent parts
- a mathematical state is defined from previous smaller states

Every recursive solution needs:
- a base case
- a smaller subproblem
- progress toward the base case
- a clear meaning for the return value

The central invariant is:

> Each recursive call receives a strictly smaller or simpler version of the original problem.

---

## 2. Sub-pattern map

### A. Basic mathematical and structural recursion

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [50. Pow(x, n)](https://leetcode.com/problems/powx-n/) | Medium | Reduce exponent size by half. |
| [70. Climbing Stairs](https://leetcode.com/problems/climbing-stairs/) | Easy | Recurrence over smaller step counts. |
| [509. Fibonacci Number](https://leetcode.com/problems/fibonacci-number/) | Easy | Direct recurrence with two smaller states. |
| [779. K-th Symbol in Grammar](https://leetcode.com/problems/k-th-symbol-in-grammar/) | Medium | Find the parent position recursively. |
| [231. Power of Two](https://leetcode.com/problems/power-of-two/) | Easy | Repeatedly divide by two. |

#### Solution: [50. Pow(x, n)](https://leetcode.com/problems/powx-n/) - Medium

```python
class Solution:
    def myPow(self, x, n):
        if n == 0:
            return 1.0
        if n < 0:
            return 1 / self.myPow(x, -n)

        half = self.myPow(x, n // 2)
        if n % 2 == 0:
            return half * half
        return half * half * x
```

Why it works: compute x^(n//2) once, square it, and multiply by x once more when n is odd.

#### Solution: [70. Climbing Stairs](https://leetcode.com/problems/climbing-stairs/) - Easy

```python
class Solution:
    def climbStairs(self, n):
        if n <= 2:
            return n
        return self.climbStairs(n - 1) + self.climbStairs(n - 2)
```

Why it works: the final step is either a one-step move from n-1 or a two-step move from n-2.

#### Solution: [509. Fibonacci Number](https://leetcode.com/problems/fibonacci-number/) - Easy

```python
class Solution:
    def fib(self, n):
        if n <= 1:
            return n
        return self.fib(n - 1) + self.fib(n - 2)
```

Why it works: Fibonacci is defined directly as the sum of the two preceding values.

#### Solution: [779. K-th Symbol in Grammar](https://leetcode.com/problems/k-th-symbol-in-grammar/) - Medium

```python
class Solution:
    def kthGrammar(self, n, k):
        if n == 1:
            return 0

        parent = self.kthGrammar(n - 1, (k + 1) // 2)
        if k % 2 == 1:
            return parent
        return 1 - parent
```

Why it works: each row expands a parent into either 01 or 10, so the child depends on whether k is the first or second position of its pair.

#### Solution: [231. Power of Two](https://leetcode.com/problems/power-of-two/) - Easy

```python
class Solution:
    def isPowerOfTwo(self, n):
        if n == 1:
            return True
        if n <= 0 or n % 2:
            return False
        return self.isPowerOfTwo(n // 2)
```

Why it works: a positive power of two can be divided by two repeatedly until it reaches exactly one.

---

### B. Tree recursion and divide-and-conquer traversal

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [94. Binary Tree Inorder Traversal](https://leetcode.com/problems/binary-tree-inorder-traversal/) | Easy | Recursively visit left, root, right. |
| [100. Same Tree](https://leetcode.com/problems/same-tree/) | Easy | Compare corresponding subtrees recursively. |
| [104. Maximum Depth of Binary Tree](https://leetcode.com/problems/maximum-depth-of-binary-tree/) | Easy | Depth is one plus the deeper child depth. |
| [226. Invert Binary Tree](https://leetcode.com/problems/invert-binary-tree/) | Easy | Recursively invert both child subtrees. |
| [236. Lowest Common Ancestor of a Binary Tree](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/) | Medium | Return subtree evidence upward. |
| [543. Diameter of Binary Tree](https://leetcode.com/problems/diameter-of-binary-tree/) | Easy | Combine heights from both child subtrees. |
| [124. Binary Tree Maximum Path Sum](https://leetcode.com/problems/binary-tree-maximum-path-sum/) | Hard | Return best downward path while updating global best. |

#### Solution: [94. Binary Tree Inorder Traversal](https://leetcode.com/problems/binary-tree-inorder-traversal/) - Easy

```python
class Solution:
    def inorderTraversal(self, root):
        if not root:
            return []
        return self.inorderTraversal(root.left) + [root.val] + self.inorderTraversal(root.right)
```

Why it works: inorder traversal is defined recursively as left subtree, current node, then right subtree.

#### Solution: [100. Same Tree](https://leetcode.com/problems/same-tree/) - Easy

```python
class Solution:
    def isSameTree(self, p, q):
        if not p and not q:
            return True
        if not p or not q or p.val != q.val:
            return False
        return self.isSameTree(p.left, q.left) and self.isSameTree(p.right, q.right)
```

Why it works: two trees match exactly when their roots match and both corresponding child pairs match.

#### Solution: [104. Maximum Depth of Binary Tree](https://leetcode.com/problems/maximum-depth-of-binary-tree/) - Easy

```python
class Solution:
    def maxDepth(self, root):
        if not root:
            return 0
        return 1 + max(self.maxDepth(root.left), self.maxDepth(root.right))
```

Why it works: the depth of a node is one greater than the deeper of its two child depths.

#### Solution: [226. Invert Binary Tree](https://leetcode.com/problems/invert-binary-tree/) - Easy

```python
class Solution:
    def invertTree(self, root):
        if not root:
            return None
        root.left, root.right = self.invertTree(root.right), self.invertTree(root.left)
        return root
```

Why it works: recursively invert each child subtree and swap their positions at the current node.

#### Solution: [236. Lowest Common Ancestor of a Binary Tree](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/) - Medium

```python
class Solution:
    def lowestCommonAncestor(self, root, p, q):
        if not root or root == p or root == q:
            return root

        left = self.lowestCommonAncestor(root.left, p, q)
        right = self.lowestCommonAncestor(root.right, p, q)
        if left and right:
            return root
        return left if left else right
```

Why it works: a node is the LCA when one target is found in each subtree, or when the node itself is one target and the other is below it.

#### Solution: [543. Diameter of Binary Tree](https://leetcode.com/problems/diameter-of-binary-tree/) - Easy

```python
class Solution:
    def diameterOfBinaryTree(self, root):
        best = 0

        def height(node):
            nonlocal best
            if not node:
                return 0
            left = height(node.left)
            right = height(node.right)
            best = max(best, left + right)
            return 1 + max(left, right)

        height(root)
        return best
```

Why it works: the longest path through a node uses the heights of both child subtrees; update the global answer while returning height upward.

#### Solution: [124. Binary Tree Maximum Path Sum](https://leetcode.com/problems/binary-tree-maximum-path-sum/) - Hard

```python
class Solution:
    def maxPathSum(self, root):
        best = float('-inf')

        def gain(node):
            nonlocal best
            if not node:
                return 0
            left = max(0, gain(node.left))
            right = max(0, gain(node.right))
            best = max(best, node.val + left + right)
            return node.val + max(left, right)

        gain(root)
        return best
```

Why it works: a recursive call returns the best one-sided path that can connect to its parent, while the global answer may use both sides through the current node.

---

### C. Backtracking and generate-all recursion

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [17. Letter Combinations of a Phone Number](https://leetcode.com/problems/letter-combinations-of-a-phone-number/) | Medium | Choose one letter per digit recursively. |
| [22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/) | Medium | Build valid strings with constrained choices. |
| [39. Combination Sum](https://leetcode.com/problems/combination-sum/) | Medium | Choose candidates repeatedly with backtracking. |
| [46. Permutations](https://leetcode.com/problems/permutations/) | Medium | Choose each unused element at each depth. |
| [47. Permutations II](https://leetcode.com/problems/permutations-ii/) | Medium | Backtracking with duplicate control. |
| [78. Subsets](https://leetcode.com/problems/subsets/) | Medium | Include/exclude recursion. |
| [90. Subsets II](https://leetcode.com/problems/subsets-ii/) | Medium | Include/exclude with duplicate skipping. |
| [79. Word Search](https://leetcode.com/problems/word-search/) | Medium | DFS choices with visited-state backtracking. |

#### Solution: [17. Letter Combinations of a Phone Number](https://leetcode.com/problems/letter-combinations-of-a-phone-number/) - Medium

```python
class Solution:
    def letterCombinations(self, digits):
        if not digits:
            return []

        letters = {
            '2': 'abc', '3': 'def', '4': 'ghi', '5': 'jkl',
            '6': 'mno', '7': 'pqrs', '8': 'tuv', '9': 'wxyz'
        }
        result = []

        def backtrack(index, path):
            if index == len(digits):
                result.append(''.join(path))
                return
            for character in letters[digits[index]]:
                path.append(character)
                backtrack(index + 1, path)
                path.pop()

        backtrack(0, [])
        return result
```

Why it works: each recursion level chooses one letter for one digit, and popping restores the path for the next choice.

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

Why it works: never place more closing brackets than opening brackets, so every generated prefix can still become valid.

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

Why it works: passing the same index permits reuse, while passing start prevents duplicate orderings.

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

Why it works: each depth selects one unused element, and undoing the selection lets the same element be considered in another position.

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

Why it works: sorting places duplicates together, and skipping an unused duplicate at the same depth removes duplicate branches.

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

Why it works: skip equal values only when they would start the same recursion level, preserving valid uses at deeper levels.

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

Why it works: mark the current cell as used while recursively exploring neighbors, then restore it so other paths can reuse it.

---

### D. Divide and conquer recursion

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [53. Maximum Subarray](https://leetcode.com/problems/maximum-subarray/) | Medium | Divide array into left, right, and crossing answers. |
| [108. Convert Sorted Array to Binary Search Tree](https://leetcode.com/problems/convert-sorted-array-to-binary-search-tree/) | Easy | Middle element recursively becomes the root. |
| [148. Sort List](https://leetcode.com/problems/sort-list/) | Medium | Merge sort recursively splits linked lists. |
| [912. Sort an Array](https://leetcode.com/problems/sort-an-array/) | Medium | Recursive merge sort. |
| [215. Kth Largest Element in an Array](https://leetcode.com/problems/kth-largest-element-in-an-array/) | Medium | Quickselect recursively narrows the partition. |

#### Solution: [53. Maximum Subarray](https://leetcode.com/problems/maximum-subarray/) - Medium

```python
class Solution:
    def maxSubArray(self, nums):
        def divide(left, right):
            if left == right:
                return nums[left], nums[left], nums[left], nums[left]

            middle = (left + right) // 2
            left_sum, left_prefix, left_suffix, left_best = divide(left, middle)
            right_sum, right_prefix, right_suffix, right_best = divide(middle + 1, right)
            total = left_sum + right_sum
            prefix = max(left_prefix, left_sum + right_prefix)
            suffix = max(right_suffix, right_sum + left_suffix)
            best = max(left_best, right_best, left_suffix + right_prefix)
            return total, prefix, suffix, best

        return divide(0, len(nums) - 1)[3]
```

Why it works: each segment returns its total, best prefix, best suffix, and best internal subarray, which is enough to combine two halves.

#### Solution: [108. Convert Sorted Array to Binary Search Tree](https://leetcode.com/problems/convert-sorted-array-to-binary-search-tree/) - Easy

```python
class Solution:
    def sortedArrayToBST(self, nums):
        def build(left, right):
            if left > right:
                return None
            middle = (left + right) // 2
            node = TreeNode(nums[middle])
            node.left = build(left, middle - 1)
            node.right = build(middle + 1, right)
            return node

        return build(0, len(nums) - 1)
```

Why it works: choosing the middle keeps the left and right subtree sizes balanced, and recursion builds each side independently.

#### Solution: [148. Sort List](https://leetcode.com/problems/sort-list/) - Medium

```python
class Solution:
    def sortList(self, head):
        if not head or not head.next:
            return head

        slow, fast = head, head.next
        while fast and fast.next:
            slow = slow.next
            fast = fast.next.next
        second = slow.next
        slow.next = None

        left = self.sortList(head)
        right = self.sortList(second)
        return self.merge(left, right)

    def merge(self, left, right):
        dummy = ListNode(0)
        tail = dummy
        while left and right:
            if left.val <= right.val:
                tail.next, left = left, left.next
            else:
                tail.next, right = right, right.next
            tail = tail.next
        tail.next = left or right
        return dummy.next
```

Why it works: split recursively until single-node lists, then merge sorted halves while preserving pointer order.

#### Solution: [912. Sort an Array](https://leetcode.com/problems/sort-an-array/) - Medium

```python
class Solution:
    def sortArray(self, nums):
        if len(nums) <= 1:
            return nums

        middle = len(nums) // 2
        left = self.sortArray(nums[:middle])
        right = self.sortArray(nums[middle:])
        result = []
        i = j = 0

        while i < len(left) and j < len(right):
            if left[i] <= right[j]:
                result.append(left[i])
                i += 1
            else:
                result.append(right[j])
                j += 1
        result.extend(left[i:])
        result.extend(right[j:])
        return result
```

Why it works: recursively sort both halves, then merge their ordered values in linear time.

---

#### Solution: [215. Kth Largest Element in an Array](https://leetcode.com/problems/kth-largest-element-in-an-array/) - Medium

```python
class Solution:
    def findKthLargest(self, nums, k):
        target = len(nums) - k

        def select(left, right):
            pivot = nums[right]
            store = left
            for index in range(left, right):
                if nums[index] <= pivot:
                    nums[store], nums[index] = nums[index], nums[store]
                    store += 1
            nums[store], nums[right] = nums[right], nums[store]

            if store == target:
                return nums[store]
            if store < target:
                return select(store + 1, right)
            return select(left, store - 1)

        return select(0, len(nums) - 1)
```

Why it works: recursive quickselect partitions around a pivot and continues only in the side containing the target sorted position.

---

### E. Memoized recursion and recursive dynamic programming

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [70. Climbing Stairs](https://leetcode.com/problems/climbing-stairs/) | Easy | Memoized recurrence. |
| [198. House Robber](https://leetcode.com/problems/house-robber/) | Medium | Choose or skip each position recursively. |
| [300. Longest Increasing Subsequence](https://leetcode.com/problems/longest-increasing-subsequence/) | Medium | Recursive state by current index and previous choice. |
| [329. Longest Increasing Path in a Matrix](https://leetcode.com/problems/longest-increasing-path-in-a-matrix/) | Hard | DFS with memoization over matrix cells. |
| [115. Distinct Subsequences](https://leetcode.com/problems/distinct-subsequences/) | Hard | Include/exclude recurrence over two strings. |

#### Solution: [198. House Robber](https://leetcode.com/problems/house-robber/) - Medium

```python
from functools import lru_cache

class Solution:
    def rob(self, nums):
        @lru_cache(None)
        def best(index):
            if index >= len(nums):
                return 0
            return max(best(index + 1), nums[index] + best(index + 2))

        return best(0)
```

Why it works: at each house, the recurrence chooses between skipping it and robbing it plus the best result two positions ahead.

#### Solution: [300. Longest Increasing Subsequence](https://leetcode.com/problems/longest-increasing-subsequence/) - Medium

```python
from functools import lru_cache

class Solution:
    def lengthOfLIS(self, nums):
        @lru_cache(None)
        def length(index):
            best = 1
            for next_index in range(index + 1, len(nums)):
                if nums[next_index] > nums[index]:
                    best = max(best, 1 + length(next_index))
            return best

        return max((length(index) for index in range(len(nums))), default=0)
```

Why it works: memoize the best increasing subsequence beginning at each index, so each state is solved once.

#### Solution: [329. Longest Increasing Path in a Matrix](https://leetcode.com/problems/longest-increasing-path-in-a-matrix/) - Hard

```python
from functools import lru_cache

class Solution:
    def longestIncreasingPath(self, matrix):
        rows, columns = len(matrix), len(matrix[0])

        @lru_cache(None)
        def path(row, column):
            best = 1
            for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                next_row, next_column = row + dr, column + dc
                if (0 <= next_row < rows and 0 <= next_column < columns
                        and matrix[next_row][next_column] > matrix[row][column]):
                    best = max(best, 1 + path(next_row, next_column))
            return best

        return max(path(row, column) for row in range(rows) for column in range(columns))
```

Why it works: values strictly increase along every recursive edge, so there are no cycles; memoization reuses each cell's best path.

#### Solution: [115. Distinct Subsequences](https://leetcode.com/problems/distinct-subsequences/) - Hard

```python
from functools import lru_cache

class Solution:
    def numDistinct(self, s, t):
        @lru_cache(None)
        def count(i, j):
            if j == len(t):
                return 1
            if i == len(s):
                return 0

            answer = count(i + 1, j)
            if s[i] == t[j]:
                answer += count(i + 1, j + 1)
            return answer

        return count(0, 0)
```

Why it works: each source character can be skipped, or used when it matches the next target character; memoization merges repeated suffix states.

---

## 3. Quick pattern recognition guide

### Use direct recursion when you see:
- a mathematical recurrence
- a tree or nested structure
- a problem that naturally shrinks by one level

### Use backtracking when you see:
- generate all combinations, subsets, or permutations
- choose, explore, undo
- constraints that can prune invalid partial paths

### Use divide and conquer when you see:
- independent left and right halves
- merge after recursive sorting or processing
- a result that combines prefix, suffix, and whole-segment information

### Use memoized recursion when you see:
- overlapping recursive states
- the same index/state being recomputed
- a recursive choice with a compact state definition

---

## 4. Core templates

### Tree recursion

```python
def solve(node):
    if not node:
        return base_value
    left = solve(node.left)
    right = solve(node.right)
    return combine(node, left, right)
```

### Backtracking

```python
def backtrack(start, path):
    if complete(path):
        result.append(path[:])
        return
    for choice in choices(start):
        path.append(choice)
        backtrack(next_start(choice), path)
        path.pop()
```

### Memoized recursion

```python
from functools import lru_cache

@lru_cache(None)
def solve(state):
    if is_base_case(state):
        return base_value
    return combine(solve(smaller_state(state)))
```

### Divide and conquer

```python
def divide(left, right):
    if left == right:
        return base_result
    middle = (left + right) // 2
    first = divide(left, middle)
    second = divide(middle + 1, right)
    return combine(first, second)
```

---

## 5. Practice order

1. [509. Fibonacci Number](https://leetcode.com/problems/fibonacci-number/)
2. [104. Maximum Depth of Binary Tree](https://leetcode.com/problems/maximum-depth-of-binary-tree/)
3. [100. Same Tree](https://leetcode.com/problems/same-tree/)
4. [78. Subsets](https://leetcode.com/problems/subsets/)
5. [46. Permutations](https://leetcode.com/problems/permutations/)
6. [22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/)
7. [39. Combination Sum](https://leetcode.com/problems/combination-sum/)
8. [79. Word Search](https://leetcode.com/problems/word-search/)
9. [50. Pow(x, n)](https://leetcode.com/problems/powx-n/)
10. [124. Binary Tree Maximum Path Sum](https://leetcode.com/problems/binary-tree-maximum-path-sum/)

---

## 6. Cheat sheet

- Base case: stop when the input is empty, complete, or smallest.
- Progress: every recursive call must move toward the base case.
- Return meaning: define exactly what a call returns to its caller.
- Backtracking: choose, recurse, undo.
- Memoization: cache by the complete state that affects future decisions.
- Tree recursion: return child information upward and combine at the parent.
- Divide and conquer: solve halves independently, then merge their summaries.

---

## 7. Interview trigger

Reach for Recursion when the statement includes:

- tree, nested list, or recursively defined structure
- generate all combinations, subsets, or permutations
- divide the input into smaller independent pieces
- choose or skip an item
- return the best result from a smaller suffix or subtree

Before coding, state the base case and the exact meaning of the recursive return value.

---

## 8. Common mistakes

- missing or incorrect base cases
- recursive calls that do not reduce the problem
- forgetting to undo a backtracking choice
- sharing mutable paths without copying completed answers
- recomputing overlapping states without memoization
- returning a value with unclear meaning to the parent call
- exceeding recursion depth when an iterative approach is safer

---

## 9. Current coverage

Every problem currently listed in the Recursion sub-pattern tables and practice order has a direct solution above.

Current mapped inventory:

- 29 unique Recursion problems
- 29 direct solutions
- 0 unsolved entries in the current file

When a larger Recursion problem export is supplied, new problems can be appended as a numbered backlog and solved one by one in the same format.

---

## 10. Remaining problems from the attached Recursion list

These 46 problems were present in the attachment but do not yet have direct solutions above. They are listed here as the next solution backlog. Existing solved problems are intentionally excluded.

- [2. Add Two Numbers](https://leetcode.com/problems/add-two-numbers/) - Medium
- [10. Regular Expression Matching](https://leetcode.com/problems/regular-expression-matching/) - Hard
- [21. Merge Two Sorted Lists](https://leetcode.com/problems/merge-two-sorted-lists/) - Easy
- [24. Swap Nodes in Pairs](https://leetcode.com/problems/swap-nodes-in-pairs/) - Medium
- [25. Reverse Nodes in k-Group](https://leetcode.com/problems/reverse-nodes-in-k-group/) - Hard
- [44. Wildcard Matching](https://leetcode.com/problems/wildcard-matching/) - Hard
- [60. Permutation Sequence](https://leetcode.com/problems/permutation-sequence/) - Hard
- [143. Reorder List](https://leetcode.com/problems/reorder-list/) - Medium
- [203. Remove Linked List Elements](https://leetcode.com/problems/remove-linked-list-elements/) - Easy
- [206. Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/) - Easy
- [224. Basic Calculator](https://leetcode.com/problems/basic-calculator/) - Hard
- [233. Number of Digit One](https://leetcode.com/problems/number-of-digit-one/) - Hard
- [234. Palindrome Linked List](https://leetcode.com/problems/palindrome-linked-list/) - Easy
- [247. Strobogrammatic Number II](https://leetcode.com/problems/strobogrammatic-number-ii/) - Medium
- [248. Strobogrammatic Number III](https://leetcode.com/problems/strobogrammatic-number-iii/) - Hard
- [255. Verify Preorder Sequence in Binary Search Tree](https://leetcode.com/problems/verify-preorder-sequence-in-binary-search-tree/) - Medium
- [273. Integer to English Words](https://leetcode.com/problems/integer-to-english-words/) - Hard
- [326. Power of Three](https://leetcode.com/problems/power-of-three/) - Easy
- [342. Power of Four](https://leetcode.com/problems/power-of-four/) - Easy
- [390. Elimination Game](https://leetcode.com/problems/elimination-game/) - Medium
- [394. Decode String](https://leetcode.com/problems/decode-string/) - Medium
- [439. Ternary Expression Parser](https://leetcode.com/problems/ternary-expression-parser/) - Medium
- [486. Predict the Winner](https://leetcode.com/problems/predict-the-winner/) - Medium
- [544. Output Contest Matches](https://leetcode.com/problems/output-contest-matches/) - Medium
- [736. Parse Lisp Expression](https://leetcode.com/problems/parse-lisp-expression/) - Hard
- [770. Basic Calculator IV](https://leetcode.com/problems/basic-calculator-iv/) - Hard
- [772. Basic Calculator III](https://leetcode.com/problems/basic-calculator-iii/) - Hard
- [776. Split BST](https://leetcode.com/problems/split-bst/) - Medium
- [894. All Possible Full Binary Trees](https://leetcode.com/problems/all-possible-full-binary-trees/) - Medium
- [1106. Parsing A Boolean Expression](https://leetcode.com/problems/parsing-a-boolean-expression/) - Hard
- [1265. Print Immutable Linked List in Reverse](https://leetcode.com/problems/print-immutable-linked-list-in-reverse/) - Medium
- [1545. Find Kth Bit in Nth Binary String](https://leetcode.com/problems/find-kth-bit-in-nth-binary-string/) - Medium
- [1611. Minimum One Bit Operations to Make Integers Zero](https://leetcode.com/problems/minimum-one-bit-operations-to-make-integers-zero/) - Hard
- [1808. Maximize Number of Nice Divisors](https://leetcode.com/problems/maximize-number-of-nice-divisors/) - Hard
- [1823. Find the Winner of the Circular Game](https://leetcode.com/problems/find-the-winner-of-the-circular-game/) - Medium
- [1922. Count Good Numbers](https://leetcode.com/problems/count-good-numbers/) - Medium
- [1969. Minimum Non-Zero Product of the Array Elements](https://leetcode.com/problems/minimum-non-zero-product-of-the-array-elements/) - Medium
- [2094. Finding 3-Digit Even Numbers](https://leetcode.com/problems/finding-3-digit-even-numbers/) - Easy
- [2487. Remove Nodes From Linked List](https://leetcode.com/problems/remove-nodes-from-linked-list/) - Medium
- [2550. Count Collisions of Monkeys on a Polygon](https://leetcode.com/problems/count-collisions-of-monkeys-on-a-polygon/) - Medium
- [3304. Find the K-th Character in String Game I](https://leetcode.com/problems/find-the-k-th-character-in-string-game-i/) - Easy
- [3307. Find the K-th Character in String Game II](https://leetcode.com/problems/find-the-k-th-character-in-string-game-ii/) - Hard
- [3483. Unique 3-Digit Even Numbers](https://leetcode.com/problems/unique-3-digit-even-numbers/) - Easy
- [3565. Sequential Grid Path Cover](https://leetcode.com/problems/sequential-grid-path-cover/) - Medium
- [3566. Partition Array into Two Equal Product Subsets](https://leetcode.com/problems/partition-array-into-two-equal-product-subsets/) - Medium
- [3782. Last Remaining Integer After Alternating Deletion Operations](https://leetcode.com/problems/last-remaining-integer-after-alternating-deletion-operations/) - Hard

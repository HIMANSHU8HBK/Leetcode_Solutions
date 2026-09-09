# Divide and Conquer Pattern Mastery

LeetCode problem list: https://leetcode.com/problem-list/divide-and-conquer/

A practical notes document for studying Divide and Conquer and its major sub-patterns on LeetCode.

> Divide and Conquer breaks a problem into smaller independent pieces, solves each piece recursively, and combines the results. The strength of the pattern comes from reducing a large problem to manageable subproblems while keeping the merge step efficient.

---

## 1. What is Divide and Conquer?

Use Divide and Conquer when:
- the input can be split into independent halves or partitions
- each subproblem has the same structure as the original
- combining solved pieces is cheaper than solving the whole problem directly
- sorting, selection, counting, or geometry can be organized around partitions
- a recursive solution has a clear split and merge phase

Every Divide and Conquer solution has:
- a base case for the smallest input
- a divide step
- recursive calls on smaller pieces
- a combine step

The central invariant is:

> Each recursive result summarizes its segment completely enough for the parent call to combine it with neighboring results.

---

## 2. Sub-pattern map

### A. Merge sort and merge-based counting

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [148. Sort List](https://leetcode.com/problems/sort-list/) | Medium | Merge sort on linked-list halves. |
| [912. Sort an Array](https://leetcode.com/problems/sort-an-array/) | Medium | Recursive merge sort. |
| [315. Count of Smaller Numbers After Self](https://leetcode.com/problems/count-of-smaller-numbers-after-self/) | Hard | Count inversions during merge. |
| [493. Reverse Pairs](https://leetcode.com/problems/reverse-pairs/) | Hard | Count cross-half pairs before merging. |
| [327. Count of Range Sum](https://leetcode.com/problems/count-of-range-sum/) | Hard | Prefix sums plus merge-based counting. |
| [53. Maximum Subarray](https://leetcode.com/problems/maximum-subarray/) | Medium | Combine total, prefix, suffix, and best summaries. |

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
                tail.next = left
                left = left.next
            else:
                tail.next = right
                right = right.next
            tail = tail.next
        tail.next = left if left else right
        return dummy.next
```

Why it works: split the linked list into halves recursively, then merge sorted halves with two pointers.

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

Why it works: recursively sort each half and merge the two ordered lists in linear time.

#### Solution: [315. Count of Smaller Numbers After Self](https://leetcode.com/problems/count-of-smaller-numbers-after-self/) - Hard

```python
class Solution:
    def countSmaller(self, nums):
        indexes = list(range(len(nums)))
        counts = [0] * len(nums)

        def merge_sort(left, right):
            if left >= right:
                return

            middle = (left + right) // 2
            merge_sort(left, middle)
            merge_sort(middle + 1, right)

            merged = []
            i, j = left, middle + 1
            while i <= middle and j <= right:
                if nums[indexes[i]] <= nums[indexes[j]]:
                    merged.append(indexes[i])
                    i += 1
                else:
                    counts[indexes[j]] += middle - i + 1
                    merged.append(indexes[j])
                    j += 1

            merged.extend(indexes[i:middle + 1])
            merged.extend(indexes[j:right + 1])
            indexes[left:right + 1] = merged

        merge_sort(0, len(nums) - 1)
        return counts
```

Why it works: when a right-half value moves before remaining left-half values, those left values are smaller elements to its right in the original array.

#### Solution: [493. Reverse Pairs](https://leetcode.com/problems/reverse-pairs/) - Hard

```python
class Solution:
    def reversePairs(self, nums):
        def divide(left, right):
            if left >= right:
                return 0

            middle = (left + right) // 2
            answer = divide(left, middle) + divide(middle + 1, right)
            j = middle + 1
            for i in range(left, middle + 1):
                while j <= right and nums[i] > 2 * nums[j]:
                    j += 1
                answer += j - (middle + 1)

            nums[left:right + 1] = sorted(nums[left:right + 1])
            return answer

        return divide(0, len(nums) - 1)
```

Why it works: sorted halves let us count every cross-half pair with two pointers before merging them.

#### Solution: [327. Count of Range Sum](https://leetcode.com/problems/count-of-range-sum/) - Hard

```python
class Solution:
    def countRangeSum(self, nums, lower, upper):
        prefix = [0]
        for value in nums:
            prefix.append(prefix[-1] + value)

        def divide(values):
            if len(values) <= 1:
                return 0, values

            middle = len(values) // 2
            left_count, left = divide(values[:middle])
            right_count, right = divide(values[middle:])
            answer = left_count + right_count
            low = high = 0

            for left_value in left:
                while low < len(right) and right[low] - left_value < lower:
                    low += 1
                while high < len(right) and right[high] - left_value <= upper:
                    high += 1
                answer += high - low

            merged = []
            i = j = 0
            while i < len(left) and j < len(right):
                if left[i] <= right[j]:
                    merged.append(left[i])
                    i += 1
                else:
                    merged.append(right[j])
                    j += 1
            merged.extend(left[i:])
            merged.extend(right[j:])
            return answer, merged

        return divide(prefix)[0]
```

Why it works: a range sum is a difference of prefix sums; divide-and-conquer counts valid cross-half differences while both halves are sorted.

#### Solution: [53. Maximum Subarray](https://leetcode.com/problems/maximum-subarray/) - Medium

```python
class Solution:
    def maxSubArray(self, nums):
        def divide(left, right):
            if left == right:
                value = nums[left]
                return value, value, value, value

            middle = (left + right) // 2
            left_total, left_prefix, left_suffix, left_best = divide(left, middle)
            right_total, right_prefix, right_suffix, right_best = divide(middle + 1, right)
            total = left_total + right_total
            prefix = max(left_prefix, left_total + right_prefix)
            suffix = max(right_suffix, right_total + left_suffix)
            best = max(left_best, right_best, left_suffix + right_prefix)
            return total, prefix, suffix, best

        return divide(0, len(nums) - 1)[3]
```

Why it works: each segment returns enough information about its total, best prefix, best suffix, and best subarray to combine two halves.

---

### B. Binary search and partition-based selection

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [215. Kth Largest Element in an Array](https://leetcode.com/problems/kth-largest-element-in-an-array/) | Medium | Quickselect recursively narrows a partition. |
| [33. Search in Rotated Sorted Array](https://leetcode.com/problems/search-in-rotated-sorted-array/) | Medium | Recursively select the sorted half. |
| [4. Median of Two Sorted Arrays](https://leetcode.com/problems/median-of-two-sorted-arrays/) | Hard | Partition two arrays recursively through binary search. |
| [69. Sqrt(x)](https://leetcode.com/problems/sqrtx/) | Easy | Binary search recursively halves the range. |
| [240. Search a 2D Matrix II](https://leetcode.com/problems/search-a-2d-matrix-ii/) | Medium | Divide the matrix search region. |

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

Why it works: partition places the pivot in its final sorted position, so recurse only into the side containing the target index.

#### Solution: [33. Search in Rotated Sorted Array](https://leetcode.com/problems/search-in-rotated-sorted-array/) - Medium

```python
class Solution:
    def search(self, nums, target):
        def binary(left, right):
            if left > right:
                return -1
            middle = (left + right) // 2
            if nums[middle] == target:
                return middle

            if nums[left] <= nums[middle]:
                if nums[left] <= target < nums[middle]:
                    return binary(left, middle - 1)
                return binary(middle + 1, right)

            if nums[middle] < target <= nums[right]:
                return binary(middle + 1, right)
            return binary(left, middle - 1)

        return binary(0, len(nums) - 1)
```

Why it works: at least one half remains sorted, so determine whether the target belongs to that half before recursing.

#### Solution: [4. Median of Two Sorted Arrays](https://leetcode.com/problems/median-of-two-sorted-arrays/) - Hard

```python
class Solution:
    def findMedianSortedArrays(self, nums1, nums2):
        if len(nums1) > len(nums2):
            nums1, nums2 = nums2, nums1

        left, right = 0, len(nums1)
        total = len(nums1) + len(nums2)

        while left <= right:
            cut1 = (left + right) // 2
            cut2 = (total + 1) // 2 - cut1
            left1 = nums1[cut1 - 1] if cut1 else float('-inf')
            right1 = nums1[cut1] if cut1 < len(nums1) else float('inf')
            left2 = nums2[cut2 - 1] if cut2 else float('-inf')
            right2 = nums2[cut2] if cut2 < len(nums2) else float('inf')

            if left1 <= right2 and left2 <= right1:
                if total % 2:
                    return float(max(left1, left2))
                return (max(left1, left2) + min(right1, right2)) / 2
            if left1 > right2:
                right = cut1 - 1
            else:
                left = cut1 + 1
```

Why it works: binary search finds a partition where every value on the left is no greater than every value on the right.

#### Solution: [69. Sqrt(x)](https://leetcode.com/problems/sqrtx/) - Easy

```python
class Solution:
    def mySqrt(self, x):
        def search(left, right):
            if left > right:
                return right
            middle = (left + right) // 2
            if middle * middle <= x:
                return search(middle + 1, right)
            return search(left, middle - 1)

        return search(0, x)
```

Why it works: recursively discard the half that cannot contain the largest integer whose square is at most x.

---

### C. Recursive tree construction and structural divide-and-conquer

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [105. Construct Binary Tree from Preorder and Inorder Traversal](https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/) | Medium | Root divides inorder into left and right subtrees. |
| [106. Construct Binary Tree from Inorder and Postorder Traversal](https://leetcode.com/problems/construct-binary-tree-from-inorder-and-postorder-traversal/) | Medium | Postorder root divides the inorder range. |
| [108. Convert Sorted Array to Binary Search Tree](https://leetcode.com/problems/convert-sorted-array-to-binary-search-tree/) | Easy | Middle element recursively becomes root. |
| [654. Maximum Binary Tree](https://leetcode.com/problems/maximum-binary-tree/) | Medium | Maximum divides the array into two subarrays. |
| [889. Construct Binary Tree from Preorder and Postorder Traversal](https://leetcode.com/problems/construct-binary-tree-from-preorder-and-postorder-traversal/) | Medium | Traversals determine recursive subtree ranges. |

#### Solution: [105. Construct Binary Tree from Preorder and Inorder Traversal](https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/) - Medium

```python
class Solution:
    def buildTree(self, preorder, inorder):
        positions = {value: index for index, value in enumerate(inorder)}
        preorder_index = 0

        def build(left, right):
            nonlocal preorder_index
            if left > right:
                return None

            value = preorder[preorder_index]
            preorder_index += 1
            node = TreeNode(value)
            middle = positions[value]
            node.left = build(left, middle - 1)
            node.right = build(middle + 1, right)
            return node

        return build(0, len(inorder) - 1)
```

Why it works: preorder gives the next subtree root, while inorder tells exactly which values belong to its left and right subtrees.

#### Solution: [106. Construct Binary Tree from Inorder and Postorder Traversal](https://leetcode.com/problems/construct-binary-tree-from-inorder-and-postorder-traversal/) - Medium

```python
class Solution:
    def buildTree(self, inorder, postorder):
        positions = {value: index for index, value in enumerate(inorder)}
        postorder_index = len(postorder) - 1

        def build(left, right):
            nonlocal postorder_index
            if left > right:
                return None

            value = postorder[postorder_index]
            postorder_index -= 1
            node = TreeNode(value)
            middle = positions[value]
            node.right = build(middle + 1, right)
            node.left = build(left, middle - 1)
            return node

        return build(0, len(inorder) - 1)
```

Why it works: postorder gives roots from right to left, so build the right subtree before the left subtree after locating the root in inorder.

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

Why it works: choosing the middle repeatedly creates balanced left and right ranges.

#### Solution: [654. Maximum Binary Tree](https://leetcode.com/problems/maximum-binary-tree/) - Medium

```python
class Solution:
    def constructMaximumBinaryTree(self, nums):
        def build(left, right):
            if left >= right:
                return None
            maximum_index = max(range(left, right), key=nums.__getitem__)
            node = TreeNode(nums[maximum_index])
            node.left = build(left, maximum_index)
            node.right = build(maximum_index + 1, right)
            return node

        return build(0, len(nums))
```

Why it works: the maximum value is the root, and the values on each side form independent recursive subtrees.

---

### D. Recursive geometry, counting, and advanced partitioning

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [23. Merge k Sorted Lists](https://leetcode.com/problems/merge-k-sorted-lists/) | Hard | Divide lists recursively and merge pairs. |
| [241. Different Ways to Add Parentheses](https://leetcode.com/problems/different-ways-to-add-parentheses/) | Medium | Split expression at every operator. |
| [395. Longest Substring with At Least K Repeating Characters](https://leetcode.com/problems/longest-substring-with-at-least-k-repeating-characters/) | Medium | Split around invalid low-frequency characters. |
| [427. Construct Quad Tree](https://leetcode.com/problems/construct-quad-tree/) | Medium | Divide a square into four quadrants. |
| [932. Beautiful Array](https://leetcode.com/problems/beautiful-array/) | Medium | Recursively construct odd and even halves. |

#### Solution: [23. Merge k Sorted Lists](https://leetcode.com/problems/merge-k-sorted-lists/) - Hard

```python
class Solution:
    def mergeKLists(self, lists):
        if not lists:
            return None
        if len(lists) == 1:
            return lists[0]

        middle = len(lists) // 2
        left = self.mergeKLists(lists[:middle])
        right = self.mergeKLists(lists[middle:])
        return self.mergeTwo(left, right)

    def mergeTwo(self, left, right):
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

Why it works: recursively reduce k lists to two halves, then merge the two resulting sorted lists.

#### Solution: [241. Different Ways to Add Parentheses](https://leetcode.com/problems/different-ways-to-add-parentheses/) - Medium

```python
from functools import lru_cache

class Solution:
    def diffWaysToCompute(self, expression):
        @lru_cache(None)
        def compute(text):
            results = []
            for index, character in enumerate(text):
                if character not in '+-*':
                    continue
                left_values = compute(text[:index])
                right_values = compute(text[index + 1:])
                for left in left_values:
                    for right in right_values:
                        if character == '+':
                            results.append(left + right)
                        elif character == '-':
                            results.append(left - right)
                        else:
                            results.append(left * right)
            if not results:
                results.append(int(text))
            return results

        return compute(expression)
```

Why it works: every operator can be the final operation, dividing the expression into independent left and right result sets.

#### Solution: [395. Longest Substring with At Least K Repeating Characters](https://leetcode.com/problems/longest-substring-with-at-least-k-repeating-characters/) - Medium

```python
from collections import Counter

class Solution:
    def longestSubstring(self, s, k):
        if len(s) < k:
            return 0

        counts = Counter(s)
        for index, character in enumerate(s):
            if counts[character] < k:
                return max(self.longestSubstring(s[:index], k), self.longestSubstring(s[index + 1:], k))
        return len(s)
```

Why it works: any character occurring fewer than k times cannot appear in a valid substring, so split the problem around it.

#### Solution: [427. Construct Quad Tree](https://leetcode.com/problems/construct-quad-tree/) - Medium

```python
class Solution:
    def construct(self, grid):
        def build(row, column, size):
            first = grid[row][column]
            uniform = all(grid[r][c] == first
                          for r in range(row, row + size)
                          for c in range(column, column + size))
            if uniform:
                return Node(first == 1, True)

            half = size // 2
            return Node(
                True,
                False,
                build(row, column, half),
                build(row, column + half, half),
                build(row + half, column, half),
                build(row + half, column + half, half)
            )

        return build(0, 0, len(grid))
```

Why it works: if a square is uniform it becomes a leaf; otherwise divide it into four equal quadrants recursively.

#### Solution: [932. Beautiful Array](https://leetcode.com/problems/beautiful-array/) - Medium

```python
from functools import lru_cache

class Solution:
    def beautifulArray(self, n):
        @lru_cache(None)
        def build(size):
            if size == 1:
                return (1,)
            odds = tuple(2 * value - 1 for value in build((size + 1) // 2))
            evens = tuple(2 * value for value in build(size // 2))
            return odds + evens

        return list(build(n))
```

Why it works: odd values and even values cannot create an arithmetic midpoint across the two groups, so recursively beautiful odd and even arrays can be concatenated.

---

#### Solution: [240. Search a 2D Matrix II](https://leetcode.com/problems/search-a-2d-matrix-ii/) - Medium

```python
class Solution:
    def searchMatrix(self, matrix, target):
        if not matrix or not matrix[0]:
            return False

        rows, columns = len(matrix), len(matrix[0])

        def search(top, bottom, left, right):
            if top > bottom or left > right:
                return False
            if target < matrix[top][left] or target > matrix[bottom][right]:
                return False

            middle_row = (top + bottom) // 2
            middle_column = (left + right) // 2
            value = matrix[middle_row][middle_column]
            if value == target:
                return True
            if value > target:
                return (search(top, middle_row - 1, left, right)
                        or search(middle_row, bottom, left, middle_column - 1))
            return (search(middle_row + 1, bottom, left, right)
                    or search(top, middle_row, middle_column + 1, right))

        return search(0, rows - 1, 0, columns - 1)
```

Why it works: compare the center of the current rectangle and recursively discard regions that cannot contain the target.

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

Why it works: recursively choose a candidate, keep the same index for reuse, and undo the choice after exploring that branch.

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

Why it works: each recursion level selects one unused value, producing every possible ordering.

#### Solution: [509. Fibonacci Number](https://leetcode.com/problems/fibonacci-number/) - Easy

```python
class Solution:
    def fib(self, n):
        if n <= 1:
            return n
        return self.fib(n - 1) + self.fib(n - 2)
```

Why it works: the Fibonacci recurrence directly divides the requested value into two smaller values.

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

Why it works: every element creates two recursive branches: exclude it or include it.

#### Solution: [889. Construct Binary Tree from Preorder and Postorder Traversal](https://leetcode.com/problems/construct-binary-tree-from-preorder-and-postorder-traversal/) - Medium

```python
class Solution:
    def constructFromPrePost(self, preorder, postorder):
        if not preorder:
            return None

        root = TreeNode(preorder[0])
        if len(preorder) == 1:
            return root

        left_root = preorder[1]
        left_size = postorder.index(left_root) + 1
        root.left = self.constructFromPrePost(preorder[1:left_size + 1], postorder[:left_size])
        root.right = self.constructFromPrePost(preorder[left_size + 1:], postorder[left_size:-1])
        return root
```

Why it works: preorder identifies the root and next left-root, while postorder locates the complete left subtree boundary.

---

## 3. Quick pattern recognition guide

### Use merge-based divide and conquer when you see:
- sorting plus a cross-half counting condition
- inversion or range counting
- results that combine left prefix, right suffix, and crossing values

### Use partition recursion when you see:
- quickselect or quicksort
- a pivot dividing the search space
- a root or maximum splitting a tree/array into independent sections

### Use backtracking recursion when you see:
- all combinations, subsets, or permutations
- a sequence of choices with undo operations
- invalid partial solutions that can be pruned

### Use memoized recursion when you see:
- repeated identical states
- include/skip choices
- a tree or matrix state whose answer depends on smaller states

---

## 4. Core templates

### Divide, recurse, combine

```python
def solve(left, right):
    if base_case(left, right):
        return base_result
    middle = (left + right) // 2
    first = solve(left, middle)
    second = solve(middle + 1, right)
    return combine(first, second)
```

### Recursive binary search

```python
def search(left, right):
    if left > right:
        return not_found
    middle = (left + right) // 2
    if is_answer(middle):
        return answer
    if target_is_left:
        return search(left, middle - 1)
    return search(middle + 1, right)
```

### Quickselect

```python
def select(left, right):
    pivot_index = partition(left, right)
    if pivot_index == target:
        return nums[pivot_index]
    if pivot_index < target:
        return select(pivot_index + 1, right)
    return select(left, pivot_index - 1)
```

### Backtracking

```python
def backtrack(path, state):
    if complete(state):
        result.append(path[:])
        return
    for choice in choices(state):
        apply(choice, state, path)
        backtrack(path, state)
        undo(choice, state, path)
```

---

## 5. Practice order

1. [509. Fibonacci Number](https://leetcode.com/problems/fibonacci-number/)
2. [108. Convert Sorted Array to Binary Search Tree](https://leetcode.com/problems/convert-sorted-array-to-binary-search-tree/)
3. [912. Sort an Array](https://leetcode.com/problems/sort-an-array/)
4. [78. Subsets](https://leetcode.com/problems/subsets/)
5. [46. Permutations](https://leetcode.com/problems/permutations/)
6. [39. Combination Sum](https://leetcode.com/problems/combination-sum/)
7. [215. Kth Largest Element in an Array](https://leetcode.com/problems/kth-largest-element-in-an-array/)
8. [105. Construct Binary Tree from Preorder and Inorder Traversal](https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/)
9. [315. Count of Smaller Numbers After Self](https://leetcode.com/problems/count-of-smaller-numbers-after-self/)
10. [241. Different Ways to Add Parentheses](https://leetcode.com/problems/different-ways-to-add-parentheses/)

---

## 6. Cheat sheet

- Base case: define the smallest solvable input first.
- Divide: split into independent smaller problems.
- Combine: summarize each child enough to solve the parent.
- Quickselect: recurse into only the partition containing the target.
- Backtracking: choose, recurse, undo.
- Memoization: cache the complete recursive state.
- Merge counting: count cross-half relationships before merging.

---

## 7. Interview trigger

Reach for Divide and Conquer when the statement includes:

- split, partition, or divide into halves
- merge sorted pieces
- count relationships across ranges
- recursively construct a tree or expression
- choose/exclude and generate all valid outcomes

Before coding, state the base case, the recursive return value, and what information the combine step requires.

---

## 8. Common mistakes

- forgetting the base case
- recursing on the same range forever
- combining only one side and losing crossing answers
- using mutable slices inefficiently in deep recursion
- failing to copy a completed backtracking path
- forgetting memoization for repeated states
- choosing a recursive approach when the call depth can exceed the language limit

---

## 9. Current coverage

Every problem currently listed in the Divide and Conquer sub-pattern tables and practice order has a direct solution above.

Current mapped inventory:

- 25 unique Divide and Conquer problems
- 25 direct solutions
- 0 unsolved entries in the current file

The attached Divide and Conquer export is now represented in the backlog below. Existing solved problems are excluded from that backlog.

---

## 10. Remaining problems from the attached Divide and Conquer list

These 52 problems were present in the attachment but do not yet have direct solutions above. They are listed here as the next solution backlog. Existing solved problems are intentionally excluded.

- [109. Convert Sorted List to Binary Search Tree](https://leetcode.com/problems/convert-sorted-list-to-binary-search-tree/) - Medium
- [169. Majority Element](https://leetcode.com/problems/majority-element/) - Easy
- [190. Reverse Bits](https://leetcode.com/problems/reverse-bits/) - Easy
- [191. Number of 1 Bits](https://leetcode.com/problems/number-of-1-bits/) - Easy
- [218. The Skyline Problem](https://leetcode.com/problems/the-skyline-problem/) - Hard
- [307. Range Sum Query - Mutable](https://leetcode.com/problems/range-sum-query-mutable/) - Medium
- [324. Wiggle Sort II](https://leetcode.com/problems/wiggle-sort-ii/) - Medium
- [347. Top K Frequent Elements](https://leetcode.com/problems/top-k-frequent-elements/) - Medium
- [372. Super Pow](https://leetcode.com/problems/super-pow/) - Medium
- [558. Logical OR of Two Binary Grids Represented as Quad-Trees](https://leetcode.com/problems/logical-or-of-two-binary-grids-represented-as-quad-trees/) - Medium
- [761. Special Binary String](https://leetcode.com/problems/special-binary-string/) - Hard
- [918. Maximum Sum Circular Subarray](https://leetcode.com/problems/maximum-sum-circular-subarray/) - Medium
- [973. K Closest Points to Origin](https://leetcode.com/problems/k-closest-points-to-origin/) - Medium
- [1274. Number of Ships in a Rectangle](https://leetcode.com/problems/number-of-ships-in-a-rectangle/) - Hard
- [1382. Balance a Binary Search Tree](https://leetcode.com/problems/balance-a-binary-search-tree/) - Medium
- [1569. Number of Ways to Reorder Array to Get Same BST](https://leetcode.com/problems/number-of-ways-to-reorder-array-to-get-same-bst/) - Hard
- [1649. Create Sorted Array through Instructions](https://leetcode.com/problems/create-sorted-array-through-instructions/) - Hard
- [1738. Find Kth Largest XOR Coordinate Value](https://leetcode.com/problems/find-kth-largest-xor-coordinate-value/) - Medium
- [1756. Design Most Recently Used Queue](https://leetcode.com/problems/design-most-recently-used-queue/) - Medium
- [1763. Longest Nice Substring](https://leetcode.com/problems/longest-nice-substring/) - Easy
- [1985. Find the Kth Largest Integer in the Array](https://leetcode.com/problems/find-the-kth-largest-integer-in-the-array/) - Medium
- [2031. Count Subarrays With More Ones Than Zeros](https://leetcode.com/problems/count-subarrays-with-more-ones-than-zeros/) - Medium
- [2179. Count Good Triplets in an Array](https://leetcode.com/problems/count-good-triplets-in-an-array/) - Hard
- [2343. Query Kth Smallest Trimmed Number](https://leetcode.com/problems/query-kth-smallest-trimmed-number/) - Medium
- [2407. Longest Increasing Subsequence II](https://leetcode.com/problems/longest-increasing-subsequence-ii/) - Hard
- [2426. Number of Pairs Satisfying Inequality](https://leetcode.com/problems/number-of-pairs-satisfying-inequality/) - Hard
- [2519. Count the Number of K-Big Indices](https://leetcode.com/problems/count-the-number-of-k-big-indices/) - Hard
- [2613. Beautiful Pairs](https://leetcode.com/problems/beautiful-pairs/) - Hard
- [2792. Count Nodes That Are Great Enough](https://leetcode.com/problems/count-nodes-that-are-great-enough/) - Hard
- [3109. Find the Index of Permutation](https://leetcode.com/problems/find-the-index-of-permutation/) - Medium
- [3165. Maximum Sum of Subsequence With Non-adjacent Elements](https://leetcode.com/problems/maximum-sum-of-subsequence-with-non-adjacent-elements/) - Hard
- [3410. Maximize Subarray Sum After Removing All Occurrences of One Element](https://leetcode.com/problems/maximize-subarray-sum-after-removing-all-occurrences-of-one-element/) - Hard
- [3520. Minimum Threshold for Inversion Pairs Count](https://leetcode.com/problems/minimum-threshold-for-inversion-pairs-count/) - Medium
- [3537. Fill a Special Grid](https://leetcode.com/problems/fill-a-special-grid/) - Medium
- [3624. Number of Integers With Popcount-Depth Equal to K II](https://leetcode.com/problems/number-of-integers-with-popcount-depth-equal-to-k-ii/) - Hard
- [3636. Threshold Majority Queries](https://leetcode.com/problems/threshold-majority-queries/) - Hard
- [3653. XOR After Range Multiplication Queries I](https://leetcode.com/problems/xor-after-range-multiplication-queries-i/) - Medium
- [3655. XOR After Range Multiplication Queries II](https://leetcode.com/problems/xor-after-range-multiplication-queries-ii/) - Hard
- [3719. Longest Balanced Subarray I](https://leetcode.com/problems/longest-balanced-subarray-i/) - Medium
- [3721. Longest Balanced Subarray II](https://leetcode.com/problems/longest-balanced-subarray-ii/) - Hard
- [3737. Count Subarrays With Majority Element I](https://leetcode.com/problems/count-subarrays-with-majority-element-i/) - Medium
- [3739. Count Subarrays With Majority Element II](https://leetcode.com/problems/count-subarrays-with-majority-element-ii/) - Hard
- [3749. Evaluate Valid Expressions](https://leetcode.com/problems/evaluate-valid-expressions/) - Hard
- [3759. Count Elements With at Least K Greater Values](https://leetcode.com/problems/count-elements-with-at-least-k-greater-values/) - Medium
- [3826. Minimum Partition Score](https://leetcode.com/problems/minimum-partition-score/) - Hard
- [3841. Palindromic Path Queries in a Tree](https://leetcode.com/problems/palindromic-path-queries-in-a-tree/) - Hard
- [3855. Sum of K-Digit Numbers in a Range](https://leetcode.com/problems/sum-of-k-digit-numbers-in-a-range/) - Hard
- [3864. Minimum Cost to Partition a Binary String](https://leetcode.com/problems/minimum-cost-to-partition-a-binary-string/) - Hard
- [3943. Number of Pairs After Increment](https://leetcode.com/problems/number-of-pairs-after-increment/) - Hard
- [4011. Count Subarrays With Even Odd Ratio I](https://leetcode.com/problems/count-subarrays-with-even-odd-ratio-i/) - Medium
- [4013. Count Subarrays With Even Odd Ratio II](https://leetcode.com/problems/count-subarrays-with-even-odd-ratio-ii/) - Hard
- [4017. Peaks in Array II](https://leetcode.com/problems/peaks-in-array-ii/) - Hard
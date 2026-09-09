# Prefix Sum Pattern Mastery

A practical notes document for studying Prefix Sum and its related sub-patterns on LeetCode.

> Prefix Sum converts repeated range accumulation into constant-time subtraction. The pattern becomes especially powerful when combined with hash maps, parity or balance transformations, two dimensions, difference arrays, and monotonic deques.

---

## 1. What is the Prefix Sum pattern?

For an array `nums`, define:

```python
prefix[i + 1] = prefix[i] + nums[i]
```

Then the sum of `nums[left:right + 1]` is:

```python
prefix[right + 1] - prefix[left]
```

Use Prefix Sum when:
- many range-sum queries must be answered
- a contiguous subarray must have a target sum
- a condition can be transformed into equal prefix states
- a matrix contains repeated rectangle-sum queries
- a range update can be represented by endpoint changes
- a negative-value array makes ordinary sliding window invalid

The key invariant is:

> A prefix state summarizes everything needed about the elements before the current position.

---

## 2. Sub-pattern map

### A. One-dimensional range sums and running prefix state

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [303. Range Sum Query - Immutable](https://leetcode.com/problems/range-sum-query-immutable/) | Easy | Repeated static range queries. |
| [724. Find Pivot Index](https://leetcode.com/problems/find-pivot-index/) | Easy | Compare left and right prefix sums. |
| [1480. Running Sum of 1d Array](https://leetcode.com/problems/running-sum-of-1d-array/) | Easy | Direct prefix construction. |
| [1732. Find the Highest Altitude](https://leetcode.com/problems/find-the-highest-altitude/) | Easy | Track the maximum prefix value. |
| [1991. Find the Middle Index in Array](https://leetcode.com/problems/find-the-middle-index-in-array/) | Easy | Prefix balance around an index. |
| [2389. Longest Subsequence With Limited Sum](https://leetcode.com/problems/longest-subsequence-with-limited-sum/) | Easy | Sort, prefix, and binary search. |

#### Solution: [303. Range Sum Query - Immutable](https://leetcode.com/problems/range-sum-query-immutable/) - Easy

```python
class NumArray:
    def __init__(self, nums):
        self.prefix = [0]
        for value in nums:
            self.prefix.append(self.prefix[-1] + value)

    def sumRange(self, left, right):
        return self.prefix[right + 1] - self.prefix[left]
```

Why it works: store every prefix total once, then subtract two prefixes to answer any inclusive range in O(1).

#### Solution: [724. Find Pivot Index](https://leetcode.com/problems/find-pivot-index/) - Easy

```python
class Solution:
    def pivotIndex(self, nums):
        total = sum(nums)
        left_sum = 0

        for index, value in enumerate(nums):
            right_sum = total - left_sum - value
            if left_sum == right_sum:
                return index
            left_sum += value

        return -1
```

Why it works: the right side is the total minus the left prefix and the current value.

#### Solution: [1480. Running Sum of 1d Array](https://leetcode.com/problems/running-sum-of-1d-array/) - Easy

```python
class Solution:
    def runningSum(self, nums):
        total = 0
        result = []

        for value in nums:
            total += value
            result.append(total)

        return result
```

Why it works: each result is the previous prefix plus the next value.

#### Solution: [1732. Find the Highest Altitude](https://leetcode.com/problems/find-the-highest-altitude/) - Easy

```python
class Solution:
    def largestAltitude(self, gain):
        altitude = 0
        best = 0

        for change in gain:
            altitude += change
            best = max(best, altitude)

        return best
```

Why it works: the altitude at each point is a prefix sum of the gains.

#### Solution: [1991. Find the Middle Index in Array](https://leetcode.com/problems/find-the-middle-index-in-array/) - Easy

```python
class Solution:
    def findMiddleIndex(self, nums):
        total = sum(nums)
        left_sum = 0

        for index, value in enumerate(nums):
            if left_sum == total - left_sum - value:
                return index
            left_sum += value

        return -1
```

Why it works: check whether the prefix before the index equals the suffix after it.

#### Solution: [2389. Longest Subsequence With Limited Sum](https://leetcode.com/problems/longest-subsequence-with-limited-sum/) - Easy

```python
from bisect import bisect_right

class Solution:
    def answerQueries(self, nums, queries):
        nums.sort()
        prefix = [0]
        for value in nums:
            prefix.append(prefix[-1] + value)

        return [bisect_right(prefix, query) - 1 for query in queries]
```

Why it works: after sorting, the maximum-length subsequence for a limit uses the smallest values; binary search finds how many prefix values fit.

---

### B. Prefix sum plus hash map for exact subarray conditions

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [560. Subarray Sum Equals K](https://leetcode.com/problems/subarray-sum-equals-k/) | Medium | Count equal prefix differences. |
| [523. Continuous Subarray Sum](https://leetcode.com/problems/continuous-subarray-sum/) | Medium | Equal remainders identify sums divisible by k. |
| [525. Contiguous Array](https://leetcode.com/problems/contiguous-array/) | Medium | Balance zeros and ones, then find repeated balance. |
| [930. Binary Subarrays With Sum](https://leetcode.com/problems/binary-subarrays-with-sum/) | Medium | Exact binary sum. |
| [974. Subarray Sums Divisible by K](https://leetcode.com/problems/subarray-sums-divisible-by-k/) | Medium | Count equal prefix remainders. |
| [1248. Count Number of Nice Subarrays](https://leetcode.com/problems/count-number-of-nice-subarrays/) | Medium | Transform odd counts into prefix counts. |
| [1590. Make Sum Divisible by P](https://leetcode.com/problems/make-sum-divisible-by-p/) | Medium | Find the shortest removable prefix-remainder interval. |

#### Solution: [560. Subarray Sum Equals K](https://leetcode.com/problems/subarray-sum-equals-k/) - Medium

```python
class Solution:
    def subarraySum(self, nums, k):
        counts = {0: 1}
        prefix = 0
        answer = 0

        for value in nums:
            prefix += value
            answer += counts.get(prefix - k, 0)
            counts[prefix] = counts.get(prefix, 0) + 1

        return answer
```

Why it works: a subarray sums to k when an earlier prefix equals the current prefix minus k.

#### Solution: [523. Continuous Subarray Sum](https://leetcode.com/problems/continuous-subarray-sum/) - Medium

```python
class Solution:
    def checkSubarraySum(self, nums, k):
        first_index = {0: -1}
        remainder = 0

        for index, value in enumerate(nums):
            remainder = (remainder + value) % k
            if remainder in first_index:
                if index - first_index[remainder] >= 2:
                    return True
            else:
                first_index[remainder] = index

        return False
```

Why it works: equal prefix remainders mean the difference between those prefixes is divisible by k; keep the earliest index to maximize length.

#### Solution: [525. Contiguous Array](https://leetcode.com/problems/contiguous-array/) - Medium

```python
class Solution:
    def findMaxLength(self, nums):
        first_index = {0: -1}
        balance = 0
        best = 0

        for index, value in enumerate(nums):
            balance += 1 if value == 1 else -1
            if balance in first_index:
                best = max(best, index - first_index[balance])
            else:
                first_index[balance] = index

        return best
```

Why it works: treating 1 as +1 and 0 as -1 makes a zero-sum range contain equal numbers of both.

#### Solution: [930. Binary Subarrays With Sum](https://leetcode.com/problems/binary-subarrays-with-sum/) - Medium

```python
class Solution:
    def numSubarraysWithSum(self, nums, goal):
        counts = {0: 1}
        prefix = 0
        answer = 0

        for value in nums:
            prefix += value
            answer += counts.get(prefix - goal, 0)
            counts[prefix] = counts.get(prefix, 0) + 1

        return answer
```

Why it works: count earlier prefixes that are exactly goal below the current prefix.

#### Solution: [974. Subarray Sums Divisible by K](https://leetcode.com/problems/subarray-sums-divisible-by-k/) - Medium

```python
from collections import defaultdict

class Solution:
    def subarraysDivByK(self, nums, k):
        counts = defaultdict(int)
        counts[0] = 1
        remainder = 0
        answer = 0

        for value in nums:
            remainder = (remainder + value) % k
            answer += counts[remainder]
            counts[remainder] += 1

        return answer
```

Why it works: two prefixes with the same remainder produce a difference divisible by k.

#### Solution: [1248. Count Number of Nice Subarrays](https://leetcode.com/problems/count-number-of-nice-subarrays/) - Medium

```python
class Solution:
    def numberOfSubarrays(self, nums, k):
        counts = {0: 1}
        odd_count = 0
        answer = 0

        for value in nums:
            odd_count += value % 2
            answer += counts.get(odd_count - k, 0)
            counts[odd_count] = counts.get(odd_count, 0) + 1

        return answer
```

Why it works: a subarray has exactly k odd values when two prefix odd-counts differ by k.

#### Solution: [1590. Make Sum Divisible by P](https://leetcode.com/problems/make-sum-divisible-by-p/) - Medium

```python
class Solution:
    def minSubarray(self, nums, p):
        total_remainder = sum(nums) % p
        if total_remainder == 0:
            return 0

        last_index = {0: -1}
        remainder = 0
        best = len(nums)

        for index, value in enumerate(nums):
            remainder = (remainder + value) % p
            needed = (remainder - total_remainder) % p
            if needed in last_index:
                best = min(best, index - last_index[needed])
            last_index[remainder] = index

        return -1 if best == len(nums) else best
```

Why it works: remove a subarray whose remainder equals the total remainder modulo p, while keeping the shortest such interval.

---

### C. Prefix balance and transformed values

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [437. Path Sum III](https://leetcode.com/problems/path-sum-iii/) | Medium | Prefix sums along root-to-node paths. |
| [1124. Longest Well-Performing Interval](https://leetcode.com/problems/longest-well-performing-interval/) | Medium | Transform tiring/non-tiring days into +1/-1 balance. |
| [1442. Count Triplets That Can Form Two Arrays of Equal XOR](https://leetcode.com/problems/count-triplets-that-can-form-two-arrays-of-equal-xor/) | Medium | Prefix XOR is the analogous operation for XOR ranges. |
| [1524. Number of Sub-arrays With Odd Sum](https://leetcode.com/problems/number-of-sub-arrays-with-odd-sum/) | Medium | Track parity of prefix sums. |
| [1594. Maximum Non Negative Product in a Matrix](https://leetcode.com/problems/maximum-non-negative-product-in-a-matrix/) | Medium | Prefix-style path state with min/max products. |

#### Solution: [1124. Longest Well-Performing Interval](https://leetcode.com/problems/longest-well-performing-interval/) - Medium

```python
class Solution:
    def longestWPI(self, hours):
        first_index = {0: -1}
        score = 0
        best = 0

        for index, hour in enumerate(hours):
            score += 1 if hour > 8 else -1
            if score > 0:
                best = index + 1
            else:
                if score not in first_index:
                    first_index[score] = index
                if score - 1 in first_index:
                    best = max(best, index - first_index[score - 1])

        return best
```

Why it works: a well-performing interval has more tiring than non-tiring days, which becomes a positive-sum subarray after the transformation.

#### Solution: [1442. Count Triplets That Can Form Two Arrays of Equal XOR](https://leetcode.com/problems/count-triplets-that-can-form-two-arrays-of-equal-xor/) - Medium

```python
class Solution:
    def countTriplets(self, arr):
        prefix = [0]
        for value in arr:
            prefix.append(prefix[-1] ^ value)

        answer = 0
        for i in range(len(arr)):
            for k in range(i + 1, len(arr)):
                if prefix[i] == prefix[k + 1]:
                    answer += k - i

        return answer
```

Why it works: equal prefix XOR values mean the XOR from i through k is zero, and every split point j between them forms a valid triplet.

#### Solution: [1524. Number of Sub-arrays With Odd Sum](https://leetcode.com/problems/number-of-sub-arrays-with-odd-sum/) - Medium

```python
class Solution:
    def numOfSubarrays(self, arr):
        even = 1
        odd = 0
        parity = 0
        answer = 0

        for value in arr:
            parity ^= value & 1
            if parity:
                answer += even
                odd += 1
            else:
                answer += odd
                even += 1

        return answer % (10**9 + 7)
```

Why it works: an odd subarray is formed by pairing an odd prefix with an earlier even prefix, or an even prefix with an earlier odd prefix.

---

### D. Two-dimensional Prefix Sum

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [304. Range Sum Query 2D - Immutable](https://leetcode.com/problems/range-sum-query-2d-immutable/) | Medium | Constant-time rectangle queries. |
| [1314. Matrix Block Sum](https://leetcode.com/problems/matrix-block-sum/) | Medium | Rectangle sums around every cell. |
| [1074. Number of Submatrices That Sum to Target](https://leetcode.com/problems/number-of-submatrices-that-sum-to-target/) | Hard | Compress rows and apply 1D prefix hashing. |

#### Solution: [304. Range Sum Query 2D - Immutable](https://leetcode.com/problems/range-sum-query-2d-immutable/) - Medium

```python
class NumMatrix:
    def __init__(self, matrix):
        rows = len(matrix)
        columns = len(matrix[0]) if rows else 0
        self.prefix = [[0] * (columns + 1) for _ in range(rows + 1)]

        for row in range(rows):
            for column in range(columns):
                self.prefix[row + 1][column + 1] = (
                    matrix[row][column]
                    + self.prefix[row][column + 1]
                    + self.prefix[row + 1][column]
                    - self.prefix[row][column]
                )

    def sumRegion(self, row1, col1, row2, col2):
        return (
            self.prefix[row2 + 1][col2 + 1]
            - self.prefix[row1][col2 + 1]
            - self.prefix[row2 + 1][col1]
            + self.prefix[row1][col1]
        )
```

Why it works: inclusion-exclusion combines four prefix rectangles to isolate the requested rectangle.

#### Solution: [1314. Matrix Block Sum](https://leetcode.com/problems/matrix-block-sum/) - Medium

```python
class Solution:
    def matrixBlockSum(self, mat, k):
        rows, columns = len(mat), len(mat[0])
        prefix = [[0] * (columns + 1) for _ in range(rows + 1)]

        for row in range(rows):
            for column in range(columns):
                prefix[row + 1][column + 1] = (
                    mat[row][column]
                    + prefix[row][column + 1]
                    + prefix[row + 1][column]
                    - prefix[row][column]
                )

        result = [[0] * columns for _ in range(rows)]
        for row in range(rows):
            for column in range(columns):
                top = max(0, row - k)
                bottom = min(rows - 1, row + k)
                left = max(0, column - k)
                right = min(columns - 1, column + k)
                result[row][column] = (
                    prefix[bottom + 1][right + 1]
                    - prefix[top][right + 1]
                    - prefix[bottom + 1][left]
                    + prefix[top][left]
                )

        return result
```

Why it works: build one 2D prefix table, then query each cell's clipped k-radius rectangle in constant time.

#### Solution: [1074. Number of Submatrices That Sum to Target](https://leetcode.com/problems/number-of-submatrices-that-sum-to-target/) - Hard

```python
from collections import defaultdict

class Solution:
    def numSubmatrixSumTarget(self, matrix, target):
        rows, columns = len(matrix), len(matrix[0])
        answer = 0

        for left in range(columns):
            row_sums = [0] * rows
            for right in range(left, columns):
                for row in range(rows):
                    row_sums[row] += matrix[row][right]

                counts = defaultdict(int)
                counts[0] = 1
                prefix = 0
                for value in row_sums:
                    prefix += value
                    answer += counts[prefix - target]
                    counts[prefix] += 1

        return answer
```

Why it works: fix the left and right columns, compress the matrix between them into row sums, then count target-sum subarrays vertically.

---

### E. Prefix Sum with Difference Arrays and range updates

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [1109. Corporate Flight Bookings](https://leetcode.com/problems/corporate-flight-bookings/) | Medium | Range additions represented by endpoint differences. |
| [1589. Maximum Sum Obtained of Any Permutation](https://leetcode.com/problems/maximum-sum-obtained-of-any-permutation/) | Medium | Count range demand with a difference array. |
| [1854. Maximum Population Year](https://leetcode.com/problems/maximum-population-year/) | Easy | Difference events become population prefixes. |
| [1893. Check if All the Integers in a Range Are Covered](https://leetcode.com/problems/check-if-all-the-integers-in-a-range-are-covered/) | Easy | Mark interval boundaries and accumulate coverage. |

#### Solution: [1109. Corporate Flight Bookings](https://leetcode.com/problems/corporate-flight-bookings/) - Medium

```python
class Solution:
    def corpFlightBookings(self, bookings, n):
        difference = [0] * (n + 1)

        for first, last, seats in bookings:
            difference[first - 1] += seats
            difference[last] -= seats

        answer = []
        current = 0
        for index in range(n):
            current += difference[index]
            answer.append(current)

        return answer
```

Why it works: add seats at the start of each booking and remove them immediately after the ending flight; the prefix restores every flight's total.

#### Solution: [1854. Maximum Population Year](https://leetcode.com/problems/maximum-population-year/) - Easy

```python
class Solution:
    def maximumPopulation(self, logs):
        difference = [0] * 102
        for birth, death in logs:
            difference[birth - 1950] += 1
            difference[death - 1950] -= 1

        current = 0
        best_population = 0
        best_year = 1950
        for offset, change in enumerate(difference[:-1]):
            current += change
            if current > best_population:
                best_population = current
                best_year = 1950 + offset

        return best_year
```

Why it works: births increase the running population at their year and deaths decrease it starting at the death year.

#### Solution: [1893. Check if All the Integers in a Range Are Covered](https://leetcode.com/problems/check-if-all-the-integers-in-a-range-are-covered/) - Easy

```python
class Solution:
    def isCovered(self, ranges, left, right):
        difference = [0] * 52
        for start, end in ranges:
            difference[start] += 1
            difference[end + 1] -= 1

        coverage = 0
        for value in range(1, right + 1):
            coverage += difference[value]
            if value >= left and coverage == 0:
                return False

        return True
```

Why it works: the prefix coverage count tells whether each value in the requested interval is covered by at least one range.

---

### Additional direct solutions for every mapped problem

#### Solution: [437. Path Sum III](https://leetcode.com/problems/path-sum-iii/) - Medium

```python
from collections import defaultdict

class Solution:
    def pathSum(self, root, targetSum):
        prefix_counts = defaultdict(int)
        prefix_counts[0] = 1

        def dfs(node, prefix):
            if not node:
                return 0

            prefix += node.val
            answer = prefix_counts[prefix - targetSum]
            prefix_counts[prefix] += 1
            answer += dfs(node.left, prefix)
            answer += dfs(node.right, prefix)
            prefix_counts[prefix] -= 1
            return answer

        return dfs(root, 0)
```

Why it works: on each root-to-node path, two equal prefix differences identify a downward path with the target sum; backtracking removes states from unrelated branches.

#### Solution: [1109. Corporate Flight Bookings](https://leetcode.com/problems/corporate-flight-bookings/) - Medium

```python
class Solution:
    def corpFlightBookings(self, bookings, n):
        difference = [0] * (n + 1)

        for first, last, seats in bookings:
            difference[first - 1] += seats
            difference[last] -= seats

        answer = []
        current = 0
        for index in range(n):
            current += difference[index]
            answer.append(current)

        return answer
```

Why it works: each booking changes the running total only at its two boundaries, and the prefix pass applies those changes to every covered flight.

#### Solution: [1589. Maximum Sum Obtained of Any Permutation](https://leetcode.com/problems/maximum-sum-obtained-of-any-permutation/) - Medium

```python
class Solution:
    def maxSumRangeQuery(self, nums, requests):
        difference = [0] * (len(nums) + 1)
        for start, end in requests:
            difference[start] += 1
            difference[end + 1] -= 1

        frequency = []
        current = 0
        for index in range(len(nums)):
            current += difference[index]
            frequency.append(current)

        nums.sort()
        frequency.sort()
        modulo = 10**9 + 7
        return sum(value * count for value, count in zip(nums, frequency)) % modulo
```

Why it works: the difference array counts how often each position is requested; sorting both frequencies and values maximizes their dot product.

#### Solution: [1594. Maximum Non Negative Product in a Matrix](https://leetcode.com/problems/maximum-non-negative-product-in-a-matrix/) - Medium

```python
class Solution:
    def maxProductPath(self, grid):
        rows, columns = len(grid), len(grid[0])
        minimum = [[0] * columns for _ in range(rows)]
        maximum = [[0] * columns for _ in range(rows)]
        minimum[0][0] = maximum[0][0] = grid[0][0]

        for row in range(rows):
            for column in range(columns):
                if row == 0 and column == 0:
                    continue

                candidates = []
                if row > 0:
                    candidates.extend((minimum[row - 1][column] * grid[row][column],
                                       maximum[row - 1][column] * grid[row][column]))
                if column > 0:
                    candidates.extend((minimum[row][column - 1] * grid[row][column],
                                       maximum[row][column - 1] * grid[row][column]))

                minimum[row][column] = min(candidates)
                maximum[row][column] = max(candidates)

        answer = maximum[-1][-1]
        return answer % (10**9 + 7) if answer >= 0 else -1
```

Why it works: a negative value can turn a small negative product into the largest positive product, so preserve both minimum and maximum path products at every cell.

---

#### Solution: [862. Shortest Subarray with Sum at Least K](https://leetcode.com/problems/shortest-subarray-with-sum-at-least-k/) - Hard

```python
from collections import deque

class Solution:
    def shortestSubarray(self, nums, k):
        prefix = [0]
        for value in nums:
            prefix.append(prefix[-1] + value)

        candidates = deque()
        best = len(nums) + 1

        for right, total in enumerate(prefix):
            while candidates and total - prefix[candidates[0]] >= k:
                best = min(best, right - candidates.popleft())
            while candidates and prefix[candidates[-1]] >= total:
                candidates.pop()
            candidates.append(right)

        return -1 if best == len(nums) + 1 else best
```

Why it works: prefix sums convert every subarray sum into a difference; the monotonic deque keeps only useful candidate starting prefixes and supports negative values.

---

## 3. Quick pattern recognition guide

### Use direct prefix sums when you see:
- repeated range-sum queries
- running totals or balance at every index
- left sum versus right sum

### Use prefix sum plus a hash map when you see:
- subarray sum equals k
- sum divisible by k
- equal counts of two categories
- exact parity or balance conditions

### Use a 2D prefix sum when you see:
- rectangle sum queries
- block sums around cells
- submatrix sum targets

### Use a difference array when you see:
- many inclusive range updates
- interval additions or coverage
- event starts and ends over a coordinate line

### Use prefix XOR when you see:
- subarray XOR conditions
- equal XOR partitions

---

## 4. Core templates

### One-dimensional prefix sum

```python
prefix = [0]
for value in nums:
    prefix.append(prefix[-1] + value)

range_sum = prefix[right + 1] - prefix[left]
```

### Count subarrays with target sum

```python
counts = {0: 1}
prefix = 0
answer = 0

for value in nums:
    prefix += value
    answer += counts.get(prefix - target, 0)
    counts[prefix] = counts.get(prefix, 0) + 1
```

### Remainder or parity state

```python
state = 0
first_or_count = {0: 1}
for value in nums:
    state = update_state(state, value)
```

### Two-dimensional prefix sum

```python
prefix[row + 1][column + 1] = (
    matrix[row][column]
    + prefix[row][column + 1]
    + prefix[row + 1][column]
    - prefix[row][column]
)
```

### Difference array

```python
difference[start] += amount
difference[end + 1] -= amount
```

---

## 5. Practice order

1. [1480. Running Sum of 1d Array](https://leetcode.com/problems/running-sum-of-1d-array/)
2. [724. Find Pivot Index](https://leetcode.com/problems/find-pivot-index/)
3. [303. Range Sum Query - Immutable](https://leetcode.com/problems/range-sum-query-immutable/)
4. [560. Subarray Sum Equals K](https://leetcode.com/problems/subarray-sum-equals-k/)
5. [525. Contiguous Array](https://leetcode.com/problems/contiguous-array/)
6. [974. Subarray Sums Divisible by K](https://leetcode.com/problems/subarray-sums-divisible-by-k/)
7. [304. Range Sum Query 2D - Immutable](https://leetcode.com/problems/range-sum-query-2d-immutable/)
8. [1109. Corporate Flight Bookings](https://leetcode.com/problems/corporate-flight-bookings/)
9. [1074. Number of Submatrices That Sum to Target](https://leetcode.com/problems/number-of-submatrices-that-sum-to-target/)
10. [862. Shortest Subarray with Sum at Least K](https://leetcode.com/problems/shortest-subarray-with-sum-at-least-k/)

---

## 6. Cheat sheet

- Range sum: `prefix[right + 1] - prefix[left]`.
- Target subarray sum: look for `current_prefix - target`.
- Divisibility: equal remainders define a divisible range.
- Equal balance: transform categories into positive and negative contributions.
- 2D query: use inclusion-exclusion over four prefix corners.
- Difference array: mark only interval boundaries, then take one prefix pass.
- Prefix XOR: replace addition with XOR when the problem's operation is XOR.

---

## 7. Interview trigger

Reach for Prefix Sum when the statement includes:

- range sum queries
- subarray sum equals a target
- divisible by k
- equal numbers of two categories
- many interval updates
- matrix rectangle sums
- a condition involving every contiguous range

Before coding, decide what the prefix state means and what two equal prefix states would imply.

---

## 8. Common mistakes

- using a sliding window when negative numbers make the sum non-monotonic
- forgetting to initialize the empty prefix with `{0: 1}`
- storing the latest index when the earliest index is needed for maximum length
- using the wrong normalized remainder for negative values
- mixing inclusive and exclusive prefix boundaries
- forgetting the inclusion-exclusion subtraction in 2D queries
- applying a range update to every element instead of using a difference array

---

## 9. Current coverage

Every problem currently listed in the Prefix Sum sub-pattern tables and practice order has a direct solution above.

Current mapped inventory:

- 26 unique Prefix Sum problems
- 26 direct solutions
- 0 unsolved entries in the current file

The attached Prefix Sum export is now represented in the backlog below. Existing solved problems are excluded from that backlog.

---

## 10. Remaining problems from the attached Prefix Sum list

These 246 problems were present in the attachment but do not yet have direct solutions above. They are listed here as the next solution backlog. Existing solved problems are intentionally excluded.

- [209. Minimum Size Subarray Sum](https://leetcode.com/problems/minimum-size-subarray-sum/) - Medium
- [238. Product of Array Except Self](https://leetcode.com/problems/product-of-array-except-self/) - Medium
- [253. Meeting Rooms II](https://leetcode.com/problems/meeting-rooms-ii/) - Medium
- [325. Maximum Size Subarray Sum Equals k](https://leetcode.com/problems/maximum-size-subarray-sum-equals-k/) - Medium
- [363. Max Sum of Rectangle No Larger Than K](https://leetcode.com/problems/max-sum-of-rectangle-no-larger-than-k/) - Hard
- [370. Range Addition](https://leetcode.com/problems/range-addition/) - Medium
- [410. Split Array Largest Sum](https://leetcode.com/problems/split-array-largest-sum/) - Hard
- [497. Random Point in Non-overlapping Rectangles](https://leetcode.com/problems/random-point-in-non-overlapping-rectangles/) - Medium
- [528. Random Pick with Weight](https://leetcode.com/problems/random-pick-with-weight/) - Medium
- [548. Split Array with Equal Sum](https://leetcode.com/problems/split-array-with-equal-sum/) - Hard
- [644. Maximum Average Subarray II](https://leetcode.com/problems/maximum-average-subarray-ii/) - Hard
- [689. Maximum Sum of 3 Non-Overlapping Subarrays](https://leetcode.com/problems/maximum-sum-of-3-non-overlapping-subarrays/) - Hard
- [713. Subarray Product Less Than K](https://leetcode.com/problems/subarray-product-less-than-k/) - Medium
- [731. My Calendar II](https://leetcode.com/problems/my-calendar-ii/) - Medium
- [732. My Calendar III](https://leetcode.com/problems/my-calendar-iii/) - Hard
- [798. Smallest Rotation with Highest Score](https://leetcode.com/problems/smallest-rotation-with-highest-score/) - Hard
- [813. Largest Sum of Averages](https://leetcode.com/problems/largest-sum-of-averages/) - Medium
- [848. Shifting Letters](https://leetcode.com/problems/shifting-letters/) - Medium
- [903. Valid Permutations for DI Sequence](https://leetcode.com/problems/valid-permutations-for-di-sequence/) - Hard
- [995. Minimum Number of K Consecutive Bit Flips](https://leetcode.com/problems/minimum-number-of-k-consecutive-bit-flips/) - Hard
- [1000. Minimum Cost to Merge Stones](https://leetcode.com/problems/minimum-cost-to-merge-stones/) - Hard
- [1004. Max Consecutive Ones III](https://leetcode.com/problems/max-consecutive-ones-iii/) - Medium
- [1094. Car Pooling](https://leetcode.com/problems/car-pooling/) - Medium
- [1140. Stone Game II](https://leetcode.com/problems/stone-game-ii/) - Medium
- [1177. Can Make Palindrome from Substring](https://leetcode.com/problems/can-make-palindrome-from-substring/) - Medium
- [1208. Get Equal Substrings Within Budget](https://leetcode.com/problems/get-equal-substrings-within-budget/) - Medium
- [1292. Maximum Side Length of a Square with Sum Less than or Equal to Threshold](https://leetcode.com/problems/maximum-side-length-of-a-square-with-sum-less-than-or-equal-to-threshold/) - Medium
- [1310. XOR Queries of a Subarray](https://leetcode.com/problems/xor-queries-of-a-subarray/) - Medium
- [1352. Product of the Last K Numbers](https://leetcode.com/problems/product-of-the-last-k-numbers/) - Medium
- [1371. Find the Longest Substring Containing Vowels in Even Counts](https://leetcode.com/problems/find-the-longest-substring-containing-vowels-in-even-counts/) - Medium
- [1413. Minimum Value to Get Positive Step by Step Sum](https://leetcode.com/problems/minimum-value-to-get-positive-step-by-step-sum/) - Easy
- [1420. Build Array Where You Can Find The Maximum Exactly K Comparisons](https://leetcode.com/problems/build-array-where-you-can-find-the-maximum-exactly-k-comparisons/) - Hard
- [1422. Maximum Score After Splitting a String](https://leetcode.com/problems/maximum-score-after-splitting-a-string/) - Easy
- [1423. Maximum Points You Can Obtain from Cards](https://leetcode.com/problems/maximum-points-you-can-obtain-from-cards/) - Medium
- [1444. Number of Ways of Cutting a Pizza](https://leetcode.com/problems/number-of-ways-of-cutting-a-pizza/) - Hard
- [1508. Range Sum of Sorted Subarray Sums](https://leetcode.com/problems/range-sum-of-sorted-subarray-sums/) - Medium
- [1525. Number of Good Ways to Split a String](https://leetcode.com/problems/number-of-good-ways-to-split-a-string/) - Medium
- [1546. Maximum Number of Non-Overlapping Subarrays With Sum Equals Target](https://leetcode.com/problems/maximum-number-of-non-overlapping-subarrays-with-sum-equals-target/) - Medium
- [1588. Sum of All Odd Length Subarrays](https://leetcode.com/problems/sum-of-all-odd-length-subarrays/) - Easy
- [1621. Number of Sets of K Non-Overlapping Line Segments](https://leetcode.com/problems/number-of-sets-of-k-non-overlapping-line-segments/) - Medium
- [1658. Minimum Operations to Reduce X to Zero](https://leetcode.com/problems/minimum-operations-to-reduce-x-to-zero/) - Medium
- [1664. Ways to Make a Fair Array](https://leetcode.com/problems/ways-to-make-a-fair-array/) - Medium
- [1674. Minimum Moves to Make Array Complementary](https://leetcode.com/problems/minimum-moves-to-make-array-complementary/) - Medium
- [1685. Sum of Absolute Differences in a Sorted Array](https://leetcode.com/problems/sum-of-absolute-differences-in-a-sorted-array/) - Medium
- [1687. Delivering Boxes from Storage to Ports](https://leetcode.com/problems/delivering-boxes-from-storage-to-ports/) - Hard
- [1703. Minimum Adjacent Swaps for K Consecutive Ones](https://leetcode.com/problems/minimum-adjacent-swaps-for-k-consecutive-ones/) - Hard
- [1712. Ways to Split Array Into Three Subarrays](https://leetcode.com/problems/ways-to-split-array-into-three-subarrays/) - Medium
- [1737. Change Minimum Characters to Satisfy One of Three Conditions](https://leetcode.com/problems/change-minimum-characters-to-satisfy-one-of-three-conditions/) - Medium
- [1738. Find Kth Largest XOR Coordinate Value](https://leetcode.com/problems/find-kth-largest-xor-coordinate-value/) - Medium
- [1744. Can You Eat Your Favorite Candy on Your Favorite Day?](https://leetcode.com/problems/can-you-eat-your-favorite-candy-on-your-favorite-day/) - Medium
- [1769. Minimum Number of Operations to Move All Balls to Each Box](https://leetcode.com/problems/minimum-number-of-operations-to-move-all-balls-to-each-box/) - Medium
- [1788. Maximize the Beauty of the Garden](https://leetcode.com/problems/maximize-the-beauty-of-the-garden/) - Hard
- [1829. Maximum XOR for Each Query](https://leetcode.com/problems/maximum-xor-for-each-query/) - Medium
- [1838. Frequency of the Most Frequent Element](https://leetcode.com/problems/frequency-of-the-most-frequent-element/) - Medium
- [1856. Maximum Subarray Min-Product](https://leetcode.com/problems/maximum-subarray-min-product/) - Medium
- [1862. Sum of Floored Pairs](https://leetcode.com/problems/sum-of-floored-pairs/) - Hard
- [1871. Jump Game VII](https://leetcode.com/problems/jump-game-vii/) - Medium
- [1872. Stone Game VIII](https://leetcode.com/problems/stone-game-viii/) - Hard
- [1878. Get Biggest Three Rhombus Sums in a Grid](https://leetcode.com/problems/get-biggest-three-rhombus-sums-in-a-grid/) - Medium
- [1889. Minimum Space Wasted From Packaging](https://leetcode.com/problems/minimum-space-wasted-from-packaging/) - Hard
- [1894. Find the Student that Will Replace the Chalk](https://leetcode.com/problems/find-the-student-that-will-replace-the-chalk/) - Medium
- [1895. Largest Magic Square](https://leetcode.com/problems/largest-magic-square/) - Medium
- [1906. Minimum Absolute Difference Queries](https://leetcode.com/problems/minimum-absolute-difference-queries/) - Medium
- [1915. Number of Wonderful Substrings](https://leetcode.com/problems/number-of-wonderful-substrings/) - Medium
- [1930. Unique Length-3 Palindromic Subsequences](https://leetcode.com/problems/unique-length-3-palindromic-subsequences/) - Medium
- [1943. Describe the Painting](https://leetcode.com/problems/describe-the-painting/) - Medium
- [1959. Minimum Total Space Wasted With K Resizing Operations](https://leetcode.com/problems/minimum-total-space-wasted-with-k-resizing-operations/) - Medium
- [1977. Number of Ways to Separate Numbers](https://leetcode.com/problems/number-of-ways-to-separate-numbers/) - Hard
- [1983. Widest Pair of Indices With Equal Range Sum](https://leetcode.com/problems/widest-pair-of-indices-with-equal-range-sum/) - Medium
- [2015. Average Height of Buildings in Each Segment](https://leetcode.com/problems/average-height-of-buildings-in-each-segment/) - Medium
- [2017. Grid Game](https://leetcode.com/problems/grid-game/) - Medium
- [2021. Brightest Position on Street](https://leetcode.com/problems/brightest-position-on-street/) - Medium
- [2024. Maximize the Confusion of an Exam](https://leetcode.com/problems/maximize-the-confusion-of-an-exam/) - Medium
- [2025. Maximum Number of Ways to Partition an Array](https://leetcode.com/problems/maximum-number-of-ways-to-partition-an-array/) - Hard
- [2055. Plates Between Candles](https://leetcode.com/problems/plates-between-candles/) - Medium
- [2083. Substrings That Begin and End With the Same Letter](https://leetcode.com/problems/substrings-that-begin-and-end-with-the-same-letter/) - Medium
- [2100. Find Good Days to Rob the Bank](https://leetcode.com/problems/find-good-days-to-rob-the-bank/) - Medium
- [2106. Maximum Fruits Harvested After at Most K Steps](https://leetcode.com/problems/maximum-fruits-harvested-after-at-most-k-steps/) - Hard
- [2121. Intervals Between Identical Elements](https://leetcode.com/problems/intervals-between-identical-elements/) - Medium
- [2132. Stamping the Grid](https://leetcode.com/problems/stamping-the-grid/) - Hard
- [2145. Count the Hidden Sequences](https://leetcode.com/problems/count-the-hidden-sequences/) - Medium
- [2171. Removing Minimum Number of Magic Beans](https://leetcode.com/problems/removing-minimum-number-of-magic-beans/) - Medium
- [2207. Maximize Number of Subsequences in a String](https://leetcode.com/problems/maximize-number-of-subsequences-in-a-string/) - Medium
- [2209. Minimum White Tiles After Covering With Carpets](https://leetcode.com/problems/minimum-white-tiles-after-covering-with-carpets/) - Hard
- [2218. Maximum Value of K Coins From Piles](https://leetcode.com/problems/maximum-value-of-k-coins-from-piles/) - Hard
- [2219. Maximum Sum Score of Array](https://leetcode.com/problems/maximum-sum-score-of-array/) - Medium
- [2222. Number of Ways to Select Buildings](https://leetcode.com/problems/number-of-ways-to-select-buildings/) - Medium
- [2234. Maximum Total Beauty of the Gardens](https://leetcode.com/problems/maximum-total-beauty-of-the-gardens/) - Hard
- [2237. Count Positions on Street With Required Brightness](https://leetcode.com/problems/count-positions-on-street-with-required-brightness/) - Medium
- [2245. Maximum Trailing Zeros in a Cornered Path](https://leetcode.com/problems/maximum-trailing-zeros-in-a-cornered-path/) - Medium
- [2251. Number of Flowers in Full Bloom](https://leetcode.com/problems/number-of-flowers-in-full-bloom/) - Hard
- [2256. Minimum Average Difference](https://leetcode.com/problems/minimum-average-difference/) - Medium
- [2270. Number of Ways to Split Array](https://leetcode.com/problems/number-of-ways-to-split-array/) - Medium
- [2271. Maximum White Tiles Covered by a Carpet](https://leetcode.com/problems/maximum-white-tiles-covered-by-a-carpet/) - Medium
- [2281. Sum of Total Strength of Wizards](https://leetcode.com/problems/sum-of-total-strength-of-wizards/) - Hard
- [2302. Count Subarrays With Score Less Than K](https://leetcode.com/problems/count-subarrays-with-score-less-than-k/) - Hard
- [2381. Shifting Letters II](https://leetcode.com/problems/shifting-letters-ii/) - Medium
- [2382. Maximum Segment Sum After Removals](https://leetcode.com/problems/maximum-segment-sum-after-removals/) - Hard
- [2391. Minimum Amount of Time to Collect Garbage](https://leetcode.com/problems/minimum-amount-of-time-to-collect-garbage/) - Medium
- [2398. Maximum Number of Robots Within Budget](https://leetcode.com/problems/maximum-number-of-robots-within-budget/) - Hard
- [2406. Divide Intervals Into Minimum Number of Groups](https://leetcode.com/problems/divide-intervals-into-minimum-number-of-groups/) - Medium
- [2420. Find All Good Indices](https://leetcode.com/problems/find-all-good-indices/) - Medium
- [2428. Maximum Sum of an Hourglass](https://leetcode.com/problems/maximum-sum-of-an-hourglass/) - Medium
- [2438. Range Product Queries of Powers](https://leetcode.com/problems/range-product-queries-of-powers/) - Medium
- [2439. Minimize Maximum of Array](https://leetcode.com/problems/minimize-maximum-of-array/) - Medium
- [2448. Minimum Cost to Make Array Equal](https://leetcode.com/problems/minimum-cost-to-make-array-equal/) - Hard
- [2478. Number of Beautiful Partitions](https://leetcode.com/problems/number-of-beautiful-partitions/) - Hard
- [2483. Minimum Penalty for a Shop](https://leetcode.com/problems/minimum-penalty-for-a-shop/) - Medium
- [2485. Find the Pivot Integer](https://leetcode.com/problems/find-the-pivot-integer/) - Easy
- [2488. Count Subarrays With Median K](https://leetcode.com/problems/count-subarrays-with-median-k/) - Hard
- [2489. Number of Substrings With Fixed Ratio](https://leetcode.com/problems/number-of-substrings-with-fixed-ratio/) - Medium
- [2505. Bitwise OR of All Subsequence Sums](https://leetcode.com/problems/bitwise-or-of-all-subsequence-sums/) - Medium
- [2528. Maximize the Minimum Powered City](https://leetcode.com/problems/maximize-the-minimum-powered-city/) - Hard
- [2536. Increment Submatrices by One](https://leetcode.com/problems/increment-submatrices-by-one/) - Medium
- [2552. Count Increasing Quadruplets](https://leetcode.com/problems/count-increasing-quadruplets/) - Hard
- [2559. Count Vowel Strings in Ranges](https://leetcode.com/problems/count-vowel-strings-in-ranges/) - Medium
- [2574. Left and Right Sum Differences](https://leetcode.com/problems/left-and-right-sum-differences/) - Easy
- [2587. Rearrange Array to Maximize Prefix Score](https://leetcode.com/problems/rearrange-array-to-maximize-prefix-score/) - Medium
- [2588. Count the Number of Beautiful Subarrays](https://leetcode.com/problems/count-the-number-of-beautiful-subarrays/) - Medium
- [2602. Minimum Operations to Make All Array Elements Equal](https://leetcode.com/problems/minimum-operations-to-make-all-array-elements-equal/) - Medium
- [2615. Sum of Distances](https://leetcode.com/problems/sum-of-distances/) - Medium
- [2640. Find the Score of All Prefixes of an Array](https://leetcode.com/problems/find-the-score-of-all-prefixes-of-an-array/) - Medium
- [2680. Maximum OR](https://leetcode.com/problems/maximum-or/) - Medium
- [2681. Power of Heroes](https://leetcode.com/problems/power-of-heroes/) - Hard
- [2731. Movement of Robots](https://leetcode.com/problems/movement-of-robots/) - Medium
- [2772. Apply Operations to Make All Array Elements Equal to Zero](https://leetcode.com/problems/apply-operations-to-make-all-array-elements-equal-to-zero/) - Medium
- [2819. Minimum Relative Loss After Buying Chocolates](https://leetcode.com/problems/minimum-relative-loss-after-buying-chocolates/) - Hard
- [2838. Maximum Coins Heroes Can Collect](https://leetcode.com/problems/maximum-coins-heroes-can-collect/) - Medium
- [2845. Count of Interesting Subarrays](https://leetcode.com/problems/count-of-interesting-subarrays/) - Medium
- [2848. Points That Intersect With Cars](https://leetcode.com/problems/points-that-intersect-with-cars/) - Easy
- [2873. Maximum Value of an Ordered Triplet I](https://leetcode.com/problems/maximum-value-of-an-ordered-triplet-i/) - Easy
- [2874. Maximum Value of an Ordered Triplet II](https://leetcode.com/problems/maximum-value-of-an-ordered-triplet-ii/) - Medium
- [2875. Minimum Size Subarray in Infinite Array](https://leetcode.com/problems/minimum-size-subarray-in-infinite-array/) - Medium
- [2906. Construct Product Matrix](https://leetcode.com/problems/construct-product-matrix/) - Medium
- [2909. Minimum Sum of Mountain Triplets II](https://leetcode.com/problems/minimum-sum-of-mountain-triplets-ii/) - Medium
- [2945. Find Maximum Non-decreasing Array Length](https://leetcode.com/problems/find-maximum-non-decreasing-array-length/) - Hard
- [2947. Count Beautiful Substrings I](https://leetcode.com/problems/count-beautiful-substrings-i/) - Medium
- [2949. Count Beautiful Substrings II](https://leetcode.com/problems/count-beautiful-substrings-ii/) - Hard
- [2950. Number of Divisible Substrings](https://leetcode.com/problems/number-of-divisible-substrings/) - Medium
- [2955. Number of Same-End Substrings](https://leetcode.com/problems/number-of-same-end-substrings/) - Medium
- [2968. Apply Operations to Maximize Frequency Score](https://leetcode.com/problems/apply-operations-to-maximize-frequency-score/) - Hard
- [2971. Find Polygon With the Largest Perimeter](https://leetcode.com/problems/find-polygon-with-the-largest-perimeter/) - Medium
- [2983. Palindrome Rearrangement Queries](https://leetcode.com/problems/palindrome-rearrangement-queries/) - Hard
- [3015. Count the Number of Houses at a Certain Distance I](https://leetcode.com/problems/count-the-number-of-houses-at-a-certain-distance-i/) - Medium
- [3017. Count the Number of Houses at a Certain Distance II](https://leetcode.com/problems/count-the-number-of-houses-at-a-certain-distance-ii/) - Hard
- [3026. Maximum Good Subarray Sum](https://leetcode.com/problems/maximum-good-subarray-sum/) - Medium
- [3028. Ant on the Boundary](https://leetcode.com/problems/ant-on-the-boundary/) - Easy
- [3070. Count Submatrices with Top-Left Element and Sum Less Than k](https://leetcode.com/problems/count-submatrices-with-top-left-element-and-sum-less-than-k/) - Medium
- [3077. Maximum Strength of K Disjoint Subarrays](https://leetcode.com/problems/maximum-strength-of-k-disjoint-subarrays/) - Hard
- [3086. Minimum Moves to Pick K Ones](https://leetcode.com/problems/minimum-moves-to-pick-k-ones/) - Hard
- [3096. Minimum Levels to Gain More Points](https://leetcode.com/problems/minimum-levels-to-gain-more-points/) - Medium
- [3129. Find All Possible Stable Binary Arrays I](https://leetcode.com/problems/find-all-possible-stable-binary-arrays-i/) - Medium
- [3130. Find All Possible Stable Binary Arrays II](https://leetcode.com/problems/find-all-possible-stable-binary-arrays-ii/) - Hard
- [3147. Taking Maximum Energy From the Mystic Dungeon](https://leetcode.com/problems/taking-maximum-energy-from-the-mystic-dungeon/) - Medium
- [3152. Special Array II](https://leetcode.com/problems/special-array-ii/) - Medium
- [3179. Find the N-th Value After K Seconds](https://leetcode.com/problems/find-the-n-th-value-after-k-seconds/) - Medium
- [3191. Minimum Operations to Make Binary Array Elements Equal to One I](https://leetcode.com/problems/minimum-operations-to-make-binary-array-elements-equal-to-one-i/) - Medium
- [3212. Count Submatrices With Equal Frequency of X and Y](https://leetcode.com/problems/count-submatrices-with-equal-frequency-of-x-and-y/) - Medium
- [3224. Minimum Array Changes to Make Differences Equal](https://leetcode.com/problems/minimum-array-changes-to-make-differences-equal/) - Medium
- [3225. Maximum Score From Grid Operations](https://leetcode.com/problems/maximum-score-from-grid-operations/) - Hard
- [3250. Find the Count of Monotonic Pairs I](https://leetcode.com/problems/find-the-count-of-monotonic-pairs-i/) - Hard
- [3251. Find the Count of Monotonic Pairs II](https://leetcode.com/problems/find-the-count-of-monotonic-pairs-ii/) - Hard
- [3261. Count Substrings That Satisfy K-Constraint II](https://leetcode.com/problems/count-substrings-that-satisfy-k-constraint-ii/) - Hard
- [3279. Maximum Total Area Occupied by Pistons](https://leetcode.com/problems/maximum-total-area-occupied-by-pistons/) - Hard
- [3312. Sorted GCD Pair Queries](https://leetcode.com/problems/sorted-gcd-pair-queries/) - Hard
- [3333. Find the Original Typed String II](https://leetcode.com/problems/find-the-original-typed-string-ii/) - Hard
- [3346. Maximum Frequency of an Element After Performing Operations I](https://leetcode.com/problems/maximum-frequency-of-an-element-after-performing-operations-i/) - Medium
- [3347. Maximum Frequency of an Element After Performing Operations II](https://leetcode.com/problems/maximum-frequency-of-an-element-after-performing-operations-ii/) - Hard
- [3354. Make Array Elements Equal to Zero](https://leetcode.com/problems/make-array-elements-equal-to-zero/) - Easy
- [3355. Zero Array Transformation I](https://leetcode.com/problems/zero-array-transformation-i/) - Medium
- [3356. Zero Array Transformation II](https://leetcode.com/problems/zero-array-transformation-ii/) - Medium
- [3361. Shift Distance Between Two Strings](https://leetcode.com/problems/shift-distance-between-two-strings/) - Medium
- [3362. Zero Array Transformation III](https://leetcode.com/problems/zero-array-transformation-iii/) - Medium
- [3364. Minimum Positive Sum Subarray](https://leetcode.com/problems/minimum-positive-sum-subarray/) - Easy
- [3381. Maximum Subarray Sum With Length Divisible by K](https://leetcode.com/problems/maximum-subarray-sum-with-length-divisible-by-k/) - Medium
- [3410. Maximize Subarray Sum After Removing All Occurrences of One Element](https://leetcode.com/problems/maximize-subarray-sum-after-removing-all-occurrences-of-one-element/) - Hard
- [3413. Maximum Coins From K Consecutive Bags](https://leetcode.com/problems/maximum-coins-from-k-consecutive-bags/) - Medium
- [3425. Longest Special Path](https://leetcode.com/problems/longest-special-path/) - Hard
- [3427. Sum of Variable Length Subarrays](https://leetcode.com/problems/sum-of-variable-length-subarrays/) - Easy
- [3432. Count Partitions with Even Sum Difference](https://leetcode.com/problems/count-partitions-with-even-sum-difference/) - Easy
- [3434. Maximum Frequency After Subarray Operation](https://leetcode.com/problems/maximum-frequency-after-subarray-operation/) - Medium
- [3445. Maximum Difference Between Even and Odd Frequency II](https://leetcode.com/problems/maximum-difference-between-even-and-odd-frequency-ii/) - Hard
- [3473. Sum of K Subarrays With Length at Least M](https://leetcode.com/problems/sum-of-k-subarrays-with-length-at-least-m/) - Medium
- [3480. Maximize Subarrays After Removing One Conflicting Pair](https://leetcode.com/problems/maximize-subarrays-after-removing-one-conflicting-pair/) - Hard
- [3486. Longest Special Path II](https://leetcode.com/problems/longest-special-path-ii/) - Hard
- [3494. Find the Minimum Amount of Time to Brew Potions](https://leetcode.com/problems/find-the-minimum-amount-of-time-to-brew-potions/) - Medium
- [3500. Minimum Cost to Divide Array Into Subarrays](https://leetcode.com/problems/minimum-cost-to-divide-array-into-subarrays/) - Hard
- [3511. Make a Positive Array](https://leetcode.com/problems/make-a-positive-array/) - Medium
- [3538. Merge Operations for Minimum Travel Time](https://leetcode.com/problems/merge-operations-for-minimum-travel-time/) - Hard
- [3540. Minimum Time to Visit All Houses](https://leetcode.com/problems/minimum-time-to-visit-all-houses/) - Medium
- [3546. Equal Sum Grid Partition I](https://leetcode.com/problems/equal-sum-grid-partition-i/) - Medium
- [3548. Equal Sum Grid Partition II](https://leetcode.com/problems/equal-sum-grid-partition-ii/) - Hard
- [3578. Count Partitions With Max-Min Difference at Most K](https://leetcode.com/problems/count-partitions-with-max-min-difference-at-most-k/) - Medium
- [3599. Partition Array to Minimize XOR](https://leetcode.com/problems/partition-array-to-minimize-xor/) - Medium
- [3628. Maximum Number of Subsequences After One Inserting](https://leetcode.com/problems/maximum-number-of-subsequences-after-one-inserting/) - Medium
- [3632. Subarrays with XOR at Least K](https://leetcode.com/problems/subarrays-with-xor-at-least-k/) - Hard
- [3636. Threshold Majority Queries](https://leetcode.com/problems/threshold-majority-queries/) - Hard
- [3652. Best Time to Buy and Sell Stock using Strategy](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-using-strategy/) - Medium
- [3653. XOR After Range Multiplication Queries I](https://leetcode.com/problems/xor-after-range-multiplication-queries-i/) - Medium
- [3654. Minimum Sum After Divisible Sum Deletions](https://leetcode.com/problems/minimum-sum-after-divisible-sum-deletions/) - Medium
- [3655. XOR After Range Multiplication Queries II](https://leetcode.com/problems/xor-after-range-multiplication-queries-ii/) - Hard
- [3656. Determine if a Simple Graph Exists](https://leetcode.com/problems/determine-if-a-simple-graph-exists/) - Medium
- [3694. Distinct Points Reachable After Substring Removal](https://leetcode.com/problems/distinct-points-reachable-after-substring-removal/) - Medium
- [3698. Split Array With Minimum Difference](https://leetcode.com/problems/split-array-with-minimum-difference/) - Medium
- [3699. Number of ZigZag Arrays I](https://leetcode.com/problems/number-of-zigzag-arrays-i/) - Hard
- [3707. Equal Score Substrings](https://leetcode.com/problems/equal-score-substrings/) - Easy
- [3709. Design Exam Scores Tracker](https://leetcode.com/problems/design-exam-scores-tracker/) - Medium
- [3714. Longest Balanced Substring II](https://leetcode.com/problems/longest-balanced-substring-ii/) - Medium
- [3719. Longest Balanced Subarray I](https://leetcode.com/problems/longest-balanced-subarray-i/) - Medium
- [3721. Longest Balanced Subarray II](https://leetcode.com/problems/longest-balanced-subarray-ii/) - Hard
- [3728. Stable Subarrays With Equal Boundary and Interior Sum](https://leetcode.com/problems/stable-subarrays-with-equal-boundary-and-interior-sum/) - Medium
- [3729. Count Distinct Subarrays Divisible by K in Sorted Array](https://leetcode.com/problems/count-distinct-subarrays-divisible-by-k-in-sorted-array/) - Hard
- [3737. Count Subarrays With Majority Element I](https://leetcode.com/problems/count-subarrays-with-majority-element-i/) - Medium
- [3739. Count Subarrays With Majority Element II](https://leetcode.com/problems/count-subarrays-with-majority-element-ii/) - Hard
- [3748. Count Stable Subarrays](https://leetcode.com/problems/count-stable-subarrays/) - Hard
- [3755. Find Maximum Balanced XOR Subarray Length](https://leetcode.com/problems/find-maximum-balanced-xor-subarray-length/) - Medium
- [3756. Concatenate Non-Zero Digits and Multiply by Sum II](https://leetcode.com/problems/concatenate-non-zero-digits-and-multiply-by-sum-ii/) - Medium
- [3771. Total Score of Dungeon Runs](https://leetcode.com/problems/total-score-of-dungeon-runs/) - Medium
- [3788. Maximum Score of a Split](https://leetcode.com/problems/maximum-score-of-a-split/) - Medium
- [3797. Count Routes to Climb a Rectangular Grid](https://leetcode.com/problems/count-routes-to-climb-a-rectangular-grid/) - Hard
- [3826. Minimum Partition Score](https://leetcode.com/problems/minimum-partition-score/) - Hard
- [3845. Maximum Subarray XOR with Bounded Range](https://leetcode.com/problems/maximum-subarray-xor-with-bounded-range/) - Hard
- [3862. Find the Smallest Balanced Index](https://leetcode.com/problems/find-the-smallest-balanced-index/) - Medium
- [3864. Minimum Cost to Partition a Binary String](https://leetcode.com/problems/minimum-cost-to-partition-a-binary-string/) - Hard
- [3883. Count Non Decreasing Arrays With Given Digit Sums](https://leetcode.com/problems/count-non-decreasing-arrays-with-given-digit-sums/) - Hard
- [3888. Minimum Operations to Make All Grid Elements Equal](https://leetcode.com/problems/minimum-operations-to-make-all-grid-elements-equal/) - Hard
- [3891. Minimum Increase to Maximize Special Indices](https://leetcode.com/problems/minimum-increase-to-maximize-special-indices/) - Medium
- [3900. Longest Balanced Substring After One Swap](https://leetcode.com/problems/longest-balanced-substring-after-one-swap/) - Medium
- [3903. Smallest Stable Index I](https://leetcode.com/problems/smallest-stable-index-i/) - Easy
- [3904. Smallest Stable Index II](https://leetcode.com/problems/smallest-stable-index-ii/) - Medium
- [3916. Number of ZigZag Arrays III](https://leetcode.com/problems/number-of-zigzag-arrays-iii/) - Hard
- [3919. Minimum Cost to Move Between Indices](https://leetcode.com/problems/minimum-cost-to-move-between-indices/) - Medium
- [3929. Minimum Partition Score II](https://leetcode.com/problems/minimum-partition-score-ii/) - Hard
- [3933. Largest Local Values in a Matrix II](https://leetcode.com/problems/largest-local-values-in-a-matrix-ii/) - Medium
- [3938. Maximum Path Intersection Sum in a Grid](https://leetcode.com/problems/maximum-path-intersection-sum-in-a-grid/) - Medium
- [3956. Maximum Sum of M Non-Overlapping Subarrays I](https://leetcode.com/problems/maximum-sum-of-m-non-overlapping-subarrays-i/) - Hard
- [3957. Maximum Sum of M Non-Overlapping Subarrays II](https://leetcode.com/problems/maximum-sum-of-m-non-overlapping-subarrays-ii/) - Hard
- [3964. Minimum Lights to Illuminate a Road](https://leetcode.com/problems/minimum-lights-to-illuminate-a-road/) - Medium
- [3969. Valid Subarrays With Matching Sum Digits I](https://leetcode.com/problems/valid-subarrays-with-matching-sum-digits-i/) - Medium
- [3972. Valid Subarrays With Matching Sum Digits II](https://leetcode.com/problems/valid-subarrays-with-matching-sum-digits-ii/) - Hard
- [3981. Count Distinct Ways to Form Target from Two Strings](https://leetcode.com/problems/count-distinct-ways-to-form-target-from-two-strings/) - Hard
- [3985. Palindromic Subarray Sum](https://leetcode.com/problems/palindromic-subarray-sum/) - Hard
- [4008. Minimum Initial Strength to Defeat All Monsters](https://leetcode.com/problems/minimum-initial-strength-to-defeat-all-monsters/) - Medium
- [4011. Count Subarrays With Even Odd Ratio I](https://leetcode.com/problems/count-subarrays-with-even-odd-ratio-i/) - Medium
- [4012. Count of Unfinished Tasks After Each Shift](https://leetcode.com/problems/count-of-unfinished-tasks-after-each-shift/) - Medium
- [4013. Count Subarrays With Even Odd Ratio II](https://leetcode.com/problems/count-subarrays-with-even-odd-ratio-ii/) - Hard
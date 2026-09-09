# Sliding Window Pattern Mastery

A practical notes document for studying the Sliding Window pattern on LeetCode.

> Sliding Window is a specialized two-pointer technique for maintaining a contiguous range while updating its state incrementally. Problems overlap with strings, arrays, frequency maps, prefix sums, and monotonic queues, so each problem is grouped by the primary idea it teaches.

---

## 1. What is the Sliding Window pattern?

Use Sliding Window when:
- the problem asks about a contiguous subarray or substring
- a window has a fixed size k
- a window must satisfy an at-most, at-least, or exact condition
- you need the longest, shortest, maximum, minimum, or count of valid ranges
- the state of a window can be updated when one value enters and one value leaves

Typical idea:
- expand the right side to include new values
- update the window state
- shrink the left side when the window becomes invalid
- record the answer while the window satisfies the invariant

The central invariant is:

> The current window always represents exactly the range described by the maintained state.

---

## 2. Sub-pattern map

### A. Fixed-size windows

Core idea: the window always contains exactly k elements. Add the incoming value and remove the outgoing value in O(1).

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [643. Maximum Average Subarray I](https://leetcode.com/problems/maximum-average-subarray-i/) | Easy | Fixed-size running sum. |
| [1456. Maximum Number of Vowels in a Substring of Given Length](https://leetcode.com/problems/maximum-number-of-vowels-in-a-substring-of-given-length/) | Medium | Fixed-size frequency/count state. |
| [1343. Number of Sub-arrays of Size K and Average Greater than or Equal to Threshold](https://leetcode.com/problems/number-of-sub-arrays-of-size-k-and-average-greater-than-or-equal-to-threshold/) | Medium | Count fixed windows satisfying a sum condition. |
| [567. Permutation in String](https://leetcode.com/problems/permutation-in-string/) | Medium | Fixed-size frequency-map window. |
| [438. Find All Anagrams in a String](https://leetcode.com/problems/find-all-anagrams-in-a-string/) | Medium | Find every fixed-size frequency match. |
| [1052. Grumpy Bookstore Owner](https://leetcode.com/problems/grumpy-bookstore-owner/) | Medium | Fixed window maximizes recoverable value. |
| [1423. Maximum Points You Can Obtain from Cards](https://leetcode.com/problems/maximum-points-you-can-obtain-from-cards/) | Medium | Complement window transforms edge selection into a fixed window. |
| [2461. Maximum Sum of Distinct Subarrays With Length K](https://leetcode.com/problems/maximum-sum-of-distinct-subarrays-with-length-k/) | Medium | Fixed-size sum plus distinctness state. |

#### Solution: [643. Maximum Average Subarray I](https://leetcode.com/problems/maximum-average-subarray-i/) - Easy

```python
class Solution:
    def findMaxAverage(self, nums, k):
        window_sum = sum(nums[:k])
        best_sum = window_sum

        for right in range(k, len(nums)):
            window_sum += nums[right] - nums[right - k]
            best_sum = max(best_sum, window_sum)

        return best_sum / k
```

Why it works: every next window differs by one incoming and one outgoing value, so the sum is updated in O(1).

Time complexity is O(n), and extra space is O(1).

#### Solution: [1456. Maximum Number of Vowels in a Substring of Given Length](https://leetcode.com/problems/maximum-number-of-vowels-in-a-substring-of-given-length/) - Medium

```python
class Solution:
    def maxVowels(self, s, k):
        vowels = set('aeiou')
        current = sum(character in vowels for character in s[:k])
        best = current

        for right in range(k, len(s)):
            if s[right - k] in vowels:
                current -= 1
            if s[right] in vowels:
                current += 1
            best = max(best, current)

        return best
```

Why it works: maintain the number of vowels in the current length-k window instead of recounting each substring.

Time complexity is O(n), and extra space is O(1) aside from the constant-size vowel set.

#### Solution: [1343. Number of Sub-arrays of Size K and Average Greater than or Equal to Threshold](https://leetcode.com/problems/number-of-sub-arrays-of-size-k-and-average-greater-than-or-equal-to-threshold/) - Medium

```python
class Solution:
    def numOfSubarrays(self, arr, k, threshold):
        target_sum = k * threshold
        window_sum = sum(arr[:k])
        answer = int(window_sum >= target_sum)

        for right in range(k, len(arr)):
            window_sum += arr[right] - arr[right - k]
            if window_sum >= target_sum:
                answer += 1

        return answer
```

Why it works: because k is fixed, average >= threshold is equivalent to sum >= k * threshold.

Time complexity is O(n), and extra space is O(1).

---

### B. Variable-size windows with an at-most condition

Core idea: expand the right pointer, then shrink from the left until the window satisfies an at-most constraint.

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [3. Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/) | Medium | At most one occurrence of each character. |
| [904. Fruit Into Baskets](https://leetcode.com/problems/fruit-into-baskets/) | Medium | Longest window with at most two distinct values. |
| [1004. Max Consecutive Ones III](https://leetcode.com/problems/max-consecutive-ones-iii/) | Medium | At most k zero replacements. |
| [2024. Maximize the Confusion of an Exam](https://leetcode.com/problems/maximize-the-confusion-of-an-exam/) | Medium | At most k changes for either character. |
| [2958. Length of Longest Subarray With at Most K Frequency](https://leetcode.com/problems/length-of-longest-subarray-with-at-most-k-frequency/) | Medium | Frequency cap inside a variable window. |
| [340. Longest Substring with At Most K Distinct Characters](https://leetcode.com/problems/longest-substring-with-at-most-k-distinct-characters/) | Medium | Classic distinct-count window. |

#### Solution: [3. Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/) - Medium

```python
class Solution:
    def lengthOfLongestSubstring(self, s):
        last_seen = {}
        left = 0
        best = 0

        for right, character in enumerate(s):
            if character in last_seen and last_seen[character] >= left:
                left = last_seen[character] + 1
            last_seen[character] = right
            best = max(best, right - left + 1)

        return best
```

Why it works: when a repeated character appears inside the current window, move left just beyond its previous occurrence.

#### Solution: [904. Fruit Into Baskets](https://leetcode.com/problems/fruit-into-baskets/) - Medium

```python
class Solution:
    def totalFruit(self, fruits):
        counts = {}
        left = 0
        best = 0

        for right, fruit in enumerate(fruits):
            counts[fruit] = counts.get(fruit, 0) + 1

            while len(counts) > 2:
                outgoing = fruits[left]
                counts[outgoing] -= 1
                if counts[outgoing] == 0:
                    del counts[outgoing]
                left += 1

            best = max(best, right - left + 1)

        return best
```

Why it works: the current window is always the longest valid range ending at right with no more than two fruit types.

#### Solution: [1004. Max Consecutive Ones III](https://leetcode.com/problems/max-consecutive-ones-iii/) - Medium

```python
class Solution:
    def longestOnes(self, nums, k):
        left = 0
        zeros = 0
        best = 0

        for right, value in enumerate(nums):
            if value == 0:
                zeros += 1

            while zeros > k:
                if nums[left] == 0:
                    zeros -= 1
                left += 1

            best = max(best, right - left + 1)

        return best
```

Why it works: shrink only when the window uses more than k zero replacements, leaving every recorded window valid.

---

### C. Variable-size windows with a minimum or threshold condition

Core idea: expand until the condition becomes true, then shrink aggressively to find the shortest or count all valid windows.

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [209. Minimum Size Subarray Sum](https://leetcode.com/problems/minimum-size-subarray-sum/) | Medium | Shortest positive-sum window reaching a target. |
| [713. Subarray Product Less Than K](https://leetcode.com/problems/subarray-product-less-than-k/) | Medium | Count valid product windows. |
| [76. Minimum Window Substring](https://leetcode.com/problems/minimum-window-substring/) | Hard | Smallest window containing required frequencies. |
| [1358. Number of Substrings Containing All Three Characters](https://leetcode.com/problems/number-of-substrings-containing-all-three-characters/) | Medium | Count suffixes after the window becomes valid. |
| [1234. Replace the Substring for Balanced String](https://leetcode.com/problems/replace-the-substring-for-balanced-string/) | Medium | Find the smallest replaceable window. |
| [1658. Minimum Operations to Reduce X to Zero](https://leetcode.com/problems/minimum-operations-to-reduce-x-to-zero/) | Medium | Complement transformation to longest valid window. |

#### Solution: [209. Minimum Size Subarray Sum](https://leetcode.com/problems/minimum-size-subarray-sum/) - Medium

```python
class Solution:
    def minSubArrayLen(self, target, nums):
        left = 0
        current_sum = 0
        best = float('inf')

        for right, value in enumerate(nums):
            current_sum += value
            while current_sum >= target:
                best = min(best, right - left + 1)
                current_sum -= nums[left]
                left += 1

        return 0 if best == float('inf') else best
```

Why it works: once the sum reaches the target, removing values from the left finds the shortest valid window ending at right.

#### Solution: [76. Minimum Window Substring](https://leetcode.com/problems/minimum-window-substring/) - Hard

```python
from collections import Counter

class Solution:
    def minWindow(self, s, t):
        need = Counter(t)
        missing = len(t)
        left = 0
        best_start = 0
        best_length = float('inf')

        for right, character in enumerate(s):
            if need[character] > 0:
                missing -= 1
            need[character] -= 1

            while missing == 0:
                if right - left + 1 < best_length:
                    best_start = left
                    best_length = right - left + 1

                outgoing = s[left]
                need[outgoing] += 1
                if need[outgoing] > 0:
                    missing += 1
                left += 1

        return '' if best_length == float('inf') else s[best_start:best_start + best_length]
```

Why it works: `missing` tracks how many required characters are still absent, so the left pointer can shrink exactly while the window remains valid.

#### Solution: [713. Subarray Product Less Than K](https://leetcode.com/problems/subarray-product-less-than-k/) - Medium

```python
class Solution:
    def numSubarrayProductLessThanK(self, nums, k):
        if k <= 1:
            return 0

        left = 0
        product = 1
        answer = 0

        for right, value in enumerate(nums):
            product *= value
            while product >= k:
                product //= nums[left]
                left += 1
            answer += right - left + 1

        return answer
```

Why it works: after shrinking to a valid product window, every subarray ending at right and starting from left through right is also valid.

---

### D. Exact-count and frequency-map windows

Core idea: maintain counts, then use either a fixed-size window or the difference between two at-most counts.

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [438. Find All Anagrams in a String](https://leetcode.com/problems/find-all-anagrams-in-a-string/) | Medium | Exact frequency match in a fixed window. |
| [567. Permutation in String](https://leetcode.com/problems/permutation-in-string/) | Medium | Exact frequency match with a boolean answer. |
| [992. Subarrays with K Different Integers](https://leetcode.com/problems/subarrays-with-k-different-integers/) | Hard | Exactly k = atMost(k) - atMost(k - 1). |
| [1248. Count Number of Nice Subarrays](https://leetcode.com/problems/count-number-of-nice-subarrays/) | Medium | Exact odd-count window. |
| [930. Binary Subarrays With Sum](https://leetcode.com/problems/binary-subarrays-with-sum/) | Medium | Exact sum using two at-most counts. |
| [1456. Maximum Number of Vowels in a Substring of Given Length](https://leetcode.com/problems/maximum-number-of-vowels-in-a-substring-of-given-length/) | Medium | Fixed frequency property. |

#### Solution: [438. Find All Anagrams in a String](https://leetcode.com/problems/find-all-anagrams-in-a-string/) - Medium

```python
from collections import Counter

class Solution:
    def findAnagrams(self, s, p):
        if len(p) > len(s):
            return []

        need = Counter(p)
        window = Counter(s[:len(p)])
        result = []

        if window == need:
            result.append(0)

        for right in range(len(p), len(s)):
            window[s[right]] += 1
            outgoing = s[right - len(p)]
            window[outgoing] -= 1
            if window[outgoing] == 0:
                del window[outgoing]
            if window == need:
                result.append(right - len(p) + 1)

        return result
```

Why it works: every window has exactly the pattern length, so equality of the frequency maps is exactly the anagram condition.

#### Solution: [992. Subarrays with K Different Integers](https://leetcode.com/problems/subarrays-with-k-different-integers/) - Hard

```python
class Solution:
    def subarraysWithKDistinct(self, nums, k):
        def at_most(limit):
            counts = {}
            left = 0
            answer = 0

            for right, value in enumerate(nums):
                counts[value] = counts.get(value, 0) + 1
                while len(counts) > limit:
                    outgoing = nums[left]
                    counts[outgoing] -= 1
                    if counts[outgoing] == 0:
                        del counts[outgoing]
                    left += 1
                answer += right - left + 1

            return answer

        return at_most(k) - at_most(k - 1)
```

Why it works: every window with exactly k distinct values is counted in at-most-k but excluded from at-most-(k-1).

---

### E. Monotonic deque windows

Core idea: maintain a deque of useful candidates so the maximum or minimum of the current window is available in O(1).

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [239. Sliding Window Maximum](https://leetcode.com/problems/sliding-window-maximum/) | Hard | Decreasing deque stores maximum candidates. |
| [1438. Longest Continuous Subarray With Absolute Diff Less Than or Equal to Limit](https://leetcode.com/problems/longest-continuous-subarray-with-absolute-diff-less-than-or-equal-to-limit/) | Medium | Two deques maintain current minimum and maximum. |
| [862. Shortest Subarray with Sum at Least K](https://leetcode.com/problems/shortest-subarray-with-sum-at-least-k/) | Hard | Monotonic prefix-sum deque. |
| [1696. Jump Game VI](https://leetcode.com/problems/jump-game-vi/) | Medium | Deque optimizes the maximum DP transition in a window. |

#### Solution: [239. Sliding Window Maximum](https://leetcode.com/problems/sliding-window-maximum/) - Hard

```python
from collections import deque

class Solution:
    def maxSlidingWindow(self, nums, k):
        window = deque()
        result = []

        for right, value in enumerate(nums):
            while window and window[0] <= right - k:
                window.popleft()
            while window and nums[window[-1]] <= value:
                window.pop()
            window.append(right)

            if right >= k - 1:
                result.append(nums[window[0]])

        return result
```

Why it works: indices leave from the front when expired, and dominated smaller values leave from the back, so the front is always the current maximum.

---

### F. Complement and transformation windows

Core idea: turn an edge-removal or replacement problem into finding the longest valid contiguous window.

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [1423. Maximum Points You Can Obtain from Cards](https://leetcode.com/problems/maximum-points-you-can-obtain-from-cards/) | Medium | Keep the longest middle window after choosing edge cards. |
| [1658. Minimum Operations to Reduce X to Zero](https://leetcode.com/problems/minimum-operations-to-reduce-x-to-zero/) | Medium | Keep the longest subarray whose sum is total - x. |
| [1493. Longest Subarray of 1's After Deleting One Element](https://leetcode.com/problems/longest-subarray-of-1s-after-deleting-one-element/) | Medium | At most one zero in the kept window. |
| [2024. Maximize the Confusion of an Exam](https://leetcode.com/problems/maximize-the-confusion-of-an-exam/) | Medium | At most k opposite answers in the window. |

#### Solution: [1423. Maximum Points You Can Obtain from Cards](https://leetcode.com/problems/maximum-points-you-can-obtain-from-cards/) - Medium

```python
class Solution:
    def maxScore(self, cardPoints, k):
        total = sum(cardPoints)
        window_size = len(cardPoints) - k

        if window_size == 0:
            return total

        window_sum = sum(cardPoints[:window_size])
        smallest_middle = window_sum

        for right in range(window_size, len(cardPoints)):
            window_sum += cardPoints[right] - cardPoints[right - window_size]
            smallest_middle = min(smallest_middle, window_sum)

        return total - smallest_middle
```

Why it works: taking k cards from the ends is equivalent to removing one contiguous middle window of length n-k; minimize that middle sum.

---

### Additional direct solutions for every mapped problem

#### Solution: [340. Longest Substring with At Most K Distinct Characters](https://leetcode.com/problems/longest-substring-with-at-most-k-distinct-characters/) - Medium

```python
class Solution:
    def lengthOfLongestSubstringKDistinct(self, s, k):
        counts = {}
        left = 0
        best = 0

        for right, character in enumerate(s):
            counts[character] = counts.get(character, 0) + 1
            while len(counts) > k:
                outgoing = s[left]
                counts[outgoing] -= 1
                if counts[outgoing] == 0:
                    del counts[outgoing]
                left += 1
            best = max(best, right - left + 1)

        return best
```

Why it works: the window is shrunk until it contains at most k distinct characters, then its length is a valid candidate.

#### Solution: [1052. Grumpy Bookstore Owner](https://leetcode.com/problems/grumpy-bookstore-owner/) - Medium

```python
class Solution:
    def maxSatisfied(self, customers, grumpy, minutes):
        baseline = sum(customers[i] for i in range(len(customers)) if grumpy[i] == 0)
        recovered = sum(customers[i] for i in range(minutes) if grumpy[i] == 1)
        best_recovered = recovered

        for right in range(minutes, len(customers)):
            if grumpy[right] == 1:
                recovered += customers[right]
            if grumpy[right - minutes] == 1:
                recovered -= customers[right - minutes]
            best_recovered = max(best_recovered, recovered)

        return baseline + best_recovered
```

Why it works: baseline satisfaction is fixed; the window finds the contiguous minutes that recover the most dissatisfied customers.

#### Solution: [1234. Replace the Substring for Balanced String](https://leetcode.com/problems/replace-the-substring-for-balanced-string/) - Medium

```python
from collections import Counter

class Solution:
    def balancedString(self, s):
        required = len(s) // 4
        counts = Counter(s)
        left = 0
        best = len(s)

        for right, character in enumerate(s):
            counts[character] -= 1
            while left <= right and all(counts[c] <= required for c in 'QWER'):
                best = min(best, right - left + 1)
                counts[s[left]] += 1
                left += 1

        return best
```

Why it works: the kept outside characters must already fit the balanced limits; the smallest window covering all excess counts is the answer.

#### Solution: [1248. Count Number of Nice Subarrays](https://leetcode.com/problems/count-number-of-nice-subarrays/) - Medium

```python
class Solution:
    def numberOfSubarrays(self, nums, k):
        def at_most(limit):
            left = 0
            answer = 0
            for right, value in enumerate(nums):
                limit -= value % 2
                while limit < 0:
                    limit += nums[left] % 2
                    left += 1
                answer += right - left + 1
            return answer

        return at_most(k) - at_most(k - 1)
```

Why it works: exactly k odd numbers equals the number with at most k odds minus the number with at most k-1 odds.

#### Solution: [1358. Number of Substrings Containing All Three Characters](https://leetcode.com/problems/number-of-substrings-containing-all-three-characters/) - Medium

```python
class Solution:
    def numberOfSubstrings(self, s):
        last_seen = [-1, -1, -1]
        answer = 0

        for right, character in enumerate(s):
            last_seen[ord(character) - ord('a')] = right
            answer += min(last_seen) + 1

        return answer
```

Why it works: once all three characters have appeared, every start at or before the earliest last occurrence produces a valid substring ending at right.

#### Solution: [1493. Longest Subarray of 1's After Deleting One Element](https://leetcode.com/problems/longest-subarray-of-1s-after-deleting-one-element/) - Medium

```python
class Solution:
    def longestSubarray(self, nums):
        left = 0
        zeros = 0
        best = 0

        for right, value in enumerate(nums):
            zeros += value == 0
            while zeros > 1:
                zeros -= nums[left] == 0
                left += 1
            best = max(best, right - left)

        return best
```

Why it works: keep a window with at most one zero, then subtract one from its size because one element must be deleted.

#### Solution: [1658. Minimum Operations to Reduce X to Zero](https://leetcode.com/problems/minimum-operations-to-reduce-x-to-zero/) - Medium

```python
class Solution:
    def minOperations(self, nums, x):
        target = sum(nums) - x
        if target < 0:
            return -1
        if target == 0:
            return len(nums)

        left = 0
        current = 0
        longest = -1

        for right, value in enumerate(nums):
            current += value
            while current > target:
                current -= nums[left]
                left += 1
            if current == target:
                longest = max(longest, right - left + 1)

        return -1 if longest == -1 else len(nums) - longest
```

Why it works: removing from both ends leaves a middle subarray with sum total-x, so maximize that middle window.

#### Solution: [1696. Jump Game VI](https://leetcode.com/problems/jump-game-vi/) - Medium

```python
from collections import deque

class Solution:
    def maxResult(self, nums, k):
        scores = [0] * len(nums)
        scores[0] = nums[0]
        candidates = deque([0])

        for i in range(1, len(nums)):
            while candidates and candidates[0] < i - k:
                candidates.popleft()
            scores[i] = scores[candidates[0]] + nums[i]
            while candidates and scores[candidates[-1]] <= scores[i]:
                candidates.pop()
            candidates.append(i)

        return scores[-1]
```

Why it works: the deque keeps the largest reachable previous score at its front while removing expired and dominated indices.

#### Solution: [2024. Maximize the Confusion of an Exam](https://leetcode.com/problems/maximize-the-confusion-of-an-exam/) - Medium

```python
class Solution:
    def maxConsecutiveAnswers(self, answerKey, k):
        def longest(target):
            left = 0
            changes = 0
            best = 0
            for right, answer in enumerate(answerKey):
                changes += answer != target
                while changes > k:
                    changes -= answerKey[left] != target
                    left += 1
                best = max(best, right - left + 1)
            return best

        return max(longest('T'), longest('F'))
```

Why it works: test each target answer separately and allow at most k opposite answers inside the window.

#### Solution: [2461. Maximum Sum of Distinct Subarrays With Length K](https://leetcode.com/problems/maximum-sum-of-distinct-subarrays-with-length-k/) - Medium

```python
class Solution:
    def maximumSubarraySum(self, nums, k):
        counts = {}
        window_sum = 0
        best = 0

        for right, value in enumerate(nums):
            counts[value] = counts.get(value, 0) + 1
            window_sum += value

            if right >= k:
                outgoing = nums[right - k]
                window_sum -= outgoing
                counts[outgoing] -= 1
                if counts[outgoing] == 0:
                    del counts[outgoing]

            if right >= k - 1 and len(counts) == k:
                best = max(best, window_sum)

        return best
```

Why it works: the window is always length k, and a window is eligible only when its frequency map contains k distinct values.

#### Solution: [2958. Length of Longest Subarray With at Most K Frequency](https://leetcode.com/problems/length-of-longest-subarray-with-at-most-k-frequency/) - Medium

```python
class Solution:
    def maxSubarrayLength(self, nums, k):
        counts = {}
        left = 0
        best = 0

        for right, value in enumerate(nums):
            counts[value] = counts.get(value, 0) + 1
            while counts[value] > k:
                outgoing = nums[left]
                counts[outgoing] -= 1
                left += 1
            best = max(best, right - left + 1)

        return best
```

Why it works: only the newly added value can violate the frequency cap, so shrink until its count is at most k again.

#### Solution: [567. Permutation in String](https://leetcode.com/problems/permutation-in-string/) - Medium

```python
from collections import Counter

class Solution:
    def checkInclusion(self, s1, s2):
        if len(s1) > len(s2):
            return False

        need = Counter(s1)
        window = Counter()
        matched = 0
        left = 0

        for right, character in enumerate(s2):
            window[character] = window.get(character, 0) + 1
            if window[character] <= need[character]:
                matched += 1

            if right - left + 1 > len(s1):
                outgoing = s2[left]
                if window[outgoing] <= need[outgoing]:
                    matched -= 1
                window[outgoing] -= 1
                left += 1

            if matched == len(s1):
                return True

        return False
```

Why it works: maintain a window of s1's length and count how many characters are satisfied without comparing complete maps each time.

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

Why it works: prefix sums turn subarray sums into differences; the deque keeps candidate prefixes increasing and removes dominated or already-valid starts.

#### Solution: [930. Binary Subarrays With Sum](https://leetcode.com/problems/binary-subarrays-with-sum/) - Medium

```python
class Solution:
    def numSubarraysWithSum(self, nums, goal):
        def at_most(limit):
            if limit < 0:
                return 0
            left = 0
            answer = 0
            for right, value in enumerate(nums):
                limit -= value
                while limit < 0:
                    limit += nums[left]
                    left += 1
                answer += right - left + 1
            return answer

        return at_most(goal) - at_most(goal - 1)
```

Why it works: for binary values, exactly goal is the difference between subarrays with sum at most goal and at most goal-1.

#### Solution: [1438. Longest Continuous Subarray With Absolute Diff Less Than or Equal to Limit](https://leetcode.com/problems/longest-continuous-subarray-with-absolute-diff-less-than-or-equal-to-limit/) - Medium

```python
from collections import deque

class Solution:
    def longestSubarray(self, nums, limit):
        minimums = deque()
        maximums = deque()
        left = 0
        best = 0

        for right, value in enumerate(nums):
            while minimums and nums[minimums[-1]] >= value:
                minimums.pop()
            while maximums and nums[maximums[-1]] <= value:
                maximums.pop()
            minimums.append(right)
            maximums.append(right)

            while nums[maximums[0]] - nums[minimums[0]] > limit:
                if minimums[0] == left:
                    minimums.popleft()
                if maximums[0] == left:
                    maximums.popleft()
                left += 1

            best = max(best, right - left + 1)

        return best
```

Why it works: the two monotonic deques expose the current minimum and maximum, so invalid windows can be shrunk in amortized O(1) time.

---

## 3. Quick pattern recognition guide

### Use a fixed-size window when you see:
- substring or subarray of exactly length k
- maximum/minimum/count over every length-k range
- one element entering and one leaving each step

### Use a variable-size window when you see:
- longest or shortest contiguous range satisfying a condition
- at most k changes, zeros, distinct values, or frequency counts
- expand until invalid, then shrink until valid

### Use a frequency map when you see:
- anagram or permutation
- required character counts
- distinct-element limits
- exact counts that can be expressed as a difference of at-most counts

### Use a monotonic deque when you see:
- maximum/minimum for every sliding window
- a range condition involving both current maximum and minimum
- DP transitions restricted to the previous k positions

---

## 4. Core templates

### Fixed-size window

```python
window = sum(nums[:k])
answer = window

for right in range(k, len(nums)):
    window += nums[right] - nums[right - k]
    answer = update(answer, window)
```

### Longest valid variable window

```python
left = 0
for right, value in enumerate(nums):
    add(value)

    while window_is_invalid:
        remove(nums[left])
        left += 1

    answer = max(answer, right - left + 1)
```

### Count valid windows

```python
left = 0
for right, value in enumerate(nums):
    add(value)
    while window_is_invalid:
        remove(nums[left])
        left += 1
    answer += right - left + 1
```

### Exactly k distinct values

```python
exactly_k = at_most(k) - at_most(k - 1)
```

### Monotonic deque

```python
from collections import deque

window = deque()
for right, value in enumerate(nums):
    while window and window[0] <= right - k:
        window.popleft()
    while window and nums[window[-1]] <= value:
        window.pop()
    window.append(right)
```

---

## 5. Practice order

1. [643. Maximum Average Subarray I](https://leetcode.com/problems/maximum-average-subarray-i/)
2. [1456. Maximum Number of Vowels in a Substring of Given Length](https://leetcode.com/problems/maximum-number-of-vowels-in-a-substring-of-given-length/)
3. [3. Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/)
4. [904. Fruit Into Baskets](https://leetcode.com/problems/fruit-into-baskets/)
5. [209. Minimum Size Subarray Sum](https://leetcode.com/problems/minimum-size-subarray-sum/)
6. [76. Minimum Window Substring](https://leetcode.com/problems/minimum-window-substring/)
7. [438. Find All Anagrams in a String](https://leetcode.com/problems/find-all-anagrams-in-a-string/)
8. [992. Subarrays with K Different Integers](https://leetcode.com/problems/subarrays-with-k-different-integers/)
9. [239. Sliding Window Maximum](https://leetcode.com/problems/sliding-window-maximum/)
10. [1658. Minimum Operations to Reduce X to Zero](https://leetcode.com/problems/minimum-operations-to-reduce-x-to-zero/)

---

## 6. Cheat sheet

- Fixed window: add the incoming value and remove the outgoing value.
- Longest valid window: expand right, shrink while invalid, then record length.
- Shortest valid window: expand until valid, then shrink as much as possible.
- Count windows: after restoring validity, add `right - left + 1`.
- Exact k: calculate at-most-k minus at-most-(k-1).
- Maximum/minimum window values: use a monotonic deque.
- Complement trick: replace edge selection with a longest or shortest middle window.

---

## 7. Interview trigger

Reach for Sliding Window when the statement includes:

- contiguous subarray or substring
- longest, shortest, maximum, minimum, or number of ranges
- at most k, exactly k, or at least k
- distinct characters or frequencies
- a fixed length k

Before coding, state the invariant explicitly: what does the current window contain, and exactly when is it valid?

---

## 8. Common mistakes

- forgetting to remove the outgoing value in a fixed-size window
- shrinking only once instead of while the window is invalid
- recording the answer before restoring validity
- confusing exactly k with at-most k
- comparing averages when comparing sums is sufficient
- storing values instead of indices in a monotonic deque
- failing to remove expired deque indices

---

## 9. Current coverage

Every problem currently listed in the sub-pattern tables, practice order, and suggested problem inventory has a direct solution above.

Current mapped inventory:

- 28 unique Sliding Window problems
- 28 direct solutions
- 0 unsolved entries in the current file

When a larger Sliding Window problem export is supplied, new problems can be appended here as a numbered backlog and solved one by one in the same format.

---

## 10. Remaining problems from the attached Sliding Window list

These 132 problems were present in the attachment but do not yet have direct solutions above. They are listed here as the next solution backlog. Existing solved problems are intentionally excluded.

#### Solution: [30. Substring with Concatenation of All Words](https://leetcode.com/problems/substring-with-concatenation-of-all-words/) - Hard

```python
from collections import Counter

class Solution:
    def findSubstring(self, s, words):
        if not s or not words:
            return []

        word_length = len(words[0])
        word_count = len(words)
        total_length = word_length * word_count
        required = Counter(words)
        result = []

        for offset in range(word_length):
            left = offset
            used = Counter()
            matched = 0

            for right in range(offset, len(s) - word_length + 1, word_length):
                word = s[right:right + word_length]
                if word not in required:
                    left = right + word_length
                    used.clear()
                    matched = 0
                    continue

                used[word] += 1
                matched += 1

                while used[word] > required[word]:
                    outgoing = s[left:left + word_length]
                    used[outgoing] -= 1
                    left += word_length
                    matched -= 1

                if matched == word_count:
                    result.append(left)
                    outgoing = s[left:left + word_length]
                    used[outgoing] -= 1
                    left += word_length
                    matched -= 1

        return result
```

Why it works: scan each possible word alignment and keep a window containing exactly the required number of fixed-length words.

#### Solution: [159. Longest Substring with At Most Two Distinct Characters](https://leetcode.com/problems/longest-substring-with-at-most-two-distinct-characters/) - Medium

```python
class Solution:
    def lengthOfLongestSubstringTwoDistinct(self, s):
        counts = {}
        left = 0
        best = 0

        for right, character in enumerate(s):
            counts[character] = counts.get(character, 0) + 1
            while len(counts) > 2:
                outgoing = s[left]
                counts[outgoing] -= 1
                if counts[outgoing] == 0:
                    del counts[outgoing]
                left += 1
            best = max(best, right - left + 1)

        return best
```

Why it works: maintain a frequency map and shrink only when the window contains a third distinct character.

#### Solution: [187. Repeated DNA Sequences](https://leetcode.com/problems/repeated-dna-sequences/) - Medium

```python
class Solution:
    def findRepeatedDnaSequences(self, s):
        seen = set()
        repeated = set()

        for start in range(len(s) - 9):
            sequence = s[start:start + 10]
            if sequence in seen:
                repeated.add(sequence)
            else:
                seen.add(sequence)

        return list(repeated)
```

Why it works: every length-10 window is recorded once, and a second occurrence moves it to the result set.

#### Solution: [219. Contains Duplicate II](https://leetcode.com/problems/contains-duplicate-ii/) - Easy

```python
class Solution:
    def containsNearbyDuplicate(self, nums, k):
        last_seen = {}

        for index, value in enumerate(nums):
            if value in last_seen and index - last_seen[value] <= k:
                return True
            last_seen[value] = index

        return False
```

Why it works: the latest index is the only previous occurrence that can be closest to the current index.

#### Solution: [220. Contains Duplicate III](https://leetcode.com/problems/contains-duplicate-iii/) - Hard

```python
class Solution:
    def containsNearbyAlmostDuplicate(self, nums, indexDiff, valueDiff):
        if valueDiff < 0:
            return False

        width = valueDiff + 1
        buckets = {}

        def bucket_id(value):
            return value // width if value >= 0 else -((-value - 1) // width) - 1

        for index, value in enumerate(nums):
            bucket = bucket_id(value)
            if bucket in buckets:
                return True
            if bucket - 1 in buckets and abs(value - buckets[bucket - 1]) <= valueDiff:
                return True
            if bucket + 1 in buckets and abs(value - buckets[bucket + 1]) <= valueDiff:
                return True

            buckets[bucket] = value
            if index >= indexDiff:
                del buckets[bucket_id(nums[index - indexDiff])]

        return False
```

Why it works: values within valueDiff must be in the same or neighboring value buckets, while the map is kept to the last indexDiff elements.

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

Why it works: a character occurring fewer than k times cannot belong to a valid answer, so split around that character and solve both sides.

#### Solution: [413. Arithmetic Slices](https://leetcode.com/problems/arithmetic-slices/) - Medium

```python
class Solution:
    def numberOfArithmeticSlices(self, nums):
        current = 0
        answer = 0

        for index in range(2, len(nums)):
            if nums[index] - nums[index - 1] == nums[index - 1] - nums[index - 2]:
                current += 1
                answer += current
            else:
                current = 0

        return answer
```

Why it works: every continued equal difference creates one new arithmetic slice for each valid slice ending at the previous position.

#### Solution: [424. Longest Repeating Character Replacement](https://leetcode.com/problems/longest-repeating-character-replacement/) - Medium

```python
class Solution:
    def characterReplacement(self, s, k):
        counts = {}
        left = 0
        most_frequent = 0
        best = 0

        for right, character in enumerate(s):
            counts[character] = counts.get(character, 0) + 1
            most_frequent = max(most_frequent, counts[character])

            while right - left + 1 - most_frequent > k:
                counts[s[left]] -= 1
                left += 1

            best = max(best, right - left + 1)

        return best
```

Why it works: the window is valid when all characters except the most frequent one can be replaced within k operations.

#### Solution: [480. Sliding Window Median](https://leetcode.com/problems/sliding-window-median/) - Hard

```python
from bisect import bisect_left, insort

class Solution:
    def medianSlidingWindow(self, nums, k):
        window = sorted(nums[:k])
        result = []

        def median():
            if k % 2:
                return float(window[k // 2])
            return (window[k // 2 - 1] + window[k // 2]) / 2

        result.append(median())
        for right in range(k, len(nums)):
            window.pop(bisect_left(window, nums[right - k]))
            insort(window, nums[right])
            result.append(median())

        return result
```

Why it works: maintain the current window in sorted order, remove the outgoing value, insert the incoming value, and read the middle element or pair.

#### Solution: [487. Max Consecutive Ones II](https://leetcode.com/problems/max-consecutive-ones-ii/) - Medium

```python
class Solution:
    def findMaxConsecutiveOnes(self, nums):
        left = 0
        zeros = 0
        best = 0

        for right, value in enumerate(nums):
            zeros += value == 0
            while zeros > 1:
                zeros -= nums[left] == 0
                left += 1
            best = max(best, right - left + 1)

        return best
```

Why it works: maintain a window containing at most one zero, which is the zero allowed to be flipped.

- [594. Longest Harmonious Subsequence](https://leetcode.com/problems/longest-harmonious-subsequence/) - Easy
- [632. Smallest Range Covering Elements from K Lists](https://leetcode.com/problems/smallest-range-covering-elements-from-k-lists/) - Hard
- [658. Find K Closest Elements](https://leetcode.com/problems/find-k-closest-elements/) - Medium
- [683. K Empty Slots](https://leetcode.com/problems/k-empty-slots/) - Hard
- [689. Maximum Sum of 3 Non-Overlapping Subarrays](https://leetcode.com/problems/maximum-sum-of-3-non-overlapping-subarrays/) - Hard
- [718. Maximum Length of Repeated Subarray](https://leetcode.com/problems/maximum-length-of-repeated-subarray/) - Medium
- [727. Minimum Window Subsequence](https://leetcode.com/problems/minimum-window-subsequence/) - Hard
- [837. New 21 Game](https://leetcode.com/problems/new-21-game/) - Medium
- [978. Longest Turbulent Subarray](https://leetcode.com/problems/longest-turbulent-subarray/) - Medium
- [995. Minimum Number of K Consecutive Bit Flips](https://leetcode.com/problems/minimum-number-of-k-consecutive-bit-flips/) - Hard
- [1016. Binary String With Substrings Representing 1 To N](https://leetcode.com/problems/binary-string-with-substrings-representing-1-to-n/) - Medium
- [1031. Maximum Sum of Two Non-Overlapping Subarrays](https://leetcode.com/problems/maximum-sum-of-two-non-overlapping-subarrays/) - Medium
- [1040. Moving Stones Until Consecutive II](https://leetcode.com/problems/moving-stones-until-consecutive-ii/) - Medium
- [1044. Longest Duplicate Substring](https://leetcode.com/problems/longest-duplicate-substring/) - Hard
- [1100. Find K-Length Substrings With No Repeated Characters](https://leetcode.com/problems/find-k-length-substrings-with-no-repeated-characters/) - Medium
- [1151. Minimum Swaps to Group All 1's Together](https://leetcode.com/problems/minimum-swaps-to-group-all-1-s-together/) - Medium
- [1156. Swap For Longest Repeated Character Substring](https://leetcode.com/problems/swap-for-longest-repeated-character-substring/) - Medium
- [1176. Diet Plan Performance](https://leetcode.com/problems/diet-plan-performance/) - Easy
- [1208. Get Equal Substrings Within Budget](https://leetcode.com/problems/get-equal-substrings-within-budget/) - Medium
- [1297. Maximum Number of Occurrences of a Substring](https://leetcode.com/problems/maximum-number-of-occurrences-of-a-substring/) - Medium
- [1425. Constrained Subsequence Sum](https://leetcode.com/problems/constrained-subsequence-sum/) - Hard
- [1477. Find Two Non-overlapping Sub-arrays Each With Target Sum](https://leetcode.com/problems/find-two-non-overlapping-sub-arrays-each-with-target-sum/) - Medium
- [1499. Max Value of Equation](https://leetcode.com/problems/max-value-of-equation/) - Hard
- [1610. Maximum Number of Visible Points](https://leetcode.com/problems/maximum-number-of-visible-points/) - Hard
- [1652. Defuse the Bomb](https://leetcode.com/problems/defuse-the-bomb/) - Easy
- [1695. Maximum Erasure Value](https://leetcode.com/problems/maximum-erasure-value/) - Medium
- [1703. Minimum Adjacent Swaps for K Consecutive Ones](https://leetcode.com/problems/minimum-adjacent-swaps-for-k-consecutive-ones/) - Hard
- [1763. Longest Nice Substring](https://leetcode.com/problems/longest-nice-substring/) - Easy
- [1838. Frequency of the Most Frequent Element](https://leetcode.com/problems/frequency-of-the-most-frequent-element/) - Medium
- [1839. Longest Substring Of All Vowels in Order](https://leetcode.com/problems/longest-substring-of-all-vowels-in-order/) - Medium
- [1852. Distinct Numbers in Each Subarray](https://leetcode.com/problems/distinct-numbers-in-each-subarray/) - Medium
- [1871. Jump Game VII](https://leetcode.com/problems/jump-game-vii/) - Medium
- [1876. Substrings of Size Three with Distinct Characters](https://leetcode.com/problems/substrings-of-size-three-with-distinct-characters/) - Easy
- [1888. Minimum Number of Flips to Make the Binary String Alternating](https://leetcode.com/problems/minimum-number-of-flips-to-make-the-binary-string-alternating/) - Medium
- [1918. Kth Smallest Subarray Sum](https://leetcode.com/problems/kth-smallest-subarray-sum/) - Medium
- [1956. Minimum Time For K Virus Variants to Spread](https://leetcode.com/problems/minimum-time-for-k-virus-variants-to-spread/) - Hard
- [1984. Minimum Difference Between Highest and Lowest of K Scores](https://leetcode.com/problems/minimum-difference-between-highest-and-lowest-of-k-scores/) - Easy
- [2009. Minimum Number of Operations to Make Array Continuous](https://leetcode.com/problems/minimum-number-of-operations-to-make-array-continuous/) - Hard
- [2067. Number of Equal Count Substrings](https://leetcode.com/problems/number-of-equal-count-substrings/) - Medium
- [2090. K Radius Subarray Averages](https://leetcode.com/problems/k-radius-subarray-averages/) - Medium
- [2106. Maximum Fruits Harvested After at Most K Steps](https://leetcode.com/problems/maximum-fruits-harvested-after-at-most-k-steps/) - Hard
- [2107. Number of Unique Flavors After Sharing K Candies](https://leetcode.com/problems/number-of-unique-flavors-after-sharing-k-candies/) - Medium
- [2110. Number of Smooth Descent Periods of a Stock](https://leetcode.com/problems/number-of-smooth-descent-periods-of-a-stock/) - Medium
- [2134. Minimum Swaps to Group All 1's Together II](https://leetcode.com/problems/minimum-swaps-to-group-all-1-s-together-ii/) - Medium
- [2156. Find Substring With Given Hash Value](https://leetcode.com/problems/find-substring-with-given-hash-value/) - Hard
- [2260. Minimum Consecutive Cards to Pick Up](https://leetcode.com/problems/minimum-consecutive-cards-to-pick-up/) - Medium
- [2269. Find the K-Beauty of a Number](https://leetcode.com/problems/find-the-k-beauty-of-a-number/) - Easy
- [2271. Maximum White Tiles Covered by a Carpet](https://leetcode.com/problems/maximum-white-tiles-covered-by-a-carpet/) - Medium
- [2302. Count Subarrays With Score Less Than K](https://leetcode.com/problems/count-subarrays-with-score-less-than-k/) - Hard
- [2379. Minimum Recolors to Get K Consecutive Black Blocks](https://leetcode.com/problems/minimum-recolors-to-get-k-consecutive-black-blocks/) - Easy
- [2398. Maximum Number of Robots Within Budget](https://leetcode.com/problems/maximum-number-of-robots-within-budget/) - Hard
- [2401. Longest Nice Subarray](https://leetcode.com/problems/longest-nice-subarray/) - Medium
- [2411. Smallest Subarrays With Maximum Bitwise OR](https://leetcode.com/problems/smallest-subarrays-with-maximum-bitwise-or/) - Medium
- [2444. Count Subarrays With Fixed Bounds](https://leetcode.com/problems/count-subarrays-with-fixed-bounds/) - Hard
- [2516. Take K of Each Character From Left and Right](https://leetcode.com/problems/take-k-of-each-character-from-left-and-right/) - Medium
- [2524. Maximum Frequency Score of a Subarray](https://leetcode.com/problems/maximum-frequency-score-of-a-subarray/) - Hard
- [2528. Maximize the Minimum Powered City](https://leetcode.com/problems/maximize-the-minimum-powered-city/) - Hard
- [2537. Count the Number of Good Subarrays](https://leetcode.com/problems/count-the-number-of-good-subarrays/) - Medium
- [2555. Maximize Win From Two Segments](https://leetcode.com/problems/maximize-win-from-two-segments/) - Medium
- [2653. Sliding Subarray Beauty](https://leetcode.com/problems/sliding-subarray-beauty/) - Medium
- [2730. Find the Longest Semi-Repetitive Substring](https://leetcode.com/problems/find-the-longest-semi-repetitive-substring/) - Medium
- [2743. Count Substrings Without Repeating Character](https://leetcode.com/problems/count-substrings-without-repeating-character/) - Medium
- [2747. Count Zero Request Servers](https://leetcode.com/problems/count-zero-request-servers/) - Medium
- [2760. Longest Even Odd Subarray With Threshold](https://leetcode.com/problems/longest-even-odd-subarray-with-threshold/) - Easy
- [2762. Continuous Subarrays](https://leetcode.com/problems/continuous-subarrays/) - Medium
- [2779. Maximum Beauty of an Array After Applying Operation](https://leetcode.com/problems/maximum-beauty-of-an-array-after-applying-operation/) - Medium
- [2781. Length of the Longest Valid Substring](https://leetcode.com/problems/length-of-the-longest-valid-substring/) - Hard
- [2799. Count Complete Subarrays in an Array](https://leetcode.com/problems/count-complete-subarrays-in-an-array/) - Medium
- [2831. Find the Longest Equal Subarray](https://leetcode.com/problems/find-the-longest-equal-subarray/) - Medium
- [2841. Maximum Sum of Almost Unique Subarray](https://leetcode.com/problems/maximum-sum-of-almost-unique-subarray/) - Medium
- [2875. Minimum Size Subarray in Infinite Array](https://leetcode.com/problems/minimum-size-subarray-in-infinite-array/) - Medium
- [2902. Count of Sub-Multisets With Bounded Sum](https://leetcode.com/problems/count-of-sub-multisets-with-bounded-sum/) - Hard
- [2904. Shortest and Lexicographically Smallest Beautiful String](https://leetcode.com/problems/shortest-and-lexicographically-smallest-beautiful-string/) - Medium
- [2932. Maximum Strong Pair XOR I](https://leetcode.com/problems/maximum-strong-pair-xor-i/) - Easy
- [2935. Maximum Strong Pair XOR II](https://leetcode.com/problems/maximum-strong-pair-xor-ii/) - Hard
- [2953. Count Complete Substrings](https://leetcode.com/problems/count-complete-substrings/) - Hard
- [2962. Count Subarrays Where Max Element Appears at Least K Times](https://leetcode.com/problems/count-subarrays-where-max-element-appears-at-least-k-times/) - Medium
- [2968. Apply Operations to Maximize Frequency Score](https://leetcode.com/problems/apply-operations-to-maximize-frequency-score/) - Hard
- [2981. Find Longest Special Substring That Occurs Thrice I](https://leetcode.com/problems/find-longest-special-substring-that-occurs-thrice-i/) - Medium
- [2982. Find Longest Special Substring That Occurs Thrice II](https://leetcode.com/problems/find-longest-special-substring-that-occurs-thrice-ii/) - Medium
- [3013. Divide an Array Into Subarrays With Minimum Cost II](https://leetcode.com/problems/divide-an-array-into-subarrays-with-minimum-cost-ii/) - Hard
- [3023. Find Pattern in Infinite Stream I](https://leetcode.com/problems/find-pattern-in-infinite-stream-i/) - Medium
- [3037. Find Pattern in Infinite Stream II](https://leetcode.com/problems/find-pattern-in-infinite-stream-ii/) - Hard
- [3086. Minimum Moves to Pick K Ones](https://leetcode.com/problems/minimum-moves-to-pick-k-ones/) - Hard
- [3090. Maximum Length Substring With Two Occurrences](https://leetcode.com/problems/maximum-length-substring-with-two-occurrences/) - Easy
- [3095. Shortest Subarray With OR at Least K I](https://leetcode.com/problems/shortest-subarray-with-or-at-least-k-i/) - Easy
- [3097. Shortest Subarray With OR at Least K II](https://leetcode.com/problems/shortest-subarray-with-or-at-least-k-ii/) - Medium
- [3134. Find the Median of the Uniqueness Array](https://leetcode.com/problems/find-the-median-of-the-uniqueness-array/) - Hard
- [3135. Equalize Strings by Adding or Removing Characters at Ends](https://leetcode.com/problems/equalize-strings-by-adding-or-removing-characters-at-ends/) - Medium
- [3191. Minimum Operations to Make Binary Array Elements Equal to One I](https://leetcode.com/problems/minimum-operations-to-make-binary-array-elements-equal-to-one-i/) - Medium
- [3206. Alternating Groups I](https://leetcode.com/problems/alternating-groups-i/) - Easy
- [3208. Alternating Groups II](https://leetcode.com/problems/alternating-groups-ii/) - Medium
- [3254. Find the Power of K-Size Subarrays I](https://leetcode.com/problems/find-the-power-of-k-size-subarrays-i/) - Medium
- [3255. Find the Power of K-Size Subarrays II](https://leetcode.com/problems/find-the-power-of-k-size-subarrays-ii/) - Medium
- [3258. Count Substrings That Satisfy K-Constraint I](https://leetcode.com/problems/count-substrings-that-satisfy-k-constraint-i/) - Easy
- [3261. Count Substrings That Satisfy K-Constraint II](https://leetcode.com/problems/count-substrings-that-satisfy-k-constraint-ii/) - Hard
- [3297. Count Substrings That Can Be Rearranged to Contain a String I](https://leetcode.com/problems/count-substrings-that-can-be-rearranged-to-contain-a-string-i/) - Medium
- [3298. Count Substrings That Can Be Rearranged to Contain a String II](https://leetcode.com/problems/count-substrings-that-can-be-rearranged-to-contain-a-string-ii/) - Hard
- [3305. Count of Substrings Containing Every Vowel and K Consonants I](https://leetcode.com/problems/count-of-substrings-containing-every-vowel-and-k-consonants-i/) - Medium
- [3306. Count of Substrings Containing Every Vowel and K Consonants II](https://leetcode.com/problems/count-of-substrings-containing-every-vowel-and-k-consonants-ii/) - Medium
- [3318. Find X-Sum of All K-Long Subarrays I](https://leetcode.com/problems/find-x-sum-of-all-k-long-subarrays-i/) - Easy
- [3321. Find X-Sum of All K-Long Subarrays II](https://leetcode.com/problems/find-x-sum-of-all-k-long-subarrays-ii/) - Hard
- [3323. Minimize Connected Groups by Inserting Interval](https://leetcode.com/problems/minimize-connected-groups-by-inserting-interval/) - Medium
- [3325. Count Substrings With K-Frequency Characters I](https://leetcode.com/problems/count-substrings-with-k-frequency-characters-i/) - Medium
- [3329. Count Substrings With K-Frequency Characters II](https://leetcode.com/problems/count-substrings-with-k-frequency-characters-ii/) - Hard
- [3346. Maximum Frequency of an Element After Performing Operations I](https://leetcode.com/problems/maximum-frequency-of-an-element-after-performing-operations-i/) - Medium
- [3347. Maximum Frequency of an Element After Performing Operations II](https://leetcode.com/problems/maximum-frequency-of-an-element-after-performing-operations-ii/) - Hard
- [3364. Minimum Positive Sum Subarray](https://leetcode.com/problems/minimum-positive-sum-subarray/) - Easy
- [3411. Maximum Subarray With Equal Products](https://leetcode.com/problems/maximum-subarray-with-equal-products/) - Easy
- [3413. Maximum Coins From K Consecutive Bags](https://leetcode.com/problems/maximum-coins-from-k-consecutive-bags/) - Medium
- [3420. Count Non-Decreasing Subarrays After K Operations](https://leetcode.com/problems/count-non-decreasing-subarrays-after-k-operations/) - Hard
- [3422. Minimum Operations to Make Subarray Elements Equal](https://leetcode.com/problems/minimum-operations-to-make-subarray-elements-equal/) - Medium
- [3439. Reschedule Meetings for Maximum Free Time I](https://leetcode.com/problems/reschedule-meetings-for-maximum-free-time-i/) - Medium
- [3445. Maximum Difference Between Even and Odd Frequency II](https://leetcode.com/problems/maximum-difference-between-even-and-odd-frequency-ii/) - Hard
- [3505. Minimum Operations to Make Elements Within K Subarrays Equal](https://leetcode.com/problems/minimum-operations-to-make-elements-within-k-subarrays-equal/) - Hard
- [3578. Count Partitions With Max-Min Difference at Most K](https://leetcode.com/problems/count-partitions-with-max-min-difference-at-most-k/) - Medium
- [3589. Count Prime-Gap Balanced Subarrays](https://leetcode.com/problems/count-prime-gap-balanced-subarrays/) - Medium
- [3634. Minimum Removals to Balance Array](https://leetcode.com/problems/minimum-removals-to-balance-array/) - Medium
- [3641. Longest Semi-Repeating Subarray](https://leetcode.com/problems/longest-semi-repeating-subarray/) - Medium
- [3652. Best Time to Buy and Sell Stock using Strategy](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-using-strategy/) - Medium
- [3672. Sum of Weighted Modes in Subarrays](https://leetcode.com/problems/sum-of-weighted-modes-in-subarrays/) - Medium
- [3679. Minimum Discards to Balance Inventory](https://leetcode.com/problems/minimum-discards-to-balance-inventory/) - Medium
- [3694. Distinct Points Reachable After Substring Removal](https://leetcode.com/problems/distinct-points-reachable-after-substring-removal/) - Medium
- [3768. Minimum Inversion Count in Subarrays of Fixed Length](https://leetcode.com/problems/minimum-inversion-count-in-subarrays-of-fixed-length/) - Hard
- [3795. Minimum Subarray Length With Distinct Sum At Least K](https://leetcode.com/problems/minimum-subarray-length-with-distinct-sum-at-least-k/) - Medium
- [3845. Maximum Subarray XOR with Bounded Range](https://leetcode.com/problems/maximum-subarray-xor-with-bounded-range/) - Hard
- [3851. Maximum Requests Without Violating the Limit](https://leetcode.com/problems/maximum-requests-without-violating-the-limit/) - Medium
- [3859. Count Subarrays With K Distinct Integers](https://leetcode.com/problems/count-subarrays-with-k-distinct-integers/) - Hard
- [3956. Maximum Sum of M Non-Overlapping Subarrays I](https://leetcode.com/problems/maximum-sum-of-m-non-overlapping-subarrays-i/) - Hard
- [3957. Maximum Sum of M Non-Overlapping Subarrays II](https://leetcode.com/problems/maximum-sum-of-m-non-overlapping-subarrays-ii/) - Hard
- [3969. Valid Subarrays With Matching Sum Digits I](https://leetcode.com/problems/valid-subarrays-with-matching-sum-digits-i/) - Medium
- [3972. Valid Subarrays With Matching Sum Digits II](https://leetcode.com/problems/valid-subarrays-with-matching-sum-digits-ii/) - Hard
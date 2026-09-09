# Sliding Window LeetCode Mastery Roadmap

This is the working roadmap for learning sliding-window problems one by one, pattern by pattern.

## Stage 1 — Fixed-Size Sliding Window

1. [643. Maximum Average Subarray I](https://leetcode.com/problems/maximum-average-subarray-i/)
2. [1456. Maximum Number of Vowels in a Substring of Given Length](https://leetcode.com/problems/maximum-number-of-vowels-in-a-substring-of-given-length/)
3. [1343. Number of Sub-arrays of Size K and Average Greater than or Equal to Threshold](https://leetcode.com/problems/number-of-sub-arrays-of-size-k-and-average-greater-than-or-equal-to-threshold/)

---

## [643. Maximum Average Subarray I](https://leetcode.com/problems/maximum-average-subarray-i/)

### Pattern

**Pattern:** Fixed-Size Sliding Window

**Secondary Pattern:** Running Sum

### What Are We Maintaining?

- Current window sum
- Best window sum seen so far

### Intuition

The expensive part is recomputing the sum of every subarray of size k. Instead, keep a moving total and slide the window by one position at a time. When we move right by one, we add the new element and subtract the element that just dropped off the left side.

### Brute Force

**Brute force:** For each index i, sum nums[i:i+k] and track the maximum.

**Time:** O(n × k)

This works, but it does redundant work because adjacent windows overlap heavily.

### KEY OBSERVATION

> **Key Observation:**
> When the window moves one step right, only the entering element and leaving element change.

### RAW CODE

```python
class Solution:
    def findMaxAverage(self, nums, k):
        window = sum(nums[:k])
        best = window

        for i in range(k, len(nums)):
            window += nums[i] - nums[i - k]
            best = max(best, window)

        return best / k
```

### COMMENTED CODE

```python
class Solution:
    def findMaxAverage(self, nums, k):
        window = sum(nums[:k])
        best = window

        for i in range(k, len(nums)):
            window += nums[i] - nums[i - k]  # Add incoming, remove outgoing.
            best = max(best, window)

        return best / k
```

### Complexity

**Time:** O(n)

**Space:** O(1)

### Cheat Sheet

### Cheat Sheet
**Pattern:** Fixed Window

**State:** `window_sum`

**Expand:** Add `nums[right]`

**Shrink:** Remove `nums[left]`

**Condition:** Window size == k

**Answer:** Maximum average / maximum sum

**Complexity:** O(n) time, O(1) space

### When should I recognize this pattern?

- "Subarray of length k"
- "Maximum/average over a window of fixed size"
- "Compute result for each window efficiently"

### Common Mistakes

- Forgetting to subtract the outgoing element.
- Updating the best value after the window is already invalid.
- Confusing fixed-size windows with variable windows.

---

## [1456. Maximum Number of Vowels in a Substring of Given Length](https://leetcode.com/problems/maximum-number-of-vowels-in-a-substring-of-given-length/)

### Pattern

**Pattern:** Fixed-Size Sliding Window

**Secondary Pattern:** Counter / Frequency Check

### What Are We Maintaining?

- Number of vowels in the current window
- Maximum number of vowels seen so far

### Intuition

We only care about how many vowels are inside the current window of length k. When the window slides, one character leaves and one enters. So we can update the count in O(1) instead of re-counting all vowels each time.

### Brute Force

**Brute force:** For every window of length k, count vowels in that substring.

**Time:** O(n × k)

This is slow because windows overlap heavily.

### KEY OBSERVATION

> **Key Observation:**
> Only one character leaves and one character enters when the window slides.

### RAW CODE

```python
class Solution:
    def maxVowels(self, s: str, k: int) -> int:
        vowels = set('aeiou')
        window_vowels = sum(ch in vowels for ch in s[:k])
        best = window_vowels

        for i in range(k, len(s)):
            if s[i - k] in vowels:
                window_vowels -= 1
            if s[i] in vowels:
                window_vowels += 1
            best = max(best, window_vowels)

        return best
```

### COMMENTED CODE

```python
class Solution:
    def maxVowels(self, s: str, k: int) -> int:
        vowels = set('aeiou')
        window_vowels = sum(ch in vowels for ch in s[:k])
        best = window_vowels

        for i in range(k, len(s)):
            if s[i - k] in vowels:
                window_vowels -= 1  # Remove the outgoing character.
            if s[i] in vowels:
                window_vowels += 1  # Add the incoming character.
            best = max(best, window_vowels)

        return best
```

### Complexity

**Time:** O(n)

**Space:** O(1) if we treat the vowels set as constant-size

### Cheat Sheet

### Cheat Sheet
**Pattern:** Fixed Window

**State:** `window_vowels`

**Expand:** Add if `s[right]` is a vowel

**Shrink:** Remove if `s[left]` is a vowel

**Condition:** Window size == k

**Answer:** Maximum vowel count in any window

**Complexity:** O(n) time, O(1) space

### When should I recognize this pattern?

- "Window of length k"
- "Count of a property inside a substring"
- "Maximum/minimum count over every fixed-size window"

### Common Mistakes

- Updating counts for the wrong side of the window.
- Recounting all vowels from scratch.
- Forgetting that each window is size k exactly.

---

## [1343. Number of Sub-arrays of Size K and Average Greater than or Equal to Threshold](https://leetcode.com/problems/number-of-sub-arrays-of-size-k-and-average-greater-than-or-equal-to-threshold/)

### Pattern

**Pattern:** Fixed-Size Sliding Window

**Secondary Pattern:** Prefix Sum / Running Sum

### What Are We Maintaining?

- Current sum of the window of size k
- Count of valid windows

### Intuition

The average of a subarray is just its sum divided by k. Since k is fixed, comparing the average to the threshold is equivalent to comparing the sum to `threshold * k`. So we slide a fixed-sized window and check the current sum against the required threshold.

### Brute Force

**Brute force:** Consider every subarray of length k, compute its sum, compare against `threshold * k`.

**Time:** O(n × k)

This repeats overlap work, which the sliding window removes.

### KEY OBSERVATION

> **Key Observation:**
> For a fixed window size k, the condition becomes:
> sum(window) >= threshold × k

### RAW CODE

```python
class Solution:
    def numSubarraysWithSumLessThanK(self, nums, k, threshold):
        pass
```

The correct version for this problem is:

```python
class Solution:
    def numSubarraysWithSumLessThanK(self, nums, k, threshold):
        pass
```

This problem should be solved using the standard fixed-window approach:

```python
class Solution:
    def numSubarraysWithSumLessThanK(self, nums, k, threshold):
        window_sum = sum(nums[:k])
        count = 0

        if window_sum >= k * threshold:
            count += 1

        for i in range(k, len(nums)):
            window_sum += nums[i] - nums[i - k]
            if window_sum >= k * threshold:
                count += 1

        return count
```

### COMMENTED CODE

```python
class Solution:
    def numSubarraysWithSumLessThanK(self, nums, k, threshold):
        window_sum = sum(nums[:k])
        count = 0

        if window_sum >= k * threshold:
            count += 1

        for i in range(k, len(nums)):
            window_sum += nums[i] - nums[i - k]  # Slide the window.
            if window_sum >= k * threshold:
                count += 1

        return count
```

### Complexity

**Time:** O(n)

**Space:** O(1)

### Cheat Sheet

### Cheat Sheet
**Pattern:** Fixed Window

**State:** `window_sum`

**Expand:** Add `nums[right]`

**Shrink:** Remove `nums[left]`

**Condition:** Window size == k and `window_sum >= threshold * k`

**Answer:** Number of valid windows

**Complexity:** O(n) time, O(1) space

### When should I recognize this pattern?

- "Subarrays of fixed size k"
- "Average greater than threshold"
- "Count valid fixed windows"

### Common Mistakes

- Comparing average directly instead of comparing `sum >= threshold * k`.
- Forgetting to count the first window.
- Doing an O(n × k) nested loop.

---

## Stage 1 Summary

### Patterns learned

- Fixed-size sliding window
- Running sum update
- Overlap elimination via window movement

### Reusable template

```python
window = sum(nums[:k])

for i in range(k, len(nums)):
    window += nums[i] - nums[i - k]
    update_answer()
```

### Recognition rules

When the problem says:

- subarray of length k
- maximum/minimum over size k
- count valid windows of size k

think fixed window and update by changing only two values.

### Problems that build on each other

- 643 introduces the fundamental fixed-window update.
- 1456 applies the same idea to a character-count condition.
- 1343 extends it to counting valid windows using a threshold condition.

This is the foundation for the variable-window and frequency-map stages that come next.

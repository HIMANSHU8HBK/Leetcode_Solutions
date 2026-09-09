# Sliding Window Mastery

## Current status

The provided roadmap does not specify the actual problem list, stage names, or problem order.

Because the source of truth is missing, I cannot safely invent a problem sequence, titles, or official LeetCode links without risking incorrect content.

> "The provided roadmap does not specify this."

## What I need to proceed

Please provide one of the following:

- the roadmap text
- the list of stages and problems in order
- a PDF/image/file containing the roadmap
- a link to the document or sheet

Once the roadmap is supplied, I will solve every problem in the exact order given and follow the required structure.

---

## Required format for each problem

## 1. Problem Title

## [643. Maximum Average Subarray I](https://leetcode.com/problems/maximum-average-subarray-i/)

## 2. Pattern

**Pattern:** Fixed-Size Sliding Window

**Secondary Pattern:** Running Sum

## 3. What Are We Maintaining?

- Window sum
- Current best sum

## 4. Intuition

Instead of recalculating the sum for every K-sized subarray, keep the current window sum. When the window moves right, add the incoming value and remove the outgoing one.

## 5. Brute Force

**Brute force:** Calculate the sum of every K-sized subarray separately.

**Time:** O(n × k)

The sliding window avoids recomputing overlapping subarrays.

## 6. KEY OBSERVATION

> **Key Observation:**
> When the window moves one position, only two elements change.

## 7. RAW CODE

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

## 8. COMMENTED CODE

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

## 9. Complexity

**Time:** O(n)

**Space:** O(1)

## 13. Cheat Sheet

### Cheat Sheet
**Pattern:** Fixed Window

**State:** `window_sum`

**Expand:** Add `nums[right]`

**Shrink:** Remove `nums[left]`

**Condition:** Window size == K

**Answer:** Maximum/minimum/count based on the problem

**Complexity:** O(n) time, O(1) space

## 14. Interview Trigger

### When should I recognize this pattern?

- "Subarray/subset of exactly K elements" → Fixed-size window.
- "Maximum/minimum average over a window of size K" → Fixed-size window.

## 15. Common Mistakes

- Forgetting to remove the outgoing element.
- Updating the answer too early.
- Misinterpreting fixed-size vs variable-size windows.

---

## Stage template

## Stage 1 Summary

### Patterns learned

- Pattern 1
- Pattern 2
- Pattern 3

### Reusable templates

```python
left = 0

for right in range(len(nums)):
    add(nums[right])

    while invalid:
        remove(nums[left])
        left += 1

    update_answer()
```

### Recognition rules

- If the condition is based on a window size, think fixed window.
- If the condition is based on validity, think variable window.

### Problems that build on each other

- Basic window fundamentals
- Then dynamic boundaries
- Then frequency-map optimization

---

## Final note

I am ready to complete the full roadmap as soon as you provide the actual problem list.

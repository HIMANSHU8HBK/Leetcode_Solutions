# Two Pointers Pattern Mastery

LeetCode problem list: https://leetcode.com/problem-list/two-pointers/

A practical notes document for studying the Two Pointers pattern on LeetCode.

> This is a curated master map of core two-pointer problems and sub-patterns. Many LeetCode problems overlap with arrays, strings, linked lists, or greedy logic, so some questions fit in more than one bucket. The goal is to group them by the primary skill they teach.

---

## 1. What is the Two Pointers pattern?

Use two pointers when:
- you need to scan from both ends
- you want to avoid O(n^2) nested loops
- the array is sorted or partially ordered
- you are checking a palindrome, partition, merge, or cycle
- you are shrinking or expanding a range while maintaining an invariant

Typical idea:
- left pointer moves forward
- right pointer moves backward
- or both move in a coordinated way
- maintain an invariant while reducing the search space

---

## 2. Sub-pattern map

### A. Pair / Target Sum on sorted arrays

Core idea: use two pointers to eliminate one dimension of search.

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [1. Two Sum](https://leetcode.com/problems/two-sum/) | Easy | General hash-map version; on sorted input, two pointers are the natural variant. |
| [167. Two Sum II - Input Array Is Sorted](https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/) | Easy | Canonical two-pointer target-sum problem. |
| [15. 3Sum](https://leetcode.com/problems/3sum/) | Medium | Fix one value and use two pointers for the rest. |
| [16. 3Sum Closest](https://leetcode.com/problems/3sum-closest/) | Medium | Same structure, but optimize for closest sum. |
| [18. 4Sum](https://leetcode.com/problems/4sum/) | Medium | Extend the same strategy to 4 elements. |
| [259. 3Sum Smaller](https://leetcode.com/problems/3sum-smaller/) | Medium | Count pairs with sum below a threshold using pointer movement. |
| [611. Valid Triangle Number](https://leetcode.com/problems/valid-triangle-number/) | Medium | Sort and use two pointers to count valid triplets. |
| [219. Contains Duplicate II](https://leetcode.com/problems/contains-duplicate-ii/) | Easy | Sliding-window / two-pointer style with a bound. |

#### Solution: [1. Two Sum](https://leetcode.com/problems/two-sum/)

```python
class Solution:
    def twoSum(self, nums, target):
        seen = {}

        for i, value in enumerate(nums):
            need = target - value
            if need in seen:
                return [seen[need], i]
            seen[value] = i

        return []
```

Why it works: the map remembers which value has already appeared, so we can find the complement in O(1) time.

#### Solution: [167. Two Sum II - Input Array Is Sorted](https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/)

```python
class Solution:
    def twoSum(self, numbers, target):
        left, right = 0, len(numbers) - 1

        while left < right:
            total = numbers[left] + numbers[right]
            if total == target:
                return [left + 1, right + 1]
            if total < target:
                left += 1
            else:
                right -= 1

        return []
```

Why it works: because the array is sorted, a too-small sum means the left pointer must move right, and a too-large sum means the right pointer must move left.

#### Solution: [15. 3Sum](https://leetcode.com/problems/3sum/)

```python
class Solution:
    def threeSum(self, nums):
        nums.sort()
        result = []

        for i in range(len(nums) - 2):
            if i > 0 and nums[i] == nums[i - 1]:
                continue

            left, right = i + 1, len(nums) - 1
            while left < right:
                total = nums[i] + nums[left] + nums[right]
                if total == 0:
                    result.append([nums[i], nums[left], nums[right]])
                    left += 1
                    right -= 1
                    while left < right and nums[left] == nums[left - 1]:
                        left += 1
                    while left < right and nums[right] == nums[right + 1]:
                        right -= 1
                elif total < 0:
                    left += 1
                else:
                    right -= 1

        return result
```

Why it works: fix one value, then use the classic sorted-array pair-sum pattern on the remaining range.

#### Solution: [16. 3Sum Closest](https://leetcode.com/problems/3sum-closest/)

```python
class Solution:
    def threeSumClosest(self, nums, target):
        nums.sort()
        best = float('inf')

        for i in range(len(nums) - 2):
            left, right = i + 1, len(nums) - 1
            while left < right:
                total = nums[i] + nums[left] + nums[right]
                if abs(total - target) < abs(best - target):
                    best = total
                if total < target:
                    left += 1
                else:
                    right -= 1

        return best
```

Why it works: we keep the best sum seen so far while shrinking the search space with the sorted order.

#### Solution: [18. 4Sum](https://leetcode.com/problems/4sum/)

```python
class Solution:
    def fourSum(self, nums, target):
        nums.sort()
        n = len(nums)
        result = []

        for i in range(n - 3):
            if i > 0 and nums[i] == nums[i - 1]:
                continue

            for j in range(i + 1, n - 2):
                if j > i + 1 and nums[j] == nums[j - 1]:
                    continue

                left, right = j + 1, n - 1
                while left < right:
                    total = nums[i] + nums[j] + nums[left] + nums[right]
                    if total == target:
                        result.append([nums[i], nums[j], nums[left], nums[right]])
                        left += 1
                        right -= 1
                        while left < right and nums[left] == nums[left - 1]:
                            left += 1
                        while left < right and nums[right] == nums[right + 1]:
                            right -= 1
                    elif total < target:
                        left += 1
                    else:
                        right -= 1

        return result
```

Why it works: it is the same pattern as 3Sum, just with one more fixed value and a larger pointer search.

#### Solution: [259. 3Sum Smaller](https://leetcode.com/problems/3sum-smaller/)

```python
class Solution:
    def threeSumSmaller(self, nums, target):
        nums.sort()
        count = 0

        for i in range(len(nums) - 2):
            left, right = i + 1, len(nums) - 1
            while left < right:
                total = nums[i] + nums[left] + nums[right]
                if total < target:
                    count += right - left
                    left += 1
                else:
                    right -= 1

        return count
```

Why it works: when the sum is already below the target, every value between left and right also works, so we can count the whole range in one step.

#### Solution: [611. Valid Triangle Number](https://leetcode.com/problems/valid-triangle-number/)

```python
class Solution:
    def triangleNumber(self, nums):
        nums.sort()
        count = 0

        for i in range(len(nums) - 2):
            left, right = i + 1, len(nums) - 1
            while left < right:
                if nums[i] + nums[left] > nums[right]:
                    count += right - left
                    right -= 1
                else:
                    left += 1

        return count
```

Why it works: we fix the largest side and count how many middle values can pair with it to form a valid triangle.

#### Solution: [219. Contains Duplicate II](https://leetcode.com/problems/contains-duplicate-ii/)

```python
class Solution:
    def containsNearbyDuplicate(self, nums, k):
        seen = {}

        for i, value in enumerate(nums):
            if value in seen and i - seen[value] <= k:
                return True
            seen[value] = i

        return False
```

Why it works: we keep the most recent index for each value and check whether it sits within the allowed window.

---

### B. Reverse / partition / reorder arrays

Core idea: move elements using left/right pointers without expensive extra structures.

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [26. Remove Duplicates from Sorted Array](https://leetcode.com/problems/remove-duplicates-from-sorted-array/) | Easy | Use write index + scan pointer. |
| [27. Remove Element](https://leetcode.com/problems/remove-element/) | Easy | Classic in-place removal pattern. |
| [80. Remove Duplicates from Sorted Array II](https://leetcode.com/problems/remove-duplicates-from-sorted-array-ii/) | Medium | Controlled duplicate removal with two pointers. |
| [88. Merge Sorted Array](https://leetcode.com/problems/merge-sorted-array/) | Easy | Merge from the end using backward pointers. |
| [75. Sort Colors](https://leetcode.com/problems/sort-colors/) | Medium | Dutch National Flag pattern with three-way pointers. |
| [283. Move Zeroes](https://leetcode.com/problems/move-zeroes/) | Easy | Partition non-zero and zero values. |
| [977. Squares of a Sorted Array](https://leetcode.com/problems/squares-of-a-sorted-array/) | Easy | Build answer from both ends. |
| [344. Reverse String](https://leetcode.com/problems/reverse-string/) | Easy | Standard reverse-pointer pattern. |
| [345. Reverse Vowels of a String](https://leetcode.com/problems/reverse-vowels-of-a-string/) | Easy | Two pointers on a string with a condition. |
| [349. Intersection of Two Arrays](https://leetcode.com/problems/intersection-of-two-arrays/) | Easy | Sorted merge / set-like pointer solution. |
| [350. Intersection of Two Arrays II](https://leetcode.com/problems/intersection-of-two-arrays-ii/) | Easy | Pointer-based counting intersection. |

#### Solution: [26. Remove Duplicates from Sorted Array](https://leetcode.com/problems/remove-duplicates-from-sorted-array/)

```python
class Solution:
    def removeDuplicates(self, nums):
        if not nums:
            return 0

        write = 1
        for read in range(1, len(nums)):
            if nums[read] != nums[write - 1]:
                nums[write] = nums[read]
                write += 1

        return write
```

Why it works: we keep the first occurrence, then overwrite any later duplicate with the next unique value.

#### Solution: [27. Remove Element](https://leetcode.com/problems/remove-element/)

```python
class Solution:
    def removeElement(self, nums, val):
        write = 0
        for value in nums:
            if value != val:
                nums[write] = value
                write += 1
        return write
```

Why it works: only non-target values are copied forward, which keeps the array compact in place.

#### Solution: [80. Remove Duplicates from Sorted Array II](https://leetcode.com/problems/remove-duplicates-from-sorted-array-ii/)

```python
class Solution:
    def removeDuplicates(self, nums):
        if len(nums) <= 2:
            return len(nums)

        write = 2
        for i in range(2, len(nums)):
            if nums[i] != nums[write - 2]:
                nums[write] = nums[i]
                write += 1

        return write
```

Why it works: we permit at most two copies of any value, then discard the extras.

#### Solution: [88. Merge Sorted Array](https://leetcode.com/problems/merge-sorted-array/)

```python
class Solution:
    def merge(self, nums1, m, nums2, n):
        i = m - 1
        j = n - 1
        k = m + n - 1

        while i >= 0 and j >= 0:
            if nums1[i] > nums2[j]:
                nums1[k] = nums1[i]
                i -= 1
            else:
                nums1[k] = nums2[j]
                j -= 1
            k -= 1

        while j >= 0:
            nums1[k] = nums2[j]
            j -= 1
            k -= 1
```

Why it works: merge from the end so that we write into the largest free slot and never overwrite an unprocessed element.

#### Solution: [75. Sort Colors](https://leetcode.com/problems/sort-colors/)

```python
class Solution:
    def sortColors(self, nums):
        low, mid, high = 0, 0, len(nums) - 1

        while mid <= high:
            if nums[mid] == 0:
                nums[low], nums[mid] = nums[mid], nums[low]
                low += 1
                mid += 1
            elif nums[mid] == 1:
                mid += 1
            else:
                nums[mid], nums[high] = nums[high], nums[mid]
                high -= 1
```

Why it works: the three regions are always [0 ... low), [low ... mid), and [high + 1 ... end], so each swap maintains the invariant.

#### Solution: [283. Move Zeroes](https://leetcode.com/problems/move-zeroes/)

```python
class Solution:
    def moveZeroes(self, nums):
        write = 0
        for value in nums:
            if value != 0:
                nums[write] = value
                write += 1

        for i in range(write, len(nums)):
            nums[i] = 0
```

Why it works: we compact all non-zero values to the front and then fill the tail with zeros.

#### Solution: [977. Squares of a Sorted Array](https://leetcode.com/problems/squares-of-a-sorted-array/)

```python
class Solution:
    def sortedSquares(self, nums):
        result = [0] * len(nums)
        left, right = 0, len(nums) - 1
        index = len(nums) - 1

        while left <= right:
            left_square = nums[left] * nums[left]
            right_square = nums[right] * nums[right]
            if left_square > right_square:
                result[index] = left_square
                left += 1
            else:
                result[index] = right_square
                right -= 1
            index -= 1

        return result
```

Why it works: the array is sorted by value, so the largest square must come from one of the ends; we fill the answer from the back.

#### Solution: [344. Reverse String](https://leetcode.com/problems/reverse-string/)

```python
class Solution:
    def reverseString(self, s):
        left, right = 0, len(s) - 1

        while left < right:
            s[left], s[right] = s[right], s[left]
            left += 1
            right -= 1
```

Why it works: swapping the two ends moves the window inward until the entire string is reversed.

#### Solution: [345. Reverse Vowels of a String](https://leetcode.com/problems/reverse-vowels-of-a-string/)

```python
class Solution:
    def reverseVowels(self, s):
        vowels = set('aeiouAEIOU')
        chars = list(s)
        left, right = 0, len(chars) - 1

        while left < right:
            while left < right and chars[left] not in vowels:
                left += 1
            while left < right and chars[right] not in vowels:
                right -= 1
            if left < right:
                chars[left], chars[right] = chars[right], chars[left]
                left += 1
                right -= 1

        return ''.join(chars)
```

Why it works: we skip non-vowels until both pointers point to vowels, then swap them.

#### Solution: [349. Intersection of Two Arrays](https://leetcode.com/problems/intersection-of-two-arrays/)

```python
class Solution:
    def intersection(self, nums1, nums2):
        nums1 = sorted(set(nums1))
        nums2 = sorted(set(nums2))
        i = j = 0
        result = []

        while i < len(nums1) and j < len(nums2):
            if nums1[i] == nums2[j]:
                result.append(nums1[i])
                i += 1
                j += 1
            elif nums1[i] < nums2[j]:
                i += 1
            else:
                j += 1

        return result
```

Why it works: sorted arrays let us advance the smaller pointer until values match or pass each other.

#### Solution: [350. Intersection of Two Arrays II](https://leetcode.com/problems/intersection-of-two-arrays-ii/)

```python
class Solution:
    def intersect(self, nums1, nums2):
        nums1.sort()
        nums2.sort()
        i = j = 0
        result = []

        while i < len(nums1) and j < len(nums2):
            if nums1[i] == nums2[j]:
                result.append(nums1[i])
                i += 1
                j += 1
            elif nums1[i] < nums2[j]:
                i += 1
            else:
                j += 1

        return result
```

Why it works: we consume equal values from both sorted arrays and ignore the rest.

---

### C. Fast and slow pointers

Core idea: use two pointers moving at different speeds to find the middle, cycle, or linked-list structure.

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [141. Linked List Cycle](https://leetcode.com/problems/linked-list-cycle/) | Easy | Fast/slow pointer detects a cycle. |
| [142. Linked List Cycle II](https://leetcode.com/problems/linked-list-cycle-ii/) | Medium | Find cycle entry point. |
| [876. Middle of the Linked List](https://leetcode.com/problems/middle-of-the-linked-list/) | Easy | Fast pointer reaches the end when slow is in the middle. |
| [19. Remove Nth Node From End of List](https://leetcode.com/problems/remove-nth-node-from-end-of-list/) | Medium | Use fast pointer ahead by n steps. |
| [234. Palindrome Linked List](https://leetcode.com/problems/palindrome-linked-list/) | Easy | Find middle, reverse second half, compare. |
| [287. Find the Duplicate Number](https://leetcode.com/problems/find-the-duplicate-number/) | Medium | Floyd cycle detection style. |
| [202. Happy Number](https://leetcode.com/problems/happy-number/) | Easy | Fast/slow pointer for cycle detection. |
| [204. Count Primes](https://leetcode.com/problems/count-primes/) | Medium | Not a classic fast/slow pointer, but often grouped with pointer-style optimization. |

#### Solution: [141. Linked List Cycle](https://leetcode.com/problems/linked-list-cycle/)

```python
class Solution:
    def hasCycle(self, head):
        slow = head
        fast = head

        while fast and fast.next:
            slow = slow.next
            fast = fast.next.next
            if slow == fast:
                return True

        return False
```

Why it works: if a cycle exists, the faster pointer eventually laps the slower one.

#### Solution: [142. Linked List Cycle II](https://leetcode.com/problems/linked-list-cycle-ii/)

```python
class Solution:
    def detectCycle(self, head):
        slow = head
        fast = head

        while fast and fast.next:
            slow = slow.next
            fast = fast.next.next
            if slow == fast:
                break
        else:
            return None

        slow = head
        while slow != fast:
            slow = slow.next
            fast = fast.next

        return slow
```

Why it works: once the pointers meet, resetting one pointer to the head preserves the cycle distance relationship and finds the entry point.

#### Solution: [876. Middle of the Linked List](https://leetcode.com/problems/middle-of-the-linked-list/)

```python
class Solution:
    def middleNode(self, head):
        slow = fast = head

        while fast and fast.next:
            slow = slow.next
            fast = fast.next.next

        return slow
```

Why it works: when the fast pointer reaches the end, the slow pointer is exactly in the middle.

#### Solution: [19. Remove Nth Node From End of List](https://leetcode.com/problems/remove-nth-node-from-end-of-list/)

```python
class Solution:
    def removeNthFromEnd(self, head, n):
        dummy = ListNode(0)
        dummy.next = head
        fast = dummy
        slow = dummy

        for _ in range(n + 1):
            fast = fast.next

        while fast:
            fast = fast.next
            slow = slow.next

        slow.next = slow.next.next
        return dummy.next
```

Why it works: the fast pointer is advanced n + 1 steps ahead, so when it reaches the end, slow sits right before the node to delete.

#### Solution: [234. Palindrome Linked List](https://leetcode.com/problems/palindrome-linked-list/)

```python
class Solution:
    def isPalindrome(self, head):
        if not head or not head.next:
            return True

        slow = head
        fast = head
        while fast and fast.next:
            slow = slow.next
            fast = fast.next.next

        if fast:
            slow = slow.next

        prev = None
        while slow:
            nxt = slow.next
            slow.next = prev
            prev = slow
            slow = nxt

        while prev:
            if head.val != prev.val:
                return False
            head = head.next
            prev = prev.next

        return True
```

Why it works: we find the midpoint, reverse the second half, and compare the two halves directly.

#### Solution: [287. Find the Duplicate Number](https://leetcode.com/problems/find-the-duplicate-number/)

```python
class Solution:
    def findDuplicate(self, nums):
        slow = nums[0]
        fast = nums[0]

        while True:
            slow = nums[slow]
            fast = nums[nums[fast]]
            if slow == fast:
                break

        slow = nums[0]
        while slow != fast:
            slow = nums[slow]
            fast = nums[fast]

        return slow
```

Why it works: this is Floyd’s cycle-finding pattern, where the duplicate value behaves like a cycle entry.

#### Solution: [202. Happy Number](https://leetcode.com/problems/happy-number/)

```python
class Solution:
    def isHappy(self, n):
        def next_number(x):
            total = 0
            while x:
                x, mod = divmod(x, 10)
                total += mod * mod
            return total

        slow = n
        fast = n

        while True:
            slow = next_number(slow)
            fast = next_number(next_number(fast))
            if slow == fast:
                break

        return slow == 1
```

Why it works: the repeated digit-square process eventually enters a cycle; the fast/slow detection identifies whether that cycle is non-trivial or resolves to 1.

#### Solution: [204. Count Primes](https://leetcode.com/problems/count-primes/)

```python
import math

class Solution:
    def countPrimes(self, n):
        if n < 2:
            return 0

        is_prime = [True] * n
        is_prime[0] = is_prime[1] = False

        for p in range(2, int(math.sqrt(n)) + 1):
            if is_prime[p]:
                for multiple in range(p * p, n, p):
                    is_prime[multiple] = False

        return sum(is_prime)
```

Why it works: we mark all composite numbers by their smallest prime factor and keep only the remaining primes. This is a classic optimization pattern even though it is not a true fast/slow pointer problem.

---

### D. Palindrome / string validation

Core idea: compare elements from both ends while maintaining the invariant of symmetry.

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [125. Valid Palindrome](https://leetcode.com/problems/valid-palindrome/) | Easy | Ignore non-alphanumeric and compare ends. |
| [680. Valid Palindrome II](https://leetcode.com/problems/valid-palindrome-ii/) | Easy | Greedy with two-pointer retry on mismatch. |
| [7. Reverse Integer](https://leetcode.com/problems/reverse-integer/) | Medium | Digit-by-digit reverse with pointer-like logic. |
| [121. Best Time to Buy and Sell Stock](https://leetcode.com/problems/best-time-to-buy-and-sell-stock/) | Easy | A simple two-pointer profit update. |
| [122. Best Time to Buy and Sell Stock II](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-ii/) | Easy | Buy low, sell high using pointer movement. |
| [11. Container With Most Water](https://leetcode.com/problems/container-with-most-water/) | Medium | Classic max-area proof using two pointers. |

#### Solution: [125. Valid Palindrome](https://leetcode.com/problems/valid-palindrome/)

```python
class Solution:
    def isPalindrome(self, s):
        left, right = 0, len(s) - 1

        while left < right:
            while left < right and not s[left].isalnum():
                left += 1
            while left < right and not s[right].isalnum():
                right -= 1
            if s[left].lower() != s[right].lower():
                return False
            left += 1
            right -= 1

        return True
```

Why it works: we ignore non-alphanumeric characters and compare the remaining ends inward.

#### Solution: [680. Valid Palindrome II](https://leetcode.com/problems/valid-palindrome-ii/)

```python
class Solution:
    def validPalindrome(self, s):
        def is_palindrome(lo, hi):
            while lo < hi:
                if s[lo] != s[hi]:
                    return False
                lo += 1
                hi -= 1
            return True

        left, right = 0, len(s) - 1
        while left < right:
            if s[left] == s[right]:
                left += 1
                right -= 1
            else:
                return is_palindrome(left + 1, right) or is_palindrome(left, right - 1)
        return True
```

Why it works: one mismatch gives us at most two possible deletions, so we test each candidate range greedily.

#### Solution: [7. Reverse Integer](https://leetcode.com/problems/reverse-integer/)

```python
class Solution:
    def reverse(self, x):
        sign = -1 if x < 0 else 1
        x = abs(x)
        result = 0

        while x:
            if result > (2**31 - 1) // 10:
                return 0
            result = result * 10 + x % 10
            x //= 10

        return sign * result
```

Why it works: we repeatedly peel off the last digit and build the reversed number from the right side.

#### Solution: [121. Best Time to Buy and Sell Stock](https://leetcode.com/problems/best-time-to-buy-and-sell-stock/)

```python
class Solution:
    def maxProfit(self, prices):
        if not prices:
            return 0

        min_price = prices[0]
        best = 0

        for price in prices[1:]:
            min_price = min(min_price, price)
            best = max(best, price - min_price)

        return best
```

Why it works: keep the minimum buying price seen so far and compare each later price against it.

#### Solution: [122. Best Time to Buy and Sell Stock II](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-ii/)

```python
class Solution:
    def maxProfit(self, prices):
        profit = 0
        for i in range(1, len(prices)):
            if prices[i] > prices[i - 1]:
                profit += prices[i] - prices[i - 1]
        return profit
```

Why it works: every positive day-to-day increase contributes to profit.

#### Solution: [11. Container With Most Water](https://leetcode.com/problems/container-with-most-water/)

```python
class Solution:
    def maxArea(self, height):
        left, right = 0, len(height) - 1
        best = 0

        while left < right:
            width = right - left
            best = max(best, min(height[left], height[right]) * width)

            if height[left] <= height[right]:
                left += 1
            else:
                right -= 1

        return best
```

Why it works: the wider the container, the more important the shorter side becomes; if the left wall is not the limiting factor, move it inward.

---

### E. Merge and compare from both ends

Core idea: two pointers work when both arrays or sequences are ordered and we need to combine them efficiently.

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [21. Merge Two Sorted Lists](https://leetcode.com/problems/merge-two-sorted-lists/) | Easy | Standard merge pointer strategy. |
| [23. Merge k Sorted Lists](https://leetcode.com/problems/merge-k-sorted-lists/) | Hard | Heap-based multiple merge, but pointer reasoning matters conceptually. |
| [315. Count of Smaller Numbers After Self](https://leetcode.com/problems/count-of-smaller-numbers-after-self/) | Hard | Merge-sort style, related to ordered merge logic. |
| [328. Odd Even Linked List](https://leetcode.com/problems/odd-even-linked-list/) | Medium | Rearranging list with pointer updates. |
| [206. Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/) | Easy | Pointer-rewiring pattern. |
| [92. Reverse Linked List II](https://leetcode.com/problems/reverse-linked-list-ii/) | Medium | Reverse a segment using pointer manipulations. |

#### Solution: [21. Merge Two Sorted Lists](https://leetcode.com/problems/merge-two-sorted-lists/)

```python
class Solution:
    def mergeTwoLists(self, l1, l2):
        dummy = ListNode(0)
        tail = dummy

        while l1 and l2:
            if l1.val <= l2.val:
                tail.next = l1
                l1 = l1.next
            else:
                tail.next = l2
                l2 = l2.next
            tail = tail.next

        tail.next = l1 if l1 else l2
        return dummy.next
```

Why it works: repeatedly append the smaller current node to a growing merged list.

#### Solution: [23. Merge k Sorted Lists](https://leetcode.com/problems/merge-k-sorted-lists/)

```python
import heapq

class Solution:
    def mergeKLists(self, lists):
        heap = []

        for i, head in enumerate(lists):
            if head:
                heapq.heappush(heap, (head.val, i, head))

        dummy = ListNode(0)
        tail = dummy

        while heap:
            val, index, node = heapq.heappop(heap)
            tail.next = node
            tail = tail.next

            if node.next:
                heapq.heappush(heap, (node.next.val, index, node.next))

        return dummy.next
```

Why it works: the heap lets us always pick the smallest remaining node across all lists.

#### Solution: [315. Count of Smaller Numbers After Self](https://leetcode.com/problems/count-of-smaller-numbers-after-self/)

```python
class Solution:
    def countSmaller(self, nums):
        n = len(nums)
        indexes = list(range(n))
        counts = [0] * n

        def merge_sort(left, right):
            if left >= right:
                return

            mid = (left + right) // 2
            merge_sort(left, mid)
            merge_sort(mid + 1, right)

            temp = []
            i, j = left, mid + 1
            while i <= mid and j <= right:
                if nums[indexes[i]] <= nums[indexes[j]]:
                    temp.append(indexes[i])
                    i += 1
                else:
                    counts[indexes[j]] += mid - i + 1
                    temp.append(indexes[j])
                    j += 1

            while i <= mid:
                temp.append(indexes[i])
                i += 1
            while j <= right:
                temp.append(indexes[j])
                j += 1

            indexes[left:right + 1] = temp

        merge_sort(0, n - 1)
        return counts
```

Why it works: merge sort keeps the right side and left side ordered, so every time an element from the right side is placed before an element from the left, it means that right-side element has smaller values to its right.

#### Solution: [328. Odd Even Linked List](https://leetcode.com/problems/odd-even-linked-list/)

```python
class Solution:
    def oddEvenList(self, head):
        if not head or not head.next:
            return head

        odd = head
        even = head.next
        even_head = even

        while even and even.next:
            odd.next = even.next
            odd = odd.next
            even.next = odd.next
            even = even.next

        odd.next = even_head
        return head
```

Why it works: the odd and even pointers partition the list, then we reconnect the odd chain to the even chain.

#### Solution: [206. Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/)

```python
class Solution:
    def reverseList(self, head):
        prev = None
        curr = head

        while curr:
            nxt = curr.next
            curr.next = prev
            prev = curr
            curr = nxt

        return prev
```

Why it works: each node points backward to the previous node, reversing the chain in place.

#### Solution: [92. Reverse Linked List II](https://leetcode.com/problems/reverse-linked-list-ii/)

```python
class Solution:
    def reverseBetween(self, head, left, right):
        dummy = ListNode(0)
        dummy.next = head
        prev = dummy

        for _ in range(left - 1):
            prev = prev.next

        curr = prev.next
        for _ in range(right - left):
            nxt = curr.next
            curr.next = nxt.next
            nxt.next = prev.next
            prev.next = nxt

        return dummy.next
```

Why it works: we move the next node of the current pointer into the front of the segment, effectively reversing only the chosen range.

---

### F. Window-style pointer squeezing / shrinking

Core idea: the two-pointer movement is used to maintain an interval or range while satisfying a condition.

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [209. Minimum Size Subarray Sum](https://leetcode.com/problems/minimum-size-subarray-sum/) | Medium | Classic shrinking-window two-pointer pattern. |
| [713. Subarray Product Less Than K](https://leetcode.com/problems/subarray-product-less-than-k/) | Medium | Product-based window with left/right pointers. |
| [438. Find All Anagrams in a String](https://leetcode.com/problems/find-all-anagrams-in-a-string/) | Medium | Hash-based window, but still pointer-controlled. |
| [3. Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/) | Medium | The canonical variable window problem. |
| [395. Longest Substring with At Least K Repeating Characters](https://leetcode.com/problems/longest-substring-with-at-least-k-repeating-characters/) | Hard | Shrink and expand with a frequency map. |
| [1004. Max Consecutive Ones III](https://leetcode.com/problems/max-consecutive-ones-iii/) | Medium | Binary-style window with at-most-k condition. |

#### Solution: [209. Minimum Size Subarray Sum](https://leetcode.com/problems/minimum-size-subarray-sum/)

```python
class Solution:
    def minSubArrayLen(self, target, nums):
        left = 0
        current = 0
        best = float('inf')

        for right, value in enumerate(nums):
            current += value
            while current >= target:
                best = min(best, right - left + 1)
                current -= nums[left]
                left += 1

        return 0 if best == float('inf') else best
```

Why it works: when the running sum exceeds the target, shrink the window from the left until it becomes valid again.

#### Solution: [713. Subarray Product Less Than K](https://leetcode.com/problems/subarray-product-less-than-k/)

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
                product /= nums[left]
                left += 1
            answer += right - left + 1

        return answer
```

Why it works: maintain a valid product window and count every subarray ending at right that fits inside it.

#### Solution: [438. Find All Anagrams in a String](https://leetcode.com/problems/find-all-anagrams-in-a-string/)

```python
from collections import Counter

class Solution:
    def findAnagrams(self, s, p):
        need = Counter(p)
        window = Counter()
        left = 0
        result = []

        for right, ch in enumerate(s):
            window[ch] += 1

            while right - left + 1 > len(p):
                left_ch = s[left]
                window[left_ch] -= 1
                if window[left_ch] == 0:
                    del window[left_ch]
                left += 1

            if window == need:
                result.append(left)

        return result
```

Why it works: as the right pointer moves forward, we keep a frequency window and shrink from the left until its size matches the pattern.

#### Solution: [3. Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/)

```python
class Solution:
    def lengthOfLongestSubstring(self, s):
        left = 0
        seen = {}
        best = 0

        for right, ch in enumerate(s):
            if ch in seen and seen[ch] >= left:
                left = seen[ch] + 1
            seen[ch] = right
            best = max(best, right - left + 1)

        return best
```

Why it works: the map stores the most recent index of each character, and when a repeat reappears, we push the left boundary just after it.

#### Solution: [395. Longest Substring with At Least K Repeating Characters](https://leetcode.com/problems/longest-substring-with-at-least-k-repeating-characters/)

```python
from collections import Counter

class Solution:
    def longestSubstring(self, s, k):
        if len(s) < k:
            return 0

        counts = Counter(s)
        for i, ch in enumerate(s):
            if counts[ch] < k:
                return max(self.longestSubstring(s[:i], k), self.longestSubstring(s[i + 1:], k))

        return len(s)
```

Why it works: if a character appears fewer than k times, it cannot be part of a valid answer, so we split on that character and recurse.

#### Solution: [1004. Max Consecutive Ones III](https://leetcode.com/problems/max-consecutive-ones-iii/)

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

Why it works: the left pointer contracts when the number of zeros exceeds the allowed budget, keeping the window valid.

---

### G. Two-pointer greedy / monotonic optimization

Core idea: pointer movement based on a greedy decision that preserves the optimal structure.

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [42. Trapping Rain Water](https://leetcode.com/problems/trapping-rain-water/) | Hard | Classic left/right boundary approach with invariant. |
| [763. Partition Labels](https://leetcode.com/problems/partition-labels/) | Medium | Greedy sweeping with pointer boundary logic. |
| [1329. Sort the Matrix Diagonally](https://leetcode.com/problems/sort-the-matrix-diagonally/) | Medium | Matrix + pointer logic, related to sweeping by position. |
| [986. Interval List Intersections](https://leetcode.com/problems/interval-list-intersections/) | Medium | Two-pointer sweep over sorted intervals. |
| [228. Summary Ranges](https://leetcode.com/problems/summary-ranges/) | Easy | Sequential pointer scan and grouping. |

#### Solution: [42. Trapping Rain Water](https://leetcode.com/problems/trapping-rain-water/)

```python
class Solution:
    def trap(self, height):
        left, right = 0, len(height) - 1
        left_max = 0
        right_max = 0
        water = 0

        while left < right:
            if height[left] <= height[right]:
                if height[left] >= left_max:
                    left_max = height[left]
                else:
                    water += left_max - height[left]
                left += 1
            else:
                if height[right] >= right_max:
                    right_max = height[right]
                else:
                    water += right_max - height[right]
                right -= 1

        return water
```

Why it works: the total water at a side depends only on the highest bar seen so far on that side, so we can move greedily without losing optimality.

#### Solution: [763. Partition Labels](https://leetcode.com/problems/partition-labels/)

```python
class Solution:
    def partitionLabels(self, s):
        last = {ch: i for i, ch in enumerate(s)}
        result = []
        start = 0
        end = 0

        for i, ch in enumerate(s):
            end = max(end, last[ch])
            if i == end:
                result.append(end - start + 1)
                start = i + 1

        return result
```

Why it works: the earliest valid partition is found when the current index reaches the furthest last occurrence of any character seen so far.

#### Solution: [1329. Sort the Matrix Diagonally](https://leetcode.com/problems/sort-the-matrix-diagonally/)

```python
from collections import defaultdict

class Solution:
    def diagonalSort(self, mat):
        groups = defaultdict(list)

        for i in range(len(mat)):
            for j in range(len(mat[0])):
                groups[i - j].append(mat[i][j])

        for key in groups:
            groups[key].sort()

        for i in range(len(mat)):
            for j in range(len(mat[0])):
                mat[i][j] = groups[i - j].pop(0)

        return mat
```

Why it works: each diagonal is grouped by the constant i - j index, then each group is sorted independently.

#### Solution: [986. Interval List Intersections](https://leetcode.com/problems/interval-list-intersections/)

```python
class Solution:
    def intervalIntersection(self, firstList, secondList):
        i = j = 0
        result = []

        while i < len(firstList) and j < len(secondList):
            lo = max(firstList[i][0], secondList[j][0])
            hi = min(firstList[i][1], secondList[j][1])

            if lo <= hi:
                result.append([lo, hi])

            if firstList[i][1] < secondList[j][1]:
                i += 1
            else:
                j += 1

        return result
```

Why it works: the interval pointers advance along sorted ranges, and we keep only the overlapping portions.

#### Solution: [228. Summary Ranges](https://leetcode.com/problems/summary-ranges/)

```python
class Solution:
    def summaryRanges(self, nums):
        if not nums:
            return []

        result = []
        start = prev = nums[0]

        for value in nums[1:]:
            if value == prev + 1:
                prev = value
            else:
                if start == prev:
                    result.append(str(start))
                else:
                    result.append(f"{start}->{prev}")
                start = prev = value

        if start == prev:
            result.append(str(start))
        else:
            result.append(f"{start}->{prev}")

        return result
```

Why it works: we keep the current run together and flush it whenever the next number breaks the consecutive pattern.

---

### H. Other important two-pointer problems

Problems that are not always “pure” two-pointer, but are extremely important in practice.

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [53. Maximum Subarray](https://leetcode.com/problems/maximum-subarray/) | Easy | Kadane’s relation to greedy pointer-style scanning. |
| [152. Maximum Product Subarray](https://leetcode.com/problems/maximum-product-subarray/) | Medium | Scan with state and local boundary updates. |
| [31. Next Permutation](https://leetcode.com/problems/next-permutation/) | Medium | In-place reordering with pointer movement. |
| [26. Remove Duplicates from Sorted Array](https://leetcode.com/problems/remove-duplicates-from-sorted-array/) | Easy | Core in-place pointer skill. |
| [977. Squares of a Sorted Array](https://leetcode.com/problems/squares-of-a-sorted-array/) | Easy | Often grouped under two-pointer sorted-array logic. |

#### Solution: [53. Maximum Subarray](https://leetcode.com/problems/maximum-subarray/)

```python
class Solution:
    def maxSubArray(self, nums):
        best = nums[0]
        current = nums[0]

        for value in nums[1:]:
            current = max(value, current + value)
            best = max(best, current)

        return best
```

Why it works: the best ending subarray at each position is either the current element alone or the previous best ending subarray plus the current element.

#### Solution: [152. Maximum Product Subarray](https://leetcode.com/problems/maximum-product-subarray/)

```python
class Solution:
    def maxProduct(self, nums):
        best = nums[0]
        curr_max = nums[0]
        curr_min = nums[0]

        for value in nums[1:]:
            prev_max, prev_min = curr_max, curr_min
            curr_max = max(value, prev_max * value, prev_min * value)
            curr_min = min(value, prev_max * value, prev_min * value)
            best = max(best, curr_max)

        return best
```

Why it works: because negative values can flip the sign of the product, we keep both maximum and minimum product endings.

#### Solution: [31. Next Permutation](https://leetcode.com/problems/next-permutation/)

```python
class Solution:
    def nextPermutation(self, nums):
        n = len(nums)
        i = n - 2

        while i >= 0 and nums[i] >= nums[i + 1]:
            i -= 1

        if i >= 0:
            j = n - 1
            while nums[j] <= nums[i]:
                j -= 1
            nums[i], nums[j] = nums[j], nums[i]

        left, right = i + 1, n - 1
        while left < right:
            nums[left], nums[right] = nums[right], nums[left]
            left += 1
            right -= 1
```

Why it works: we find which suffix is in descending order, swap in the next larger value, then reverse the suffix to get the lexicographically smallest larger permutation.

---

## 3. Quick pattern recognition guide

### Use two pointers when you see:

### Typical interview questions to ask yourself:

---

## 4. Core templates

### Basic pair-sum template

```python
left, right = 0, len(nums) - 1
while left < right:
    total = nums[left] + nums[right]
    if total == target:
        return [left, right]
    elif total < target:
        left += 1
    else:
        right -= 1
```

### Fast-slow pointer template

```python
slow = fast = head
while fast and fast.next:
    slow = slow.next
    fast = fast.next.next
```

### Shrinking window template

```python
left = 0
for right in range(len(nums)):
    add(nums[right])
    while window_is_invalid:
        remove(nums[left])
        left += 1
```

### Partition / reorder template

```python
write = 0
for value in nums:
    if condition(value):
        nums[write] = value
        write += 1
```

---

## 5. Practice order

If you are learning the pattern in a structured way, the best order is:

1. [167. Two Sum II - Input Array Is Sorted](https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/)
2. [26. Remove Duplicates from Sorted Array](https://leetcode.com/problems/remove-duplicates-from-sorted-array/)
3. [125. Valid Palindrome](https://leetcode.com/problems/valid-palindrome/)
4. [141. Linked List Cycle](https://leetcode.com/problems/linked-list-cycle/)
5. [11. Container With Most Water](https://leetcode.com/problems/container-with-most-water/)
6. [209. Minimum Size Subarray Sum](https://leetcode.com/problems/minimum-size-subarray-sum/)
7. [42. Trapping Rain Water](https://leetcode.com/problems/trapping-rain-water/)
8. [15. 3Sum](https://leetcode.com/problems/3sum/)
9. [18. 4Sum](https://leetcode.com/problems/4sum/)
10. [234. Palindrome Linked List](https://leetcode.com/problems/palindrome-linked-list/)

These ten problems hit the main ideas of the pattern: pair sum, in-place compaction, palindrome checks, cycle detection, monotonic optimization, and variable window shrinking.

---

## 6. Cheat sheet

- Sorted pair sum: move one pointer inward based on total size.
- Remove duplicates: keep a write pointer and compact valid values.
- Palindrome: compare ends inward; skip non-alphanumeric when needed.
- Fast/slow: when one pointer moves faster, it detects cycles and middle points.
- Subarray windows: expand right, shrink left when a condition breaks.
- Greedy pointer optimization: one side is never better than the current max boundary.

---

## 7. Interview trigger

During an interview, the signal to reach for two pointers is often:

- “sorted” or “partially sorted” data
- “find a pair / triplet / duplicate”
- “in-place” modification
- “check if a linked list is cyclic”
- “minimum or maximum range under a condition”

If the problem is asking for an O(n log n) or O(n) approach and the data is linearly ordered, two pointers is almost always the first thing to test.

---

## 8. Common mistakes

- forgetting to sort before applying the pair-sum pattern
- moving the wrong pointer when the sum is too large or too small
- losing the invariant while shrinking a window
- not handling duplicates with skip conditions in 3Sum / 4Sum
- forgetting to reverse or reconnect the second half for palindrome linked lists
- not checking the cycle-entry logic correctly in Floyd’s algorithm

This is the core mental model behind most two-pointer problems: keep a valid state, move only the pointer that can improve the condition, and preserve the invariant until the answer emerges.

---

#### Solution: [5. Longest Palindromic Substring](https://leetcode.com/problems/longest-palindromic-substring/) - Medium

```python
class Solution:
    def longestPalindrome(self, s):
        best_start = 0
        best_length = 1 if s else 0

        def expand(left, right):
            while left >= 0 and right < len(s) and s[left] == s[right]:
                left -= 1
                right += 1
            return left + 1, right - left - 1

        for center in range(len(s)):
            odd_start, odd_length = expand(center, center)
            even_start, even_length = expand(center, center + 1)

            if odd_length > best_length:
                best_start, best_length = odd_start, odd_length
            if even_length > best_length:
                best_start, best_length = even_start, even_length

        return s[best_start:best_start + best_length]
```

Why it works: every palindrome has either one center character or a center gap between two characters. Expand around both center types and keep the longest result.

Time complexity is O(n^2), and the extra space is O(1).

#### Solution: [28. Find the Index of the First Occurrence in a String](https://leetcode.com/problems/find-the-index-of-the-first-occurrence-in-a-string/) - Easy

```python
class Solution:
    def strStr(self, haystack, needle):
        if not needle:
            return 0

        for start in range(len(haystack) - len(needle) + 1):
            if haystack[start:start + len(needle)] == needle:
                return start

        return -1
```

Why it works: each possible starting position is checked against the complete pattern, returning the first exact match.

#### Solution: [61. Rotate List](https://leetcode.com/problems/rotate-list/) - Medium

```python
class Solution:
    def rotateRight(self, head, k):
        if not head or not head.next or k == 0:
            return head

        length = 1
        tail = head
        while tail.next:
            tail = tail.next
            length += 1

        k %= length
        if k == 0:
            return head

        tail.next = head
        steps_to_new_tail = length - k
        new_tail = tail
        for _ in range(steps_to_new_tail):
            new_tail = new_tail.next

        new_head = new_tail.next
        new_tail.next = None
        return new_head
```

Why it works: connect the list into a circle, then break it immediately before the new head after reducing k modulo the list length.

#### Solution: [82. Remove Duplicates from Sorted List II](https://leetcode.com/problems/remove-duplicates-from-sorted-list-ii/) - Medium

```python
class Solution:
    def deleteDuplicates(self, head):
        dummy = ListNode(0)
        dummy.next = head
        prev = dummy

        while head:
            if head.next and head.val == head.next.val:
                duplicate = head.val
                while head and head.val == duplicate:
                    head = head.next
                prev.next = head
            else:
                prev = head
                head = head.next

        return dummy.next
```

Why it works: when a duplicate run is found, skip the entire run so only values appearing exactly once remain.

#### Solution: [86. Partition List](https://leetcode.com/problems/partition-list/) - Medium

```python
class Solution:
    def partition(self, head, x):
        before = ListNode(0)
        after = ListNode(0)
        before_tail = before
        after_tail = after

        while head:
            if head.val < x:
                before_tail.next = head
                before_tail = before_tail.next
            else:
                after_tail.next = head
                after_tail = after_tail.next
            head = head.next

        after_tail.next = None
        before_tail.next = after.next
        return before.next
```

Why it works: maintain two stable chains, one for values below x and one for values at least x, then join them.

#### Solution: [143. Reorder List](https://leetcode.com/problems/reorder-list/) - Medium

```python
class Solution:
    def reorderList(self, head):
        if not head or not head.next:
            return

        slow = fast = head
        while fast.next and fast.next.next:
            slow = slow.next
            fast = fast.next.next

        second = slow.next
        slow.next = None
        previous = None
        while second:
            next_node = second.next
            second.next = previous
            previous = second
            second = next_node

        first = head
        second = previous
        while second:
            first_next = first.next
            second_next = second.next
            first.next = second
            second.next = first_next
            first = first_next
            second = second_next
```

Why it works: split the list at its midpoint, reverse the second half, and interleave nodes from both halves.

#### Solution: [148. Sort List](https://leetcode.com/problems/sort-list/) - Medium

```python
class Solution:
    def sortList(self, head):
        if not head or not head.next:
            return head

        slow = head
        fast = head.next
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

Why it works: recursively split the list into halves, sort both halves, and merge them with two pointers.

#### Solution: [151. Reverse Words in a String](https://leetcode.com/problems/reverse-words-in-a-string/) - Medium

```python
class Solution:
    def reverseWords(self, s):
        words = s.split()
        left, right = 0, len(words) - 1
        while left < right:
            words[left], words[right] = words[right], words[left]
            left += 1
            right -= 1
        return ' '.join(words)
```

Why it works: split removes extra spaces, then reverse the word array with two pointers before joining it once.

#### Solution: [160. Intersection of Two Linked Lists](https://leetcode.com/problems/intersection-of-two-linked-lists/) - Easy

```python
class Solution:
    def getIntersectionNode(self, headA, headB):
        pointer_a = headA
        pointer_b = headB

        while pointer_a != pointer_b:
            pointer_a = pointer_a.next if pointer_a else headB
            pointer_b = pointer_b.next if pointer_b else headA

        return pointer_a
```

Why it works: each pointer traverses both lists, cancelling the length difference and meeting at the shared node or None.

#### Solution: [161. One Edit Distance](https://leetcode.com/problems/one-edit-distance/) - Medium

```python
class Solution:
    def isOneEditDistance(self, s, t):
        if abs(len(s) - len(t)) > 1:
            return False
        if len(s) > len(t):
            s, t = t, s

        for i in range(len(s)):
            if s[i] != t[i]:
                if len(s) == len(t):
                    return s[i + 1:] == t[i + 1:]
                return s[i:] == t[i + 1:]

        return len(t) == len(s) + 1
```

Why it works: after the first mismatch, the remaining suffixes must match after one replacement or one skipped character.

#### Solution: [165. Compare Version Numbers](https://leetcode.com/problems/compare-version-numbers/) - Medium

```python
class Solution:
    def compareVersion(self, version1, version2):
        parts1 = version1.split('.')
        parts2 = version2.split('.')
        length = max(len(parts1), len(parts2))

        for i in range(length):
            value1 = int(parts1[i]) if i < len(parts1) else 0
            value2 = int(parts2[i]) if i < len(parts2) else 0
            if value1 < value2:
                return -1
            if value1 > value2:
                return 1

        return 0
```

Why it works: compare corresponding numeric revision components while treating missing trailing components as zero.

#### Solution: [170. Two Sum III - Data structure design](https://leetcode.com/problems/two-sum-iii-data-structure-design/) - Easy

```python
class TwoSum:
    def __init__(self):
        self.counts = {}

    def add(self, number):
        self.counts[number] = self.counts.get(number, 0) + 1

    def find(self, value):
        for number, count in self.counts.items():
            complement = value - number
            if complement != number and complement in self.counts:
                return True
            if complement == number and count > 1:
                return True
        return False
```

Why it works: store frequencies during add, then check whether each value has a distinct complement or enough copies of itself.

#### Solution: [186. Reverse Words in a String II](https://leetcode.com/problems/reverse-words-in-a-string-ii/) - Medium

```python
class Solution:
    def reverseWords(self, s):
        def reverse(left, right):
            while left < right:
                s[left], s[right] = s[right], s[left]
                left += 1
                right -= 1

        reverse(0, len(s) - 1)
        start = 0
        for end in range(len(s) + 1):
            if end == len(s) or s[end] == ' ':
                reverse(start, end - 1)
                start = end + 1
```

Why it works: reverse the entire character array first, then reverse each word to restore the letters while keeping word order reversed.

#### Solution: [189. Rotate Array](https://leetcode.com/problems/rotate-array/) - Medium

```python
class Solution:
    def rotate(self, nums, k):
        n = len(nums)
        k %= n

        def reverse(left, right):
            while left < right:
                nums[left], nums[right] = nums[right], nums[left]
                left += 1
                right -= 1

        reverse(0, n - 1)
        reverse(0, k - 1)
        reverse(k, n - 1)
```

Why it works: reversing the whole array and then reversing each resulting part moves the last k values to the front in place.

#### Solution: [244. Shortest Word Distance II](https://leetcode.com/problems/shortest-word-distance-ii/) - Medium

```python
class WordDistance:
    def __init__(self, wordsDict):
        self.positions = {}
        for index, word in enumerate(wordsDict):
            self.positions.setdefault(word, []).append(index)

    def shortest(self, word1, word2):
        first = self.positions[word1]
        second = self.positions[word2]
        i = j = 0
        best = float('inf')

        while i < len(first) and j < len(second):
            best = min(best, abs(first[i] - second[j]))
            if first[i] < second[j]:
                i += 1
            else:
                j += 1

        return best
```

Why it works: the stored positions are sorted, so two pointers find the closest pair of occurrences in linear time per query.

#### Solution: [246. Strobogrammatic Number](https://leetcode.com/problems/strobogrammatic-number/) - Easy

```python
class Solution:
    def isStrobogrammatic(self, num):
        pairs = {'0': '0', '1': '1', '6': '9', '8': '8', '9': '6'}
        left, right = 0, len(num) - 1

        while left <= right:
            if num[left] not in pairs or pairs[num[left]] != num[right]:
                return False
            left += 1
            right -= 1

        return True
```

Why it works: every digit on the left must map to the corresponding rotated digit on the right.

#### Solution: [251. Flatten 2D Vector](https://leetcode.com/problems/flatten-2d-vector/) - Medium

```python
class Vector2D:
    def __init__(self, vec):
        self.vec = vec
        self.row = 0
        self.column = 0
        self._skip_empty_rows()

    def _skip_empty_rows(self):
        while self.row < len(self.vec) and self.column >= len(self.vec[self.row]):
            self.row += 1
            self.column = 0

    def next(self):
        value = self.vec[self.row][self.column]
        self.column += 1
        self._skip_empty_rows()
        return value

    def hasNext(self):
        self._skip_empty_rows()
        return self.row < len(self.vec)
```

Why it works: keep a row and column pointer, skipping empty rows before every read or availability check.

#### Solution: [253. Meeting Rooms II](https://leetcode.com/problems/meeting-rooms-ii/) - Medium

```python
class Solution:
    def minMeetingRooms(self, intervals):
        starts = sorted(interval[0] for interval in intervals)
        ends = sorted(interval[1] for interval in intervals)
        start = end = 0
        rooms = 0

        while start < len(starts):
            if starts[start] < ends[end]:
                rooms += 1
                start += 1
            else:
                end += 1
                start += 1

        return rooms
```

Why it works: compare the next meeting start with the earliest ending meeting to decide whether a new room is needed.

#### Solution: [272. Closest Binary Search Tree Value II](https://leetcode.com/problems/closest-binary-search-tree-value-ii/) - Hard

```python
from collections import deque

class Solution:
    def closestKValues(self, root, target, k):
        values = []

        def inorder(node):
            if not node:
                return
            inorder(node.left)
            values.append(node.val)
            inorder(node.right)

        inorder(root)
        values.sort(key=lambda value: abs(value - target))
        return values[:k]
```

Why it works: inorder traversal collects all BST values, after which sorting by distance selects the k closest values. This is a direct, easy-to-follow solution with O(n log n) time.

#### Solution: [277. Find the Celebrity](https://leetcode.com/problems/find-the-celebrity/) - Medium

```python
class Solution:
    def findCelebrity(self, n):
        candidate = 0

        for person in range(1, n):
            if knows(candidate, person):
                candidate = person

        for person in range(n):
            if person == candidate:
                continue
            if knows(candidate, person) or not knows(person, candidate):
                return -1

        return candidate
```

Why it works: if the current candidate knows someone, the candidate cannot be the celebrity, so replace it. A final verification checks both celebrity conditions.

#### Solution: [295. Find Median from Data Stream](https://leetcode.com/problems/find-median-from-data-stream/) - Hard

```python
import heapq

class MedianFinder:
    def __init__(self):
        self.lower = []
        self.upper = []

    def addNum(self, num):
        heapq.heappush(self.lower, -num)
        heapq.heappush(self.upper, -heapq.heappop(self.lower))

        if len(self.upper) > len(self.lower):
            heapq.heappush(self.lower, -heapq.heappop(self.upper))

    def findMedian(self):
        if len(self.lower) > len(self.upper):
            return -self.lower[0]
        return (-self.lower[0] + self.upper[0]) / 2
```

Why it works: the max-heap stores the lower half and the min-heap stores the upper half, keeping their sizes balanced so the median is always at the roots.

#### Solution: [321. Create Maximum Number](https://leetcode.com/problems/create-maximum-number/) - Hard

```python
class Solution:
    def maxNumber(self, nums1, nums2, k):
        best = []

        for take in range(max(0, k - len(nums2)), min(k, len(nums1)) + 1):
            first = self.pick(nums1, take)
            second = self.pick(nums2, k - take)
            candidate = self.merge(first, second)
            best = max(best, candidate)

        return best

    def pick(self, nums, length):
        drop = len(nums) - length
        stack = []
        for value in nums:
            while drop and stack and stack[-1] < value:
                stack.pop()
                drop -= 1
            stack.append(value)
        return stack[:length]

    def merge(self, first, second):
        result = []
        while first or second:
            if first > second:
                result.append(first.pop(0))
            else:
                result.append(second.pop(0))
        return result
```

Why it works: try every valid split, keep the best subsequence from each array, and greedily merge the lexicographically larger remaining suffix.

#### Solution: [360. Sort Transformed Array](https://leetcode.com/problems/sort-transformed-array/) - Medium

```python
class Solution:
    def sortTransformedArray(self, nums, a, b, c):
        def transform(value):
            return a * value * value + b * value + c

        result = [0] * len(nums)
        left, right = 0, len(nums) - 1

        if a >= 0:
            index = len(nums) - 1
            while left <= right:
                left_value = transform(nums[left])
                right_value = transform(nums[right])
                if left_value > right_value:
                    result[index] = left_value
                    left += 1
                else:
                    result[index] = right_value
                    right -= 1
                index -= 1
        else:
            index = 0
            while left <= right:
                left_value = transform(nums[left])
                right_value = transform(nums[right])
                if left_value < right_value:
                    result[index] = left_value
                    left += 1
                else:
                    result[index] = right_value
                    right -= 1
                index += 1

        return result
```

Why it works: a quadratic transformation is monotonic from the vertex outward, so the largest or smallest transformed value must come from an end.

#### Solution: [392. Is Subsequence](https://leetcode.com/problems/is-subsequence/) - Easy

```python
class Solution:
    def isSubsequence(self, s, t):
        i = 0
        for character in t:
            if i < len(s) and s[i] == character:
                i += 1
        return i == len(s)
```

Why it works: scan the larger string once and advance the subsequence pointer only when the next required character appears.

#### Solution: [408. Valid Word Abbreviation](https://leetcode.com/problems/valid-word-abbreviation/) - Easy

```python
class Solution:
    def validWordAbbreviation(self, word, abbr):
        word_index = 0
        abbr_index = 0

        while word_index < len(word) and abbr_index < len(abbr):
            if abbr[abbr_index].isalpha():
                if word[word_index] != abbr[abbr_index]:
                    return False
                word_index += 1
                abbr_index += 1
                continue

            if abbr[abbr_index] == '0':
                return False

            number = 0
            while abbr_index < len(abbr) and abbr[abbr_index].isdigit():
                number = number * 10 + int(abbr[abbr_index])
                abbr_index += 1
            word_index += number

        return word_index == len(word) and abbr_index == len(abbr)
```

Why it works: two pointers parse literal characters directly and treat each digit run as the number of word characters to skip.

#### Solution: [443. String Compression](https://leetcode.com/problems/string-compression/) - Medium

```python
class Solution:
    def compress(self, chars):
        write = 0
        read = 0

        while read < len(chars):
            character = chars[read]
            start = read
            while read < len(chars) and chars[read] == character:
                read += 1

            chars[write] = character
            write += 1
            count = read - start
            if count > 1:
                for digit in str(count):
                    chars[write] = digit
                    write += 1

        return write
```

Why it works: the read pointer consumes each run and the write pointer overwrites the array with the compressed character and count.

#### Solution: [455. Assign Cookies](https://leetcode.com/problems/assign-cookies/) - Easy

```python
class Solution:
    def findContentChildren(self, greed, cookies):
        greed.sort()
        cookies.sort()
        child = cookie = 0

        while child < len(greed) and cookie < len(cookies):
            if cookies[cookie] >= greed[child]:
                child += 1
            cookie += 1

        return child
```

Why it works: always give the smallest sufficient cookie to the least greedy remaining child, preserving larger cookies for harder matches.

#### Solution: [457. Circular Array Loop](https://leetcode.com/problems/circular-array-loop/) - Medium

```python
class Solution:
    def circularArrayLoop(self, nums):
        n = len(nums)

        def next_index(index):
            return (index + nums[index]) % n

        def same_direction(index, direction):
            return nums[index] * direction > 0

        for start in range(n):
            if nums[start] == 0:
                continue

            direction = nums[start]
            slow = start
            fast = start

            while (same_direction(slow, direction)
                   and same_direction(next_index(fast), direction)):
                slow = next_index(slow)
                fast = next_index(next_index(fast))
                if slow == fast:
                    if slow == next_index(slow):
                        break
                    return True

            index = start
            while same_direction(index, direction):
                next_node = next_index(index)
                nums[index] = 0
                index = next_node

        return False
```

Why it works: Floyd cycle detection finds a cycle only when all moves keep the same direction, and the self-loop check rejects one-element cycles.

#### Solution: [466. Count The Repetitions](https://leetcode.com/problems/count-the-repetitions/) - Hard

```python
class Solution:
    def getMaxRepetitions(self, s1, n1, s2, n2):
        if n1 == 0:
            return 0

        index = 0
        count1 = 0
        count2 = 0
        seen = {}
        gained = {}

        while count1 < n1:
            for character in s1:
                if character == s2[index]:
                    index += 1
                    if index == len(s2):
                        index = 0
                        count2 += 1
            count1 += 1

            if index in seen:
                previous_count1 = seen[index]
                previous_count2 = gained[index]
                cycle1 = count1 - previous_count1
                cycle2 = count2 - previous_count2
                remaining = n1 - count1
                cycles = remaining // cycle1
                count1 += cycles * cycle1
                count2 += cycles * cycle2
            else:
                seen[index] = count1
                gained[index] = count2

        return count2 // n2
```

Why it works: the matched position inside s2 repeats, creating a cycle that lets us skip many copies of s1 at once.

#### Solution: [475. Heaters](https://leetcode.com/problems/heaters/) - Medium

```python
class Solution:
    def findRadius(self, houses, heaters):
        houses.sort()
        heaters.sort()
        heater = 0
        radius = 0

        for house in houses:
            while (heater + 1 < len(heaters)
                   and abs(heaters[heater + 1] - house) <= abs(heaters[heater] - house)):
                heater += 1
            radius = max(radius, abs(heaters[heater] - house))

        return radius
```

Why it works: with sorted houses and heaters, the closest heater pointer only moves forward, and the largest nearest distance determines the required radius.

#### Solution: [481. Magical String](https://leetcode.com/problems/magical-string/) - Medium

```python
class Solution:
    def magicalString(self, n):
        if n <= 0:
            return 0
        if n <= 3:
            return 1

        sequence = [1, 2, 2]
        read = 2
        next_value = 1
        while len(sequence) < n:
            sequence.extend([next_value] * sequence[read])
            next_value = 3 - next_value
            read += 1

        return sequence[:n].count(1)
```

Why it works: the sequence describes its own run lengths, so a read pointer expands each run while alternating between 1 and 2.

#### Solution: [522. Longest Uncommon Subsequence II](https://leetcode.com/problems/longest-uncommon-subsequence-ii/) - Medium

```python
class Solution:
    def findLUSlength(self, strs):
        def is_subsequence(shorter, longer):
            i = 0
            for character in longer:
                if i < len(shorter) and shorter[i] == character:
                    i += 1
            return i == len(shorter)

        best = -1
        for i, candidate in enumerate(strs):
            if len(candidate) <= best:
                continue
            if all(i == j or not is_subsequence(candidate, other)
                   for j, other in enumerate(strs)):
                best = len(candidate)

        return best
```

Why it works: a candidate is uncommon only if it is not a subsequence of any other string; checking longer candidates first lets us keep the maximum length.

#### Solution: [524. Longest Word in Dictionary through Deleting](https://leetcode.com/problems/longest-word-in-dictionary-through-deleting/) - Medium

```python
class Solution:
    def findLongestWord(self, s, dictionary):
        def is_subsequence(word):
            i = 0
            for character in s:
                if i < len(word) and word[i] == character:
                    i += 1
            return i == len(word)

        best = ''
        for word in dictionary:
            if is_subsequence(word) and (len(word) > len(best)
                                         or len(word) == len(best) and word < best):
                best = word
        return best
```

Why it works: use two pointers to test each dictionary word as a subsequence, then apply the required length and lexicographic tie-breakers.

#### Solution: [532. K-diff Pairs in an Array](https://leetcode.com/problems/k-diff-pairs-in-an-array/) - Medium

```python
class Solution:
    def findPairs(self, nums, k):
        if k < 0:
            return 0

        nums.sort()
        left, right = 0, 1
        pairs = 0

        while right < len(nums):
            if left == right or nums[right] - nums[left] < k:
                right += 1
            elif nums[right] - nums[left] > k:
                left += 1
            else:
                pairs += 1
                left += 1
                right += 1
                while right < len(nums) and nums[right] == nums[right - 1]:
                    right += 1

        return pairs
```

Why it works: sorted pointers compare differences directly, and advancing past equal right values prevents counting the same pair more than once.

#### Solution: [541. Reverse String II](https://leetcode.com/problems/reverse-string-ii/) - Easy

```python
class Solution:
    def reverseStr(self, s, k):
        chars = list(s)
        for start in range(0, len(chars), 2 * k):
            left = start
            right = min(start + k - 1, len(chars) - 1)
            while left < right:
                chars[left], chars[right] = chars[right], chars[left]
                left += 1
                right -= 1
        return ''.join(chars)
```

Why it works: process each 2k block independently and reverse only its first k characters with two pointers.

#### Solution: [556. Next Greater Element III](https://leetcode.com/problems/next-greater-element-iii/) - Medium

```python
class Solution:
    def nextGreaterElement(self, n):
        digits = list(str(n))
        i = len(digits) - 2

        while i >= 0 and digits[i] >= digits[i + 1]:
            i -= 1
        if i < 0:
            return -1

        j = len(digits) - 1
        while digits[j] <= digits[i]:
            j -= 1
        digits[i], digits[j] = digits[j], digits[i]

        left, right = i + 1, len(digits) - 1
        while left < right:
            digits[left], digits[right] = digits[right], digits[left]
            left += 1
            right -= 1

        result = int(''.join(digits))
        return result if result < 2**31 else -1
```

Why it works: find the rightmost increasing pair, swap the pivot with the smallest larger digit, then reverse the suffix to get the next permutation.

#### Solution: [557. Reverse Words in a String III](https://leetcode.com/problems/reverse-words-in-a-string-iii/) - Easy

```python
class Solution:
    def reverseWords(self, s):
        chars = list(s)
        start = 0

        for end in range(len(chars) + 1):
            if end == len(chars) or chars[end] == ' ':
                left, right = start, end - 1
                while left < right:
                    chars[left], chars[right] = chars[right], chars[left]
                    left += 1
                    right -= 1
                start = end + 1

        return ''.join(chars)
```

Why it works: identify each word boundary and reverse only the characters inside that word.

#### Solution: [567. Permutation in String](https://leetcode.com/problems/permutation-in-string/) - Medium

```python
from collections import Counter

class Solution:
    def checkInclusion(self, s1, s2):
        if len(s1) > len(s2):
            return False

        need = Counter(s1)
        window = Counter(s2[:len(s1)])
        if window == need:
            return True

        for right in range(len(s1), len(s2)):
            window[s2[right]] += 1
            left_character = s2[right - len(s1)]
            window[left_character] -= 1
            if window[left_character] == 0:
                del window[left_character]
            if window == need:
                return True

        return False
```

Why it works: maintain a fixed-size frequency window equal to s1 and compare its character counts as it slides through s2.

#### Solution: [581. Shortest Unsorted Continuous Subarray](https://leetcode.com/problems/shortest-unsorted-continuous-subarray/) - Medium

```python
class Solution:
    def findUnsortedSubarray(self, nums):
        left, right = 0, len(nums) - 1

        while left < right and nums[left] <= nums[left + 1]:
            left += 1
        if left == right:
            return 0

        while right > left and nums[right - 1] <= nums[right]:
            right -= 1

        middle_min = min(nums[left:right + 1])
        middle_max = max(nums[left:right + 1])

        while left > 0 and nums[left - 1] > middle_min:
            left -= 1
        while right + 1 < len(nums) and nums[right + 1] < middle_max:
            right += 1

        return right - left + 1
```

Why it works: find the already sorted prefix and suffix, then expand the unsorted window whenever an outside value belongs inside it.

#### Solution: [633. Sum of Square Numbers](https://leetcode.com/problems/sum-of-square-numbers/) - Medium

```python
import math

class Solution:
    def judgeSquareSum(self, c):
        left = 0
        right = math.isqrt(c)

        while left <= right:
            total = left * left + right * right
            if total == c:
                return True
            if total < c:
                left += 1
            else:
                right -= 1

        return False
```

Why it works: the sum increases when the left square grows and decreases when the right square shrinks, giving a sorted two-pointer search over possible squares.

#### Solution: [647. Palindromic Substrings](https://leetcode.com/problems/palindromic-substrings/) - Medium

```python
class Solution:
    def countSubstrings(self, s):
        count = 0

        def expand(left, right):
            nonlocal count
            while left >= 0 and right < len(s) and s[left] == s[right]:
                count += 1
                left -= 1
                right += 1

        for center in range(len(s)):
            expand(center, center)
            expand(center, center + 1)

        return count
```

Why it works: every palindrome expands from either a character center or a gap center, so count both kinds of expansions.

#### Solution: [653. Two Sum IV - Input is a BST](https://leetcode.com/problems/two-sum-iv-input-is-a-bst/) - Easy

```python
class Solution:
    def findTarget(self, root, k):
        seen = set()

        def search(node):
            if not node:
                return False
            if k - node.val in seen:
                return True
            seen.add(node.val)
            return search(node.left) or search(node.right)

        return search(root)
```

Why it works: while traversing the tree, store visited values and check whether the complement already exists.

#### Solution: [658. Find K Closest Elements](https://leetcode.com/problems/find-k-closest-elements/) - Medium

```python
class Solution:
    def findClosestElements(self, arr, k, x):
        left, right = 0, len(arr) - k

        while left < right:
            middle = (left + right) // 2
            if x - arr[middle] > arr[middle + k] - x:
                left = middle + 1
            else:
                right = middle

        return arr[left:left + k]
```

Why it works: binary search chooses the best starting position for a length-k window by comparing the two values that would be excluded.

#### Solution: [696. Count Binary Substrings](https://leetcode.com/problems/count-binary-substrings/) - Easy

```python
class Solution:
    def countBinarySubstrings(self, s):
        previous_group = 0
        current_group = 1
        answer = 0

        for i in range(1, len(s)):
            if s[i] == s[i - 1]:
                current_group += 1
            else:
                answer += min(previous_group, current_group)
                previous_group = current_group
                current_group = 1

        return answer + min(previous_group, current_group)
```

Why it works: each adjacent pair of equal-length groups contributes one valid substring per position in the smaller group.

#### Solution: [719. Find K-th Smallest Pair Distance](https://leetcode.com/problems/find-k-th-smallest-pair-distance/) - Hard

```python
class Solution:
    def smallestDistancePair(self, nums, k):
        nums.sort()
        left, right = 0, nums[-1] - nums[0]

        def count_at_most(distance):
            count = 0
            start = 0
            for end in range(len(nums)):
                while nums[end] - nums[start] > distance:
                    start += 1
                count += end - start
            return count

        while left < right:
            middle = (left + right) // 2
            if count_at_most(middle) >= k:
                right = middle
            else:
                left = middle + 1

        return left
```

Why it works: binary search the distance, while a sliding two-pointer window counts how many pairs have distance at most that value.

#### Solution: [723. Candy Crush](https://leetcode.com/problems/candy-crush/) - Medium

```python
class Solution:
    def candyCrush(self, board):
        rows, columns = len(board), len(board[0])
        changed = True

        while changed:
            changed = False
            crush = [[False] * columns for _ in range(rows)]

            for row in range(rows):
                for column in range(columns - 2):
                    value = abs(board[row][column])
                    if value and value == abs(board[row][column + 1]) == abs(board[row][column + 2]):
                        crush[row][column] = crush[row][column + 1] = crush[row][column + 2] = True

            for row in range(rows - 2):
                for column in range(columns):
                    value = abs(board[row][column])
                    if value and value == abs(board[row + 1][column]) == abs(board[row + 2][column]):
                        crush[row][column] = crush[row + 1][column] = crush[row + 2][column] = True

            for row in range(rows):
                for column in range(columns):
                    if crush[row][column]:
                        board[row][column] = 0
                        changed = True

            for column in range(columns):
                write = rows - 1
                for row in range(rows - 1, -1, -1):
                    if board[row][column]:
                        board[write][column] = board[row][column]
                        write -= 1
                while write >= 0:
                    board[write][column] = 0
                    write -= 1

        return board
```

Why it works: repeatedly mark every horizontal and vertical run of at least three, crush marked cells, and apply gravity until no cells change.

#### Solution: [777. Swap Adjacent in LR String](https://leetcode.com/problems/swap-adjacent-in-lr-string/) - Medium

```python
class Solution:
    def canTransform(self, start, result):
        if start.replace('X', '') != result.replace('X', ''):
            return False

        start_positions = [(character, index) for index, character in enumerate(start) if character != 'X']
        result_positions = [(character, index) for index, character in enumerate(result) if character != 'X']

        for (start_character, start_index), (result_character, result_index) in zip(start_positions, result_positions):
            if start_character != result_character:
                return False
            if start_character == 'L' and start_index < result_index:
                return False
            if start_character == 'R' and start_index > result_index:
                return False

        return True
```

Why it works: removing X preserves the order of L and R; L can only move left and R can only move right.

#### Solution: [786. K-th Smallest Prime Fraction](https://leetcode.com/problems/k-th-smallest-prime-fraction/) - Medium

```python
class Solution:
    def kthSmallestPrimeFraction(self, arr, k):
        left, right = 0.0, 1.0

        while True:
            middle = (left + right) / 2
            count = 0
            best_numerator = 0
            best_denominator = 1
            numerator_index = 0

            for denominator_index in range(1, len(arr)):
                while numerator_index < denominator_index and arr[numerator_index] / arr[denominator_index] < middle:
                    numerator_index += 1
                count += numerator_index
                if numerator_index and arr[numerator_index - 1] * best_denominator > best_numerator * arr[denominator_index]:
                    best_numerator = arr[numerator_index - 1]
                    best_denominator = arr[denominator_index]

            if count == k:
                return [best_numerator, best_denominator]
            if count < k:
                left = middle
            else:
                right = middle
```

Why it works: binary search the fraction value and use a pointer to count fractions no greater than the midpoint while tracking the largest such fraction.

#### Solution: [795. Number of Subarrays with Bounded Maximum](https://leetcode.com/problems/number-of-subarrays-with-bounded-maximum/) - Medium

```python
class Solution:
    def numSubarrayBoundedMax(self, nums, left, right):
        answer = 0
        valid_start = 0
        last_too_large = -1

        for index, value in enumerate(nums):
            if value > right:
                last_too_large = index
            if value >= left:
                valid_start = index
            answer += valid_start - last_too_large

        return answer
```

Why it works: for every ending index, valid subarrays must start after the last value above right and at or before the latest value inside the allowed range.

#### Solution: [809. Expressive Words](https://leetcode.com/problems/expressive-words/) - Medium

```python
class Solution:
    def expressiveWords(self, s, words):
        def is_stretchy(word):
            i = j = 0
            while i < len(s) and j < len(word):
                if s[i] != word[j]:
                    return False

                start_i, start_j = i, j
                while i < len(s) and s[i] == s[start_i]:
                    i += 1
                while j < len(word) and word[j] == word[start_j]:
                    j += 1

                source_count = i - start_i
                word_count = j - start_j
                if source_count < word_count or source_count < 3 and source_count != word_count:
                    return False

            return i == len(s) and j == len(word)

        return sum(is_stretchy(word) for word in words)
```

Why it works: compare matching runs in both strings; a source run may be longer only when it has at least three characters.

#### Solution: [821. Shortest Distance to a Character](https://leetcode.com/problems/shortest-distance-to-a-character/) - Easy

```python
class Solution:
    def shortestToChar(self, s, c):
        distances = [len(s)] * len(s)
        previous = -len(s)

        for i, character in enumerate(s):
            if character == c:
                previous = i
            distances[i] = i - previous

        previous = 2 * len(s)
        for i in range(len(s) - 1, -1, -1):
            if s[i] == c:
                previous = i
            distances[i] = min(distances[i], previous - i)

        return distances
```

Why it works: one pass records the distance to the closest target on the left, and a reverse pass corrects it using the closest target on the right.

#### Solution: [825. Friends Of Appropriate Ages](https://leetcode.com/problems/friends-of-appropriate-ages/) - Medium

```python
class Solution:
    def numFriendRequests(self, ages):
        counts = [0] * 121
        for age in ages:
            counts[age] += 1

        answer = 0
        for sender in range(15, 121):
            if counts[sender] == 0:
                continue
            for receiver in range(15, 121):
                if counts[receiver] == 0:
                    continue
                if receiver <= 0.5 * sender + 7 or receiver > sender or receiver > 100 and sender < 100:
                    continue
                answer += counts[sender] * (counts[receiver] - (sender == receiver))

        return answer
```

Why it works: age values are bounded, so count each sender/receiver age pair directly while applying the request rules.

#### Solution: [826. Most Profit Assigning Work](https://leetcode.com/problems/most-profit-assigning-work/) - Medium

```python
class Solution:
    def maxProfitAssignment(self, difficulty, profit, worker):
        jobs = sorted(zip(difficulty, profit))
        worker.sort()
        best_profit = 0
        job_index = 0
        answer = 0

        for ability in worker:
            while job_index < len(jobs) and jobs[job_index][0] <= ability:
                best_profit = max(best_profit, jobs[job_index][1])
                job_index += 1
            answer += best_profit

        return answer
```

Why it works: workers are processed from easiest to hardest, while a running maximum stores the best profit among jobs they can perform.

#### Solution: [832. Flipping an Image](https://leetcode.com/problems/flipping-an-image/) - Easy

```python
class Solution:
    def flipAndInvertImage(self, image):
        for row in image:
            left, right = 0, len(row) - 1
            while left <= right:
                row[left], row[right] = 1 - row[right], 1 - row[left]
                left += 1
                right -= 1
        return image
```

Why it works: reversing and inverting can be combined in one symmetric swap, so each row needs only one two-pointer pass.

#### Solution: [838. Push Dominoes](https://leetcode.com/problems/push-dominoes/) - Medium

```python
class Solution:
    def pushDominoes(self, dominoes):
        symbols = ['L'] + list(dominoes) + ['R']
        left = 0

        for right in range(1, len(symbols)):
            if symbols[right] == '.':
                continue

            distance = right - left - 1
            if symbols[left] == symbols[right]:
                for i in range(left + 1, right):
                    symbols[i] = symbols[left]
            elif symbols[left] == 'R' and symbols[right] == 'L':
                for i in range(distance // 2 + 1):
                    symbols[left + 1 + i] = 'R'
                    symbols[right - 1 - i] = 'L'
            elif symbols[left] == 'L' and symbols[right] == 'R':
                pass

            left = right

        return ''.join(symbols[1:-1])
```

Why it works: process the region between consecutive non-dot forces; the boundary directions determine whether the region fills, splits inward, or stays unchanged.

#### Solution: [844. Backspace String Compare](https://leetcode.com/problems/backspace-string-compare/) - Easy

```python
class Solution:
    def backspaceCompare(self, s, t):
        def next_valid_index(text, index):
            skips = 0
            while index >= 0:
                if text[index] == '#':
                    skips += 1
                elif skips:
                    skips -= 1
                else:
                    return index
                index -= 1
            return -1

        i, j = len(s) - 1, len(t) - 1
        while True:
            i = next_valid_index(s, i)
            j = next_valid_index(t, j)
            if i < 0 or j < 0:
                return i == j
            if s[i] != t[j]:
                return False
            i -= 1
            j -= 1
```

Why it works: scan backward and skip deleted characters, allowing both strings to be compared without building their expanded forms.

#### Solution: [845. Longest Mountain in Array](https://leetcode.com/problems/longest-mountain-in-array/) - Medium

```python
class Solution:
    def longestMountain(self, arr):
        best = 0
        i = 1

        while i < len(arr) - 1:
            if not (arr[i - 1] < arr[i] > arr[i + 1]):
                i += 1
                continue

            left = i - 1
            right = i + 1
            while left > 0 and arr[left - 1] < arr[left]:
                left -= 1
            while right + 1 < len(arr) and arr[right] > arr[right + 1]:
                right += 1
            best = max(best, right - left + 1)
            i = right

        return best
```

Why it works: identify each peak, expand through its increasing and decreasing slopes, and skip directly to the end of the mountain.

#### Solution: [870. Advantage Shuffle](https://leetcode.com/problems/advantage-shuffle/) - Medium

```python
class Solution:
    def advantageCount(self, nums1, nums2):
        nums1.sort()
        order = sorted(range(len(nums2)), key=lambda i: nums2[i])
        result = [0] * len(nums2)
        left, right = 0, len(nums1) - 1

        for index in reversed(order):
            if nums1[right] > nums2[index]:
                result[index] = nums1[right]
                right -= 1
            else:
                result[index] = nums1[left]
                left += 1

        return result
```

Why it works: use the largest available value to beat the largest opponent when possible; otherwise sacrifice the smallest value.

#### Solution: [881. Boats to Save People](https://leetcode.com/problems/boats-to-save-people/) - Medium

```python
class Solution:
    def numRescueBoats(self, people, limit):
        people.sort()
        left, right = 0, len(people) - 1
        boats = 0

        while left <= right:
            if people[left] + people[right] <= limit:
                left += 1
            right -= 1
            boats += 1

        return boats
```

Why it works: the heaviest remaining person must ride now; pair them with the lightest person only when the limit allows it.

#### Solution: [905. Sort Array By Parity](https://leetcode.com/problems/sort-array-by-parity/) - Easy

```python
class Solution:
    def sortArrayByParity(self, nums):
        left, right = 0, len(nums) - 1

        while left < right:
            while left < right and nums[left] % 2 == 0:
                left += 1
            while left < right and nums[right] % 2 == 1:
                right -= 1
            if left < right:
                nums[left], nums[right] = nums[right], nums[left]

        return nums
```

Why it works: move the left pointer past valid evens and the right pointer past valid odds, then swap misplaced values.

#### Solution: [917. Reverse Only Letters](https://leetcode.com/problems/reverse-only-letters/) - Easy

```python
class Solution:
    def reverseOnlyLetters(self, s):
        chars = list(s)
        left, right = 0, len(chars) - 1

        while left < right:
            while left < right and not chars[left].isalpha():
                left += 1
            while left < right and not chars[right].isalpha():
                right -= 1
            if left < right:
                chars[left], chars[right] = chars[right], chars[left]
                left += 1
                right -= 1

        return ''.join(chars)
```

Why it works: skip non-letters from both sides and swap only the letters, leaving symbols in their original positions.

#### Solution: [922. Sort Array By Parity II](https://leetcode.com/problems/sort-array-by-parity-ii/) - Easy

```python
class Solution:
    def sortArrayByParityII(self, nums):
        even = 0
        odd = 1

        while even < len(nums) and odd < len(nums):
            if nums[even] % 2 == 0:
                even += 2
            elif nums[odd] % 2 == 1:
                odd += 2
            else:
                nums[even], nums[odd] = nums[odd], nums[even]
                even += 2
                odd += 2

        return nums
```

Why it works: even indices require even values and odd indices require odd values, so advance valid pointers and swap mismatches.

#### Solution: [923. 3Sum With Multiplicity](https://leetcode.com/problems/3sum-with-multiplicity/) - Medium

```python
class Solution:
    def threeSumMulti(self, arr, target):
        arr.sort()
        answer = 0
        modulo = 10**9 + 7

        for i in range(len(arr)):
            left, right = i + 1, len(arr) - 1
            while left < right:
                total = arr[i] + arr[left] + arr[right]
                if total < target:
                    left += 1
                elif total > target:
                    right -= 1
                elif arr[left] != arr[right]:
                    left_count = 1
                    right_count = 1
                    while left + 1 < right and arr[left] == arr[left + 1]:
                        left += 1
                        left_count += 1
                    while right - 1 > left and arr[right] == arr[right - 1]:
                        right -= 1
                        right_count += 1
                    answer += left_count * right_count
                    left += 1
                    right -= 1
                else:
                    count = right - left + 1
                    answer += count * (count - 1) // 2
                    break

        return answer % modulo
```

Why it works: after sorting, equal-value runs can be counted in groups, avoiding enumeration of every duplicate triplet.

#### Solution: [925. Long Pressed Name](https://leetcode.com/problems/long-pressed-name/) - Easy

```python
class Solution:
    def isLongPressedName(self, name, typed):
        i = j = 0

        while j < len(typed):
            if i < len(name) and name[i] == typed[j]:
                i += 1
            elif j == 0 or typed[j] != typed[j - 1]:
                return False
            j += 1

        return i == len(name)
```

Why it works: each typed character must either match the next name character or be a repeat of the previous typed character.

#### Solution: [942. DI String Match](https://leetcode.com/problems/di-string-match/) - Easy

```python
class Solution:
    def diStringMatch(self, s):
        low, high = 0, len(s)
        result = []

        for character in s:
            if character == 'I':
                result.append(low)
                low += 1
            else:
                result.append(high)
                high -= 1

        result.append(low)
        return result
```

Why it works: use the smallest available number for an increase and the largest available number for a decrease, leaving the final number forced.

#### Solution: [948. Bag of Tokens](https://leetcode.com/problems/bag-of-tokens/) - Medium

```python
class Solution:
    def bagOfTokensScore(self, tokens, power):
        tokens.sort()
        left, right = 0, len(tokens) - 1
        score = 0
        best = 0

        while left <= right:
            if power >= tokens[left]:
                power -= tokens[left]
                left += 1
                score += 1
                best = max(best, score)
            elif score > 0:
                power += tokens[right]
                right -= 1
                score -= 1
            else:
                break

        return best
```

Why it works: play the cheapest available token face up to gain score, and when power is insufficient, trade the most expensive remaining token face down to regain as much power as possible.

Time complexity is O(n log n), and the extra space is O(1) aside from the sorting implementation.

#### Solution: [962. Maximum Width Ramp](https://leetcode.com/problems/maximum-width-ramp/) - Medium

```python
class Solution:
    def maxWidthRamp(self, nums):
        decreasing = []

        for index, value in enumerate(nums):
            if not decreasing or value < nums[decreasing[-1]]:
                decreasing.append(index)

        best = 0
        for right in range(len(nums) - 1, -1, -1):
            while decreasing and nums[decreasing[-1]] <= nums[right]:
                best = max(best, right - decreasing.pop())

        return best
```

Why it works: the stack stores only indices that introduce a new smaller prefix value. Scanning from the right lets each valid left endpoint pair with its farthest possible right endpoint before it is removed.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [969. Pancake Sorting](https://leetcode.com/problems/pancake-sorting/) - Medium

```python
class Solution:
    def pancakeSort(self, arr):
        flips = []

        for size in range(len(arr), 1, -1):
            largest_index = arr.index(size)
            if largest_index == size - 1:
                continue

            if largest_index != 0:
                flips.append(largest_index + 1)
                arr[:largest_index + 1] = reversed(arr[:largest_index + 1])

            flips.append(size)
            arr[:size] = reversed(arr[:size])

        return flips
```

Why it works: place the largest unsorted value at the front with one flip, then flip the whole unsorted prefix to move it into its final position.

Time complexity is O(n^2), and the extra space is O(n) for the returned flips.

#### Solution: [1023. Camelcase Matching](https://leetcode.com/problems/camelcase-matching/) - Medium

```python
class Solution:
    def camelMatch(self, queries, pattern):
        def matches(query):
            pattern_index = 0

            for character in query:
                if pattern_index < len(pattern) and character == pattern[pattern_index]:
                    pattern_index += 1
                elif character.isupper():
                    return False

            return pattern_index == len(pattern)

        return [matches(query) for query in queries]
```

Why it works: pattern characters must appear in order, while unmatched lowercase query characters are allowed and unmatched uppercase characters make the query invalid.

Time complexity is O(total query length), and the extra space is O(1) excluding the result.

#### Solution: [1048. Longest String Chain](https://leetcode.com/problems/longest-string-chain/) - Medium

```python
class Solution:
    def longestStrChain(self, words):
        words.sort(key=len)
        best_chain = {}
        answer = 0

        for word in words:
            best_chain[word] = 1
            for index in range(len(word)):
                predecessor = word[:index] + word[index + 1:]
                best_chain[word] = max(best_chain[word], best_chain.get(predecessor, 0) + 1)
            answer = max(answer, best_chain[word])

        return answer
```

Why it works: after sorting by length, every valid predecessor has already been processed. Removing one character from the current word enumerates all possible predecessors.

Time complexity is O(nL^2), and the extra space is O(nL), where L is the maximum word length.

#### Solution: [1055. Shortest Way to Form String](https://leetcode.com/problems/shortest-way-to-form-string/) - Medium

```python
class Solution:
    def shortestWay(self, source, target):
        if any(character not in source for character in target):
            return -1

        subsequences = 0
        target_index = 0

        while target_index < len(target):
            source_index = 0
            start = target_index

            while source_index < len(source) and target_index < len(target):
                if source[source_index] == target[target_index]:
                    target_index += 1
                source_index += 1

            if target_index == start:
                return -1
            subsequences += 1

        return subsequences
```

Why it works: each pass greedily consumes the longest possible subsequence of target from source, so no shorter collection of source passes can cover the same target prefix.

Time complexity is O(len(source) * len(target)) in the worst case, and the extra space is O(1).

#### Solution: [1089. Duplicate Zeros](https://leetcode.com/problems/duplicate-zeros/) - Easy

```python
class Solution:
    def duplicateZeros(self, arr):
        zeroes = arr.count(0)
        read = len(arr) - 1
        write = len(arr) + zeroes - 1

        while read >= 0:
            if write < len(arr):
                arr[write] = arr[read]
            write -= 1

            if arr[read] == 0:
                if write < len(arr):
                    arr[write] = 0
                write -= 1
            read -= 1
```

Why it works: count the zeros that will be duplicated, then write backward from the virtual expanded array so every original value is copied into its final position without overwriting unread values.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [1099. Two Sum Less Than K](https://leetcode.com/problems/two-sum-less-than-k/) - Easy

```python
class Solution:
    def twoSumLessThanK(self, nums, k):
        nums.sort()
        left, right = 0, len(nums) - 1
        best = -1

        while left < right:
            total = nums[left] + nums[right]
            if total < k:
                best = max(best, total)
                left += 1
            else:
                right -= 1

        return best
```

Why it works: when a pair is below k, increasing the left value is the only move that can improve its sum; otherwise, the right value is too large and must move left.

Time complexity is O(n log n), and the extra space is O(1) aside from the sorting implementation.

#### Solution: [1147. Longest Chunked Palindrome Decomposition](https://leetcode.com/problems/longest-chunked-palindrome-decomposition/) - Hard

```python
class Solution:
    def longestDecomposition(self, text):
        left_chunk = ''
        right_chunk = ''
        answer = 0

        for left, right in zip(text, reversed(text)):
            left_chunk += left
            right_chunk = right + right_chunk
            if left_chunk == right_chunk:
                answer += 2
                left_chunk = ''
                right_chunk = ''

        if left_chunk:
            answer += 1

        return answer
```

Why it works: greedily commit the smallest matching chunks from both ends. Matching earlier cannot reduce the best possible number of chunks because every decomposition must begin with a matching pair or a single middle chunk.

Time complexity is O(n^2) with immutable string concatenation, and the extra space is O(n).

#### Solution: [1163. Last Substring in Lexicographical Order](https://leetcode.com/problems/last-substring-in-lexicographical-order/) - Hard

```python
class Solution:
    def lastSubstring(self, s):
        first, candidate = 0, 1
        offset = 0

        while candidate + offset < len(s):
            if s[first + offset] == s[candidate + offset]:
                offset += 1
                continue

            if s[first + offset] < s[candidate + offset]:
                first += offset + 1
                if first >= candidate:
                    candidate = first + 1
            else:
                candidate += offset + 1
            offset = 0

        return s[first:]
```

Why it works: compare two candidate suffixes until they differ; the suffix with the larger character survives, and the skipped candidates cannot be lexicographically maximal after that comparison.

Time complexity is O(n), and the extra space is O(1) excluding the returned substring.

---

#### Solution: [1214. Two Sum BSTs](https://leetcode.com/problems/two-sum-bsts/) - Medium

```python
class Solution:
    def twoSumBSTs(self, root1, root2, target):
        def inorder(node, values):
            if not node:
                return
            inorder(node.left, values)
            values.append(node.val)
            inorder(node.right, values)

        first = []
        second = []
        inorder(root1, first)
        inorder(root2, second)

        left, right = 0, len(second) - 1
        while left < len(first) and right >= 0:
            total = first[left] + second[right]
            if total == target:
                return True
            if total < target:
                left += 1
            else:
                right -= 1

        return False
```

Why it works: inorder traversal produces two sorted value lists, so the pair sum can be searched with one pointer moving upward and the other moving downward.

Time complexity is O(n + m), and the extra space is O(n + m).

#### Solution: [1229. Meeting Scheduler](https://leetcode.com/problems/meeting-scheduler/) - Medium

```python
class Solution:
    def minAvailableDuration(self, slots1, slots2, duration):
        slots1.sort()
        slots2.sort()
        first = second = 0

        while first < len(slots1) and second < len(slots2):
            start = max(slots1[first][0], slots2[second][0])
            end = min(slots1[first][1], slots2[second][1])
            if end - start >= duration:
                return [start, start + duration]

            if slots1[first][1] < slots2[second][1]:
                first += 1
            else:
                second += 1

        return []
```

Why it works: compare the current intervals, use their overlap when it is long enough, and advance the interval that ends first because it cannot create a later overlap.

Time complexity is O(n log n + m log m), and the extra space is O(1) aside from sorting.

#### Solution: [1237. Find Positive Integer Solution for a Given Equation](https://leetcode.com/problems/find-positive-integer-solution-for-a-given-equation/) - Medium

```python
class Solution:
    def findSolution(self, customfunction, z):
        result = []
        x, y = 1, 1000

        while x <= 1000 and y >= 1:
            value = customfunction.f(x, y)
            if value == z:
                result.append([x, y])
                x += 1
                y -= 1
            elif value < z:
                x += 1
            else:
                y -= 1

        return result
```

Why it works: the function increases with x and decreases with y, so a value that is too small requires a larger x, while a value that is too large requires a smaller y.

Time complexity is O(1000), and the extra space is O(1) excluding the result.

#### Solution: [1265. Print Immutable Linked List in Reverse](https://leetcode.com/problems/print-immutable-linked-list-in-reverse/) - Medium

```python
class Solution:
    def printLinkedListInReverse(self, head):
        nodes = []
        node = head

        while node:
            nodes.append(node)
            node = node.getNext()

        for node in reversed(nodes):
            node.printValue()
```

Why it works: the immutable nodes cannot be rewired, so store their references during a forward traversal and call printValue in reverse order afterward.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [1332. Remove Palindromic Subsequences](https://leetcode.com/problems/remove-palindromic-subsequences/) - Easy

```python
class Solution:
    def removePalindromeSub(self, s):
        left, right = 0, len(s) - 1
        while left < right:
            if s[left] != s[right]:
                return 2
            left += 1
            right -= 1

        return 1 if s else 0
```

Why it works: if the string is already a palindrome, remove it in one subsequence. Otherwise, remove all a characters and then all b characters in two subsequences.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [1346. Check If N and Its Double Exist](https://leetcode.com/problems/check-if-n-and-its-double-exist/) - Easy

```python
class Solution:
    def checkIfExist(self, arr):
        seen = set()

        for value in arr:
            if value * 2 in seen or value % 2 == 0 and value // 2 in seen:
                return True
            seen.add(value)

        return False
```

Why it works: for each value, check whether its double or its half has already appeared. The set also handles zero correctly because a second zero is a valid match.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [1385. Find the Distance Value Between Two Arrays](https://leetcode.com/problems/find-the-distance-value-between-two-arrays/) - Easy

```python
class Solution:
    def findTheDistanceValue(self, arr1, arr2, d):
        arr1.sort()
        arr2.sort()
        pointer = 0
        answer = 0

        for value in arr1:
            while pointer < len(arr2) and arr2[pointer] < value - d:
                pointer += 1
            if pointer == len(arr2) or arr2[pointer] > value + d:
                answer += 1

        return answer
```

Why it works: after sorting both arrays, the pointer skips values that are too small. If the first remaining value is also above the allowed range, every value in arr2 is farther than d from the current value.

Time complexity is O(n log n + m log m), and the extra space is O(1) aside from sorting.

#### Solution: [1455. Check If a Word Occurs As a Prefix of Any Word in a Sentence](https://leetcode.com/problems/check-if-a-word-occurs-as-a-prefix-of-any-word-in-a-sentence/) - Easy

```python
class Solution:
    def isPrefixOfWord(self, sentence, searchWord):
        for index, word in enumerate(sentence.split(), start=1):
            if word.startswith(searchWord):
                return index

        return -1
```

Why it works: scan the words from left to right and return the first position whose beginning matches searchWord.

Time complexity is O(n), and the extra space is O(n) for the split words.

#### Solution: [1471. The k Strongest Values in an Array](https://leetcode.com/problems/the-k-strongest-values-in-an-array/) - Medium

```python
class Solution:
    def getStrongest(self, arr, k):
        arr.sort()
        median = arr[(len(arr) - 1) // 2]
        left, right = 0, len(arr) - 1
        result = []

        while len(result) < k:
            left_strength = abs(arr[left] - median)
            right_strength = abs(arr[right] - median)
            if right_strength >= left_strength:
                result.append(arr[right])
                right -= 1
            else:
                result.append(arr[left])
                left += 1

        return result
```

Why it works: after sorting, the strongest remaining value must be at one of the ends. Compare the two endpoint strengths and choose the right endpoint on ties because it has the larger value.

Time complexity is O(n log n), and the extra space is O(k) for the result.

#### Solution: [1498. Number of Subsequences That Satisfy the Given Sum Condition](https://leetcode.com/problems/number-of-subsequences-that-satisfy-the-given-sum-condition/) - Medium

```python
class Solution:
    def numSubseq(self, nums, target):
        modulo = 10**9 + 7
        nums.sort()
        powers = [1] * len(nums)

        for index in range(1, len(nums)):
            powers[index] = powers[index - 1] * 2 % modulo

        left, right = 0, len(nums) - 1
        answer = 0

        while left <= right:
            if nums[left] + nums[right] <= target:
                answer = (answer + powers[right - left]) % modulo
                left += 1
            else:
                right -= 1

        return answer
```

Why it works: when the smallest and largest selected values fit the target, every subset of the values between them can be chosen, giving 2^(right - left) valid subsequences.

Time complexity is O(n log n), and the extra space is O(n).

---

#### Solution: [1508. Range Sum of Sorted Subarray Sums](https://leetcode.com/problems/range-sum-of-sorted-subarray-sums/) - Medium

```python
class Solution:
    def rangeSum(self, nums, n, left, right):
        modulo = 10**9 + 7
        sums = []

        for start in range(n):
            current = 0
            for end in range(start, n):
                current += nums[end]
                sums.append(current)

        sums.sort()
        return sum(sums[left - 1:right]) % modulo
```

Why it works: generate every contiguous subarray sum, sort those sums, and add the requested rank range.

Time complexity is O(n^2 log n), and the extra space is O(n^2).

#### Solution: [1537. Get the Maximum Score](https://leetcode.com/problems/get-the-maximum-score/) - Hard

```python
class Solution:
    def maxSum(self, nums1, nums2):
        first = second = 0
        i = j = 0
        modulo = 10**9 + 7

        while i < len(nums1) or j < len(nums2):
            if j == len(nums2) or (i < len(nums1) and nums1[i] < nums2[j]):
                first += nums1[i]
                i += 1
            elif i == len(nums1) or nums2[j] < nums1[i]:
                second += nums2[j]
                j += 1
            else:
                best = max(first, second) + nums1[i]
                first = best
                second = best
                i += 1
                j += 1

        return max(first, second) % modulo
```

Why it works: accumulate the score along both paths, and at every common value choose the larger accumulated score before continuing from the shared point.

Time complexity is O(n + m), and the extra space is O(1).

#### Solution: [1570. Dot Product of Two Sparse Vectors](https://leetcode.com/problems/dot-product-of-two-sparse-vectors/) - Medium

```python
class SparseVector:
    def __init__(self, nums):
        self.values = [(index, value) for index, value in enumerate(nums) if value]

    def dotProduct(self, vec):
        first = second = 0
        result = 0

        while first < len(self.values) and second < len(vec.values):
            first_index, first_value = self.values[first]
            second_index, second_value = vec.values[second]
            if first_index == second_index:
                result += first_value * second_value
                first += 1
                second += 1
            elif first_index < second_index:
                first += 1
            else:
                second += 1

        return result
```

Why it works: store only non-zero entries, then advance the pointer with the smaller index until matching indices can be multiplied.

Building a vector takes O(n) time and O(k) space, where k is the number of non-zero values. A dot product takes O(k1 + k2) time.

#### Solution: [1574. Shortest Subarray to be Removed to Make Array Sorted](https://leetcode.com/problems/shortest-subarray-to-be-removed-to-make-array-sorted/) - Medium

```python
class Solution:
    def findLengthOfShortestSubarray(self, arr):
        n = len(arr)
        left = 0
        while left + 1 < n and arr[left] <= arr[left + 1]:
            left += 1

        if left == n - 1:
            return 0

        right = n - 1
        while right > 0 and arr[right - 1] <= arr[right]:
            right -= 1

        answer = min(n - left - 1, right)
        first, second = 0, right

        while first <= left and second < n:
            if arr[first] <= arr[second]:
                answer = min(answer, second - first - 1)
                first += 1
            else:
                second += 1

        return answer
```

Why it works: keep the longest sorted prefix and suffix, then use two pointers to find the smallest gap that connects a prefix value to a suffix value without breaking order.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [1577. Number of Ways Where Square of Number Is Equal to Product of Two Numbers](https://leetcode.com/problems/number-of-ways-where-square-of-number-is-equal-to-product-of-two-numbers/) - Medium

```python
class Solution:
    def numTriplets(self, nums1, nums2):
        def count(first, second):
            second.sort()
            answer = 0

            for value in first:
                target = value * value
                left, right = 0, len(second) - 1

                while left < right:
                    product = second[left] * second[right]
                    if product < target:
                        left += 1
                    elif product > target:
                        right -= 1
                    elif second[left] != second[right]:
                        left_count = 1
                        right_count = 1
                        while left + 1 < right and second[left] == second[left + 1]:
                            left += 1
                            left_count += 1
                        while right - 1 > left and second[right] == second[right - 1]:
                            right -= 1
                            right_count += 1
                        answer += left_count * right_count
                        left += 1
                        right -= 1
                    else:
                        count = right - left + 1
                        answer += count * (count - 1) // 2
                        break

            return answer

        return count(nums1, nums2) + count(nums2, nums1)
```

Why it works: for each possible squared value, sort the other array and use two pointers to count pairs whose product matches it, including duplicate multiplicities.

Time complexity is O(n^2 log n + m^2 log m), and the extra space is O(1) aside from sorting.

#### Solution: [1616. Split Two Strings to Make Palindrome](https://leetcode.com/problems/split-two-strings-to-make-palindrome/) - Medium

```python
class Solution:
    def checkPalindromeFormation(self, a, b):
        def is_palindrome(text, left, right):
            while left < right:
                if text[left] != text[right]:
                    return False
                left += 1
                right -= 1
            return True

        def can_form(first, second):
            left, right = 0, len(first) - 1
            while left < right and first[left] == second[right]:
                left += 1
                right -= 1
            return is_palindrome(first, left, right) or is_palindrome(second, left, right)

        return can_form(a, b) or can_form(b, a)
```

Why it works: compare the outer characters contributed by the two strings until the first mismatch, then the remaining unmatched section must be a palindrome in either source string.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [1634. Add Two Polynomials Represented as Linked Lists](https://leetcode.com/problems/add-two-polynomials-represented-as-linked-lists/) - Medium

```python
class Solution:
    def addPoly(self, poly1, poly2):
        dummy = PolyNode(0, 0)
        tail = dummy

        while poly1 or poly2:
            if not poly2 or (poly1 and poly1.power > poly2.power):
                coefficient = poly1.coefficient
                power = poly1.power
                poly1 = poly1.next
            elif not poly1 or poly2.power > poly1.power:
                coefficient = poly2.coefficient
                power = poly2.power
                poly2 = poly2.next
            else:
                coefficient = poly1.coefficient + poly2.coefficient
                power = poly1.power
                poly1 = poly1.next
                poly2 = poly2.next

            if coefficient:
                tail.next = PolyNode(coefficient, power)
                tail = tail.next

        return dummy.next
```

Why it works: the polynomial lists are sorted by descending power, so merge them like sorted lists and combine nodes with equal powers.

Time complexity is O(n + m), and the extra space is O(1) excluding the output list.

#### Solution: [1650. Lowest Common Ancestor of a Binary Tree III](https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree-iii/) - Medium

```python
class Solution:
    def lowestCommonAncestor(self, p, q):
        first, second = p, q

        while first != second:
            first = first.parent if first else q
            second = second.parent if second else p

        return first
```

Why it works: each pointer traverses one path and then the other path, so both cover the same total distance and meet at the first shared ancestor.

Time complexity is O(h), and the extra space is O(1).

#### Solution: [1679. Max Number of K-Sum Pairs](https://leetcode.com/problems/max-number-of-k-sum-pairs/) - Medium

#### Solution: [2149. Rearrange Array Elements by Sign](https://leetcode.com/problems/rearrange-array-elements-by-sign/) - Medium

```python
class Solution:
    def rearrangeArray(self, nums):
        result = [0] * len(nums)
        positive = 0
        negative = 1

        for value in nums:
            if value > 0:
                result[positive] = value
                positive += 2
            else:
                result[negative] = value
                negative += 2

        return result
```

Why it works: place positive values at even indices and negative values at odd indices, advancing each write pointer by two.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [2161. Partition Array According to Given Pivot](https://leetcode.com/problems/partition-array-according-to-given-pivot/) - Medium

```python
class Solution:
    def pivotArray(self, nums, pivot):
        result = []
        for value in nums:
            if value < pivot:
                result.append(value)
        for value in nums:
            if value == pivot:
                result.append(value)
        for value in nums:
            if value > pivot:
                result.append(value)
        return result
```

Why it works: three stable passes preserve the original order within the less-than, equal-to, and greater-than partitions.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [2193. Minimum Number of Moves to Make Palindrome](https://leetcode.com/problems/minimum-number-of-moves-to-make-palindrome/) - Hard

```python
class Solution:
    def minMovesToMakePalindrome(self, s):
        characters = list(s)
        left, right = 0, len(characters) - 1
        moves = 0

        while left < right:
            if characters[left] == characters[right]:
                left += 1
                right -= 1
                continue

            match = right
            while match > left and characters[match] != characters[left]:
                match -= 1

            if match == left:
                characters[left], characters[left + 1] = characters[left + 1], characters[left]
                moves += 1
            else:
                while match < right:
                    characters[match], characters[match + 1] = characters[match + 1], characters[match]
                    match += 1
                    moves += 1
                left += 1
                right -= 1

        return moves
```

Why it works: match the left character with the nearest equal character on the right and bubble it into place. If it has no partner, it is the middle character and moves one step toward the center.

Time complexity is O(n^2), and the extra space is O(n).

#### Solution: [2200. Find All K-Distant Indices in an Array](https://leetcode.com/problems/find-all-k-distant-indices-in-an-array/) - Easy

```python
class Solution:
    def findKDistantIndices(self, nums, key, k):
        key_indices = [index for index, value in enumerate(nums) if value == key]
        result = []
        pointer = 0

        for index in range(len(nums)):
            while pointer < len(key_indices) and key_indices[pointer] < index - k:
                pointer += 1
            if pointer < len(key_indices) and key_indices[pointer] <= index + k:
                result.append(index)

        return result
```

Why it works: the key indices are sorted, so discard keys too far left and check whether the next key is within k of the current index.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [2234. Maximum Total Beauty of the Gardens](https://leetcode.com/problems/maximum-total-beauty-of-the-gardens/) - Hard

```python
from bisect import bisect_left

class Solution:
    def maximumBeauty(self, flowers, newFlowers, target, full, partial):
        flowers.sort()
        flowers = [min(value, target) for value in flowers]
        prefix = [0]
        for value in flowers:
            prefix.append(prefix[-1] + value)

        answer = 0
        n = len(flowers)
        remaining_flowers = newFlowers

        for complete in range(n + 1):
            if complete:
                index = n - complete
                remaining_flowers -= target - flowers[index]
                if remaining_flowers < 0:
                    break

            remaining = n - complete
            if remaining == 0:
                answer = max(answer, complete * full)
                continue

            low, high = 0, target - 1
            while low < high:
                middle = (low + high + 1) // 2
                count = bisect_left(flowers, middle, 0, remaining)
                cost = middle * count - prefix[count]
                if cost <= remaining_flowers:
                    low = middle
                else:
                    high = middle - 1

            answer = max(answer, complete * full + low * partial)

        return answer
```

Why it works: choose how many gardens to complete from the largest upward, then binary search the highest possible minimum for the remaining gardens using prefix sums.

Time complexity is O(n log n + n log target log n), and the extra space is O(n).

---

```python
class Solution:
These 95 problems were present in the attachment but do not yet have a direct solution above. They are listed here as the next solution backlog.
        nums.sort()
        left, right = 0, len(nums) - 1
        operations = 0

        while left < right:
            total = nums[left] + nums[right]
            if total == k:
                operations += 1
                left += 1
                right -= 1
            elif total < k:
                left += 1
            else:
                right -= 1

        return operations
```

Why it works: after sorting, a sum that is too small requires a larger left value, while a sum that is too large requires a smaller right value. Equal sums consume both values as one operation.

Time complexity is O(n log n), and the extra space is O(1) aside from sorting.

#### Solution: [1697. Checking Existence of Edge Length Limited Paths](https://leetcode.com/problems/checking-existence-of-edge-length-limited-paths/) - Hard

```python
class Solution:
    def distanceLimitedPathsExist(self, n, edgeList, queries):
        parent = list(range(n))
        rank = [0] * n

        def find(node):
            while parent[node] != node:
                parent[node] = parent[parent[node]]
                node = parent[node]
            return node

        def union(first, second):
            first = find(first)
            second = find(second)
            if first == second:
                return
            if rank[first] < rank[second]:
                first, second = second, first
            parent[second] = first
            if rank[first] == rank[second]:
                rank[first] += 1

        edgeList.sort(key=lambda edge: edge[2])
        ordered_queries = sorted(enumerate(queries), key=lambda item: item[1][2])
        answer = [False] * len(queries)
        edge_index = 0

        for query_index, (start, end, limit) in ordered_queries:
            while edge_index < len(edgeList) and edgeList[edge_index][2] < limit:
                union(edgeList[edge_index][0], edgeList[edge_index][1])
                edge_index += 1
            answer[query_index] = find(start) == find(end)

        return answer
```

Why it works: process edges and queries in increasing weight order. Before answering a query, union every edge whose weight is below its limit; connectivity in the resulting DSU is exactly the required path condition.

Time complexity is O((E + Q) log(E + Q)), and the extra space is O(n + Q).


#### Solution: [1712. Ways to Split Array Into Three Subarrays](https://leetcode.com/problems/ways-to-split-array-into-three-subarrays/) - Medium

```python
class Solution:
    def waysToSplit(self, nums):
        modulo = 10**9 + 7
        prefix = [0]
        for value in nums:
            prefix.append(prefix[-1] + value)

        total = prefix[-1]
        first = second = 1
        answer = 0

        for left_end in range(len(nums) - 2):
            left_sum = prefix[left_end + 1]
            first = max(first, left_end + 1)
            while first < len(nums) - 1 and prefix[first + 1] - left_sum < left_sum:
                first += 1

            second = max(second, first)
            while second < len(nums) - 1 and prefix[second + 1] - left_sum <= total - prefix[second + 1]:
                second += 1

            answer += second - first

        return answer % modulo
```

Why it works: prefix sums make each partition sum available in O(1), while two monotonic pointers track the first and last valid end of the middle subarray for each left split.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [1721. Swapping Nodes in a Linked List](https://leetcode.com/problems/swapping-nodes-in-a-linked-list/) - Medium

```python
class Solution:
    def swapNodes(self, head, k):
        first = head
        for _ in range(k - 1):
            first = first.next

        fast = first
        second = head
        while fast.next:
            fast = fast.next
            second = second.next

        first.val, second.val = second.val, first.val
        return head
```

Why it works: place one pointer on the kth node from the start, then move a second pointer as the first pointer reaches the end so it lands on the kth node from the end.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [1750. Minimum Length of String After Deleting Similar Ends](https://leetcode.com/problems/minimum-length-of-string-after-deleting-similar-ends/) - Medium

```python
class Solution:
    def minimumLength(self, s):
        left, right = 0, len(s) - 1

        while left < right and s[left] == s[right]:
            character = s[left]
            while left <= right and s[left] == character:
                left += 1
            while left <= right and s[right] == character:
                right -= 1

        return right - left + 1
```

Why it works: when both ends match, every consecutive copy of that character can be removed from both sides. Stop at the first unmatched pair or when the pointers cross.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [1754. Largest Merge Of Two Strings](https://leetcode.com/problems/largest-merge-of-two-strings/) - Medium

```python
class Solution:
    def largestMerge(self, word1, word2):
        first = second = 0
        result = []

        while first < len(word1) or second < len(word2):
            if word1[first:] >= word2[second:]:
                result.append(word1[first])
                first += 1
            else:
                result.append(word2[second])
                second += 1

        return ''.join(result)
```

Why it works: choose the first character from the lexicographically larger remaining suffix. That choice leaves the largest possible merge prefix at every step.

Time complexity is O((n + m)^2) with suffix comparisons, and the extra space is O(n + m).

#### Solution: [1755. Closest Subsequence Sum](https://leetcode.com/problems/closest-subsequence-sum/) - Hard

```python
from bisect import bisect_left

class Solution:
    def minAbsDifference(self, nums, goal):
        def subset_sums(values):
            sums = [0]
            for value in values:
                sums += [current + value for current in sums]
            return sums

        middle = len(nums) // 2
        first = subset_sums(nums[:middle])
        second = sorted(subset_sums(nums[middle:]))
        answer = abs(goal)

        for value in first:
            target = goal - value
            index = bisect_left(second, target)
            if index < len(second):
                answer = min(answer, abs(value + second[index] - goal))
            if index > 0:
                answer = min(answer, abs(value + second[index - 1] - goal))

        return answer
```

Why it works: divide the array into two halves, enumerate each half's subset sums, and use binary search to find the closest complementary sum.

Time complexity is O(2^(n/2) log 2^(n/2)), and the extra space is O(2^(n/2)).

#### Solution: [1764. Form Array by Concatenating Subarrays of Another Array](https://leetcode.com/problems/form-array-by-concatenating-subarrays-of-another-array/) - Medium

```python
class Solution:
    def canChoose(self, groups, nums):
        start = 0

        for group in groups:
            found = False
            while start + len(group) <= len(nums):
                if nums[start:start + len(group)] == group:
                    start += len(group)
                    found = True
                    break
                start += 1

            if not found:
                return False

        return True
```

Why it works: search for each group only after the previous group, and advance past the first matching occurrence so groups cannot overlap.

Time complexity is O(nm) in the worst case, and the extra space is O(1) excluding slices.

#### Solution: [1768. Merge Strings Alternately](https://leetcode.com/problems/merge-strings-alternately/) - Easy

```python
class Solution:
    def mergeAlternately(self, word1, word2):
        result = []
        left = right = 0

        while left < len(word1) or right < len(word2):
            if left < len(word1):
                result.append(word1[left])
                left += 1
            if right < len(word2):
                result.append(word2[right])
                right += 1

        return ''.join(result)
```

Why it works: two pointers consume one character from each string whenever available, naturally appending any leftover suffix.

Time complexity is O(n + m), and the extra space is O(n + m).

#### Solution: [1782. Count Pairs Of Nodes](https://leetcode.com/problems/count-pairs-of-nodes/) - Hard

```python
class Solution:
    def countPairs(self, n, edges, queries):
        degree = [0] * (n + 1)
        shared = {}

        for first, second in edges:
            degree[first] += 1
            degree[second] += 1
            if first > second:
                first, second = second, first
            shared[(first, second)] = shared.get((first, second), 0) + 1

        sorted_degrees = sorted(degree[1:])
        answer = []

        for query in queries:
            left, right = 0, n - 1
            count = 0
            while left < right:
                if sorted_degrees[left] + sorted_degrees[right] > query:
                    count += right - left
                    right -= 1
                else:
                    left += 1

            for (first, second), edge_count in shared.items():
                if degree[first] + degree[second] > query and degree[first] + degree[second] - edge_count <= query:
                    count -= 1

            answer.append(count)

        return answer
```

Why it works: sorted degrees count candidate pairs by degree sum, then duplicate edges are subtracted when their shared-edge count lowers the true pair count below the query threshold.

Time complexity is O((E + n) log n + QE), and the extra space is O(n + E).

#### Solution: [1793. Maximum Score of a Good Subarray](https://leetcode.com/problems/maximum-score-of-a-good-subarray/) - Hard

```python
class Solution:
    def maximumScore(self, nums, k):
        left = right = k
        minimum = nums[k]
        answer = minimum

        while left > 0 or right < len(nums) - 1:
            if left == 0:
                right += 1
            elif right == len(nums) - 1:
                left -= 1
            elif nums[left - 1] >= nums[right + 1]:
                left -= 1
            else:
                right += 1

            minimum = min(minimum, nums[left], nums[right])
            answer = max(answer, minimum * (right - left + 1))

        return answer
```

Why it works: expand the window containing k toward the larger neighboring value, preserving the best possible minimum for each width and updating the score after every expansion.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [1813. Sentence Similarity III](https://leetcode.com/problems/sentence-similarity-iii/) - Medium

```python
class Solution:
    def areSentencesSimilar(self, sentence1, sentence2):
        first = sentence1.split()
        second = sentence2.split()

        if len(first) > len(second):
            first, second = second, first

        left = 0
        while left < len(first) and first[left] == second[left]:
            left += 1

        right = 0
        while right < len(first) - left and first[-1 - right] == second[-1 - right]:
            right += 1

        return left + right == len(first)
```

Why it works: after aligning the common prefix and suffix, the shorter sentence is similar exactly when those two matching regions cover it completely.

Time complexity is O(n + m), and the extra space is O(n + m) for the split words.

---

#### Solution: [1826. Faulty Sensor](https://leetcode.com/problems/faulty-sensor/) - Easy

```python
class Solution:
    def badSensor(self, sensor1, sensor2):
        mismatch = 0
        while mismatch < len(sensor1) and sensor1[mismatch] == sensor2[mismatch]:
            mismatch += 1

        if mismatch == len(sensor1):
            return -1

        first_is_faulty = sensor1[mismatch + 1:] == sensor2[mismatch:-1]
        return 1 if first_is_faulty else 2
```

Why it works: before the first mismatch both sensors agree. The faulty sensor must have one extra reading, so removing the next reading from sensor1 is the only candidate that can restore the remaining alignment.

Time complexity is O(n), and the extra space is O(n) for the slices.

#### Solution: [1842. Next Palindrome Using Same Digits](https://leetcode.com/problems/next-palindrome-using-same-digits/) - Hard

```python
class Solution:
    def nextPalindrome(self, num):
        half = list(num[:(len(num) + 1) // 2])
        index = len(half) - 2

        while index >= 0 and half[index] >= half[index + 1]:
            index -= 1
        if index < 0:
            return ''

        swap = len(half) - 1
        while half[swap] <= half[index]:
            swap -= 1
        half[index], half[swap] = half[swap], half[index]
        half[index + 1:] = reversed(half[index + 1:])

        if len(num) % 2:
            return ''.join(half + half[-2::-1])
        return ''.join(half + half[::-1])
```

Why it works: the first half determines the palindrome, so find its next permutation and mirror it. If the half has no next permutation, the requested larger palindrome does not exist.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [1850. Minimum Adjacent Swaps to Reach the Kth Smallest Number](https://leetcode.com/problems/minimum-adjacent-swaps-to-reach-the-kth-smallest-number/) - Medium

```python
class Solution:
    def getMinSwaps(self, num, k):
        target = list(num)

        for _ in range(k):
            index = len(target) - 2
            while target[index] >= target[index + 1]:
                index -= 1
            swap = len(target) - 1
            while target[swap] <= target[index]:
                swap -= 1
            target[index], target[swap] = target[swap], target[index]
            target[index + 1:] = reversed(target[index + 1:])

        current = list(num)
        swaps = 0
        for index in range(len(current)):
            if current[index] == target[index]:
                continue
            next_index = index + 1
            while current[next_index] != target[index]:
                next_index += 1
            while next_index > index:
                current[next_index], current[next_index - 1] = current[next_index - 1], current[next_index]
                next_index -= 1
                swaps += 1

        return swaps
```

Why it works: generate the kth lexicographic permutation, then greedily move each required digit left to its target position using the minimum adjacent swaps.

Time complexity is O(kn + n^2), and the extra space is O(n).

#### Solution: [1855. Maximum Distance Between a Pair of Values](https://leetcode.com/problems/maximum-distance-between-a-pair-of-values/) - Medium

```python
class Solution:
    def maxDistance(self, nums1, nums2):
        first = second = 0
        answer = 0

        while first < len(nums1) and second < len(nums2):
            if nums1[first] <= nums2[second]:
                answer = max(answer, second - first)
                second += 1
            else:
                first += 1

        return answer
```

Why it works: both arrays are non-increasing. When the current pair is valid, moving the second pointer can only increase the distance; when it is invalid, only a smaller nums1 value can help.

Time complexity is O(n + m), and the extra space is O(1).

#### Solution: [1861. Rotating the Box](https://leetcode.com/problems/rotating-the-box/) - Medium

```python
class Solution:
    def rotateTheBox(self, box):
        for row in box:
            write = len(row) - 1
            for index in range(len(row) - 1, -1, -1):
                if row[index] == '*':
                    write = index - 1
                elif row[index] == '#':
                    row[index] = '.'
                    row[write] = '#'
                    write -= 1

        return [list(row) for row in zip(*box[::-1])]
```

Why it works: compact stones toward the right within each obstacle-separated row, then transpose the box after reversing its rows to rotate it clockwise.

Time complexity is O(mn), and the extra space is O(mn) for the rotated result.

---

#### Solution: [1868. Product of Two Run-Length Encoded Arrays](https://leetcode.com/problems/product-of-two-run-length-encoded-arrays/) - Medium

```python
class Solution:
    def findRLEArray(self, encoded1, encoded2):
        first = second = 0
        result = []

        while first < len(encoded1) and second < len(encoded2):
            value = encoded1[first][0] * encoded2[second][0]
            count = min(encoded1[first][1], encoded2[second][1])

            if result and result[-1][0] == value:
                result[-1][1] += count
            else:
                result.append([value, count])

            encoded1[first][1] -= count
            encoded2[second][1] -= count
            if encoded1[first][1] == 0:
                first += 1
            if encoded2[second][1] == 0:
                second += 1

        return result
```

Why it works: the current runs overlap for the smaller remaining count. Consume that overlap, multiply the values, and advance whichever run ends first.

Time complexity is O(n + m), and the extra space is O(n + m) for the result.

#### Solution: [1877. Minimize Maximum Pair Sum in Array](https://leetcode.com/problems/minimize-maximum-pair-sum-in-array/) - Medium

```python
class Solution:
    def minPairSum(self, nums):
        nums.sort()
        left, right = 0, len(nums) - 1
        answer = 0

        while left < right:
            answer = max(answer, nums[left] + nums[right])
            left += 1
            right -= 1

        return answer
```

Why it works: pairing the smallest value with the largest balances every pair as evenly as possible, minimizing the largest pair sum.

Time complexity is O(n log n), and the extra space is O(1) aside from sorting.

#### Solution: [1885. Count Pairs in Two Arrays](https://leetcode.com/problems/count-pairs-in-two-arrays/) - Medium

```python
class Solution:
    def countPairs(self, nums1, nums2):
        differences = [first - second for first, second in zip(nums1, nums2)]
        differences.sort()
        left, right = 0, len(differences) - 1
        answer = 0

        while left < right:
            if differences[left] + differences[right] > 0:
                answer += right - left
                right -= 1
            else:
                left += 1

        return answer
```

Why it works: the required inequality becomes diff[i] + diff[j] > 0. After sorting, a valid right endpoint makes every index between left and right valid as well.

Time complexity is O(n log n), and the extra space is O(n).

#### Solution: [1898. Maximum Number of Removable Characters](https://leetcode.com/problems/maximum-number-of-removable-characters/) - Medium

```python
class Solution:
    def maximumRemovals(self, s, p, removable):
        def is_subsequence(count):
            removed = set(removable[:count])
            pattern_index = 0

            for index, character in enumerate(s):
                if index in removed:
                    continue
                if pattern_index < len(p) and character == p[pattern_index]:
                    pattern_index += 1

            return pattern_index == len(p)

        left, right = 0, len(removable)
        while left < right:
            middle = (left + right + 1) // 2
            if is_subsequence(middle):
                left = middle
            else:
                right = middle - 1

        return left
```

Why it works: removing more characters can only make subsequence matching harder, so binary search the largest removable prefix that still preserves p as a subsequence.

Time complexity is O((n + k) log k), and the extra space is O(k).

#### Solution: [1960. Maximum Product of the Length of Two Palindromic Substrings](https://leetcode.com/problems/maximum-product-of-the-length-of-two-palindromic-substrings/) - Hard

```python
class Solution:
    def maxProduct(self, s):
        n = len(s)
        odd = [0] * n
        even = [0] * n
        left = 0
        right = -1

        for index in range(n):
            radius = 1 if index > right else min(odd[left + right - index], right - index + 1)
            while index - radius >= 0 and index + radius < n and s[index - radius] == s[index + radius]:
                radius += 1
            odd[index] = radius
            if index + radius - 1 > right:
                left = index - radius + 1
                right = index + radius - 1

        left = 0
        right = -1
        for index in range(n):
            radius = 0 if index > right else min(even[left + right - index + 1], right - index + 1)
            while index - radius - 1 >= 0 and index + radius < n and s[index - radius - 1] == s[index + radius]:
                radius += 1
            even[index] = radius
            if index + radius - 1 > right:
                left = index - radius
                right = index + radius - 1

        ending = [0] * n
        starting = [0] * n
        for index, radius in enumerate(odd):
            start = index - radius + 1
            end = index + radius - 1
            length = 2 * radius - 1
            ending[end] = max(ending[end], length)
            starting[start] = max(starting[start], length)

        for index, radius in enumerate(even):
            if radius == 0:
                continue
            start = index - radius
            end = index + radius - 1
            length = 2 * radius
            ending[end] = max(ending[end], length)
            starting[start] = max(starting[start], length)

        for index in range(1, n):
            ending[index] = max(ending[index], ending[index - 1])
        for index in range(n - 2, -1, -1):
            starting[index] = max(starting[index], starting[index + 1])

        return max(ending[index] * starting[index + 1] for index in range(n - 1))
```

Why it works: Manacher-style radii identify every palindrome in linear time. Store the best palindrome ending at each position and starting at each position, then maximize the product across every split.

Time complexity is O(n), and the extra space is O(n).

---

#### Solution: [1961. Check If String Is a Prefix of Array](https://leetcode.com/problems/check-if-string-is-a-prefix-of-array/) - Easy

```python
class Solution:
    def isPrefixString(self, s, words):
        index = 0

        for word in words:
            if s[index:index + len(word)] != word:
                return False
            index += len(word)
            if index == len(s):
                return True
            if index > len(s):
                return False

        return False
```

Why it works: consume words from the beginning of s and stop as soon as their concatenation reaches the full string.

Time complexity is O(n), and the extra space is O(1) excluding slices.

#### Solution: [1963. Minimum Number of Swaps to Make the String Balanced](https://leetcode.com/problems/minimum-number-of-swaps-to-make-the-string-balanced/) - Medium

```python
class Solution:
    def minSwaps(self, s):
        balance = 0
        swaps = 0

        for character in s:
            balance += 1 if character == '[' else -1
            if balance < 0:
                swaps += 1
                balance = 1

        return swaps
```

Why it works: whenever a closing bracket makes the prefix invalid, swap in a later opening bracket. Each such correction fixes the earliest possible imbalance.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [1989. Maximum Number of People That Can Be Caught in Tag](https://leetcode.com/problems/maximum-number-of-people-that-can-be-caught-in-tag/) - Medium

```python
class Solution:
    def catchMaximumAmountofPeople(self, team, dist):
        catchers = [index for index, value in enumerate(team) if value == 1]
        players = [index for index, value in enumerate(team) if value == 0]
        catcher = player = 0
        answer = 0

        while catcher < len(catchers) and player < len(players):
            if players[player] < catchers[catcher] - dist:
                player += 1
            elif catchers[catcher] < players[player] - dist:
                catcher += 1
            else:
                answer += 1
                catcher += 1
                player += 1

        return answer
```

Why it works: both position lists are sorted. Discard positions that are too far apart, and greedily match the first catcher and player that can reach each other.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [2000. Reverse Prefix of Word](https://leetcode.com/problems/reverse-prefix-of-word/) - Easy

```python
class Solution:
    def reversePrefix(self, word, ch):
        end = word.find(ch)
        if end == -1:
            return word
        return word[:end + 1][::-1] + word[end + 1:]
```

Why it works: reverse exactly through the first occurrence of ch and leave the remaining suffix unchanged.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [2014. Longest Subsequence Repeated k Times](https://leetcode.com/problems/longest-subsequence-repeated-k-times/) - Hard

```python
from collections import deque, Counter

class Solution:
    def longestSubsequenceRepeatedK(self, s, k):
        counts = Counter(s)
        alphabet = sorted((character for character, count in counts.items() if count >= k), reverse=True)

        def is_subsequence(candidate):
            index = 0
            repeated = candidate * k
            for character in s:
                if index < len(repeated) and character == repeated[index]:
                    index += 1
            return index == len(repeated)

        queue = deque([''])
        answer = ''
        while queue:
            candidate = queue.popleft()
            if len(candidate) > len(answer) or len(candidate) == len(answer) and candidate > answer:
                answer = candidate

            for character in alphabet:
                next_candidate = candidate + character
                if is_subsequence(next_candidate):
                    queue.append(next_candidate)

        return answer
```

Why it works: only characters appearing at least k times can be used. Breadth-first construction tests every viable candidate and keeps the longest, lexicographically largest repeated subsequence.

Time complexity depends on the bounded candidate space and subsequence checks; each check is O(n), with O(n) auxiliary space for the queue.

#### Solution: [2035. Partition Array Into Two Arrays to Minimize Sum Difference](https://leetcode.com/problems/partition-array-into-two-arrays-to-minimize-sum-difference/) - Hard

```python
from bisect import bisect_left

class Solution:
    def minimumDifference(self, nums):
        half = len(nums) // 2
        total = sum(nums)

        def subset_sums(values):
            result = [[] for _ in range(len(values) + 1)]
            for mask in range(1 << len(values)):
                count = 0
                current = 0
                for index, value in enumerate(values):
                    if mask >> index & 1:
                        count += 1
                        current += value
                result[count].append(current)
            return result

        first = subset_sums(nums[:half])
        second = subset_sums(nums[half:])
        answer = float('inf')

        for values in second:
            values.sort()
        for count, sums in enumerate(first):
            needed = half - count
            for value in sums:
                target = total / 2 - value
                index = bisect_left(second[needed], target)
                for candidate in (index - 1, index):
                    if 0 <= candidate < len(second[needed]):
                        chosen = value + second[needed][candidate]
                        answer = min(answer, abs(total - 2 * chosen))

        return answer
```

Why it works: enumerate subset sums by element count for both halves, then binary search the complementary sum needed to make one partition as close as possible to half the total.

Time complexity is O(n 2^(n/2)), and the extra space is O(2^(n/2)).

#### Solution: [2046. Sort Linked List Already Sorted Using Absolute Values](https://leetcode.com/problems/sort-linked-list-already-sorted-using-absolute-values/) - Medium

```python
class Solution:
    def sortLinkedList(self, head):
        negative = None
        current = head

        while current and current.val < 0:
            next_node = current.next
            current.next = negative
            negative = current
            current = next_node

        positive = current
        dummy = ListNode(0)
        tail = dummy

        while negative or positive:
            if not positive or negative and negative.val <= positive.val:
                tail.next = negative
                negative = negative.next
            else:
                tail.next = positive
                positive = positive.next
            tail = tail.next

        tail.next = None
        return dummy.next
```

Why it works: the negative prefix becomes sorted after reversal, while the non-negative suffix is already sorted. Merge those two sorted lists.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [2071. Maximum Number of Tasks You Can Assign](https://leetcode.com/problems/maximum-number-of-tasks-you-can-assign/) - Hard

```python
from collections import deque

class Solution:
    def maxTaskAssign(self, tasks, workers, pills, strength):
        tasks.sort()
        workers.sort()

        def can_assign(count):
            available = deque()
            task_index = 0
            pills_left = pills

            for worker in workers[-count:]:
                while task_index < count and tasks[task_index] <= worker + strength:
                    available.append(tasks[task_index])
                    task_index += 1

                if not available:
                    return False
                if available[0] <= worker:
                    available.popleft()
                elif pills_left:
                    pills_left -= 1
                    available.pop()
                else:
                    return False

            return True

        left, right = 0, min(len(tasks), len(workers))
        while left < right:
            middle = (left + right + 1) // 2
            if can_assign(middle):
                left = middle
            else:
                right = middle - 1

        return left
```

Why it works: binary search the number of tasks. For a candidate count, process the strongest workers from weakest to strongest, using a pill on the hardest available task only when necessary.

Time complexity is O((n + m) log min(n, m)), and the extra space is O(n).

#### Solution: [2095. Delete the Middle Node of a Linked List](https://leetcode.com/problems/delete-the-middle-node-of-a-linked-list/) - Medium

```python
class Solution:
    def deleteMiddle(self, head):
        if not head or not head.next:
            return None

        previous = None
        slow = fast = head
        while fast and fast.next:
            previous = slow
            slow = slow.next
            fast = fast.next.next

        previous.next = slow.next
        return head
```

Why it works: the fast pointer moves twice as quickly, so when it reaches the end, slow points to the middle node and previous can unlink it.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [2105. Watering Plants II](https://leetcode.com/problems/watering-plants-ii/) - Medium

```python
class Solution:
    def minimumRefill(self, plants, capacityA, capacityB):
        left, right = 0, len(plants) - 1
        water_left, water_right = capacityA, capacityB
        refills = 0

        while left < right:
            if water_left < plants[left]:
                refills += 1
                water_left = capacityA
            water_left -= plants[left]
            left += 1

            if water_right < plants[right]:
                refills += 1
                water_right = capacityB
            water_right -= plants[right]
            right -= 1

        if left == right and max(water_left, water_right) < plants[left]:
            refills += 1

        return refills
```

Why it works: two pointers simulate Alice and Bob watering from opposite ends. On the final plant, the person with more remaining water handles it if possible.

Time complexity is O(n), and the extra space is O(1).

---

#### Solution: [2108. Find First Palindromic String in the Array](https://leetcode.com/problems/find-first-palindromic-string-in-the-array/) - Easy

```python
class Solution:
    def firstPalindrome(self, words):
        for word in words:
            if word == word[::-1]:
                return word
        return ''
```

Why it works: scan the words in order and return the first word that equals its reverse.

Time complexity is O(nL), and the extra space is O(L), where L is the maximum word length.

#### Solution: [2109. Adding Spaces to a String](https://leetcode.com/problems/adding-spaces-to-a-string/) - Medium

```python
class Solution:
    def addSpaces(self, s, spaces):
        result = []
        space_index = 0

        for index, character in enumerate(s):
            if space_index < len(spaces) and index == spaces[space_index]:
                result.append(' ')
                space_index += 1
            result.append(character)

        return ''.join(result)
```

Why it works: a pointer tracks the next insertion position while a single pass copies the original characters in order.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [2110. Number of Smooth Descent Periods of a Stock](https://leetcode.com/problems/number-of-smooth-descent-periods-of-a-stock/) - Medium

```python
class Solution:
    def getDescentPeriods(self, prices):
        answer = 0
        length = 0

        for index, price in enumerate(prices):
            if index > 0 and prices[index - 1] - price == 1:
                length += 1
            else:
                length = 1
            answer += length

        return answer
```

Why it works: every valid descent ending at the current day contributes one new period for each day in the current consecutive run.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [2122. Recover the Original Array](https://leetcode.com/problems/recover-the-original-array/) - Hard

```python
from collections import Counter

class Solution:
    def recoverArray(self, nums):
        nums.sort()
        smallest = nums[0]

        for index in range(1, len(nums)):
            difference = nums[index] - smallest
            if difference <= 0 or difference % 2:
                continue

            half = difference // 2
            counts = Counter(nums)
            lower = []
            valid = True

            for value in nums:
                if counts[value] == 0:
                    continue
                if counts[value + difference] == 0:
                    valid = False
                    break
                lower.append(value + half)
                counts[value] -= 1
                counts[value + difference] -= 1

            if valid:
                return lower

        return []
```

Why it works: the smallest transformed value must pair with a value exactly 2k larger. Try each possible positive difference, consume pairs with a frequency map, and return the midpoint values when every number is matched.

Time complexity is O(n^2), and the extra space is O(n).

#### Solution: [2130. Maximum Twin Sum of a Linked List](https://leetcode.com/problems/maximum-twin-sum-of-a-linked-list/) - Medium

```python
class Solution:
    def pairSum(self, head):
        values = []
        while head:
            values.append(head.val)
            head = head.next

        answer = 0
        left, right = 0, len(values) - 1
        while left < right:
            answer = max(answer, values[left] + values[right])
            left += 1
            right -= 1

        return answer
```

Why it works: store the list values, then use two pointers to pair the first half with the mirrored second half.

Time complexity is O(n), and the extra space is O(n).

---

#### Solution: [2300. Successful Pairs of Spells and Potions](https://leetcode.com/problems/successful-pairs-of-spells-and-potions/) - Medium

```python
from bisect import bisect_left

class Solution:
    def successfulPairs(self, spells, potions, success):
        potions.sort()
        result = []

        for spell in spells:
            needed = (success + spell - 1) // spell
            result.append(len(potions) - bisect_left(potions, needed))

        return result
```

Why it works: sort the potion strengths, then binary search the first potion whose product with the current spell reaches success.

Time complexity is O((n + m) log m), and the extra space is O(1) aside from sorting and the result.

#### Solution: [2330. Valid Palindrome IV](https://leetcode.com/problems/valid-palindrome-iv/) - Easy

```python
class Solution:
    def makePalindrome(self, s):
        mismatches = 0
        left, right = 0, len(s) - 1

        while left < right:
            if s[left] != s[right]:
                mismatches += 1
            left += 1
            right -= 1

        return mismatches <= 2
```

Why it works: one replacement can fix each mismatched mirrored pair, so count the mismatches and accept at most two.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [2332. The Latest Time to Catch a Bus](https://leetcode.com/problems/the-latest-time-to-catch-a-bus/) - Medium

```python
class Solution:
    def latestTimeCatchTheBus(self, buses, passengers, capacity):
        buses.sort()
        passengers.sort()
        passenger_index = 0
        boarded = set()
        latest = 0

        for bus in buses:
            count = 0
            last_boarded = None
            while passenger_index < len(passengers) and passengers[passenger_index] <= bus and count < capacity:
                last_boarded = passengers[passenger_index]
                boarded.add(last_boarded)
                passenger_index += 1
                count += 1

            latest = bus if count < capacity else last_boarded

        while latest in boarded:
            latest -= 1

        return latest
```

Why it works: simulate boarding in chronological order. The latest arrival is the bus time if a seat remains, otherwise the last passenger boarded, then move backward past occupied times.

Time complexity is O(n log n + m log m), and the extra space is O(m).

#### Solution: [2337. Move Pieces to Obtain a String](https://leetcode.com/problems/move-pieces-to-obtain-a-string/) - Medium

```python
class Solution:
    def canChange(self, start, target):
        start_pieces = [(character, index) for index, character in enumerate(start) if character != '_']
        target_pieces = [(character, index) for index, character in enumerate(target) if character != '_']

        if len(start_pieces) != len(target_pieces):
            return False

        for (start_character, start_index), (target_character, target_index) in zip(start_pieces, target_pieces):
            if start_character != target_character:
                return False
            if start_character == 'L' and start_index < target_index:
                return False
            if start_character == 'R' and start_index > target_index:
                return False

        return True
```

Why it works: removing underscores preserves piece order. L can only move left and R can only move right, so compare each piece’s allowed displacement.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [2367. Number of Arithmetic Triplets](https://leetcode.com/problems/number-of-arithmetic-triplets/) - Easy

```python
class Solution:
    def arithmeticTriplets(self, nums, diff):
        values = set(nums)
        return sum(value + diff in values and value + 2 * diff in values for value in nums)
```

Why it works: nums is strictly increasing, so each value can be the first element of at most one arithmetic triplet. Check the other two values in a set.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [2396. Strictly Palindromic Number](https://leetcode.com/problems/strictly-palindromic-number/) - Medium

```python
class Solution:
    def isStrictlyPalindromic(self, n):
        return False
```

Why it works: every integer n >= 4 fails to be palindromic in at least one base from 2 through n - 2, so the required condition is impossible.

Time complexity is O(1), and the extra space is O(1).

#### Solution: [2406. Divide Intervals Into Minimum Number of Groups](https://leetcode.com/problems/divide-intervals-into-minimum-number-of-groups/) - Medium

```python
class Solution:
    def minGroups(self, intervals):
        starts = sorted(interval[0] for interval in intervals)
        ends = sorted(interval[1] for interval in intervals)
        start = end = 0
        groups = 0

        while start < len(starts):
            if starts[start] <= ends[end]:
                groups += 1
                start += 1
            else:
                end += 1
                start += 1

        return groups
```

Why it works: a new group is needed when the next interval starts before the earliest active interval ends. Otherwise, one existing group becomes available.

Time complexity is O(n log n), and the extra space is O(n).

#### Solution: [2410. Maximum Matching of Players With Trainers](https://leetcode.com/problems/maximum-matching-of-players-with-trainers/) - Medium

```python
class Solution:
    def matchPlayersAndTrainers(self, players, trainers):
        players.sort()
        trainers.sort()
        player = trainer = 0
        matches = 0

        while player < len(players) and trainer < len(trainers):
            if players[player] <= trainers[trainer]:
                matches += 1
                player += 1
            trainer += 1

        return matches
```

Why it works: match the weakest remaining player with the weakest trainer who can handle them, preserving stronger trainers for stronger players.

Time complexity is O(n log n + m log m), and the extra space is O(1) aside from sorting.

#### Solution: [2422. Merge Operations to Turn Array Into a Palindrome](https://leetcode.com/problems/merge-operations-to-turn-array-into-a-palindrome/) - Medium

```python
class Solution:
    def minimumOperations(self, nums):
        left, right = 0, len(nums) - 1
        operations = 0

        while left < right:
            if nums[left] == nums[right]:
                left += 1
                right -= 1
            elif nums[left] < nums[right]:
                nums[left + 1] += nums[left]
                left += 1
                operations += 1
            else:
                nums[right - 1] += nums[right]
                right -= 1
                operations += 1

        return operations
```

Why it works: compare the two ends. Merge the smaller side into its neighbor because it must be combined before the ends can match.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [2441. Largest Positive Integer That Exists With Its Negative](https://leetcode.com/problems/largest-positive-integer-that-exists-with-its-negative/) - Easy

```python
class Solution:
    def findMaxK(self, nums):
        values = set(nums)
        return max((value for value in values if value > 0 and -value in values), default=-1)
```

Why it works: a positive value qualifies exactly when its negative is present, so scan the set of values and keep the largest qualifying positive.

Time complexity is O(n), and the extra space is O(n).

---

#### Solution: [2460. Apply Operations to an Array](https://leetcode.com/problems/apply-operations-to-an-array/) - Easy

```python
class Solution:
    def applyOperations(self, nums):
        for index in range(len(nums) - 1):
            if nums[index] == nums[index + 1]:
                nums[index] *= 2
                nums[index + 1] = 0

        write = 0
        for value in nums:
            if value:
                nums[write] = value
                write += 1

        while write < len(nums):
            nums[write] = 0
            write += 1

        return nums
```

Why it works: perform each adjacent merge from left to right, then use a write pointer to compact non-zero values and fill the remaining suffix with zeros.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [2462. Total Cost to Hire K Workers](https://leetcode.com/problems/total-cost-to-hire-k-workers/) - Medium

```python
import heapq

class Solution:
    def totalCost(self, costs, k, candidates):
        left_heap = []
        right_heap = []
        left = 0
        right = len(costs) - 1

        for _ in range(candidates):
            if left <= right:
                heapq.heappush(left_heap, costs[left])
                left += 1
        for _ in range(candidates):
            if left <= right:
                heapq.heappush(right_heap, costs[right])
                right -= 1

        answer = 0
        for _ in range(k):
            if not right_heap or left_heap and left_heap[0] <= right_heap[0]:
                answer += heapq.heappop(left_heap)
                if left <= right:
                    heapq.heappush(left_heap, costs[left])
                    left += 1
            else:
                answer += heapq.heappop(right_heap)
                if left <= right:
                    heapq.heappush(right_heap, costs[right])
                    right -= 1

        return answer
```

Why it works: two heaps represent the available candidates from both ends. Hire the cheaper end and replace it from the same side while the unseen ranges do not overlap.

Time complexity is O((n + k) log candidates), and the extra space is O(candidates).

#### Solution: [2465. Number of Distinct Averages](https://leetcode.com/problems/number-of-distinct-averages/) - Easy

```python
class Solution:
    def distinctAverages(self, nums):
        nums.sort()
        averages = set()
        left, right = 0, len(nums) - 1

        while left < right:
            averages.add(nums[left] + nums[right])
            left += 1
            right -= 1

        return len(averages)
```

Why it works: after sorting, repeatedly pairing the smallest and largest values produces every required average, and doubling the average does not change distinctness.

Time complexity is O(n log n), and the extra space is O(n).

#### Solution: [2472. Maximum Number of Non-overlapping Palindrome Substrings](https://leetcode.com/problems/maximum-number-of-non-overlapping-palindrome-substrings/) - Hard

```python
class Solution:
    def maxPalindromes(self, s, k):
        n = len(s)
        palindrome = [[False] * n for _ in range(n)]
        best = [0] * (n + 1)

        for end in range(n):
            best[end + 1] = best[end]
            for start in range(end, -1, -1):
                if s[start] == s[end] and (end - start < 2 or palindrome[start + 1][end - 1]):
                    palindrome[start][end] = True
                    if end - start + 1 >= k:
                        best[end + 1] = max(best[end + 1], best[start] + 1)

        return best[n]
```

Why it works: dynamic programming records palindromic intervals and the best count for every prefix. When a palindrome ends at the current position, append it only after the prefix before its start.

Time complexity is O(n^2), and the extra space is O(n^2).

#### Solution: [2486. Append Characters to String to Make Subsequence](https://leetcode.com/problems/append-characters-to-string-to-make-subsequence/) - Medium

```python
class Solution:
    def appendCharacters(self, s, t):
        target_index = 0
        for character in s:
            if target_index < len(t) and character == t[target_index]:
                target_index += 1

        return len(t) - target_index
```

Why it works: match the longest prefix of t that already appears as a subsequence of s. The unmatched suffix must be appended.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [2491. Divide Players Into Teams of Equal Skill](https://leetcode.com/problems/divide-players-into-teams-of-equal-skill/) - Medium

```python
class Solution:
    def dividePlayers(self, skill):
        skill.sort()
        left, right = 0, len(skill) - 1
        target = skill[left] + skill[right]
        chemistry = 0

        while left < right:
            if skill[left] + skill[right] != target:
                return -1
            chemistry += skill[left] * skill[right]
            left += 1
            right -= 1

        return chemistry
```

Why it works: sorting makes the smallest player pair naturally with the largest. Every pair must have the same target skill sum, so any mismatch makes a valid division impossible.

Time complexity is O(n log n), and the extra space is O(1) aside from sorting.

#### Solution: [2503. Maximum Number of Points From Grid Queries](https://leetcode.com/problems/maximum-number-of-points-from-grid-queries/) - Hard

```python
import heapq

class Solution:
    def maxPoints(self, grid, queries):
        rows, columns = len(grid), len(grid[0])
        answer = [0] * len(queries)
        ordered = sorted(enumerate(queries), key=lambda item: item[1])
        heap = [(grid[0][0], 0, 0)]
        visited = {(0, 0)}
        points = 0

        for query_index, limit in ordered:
            while heap and heap[0][0] < limit:
                value, row, column = heapq.heappop(heap)
                points += 1
                for next_row, next_column in ((row - 1, column), (row + 1, column), (row, column - 1), (row, column + 1)):
                    if 0 <= next_row < rows and 0 <= next_column < columns and (next_row, next_column) not in visited:
                        visited.add((next_row, next_column))
                        heapq.heappush(heap, (grid[next_row][next_column], next_row, next_column))
            answer[query_index] = points

        return answer
```

Why it works: process queries in increasing order and expand reachable cells through a min-heap. Every popped cell has the smallest frontier value and is reachable under the current query.

Time complexity is O((mn + q) log(mn)), and the extra space is O(mn).

#### Solution: [2511. Maximum Enemy Forts That Can Be Captured](https://leetcode.com/problems/maximum-enemy-forts-that-can-be-captured/) - Easy

```python
class Solution:
    def captureForts(self, forts):
        answer = 0
        last_fort = -1

        for index, value in enumerate(forts):
            if value == 1:
                last_fort = index
            elif value == -1 and last_fort != -1:
                answer = max(answer, index - last_fort - 1)
                last_fort = -1

        last_fort = -1
        for index in range(len(forts) - 1, -1, -1):
            if forts[index] == -1:
                last_fort = index
            elif forts[index] == 1 and last_fort != -1:
                answer = max(answer, last_fort - index - 1)
                last_fort = -1

        return answer
```

Why it works: a capture is possible only across a contiguous run of empty forts between an enemy and your fort. Scan in both directions to cover either orientation.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [2540. Minimum Common Value](https://leetcode.com/problems/minimum-common-value/) - Easy

```python
class Solution:
    def getCommon(self, nums1, nums2):
        first = second = 0

        while first < len(nums1) and second < len(nums2):
            if nums1[first] == nums2[second]:
                return nums1[first]
            if nums1[first] < nums2[second]:
                first += 1
            else:
                second += 1

        return -1
```

Why it works: both arrays are sorted, so advance the pointer at the smaller value until the first common value is found.

Time complexity is O(n + m), and the extra space is O(1).

#### Solution: [2562. Find the Array Concatenation Value](https://leetcode.com/problems/find-the-array-concatenation-value/) - Easy

```python
class Solution:
    def findTheArrayConcVal(self, nums):
        left, right = 0, len(nums) - 1
        answer = 0

        while left <= right:
            if left == right:
                answer += nums[left]
            else:
                answer += int(str(nums[left]) + str(nums[right]))
            left += 1
            right -= 1

        return answer
```

Why it works: two pointers take values from opposite ends and concatenate each pair in order, with the center value added once when the array length is odd.

Time complexity is O(n), and the extra space is O(1) aside from integer conversion.

---

#### Solution: [2563. Count the Number of Fair Pairs](https://leetcode.com/problems/count-the-number-of-fair-pairs/) - Medium

```python
class Solution:
    def countFairPairs(self, nums, lower, upper):
        nums.sort()

        def count_at_most(limit):
            left, right = 0, len(nums) - 1
            answer = 0
            while left < right:
                if nums[left] + nums[right] <= limit:
                    answer += right - left
                    left += 1
                else:
                    right -= 1
            return answer

        return count_at_most(upper) - count_at_most(lower - 1)
```

Why it works: count pairs with sum at most each boundary. Their difference leaves exactly the pairs whose sum lies in [lower, upper].

Time complexity is O(n log n), and the extra space is O(1) aside from sorting.

#### Solution: [2565. Subsequence With the Minimum Score](https://leetcode.com/problems/subsequence-with-the-minimum-score/) - Hard

```python
class Solution:
    def minimumScore(self, s, t):
        prefix = [-1] * len(t)
        suffix = [len(s)] * len(t)
        source_index = 0

        for target_index, character in enumerate(t):
            while source_index < len(s) and s[source_index] != character:
                source_index += 1
            if source_index == len(s):
                break
            prefix[target_index] = source_index
            source_index += 1

        source_index = len(s) - 1
        for target_index in range(len(t) - 1, -1, -1):
            while source_index >= 0 and s[source_index] != t[target_index]:
                source_index -= 1
            if source_index < 0:
                break
            suffix[target_index] = source_index
            source_index -= 1

        answer = len(t)
        right = 0
        for left in range(len(t) + 1):
            if left > 0 and prefix[left - 1] == -1:
                break
            while right < len(t) and (left == 0 or suffix[right] <= prefix[left - 1]):
                right += 1
            answer = min(answer, right - left)

        return answer
```

Why it works: prefix and suffix arrays identify which parts of t can remain matched. The removed middle section is minimized by sliding the boundary between those two matched parts.

Time complexity is O(n + m), and the extra space is O(m).

#### Solution: [2570. Merge Two 2D Arrays by Summing Values](https://leetcode.com/problems/merge-two-2d-arrays-by-summing-values/) - Easy

```python
class Solution:
    def mergeArrays(self, nums1, nums2):
        first = second = 0
        result = []

        while first < len(nums1) and second < len(nums2):
            if nums1[first][0] == nums2[second][0]:
                result.append([nums1[first][0], nums1[first][1] + nums2[second][1]])
                first += 1
                second += 1
            elif nums1[first][0] < nums2[second][0]:
                result.append(nums1[first])
                first += 1
            else:
                result.append(nums2[second])
                second += 1

        result.extend(nums1[first:])
        result.extend(nums2[second:])
        return result
```

Why it works: merge the two sorted ID lists, combining values whenever both pointers reference the same ID.

Time complexity is O(n + m), and the extra space is O(n + m) for the result.

#### Solution: [2576. Find the Maximum Number of Marked Indices](https://leetcode.com/problems/find-the-maximum-number-of-marked-indices/) - Medium

```python
class Solution:
    def maxNumOfMarkedIndices(self, nums):
        nums.sort()
        left, right = 0, len(nums) // 2
        pairs = 0

        while left < len(nums) // 2 and right < len(nums):
            if nums[left] * 2 <= nums[right]:
                pairs += 1
                left += 1
                right += 1
            else:
                right += 1

        return pairs * 2
```

Why it works: use the smaller half as possible first elements and greedily match each with the earliest larger value at least twice as large.

Time complexity is O(n log n), and the extra space is O(1) aside from sorting.

#### Solution: [2592. Maximize Greatness of an Array](https://leetcode.com/problems/maximize-greatness-of-an-array/) - Medium

```python
class Solution:
    def maximizeGreatness(self, nums):
        nums.sort()
        smaller = 0

        for value in nums:
            if value > nums[smaller]:
                smaller += 1

        return smaller
```

Why it works: match each value against the smallest still-unmatched value it can exceed. Each successful match contributes one position of greatness.

Time complexity is O(n log n), and the extra space is O(1) aside from sorting.

#### Solution: [2604. Minimum Time to Eat All Grains](https://leetcode.com/problems/minimum-time-to-eat-all-grains/) - Hard

```python
class Solution:
    def minimumTime(self, hens, grains):
        hens.sort()
        grains.sort()

        def can_finish(time):
            grain = 0
            for hen in hens:
                if grain == len(grains):
                    return True

                first = grains[grain]
                if first > hen + time:
                    return False

                if first <= hen:
                    distance_left = hen - first
                    reach = max(hen + time - 2 * distance_left,
                                hen + (time - distance_left) // 2)
                else:
                    reach = hen + time

                while grain < len(grains) and grains[grain] <= reach:
                    grain += 1

            return grain == len(grains)

        low, high = 0, 10**9
        while low < high:
            middle = (low + high) // 2
            if can_finish(middle):
                high = middle
            else:
                low = middle + 1

        return low
```

Why it works: for a candidate time, each hen consumes the earliest remaining grains it can reach. Binary search finds the smallest time for which every grain can be covered.

Time complexity is O((n + m) log C), where C is the search bound, and the extra space is O(1) aside from sorting.

#### Solution: [2674. Split a Circular Linked List](https://leetcode.com/problems/split-a-circular-linked-list/) - Medium

```python
class Solution:
    def splitCircularLinkedList(self, list):
        slow = fast = list
        while fast.next != list and fast.next.next != list:
            slow = slow.next
            fast = fast.next.next

        if fast.next.next == list:
            fast = fast.next

        second = slow.next
        slow.next = list
        fast.next = second
        return [list, second]
```

Why it works: slow and fast locate the midpoint of the circular list. Reconnect the tail to the second head and the midpoint to the first head to form two circular lists.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [2697. Lexicographically Smallest Palindrome](https://leetcode.com/problems/lexicographically-smallest-palindrome/) - Easy

```python
class Solution:
    def makeSmallestPalindrome(self, s):
        characters = list(s)
        left, right = 0, len(characters) - 1

        while left < right:
            characters[left] = characters[right] = min(characters[left], characters[right])
            left += 1
            right -= 1

        return ''.join(characters)
```

Why it works: each mirrored pair must become equal. Choosing the smaller character at every pair gives the lexicographically smallest palindrome.

Time complexity is O(n), and the extra space is O(n).

#### Solution: [2824. Count Pairs Whose Sum is Less than Target](https://leetcode.com/problems/count-pairs-whose-sum-is-less-than-target/) - Easy

```python
class Solution:
    def countPairs(self, nums, target):
        nums.sort()
        left, right = 0, len(nums) - 1
        answer = 0

        while left < right:
            if nums[left] + nums[right] < target:
                answer += right - left
                left += 1
            else:
                right -= 1

        return answer
```

Why it works: when the smallest and largest values form a sum below target, every value between left and right also forms a valid pair with left.

Time complexity is O(n log n), and the extra space is O(1) aside from sorting.

#### Solution: [2825. Make String a Subsequence Using Cyclic Increments](https://leetcode.com/problems/make-string-a-subsequence-using-cyclic-increments/) - Medium

```python
class Solution:
    def canMakeSubsequence(self, str1, str2):
        target_index = 0

        for character in str1:
            if target_index == len(str2):
                break
            next_character = chr((ord(character) - ord('a') + 1) % 26 + ord('a'))
            if character == str2[target_index] or next_character == str2[target_index]:
                target_index += 1

        return target_index == len(str2)
```

Why it works: scan str1 once and match each needed character either directly or by its allowed single cyclic increment.

Time complexity is O(n), and the extra space is O(1).

---

#### Solution: [2838. Maximum Coins Heroes Can Collect](https://leetcode.com/problems/maximum-coins-heroes-can-collect/) - Medium

```python
from bisect import bisect_right

class Solution:
    def maximumCoins(self, heroes, monsters):
        monsters.sort()
        powers = [power for power, _ in monsters]
        prefix = [0]
        for _, coins in monsters:
            prefix.append(prefix[-1] + coins)

        return [prefix[bisect_right(powers, hero)] for hero in heroes]
```

Why it works: sort monsters by power and build prefix coin totals. Binary search finds the monsters each hero can defeat.

Time complexity is O(m log m + h log m), and the extra space is O(m).

#### Solution: [2856. Minimum Array Length After Pair Removals](https://leetcode.com/problems/minimum-array-length-after-pair-removals/) - Medium

```python
class Solution:
    def minLengthAfterRemovals(self, nums):
        middle = (len(nums) + 1) // 2
        left, right = 0, middle
        removed = 0

        while left < middle and right < len(nums):
            if nums[left] < nums[right]:
                removed += 2
                left += 1
                right += 1
            else:
                right += 1

        return len(nums) - removed
```

Why it works: pair each value in the first half with a strictly larger value in the second half. Every such match removes two elements, and unmatched elements remain.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [2903. Find Indices With Index and Value Difference I](https://leetcode.com/problems/find-indices-with-index-and-value-difference-i/) - Easy

```python
class Solution:
    def findIndices(self, nums, indexDifference, valueDifference):
        minimum_index = maximum_index = 0

        for right in range(indexDifference, len(nums)):
            candidate = right - indexDifference
            if nums[candidate] < nums[minimum_index]:
                minimum_index = candidate
            if nums[candidate] > nums[maximum_index]:
                maximum_index = candidate

            if nums[right] - nums[minimum_index] >= valueDifference:
                return [minimum_index, right]
            if nums[maximum_index] - nums[right] >= valueDifference:
                return [maximum_index, right]

        return [-1, -1]
```

Why it works: maintain the minimum and maximum values among indices far enough behind the current right pointer, so each value-difference condition is checked in constant time.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [2905. Find Indices With Index and Value Difference II](https://leetcode.com/problems/find-indices-with-index-and-value-difference-ii/) - Medium

```python
class Solution:
    def findIndices(self, nums, indexDifference, valueDifference):
        minimum_index = maximum_index = 0

        for right in range(indexDifference, len(nums)):
            candidate = right - indexDifference
            if nums[candidate] < nums[minimum_index]:
                minimum_index = candidate
            if nums[candidate] > nums[maximum_index]:
                maximum_index = candidate

            if nums[right] - nums[minimum_index] >= valueDifference:
                return [minimum_index, right]
            if nums[maximum_index] - nums[right] >= valueDifference:
                return [maximum_index, right]

        return [-1, -1]
```

Why it works: the index constraint is handled by the delayed candidate pointer, while running extrema capture every possible earlier value efficiently.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [2911. Minimum Changes to Make K Semi-palindromes](https://leetcode.com/problems/minimum-changes-to-make-k-semi-palindromes/) - Hard

```python
class Solution:
    def minimumChanges(self, s, k):
        n = len(s)
        factors = [[] for _ in range(n + 1)]
        for divisor in range(1, n):
            for length in range(divisor * 2, n + 1, divisor):
                factors[length].append(divisor)

        cost = [[0] * n for _ in range(n)]
        for left in range(n):
            for right in range(left + 1, n):
                length = right - left + 1
                best = length
                for step in factors[length]:
                    changes = 0
                    for offset in range(step):
                        first, last = left + offset, right - step + 1 + offset
                        while first < last:
                            if s[first] != s[last]:
                                changes += 1
                            first += step
                            last -= step
                    best = min(best, changes)
                cost[left][right] = best

        infinity = n * n
        dp = [[infinity] * (k + 1) for _ in range(n + 1)]
        dp[n][0] = 0

        for start in range(n - 1, -1, -1):
            for parts in range(1, k + 1):
                for end in range(start + 1, n):
                    if n - end - 1 < parts - 1:
                        continue
                    dp[start][parts] = min(dp[start][parts], cost[start][end] + dp[end + 1][parts - 1])

        return dp[0][k]
```

Why it works: precompute the minimum changes for every substring to become a semi-palindrome over each proper divisor of its length, then use dynamic programming to split the string into k parts.

Time complexity is O(n^3), and the extra space is O(n^2).

#### Solution: [2938. Separate Black and White Balls](https://leetcode.com/problems/separate-black-and-white-balls/) - Medium

```python
class Solution:
    def minimumSteps(self, s):
        white = 0
        swaps = 0

        for character in s:
            if character == '1':
                white += 1
            else:
                swaps += white

        return swaps
```

Why it works: every black ball contributes one swap for each white ball before it, so count the whites already seen while scanning left to right.

Time complexity is O(n), and the extra space is O(1).

#### Solution: [2970. Count the Number of Incremovable Subarrays I](https://leetcode.com/problems/count-the-number-of-incremovable-subarrays-i/) - Easy

```python
class Solution:
    def incremovableSubarrayCount(self, nums):
        answer = 0

        for left in range(len(nums)):
            for right in range(left, len(nums)):
                remaining = nums[:left] + nums[right + 1:]
                if all(remaining[index - 1] < remaining[index] for index in range(1, len(remaining))):
                    answer += 1

        return answer
```

Why it works: enumerate every non-empty removal interval and directly verify that the concatenated remaining prefix and suffix are strictly increasing.

Time complexity is O(n^3), and the extra space is O(n).

#### Solution: [2972. Count the Number of Incremovable Subarrays II](https://leetcode.com/problems/count-the-number-of-incremovable-subarrays-ii/) - Hard

```python
from bisect import bisect_right

class Solution:
    def incremovableSubarrayCount(self, nums):
        n = len(nums)
        suffix_start = n - 1
        while suffix_start > 0 and nums[suffix_start - 1] < nums[suffix_start]:
            suffix_start -= 1

        answer = n - suffix_start + 1
        left = 0
        while left < n and (left == 0 or nums[left - 1] < nums[left]):
            first_valid_suffix = max(suffix_start, left + 1)
            position = bisect_right(nums, nums[left], first_valid_suffix, n)
            answer += n - position + 1
            left += 1

        return answer
```

Why it works: every valid removal leaves an increasing prefix and suffix whose boundary values are ordered. For each increasing prefix, binary search finds the earliest compatible suffix boundary.

Time complexity is O(n log n), and the extra space is O(1).

#### Solution: [3006. Find Beautiful Indices in the Given Array I](https://leetcode.com/problems/find-beautiful-indices-in-the-given-array-i/) - Easy

```python
class Solution:
    def beautifulIndices(self, s, a, b, k):
        def occurrences(pattern):
            result = []
            start = 0
            while True:
                index = s.find(pattern, start)
                if index == -1:
                    return result
                result.append(index)
                start = index + 1

        positions_a = occurrences(a)
        positions_b = occurrences(b)
        result = []
        pointer = 0

        for position in positions_a:
            while pointer < len(positions_b) and positions_b[pointer] < position - k:
                pointer += 1
            if pointer < len(positions_b) and positions_b[pointer] <= position + k:
                result.append(position)

        return result
```

Why it works: collect sorted occurrence positions, then use a pointer into b’s positions to test whether each a occurrence has a nearby b occurrence.

Time complexity is O(n + number of matches), and the extra space is O(n).

---

## 9. Remaining problems from the attached Two Pointers list

These 56 problems were present in the attachment but do not yet have a direct solution above. They are listed here as the next solution backlog.

- [2868. The Wording Game](https://leetcode.com/problems/the-wording-game/) - Hard
- [3008. Find Beautiful Indices in the Given Array II](https://leetcode.com/problems/find-beautiful-indices-in-the-given-array-ii/) - Hard
- [3132. Find the Integer Added to Array II](https://leetcode.com/problems/find-the-integer-added-to-array-ii/) - Medium
- [3186. Maximum Total Damage With Spell Casting](https://leetcode.com/problems/maximum-total-damage-with-spell-casting/) - Medium
- [3194. Minimum Average of Smallest and Largest Elements](https://leetcode.com/problems/minimum-average-of-smallest-and-largest-elements/) - Easy
- [3218. Minimum Cost for Cutting Cake I](https://leetcode.com/problems/minimum-cost-for-cutting-cake-i/) - Medium
- [3239. Minimum Number of Flips to Make Binary Grid Palindromic I](https://leetcode.com/problems/minimum-number-of-flips-to-make-binary-grid-palindromic-i/) - Medium
- [3240. Minimum Number of Flips to Make Binary Grid Palindromic II](https://leetcode.com/problems/minimum-number-of-flips-to-make-binary-grid-palindromic-ii/) - Medium
- [3284. Sum of Consecutive Subarrays](https://leetcode.com/problems/sum-of-consecutive-subarrays/) - Medium
- [3302. Find the Lexicographically Smallest Valid Sequence](https://leetcode.com/problems/find-the-lexicographically-smallest-valid-sequence/) - Medium
- [3316. Find Maximum Removals From Source String](https://leetcode.com/problems/find-maximum-removals-from-source-string/) - Medium
- [3356. Zero Array Transformation II](https://leetcode.com/problems/zero-array-transformation-ii/) - Medium
- [3362. Zero Array Transformation III](https://leetcode.com/problems/zero-array-transformation-iii/) - Medium
- [3400. Maximum Number of Matching Indices After Right Shifts](https://leetcode.com/problems/maximum-number-of-matching-indices-after-right-shifts/) - Medium
- [3403. Find the Lexicographically Largest String From the Box I](https://leetcode.com/problems/find-the-lexicographically-largest-string-from-the-box-i/) - Medium
- [3406. Find the Lexicographically Largest String From the Box II](https://leetcode.com/problems/find-the-lexicographically-largest-string-from-the-box-ii/) - Hard
- [3455. Shortest Matching Substring](https://leetcode.com/problems/shortest-matching-substring/) - Hard
- [3460. Longest Common Prefix After at Most One Removal](https://leetcode.com/problems/longest-common-prefix-after-at-most-one-removal/) - Medium
- [3503. Longest Palindrome After Substring Concatenation I](https://leetcode.com/problems/longest-palindrome-after-substring-concatenation-i/) - Medium
- [3504. Longest Palindrome After Substring Concatenation II](https://leetcode.com/problems/longest-palindrome-after-substring-concatenation-ii/) - Hard
- [3534. Path Existence Queries in a Graph II](https://leetcode.com/problems/path-existence-queries-in-a-graph-ii/) - Hard
- [3555. Smallest Subarray to Sort in Every Sliding Window](https://leetcode.com/problems/smallest-subarray-to-sort-in-every-sliding-window/) - Medium
- [3584. Maximum Product of First and Last Elements of a Subsequence](https://leetcode.com/problems/maximum-product-of-first-and-last-elements-of-a-subsequence/) - Medium
- [3633. Earliest Finish Time for Land and Water Rides I](https://leetcode.com/problems/earliest-finish-time-for-land-and-water-rides-i/) - Easy
- [3635. Earliest Finish Time for Land and Water Rides II](https://leetcode.com/problems/earliest-finish-time-for-land-and-water-rides-ii/) - Medium
- [3643. Flip Square Submatrix Vertically](https://leetcode.com/problems/flip-square-submatrix-vertically/) - Easy
- [3645. Maximum Total from Optimal Activation Order](https://leetcode.com/problems/maximum-total-from-optimal-activation-order/) - Medium
- [3649. Number of Perfect Pairs](https://leetcode.com/problems/number-of-perfect-pairs/) - Medium
- [3667. Sort Array By Absolute Value](https://leetcode.com/problems/sort-array-by-absolute-value/) - Easy
- [3685. Subsequence Sum After Capping Elements](https://leetcode.com/problems/subsequence-sum-after-capping-elements/) - Medium
- [3722. Lexicographically Smallest String After Reverse](https://leetcode.com/problems/lexicographically-smallest-string-after-reverse/) - Medium
- [3730. Maximum Calories Burnt from Jumps](https://leetcode.com/problems/maximum-calories-burnt-from-jumps/) - Medium
- [3734. Lexicographically Smallest Palindromic Permutation Greater Than Target](https://leetcode.com/problems/lexicographically-smallest-palindromic-permutation-greater-than-target/) - Hard
- [3750. Minimum Number of Flips to Reverse Binary String](https://leetcode.com/problems/minimum-number-of-flips-to-reverse-binary-string/) - Easy
- [3752. Lexicographically Smallest Negated Permutation that Sums to Target](https://leetcode.com/problems/lexicographically-smallest-negated-permutation-that-sums-to-target/) - Medium
- [3766. Minimum Operations to Make Binary Palindrome](https://leetcode.com/problems/minimum-operations-to-make-binary-palindrome/) - Medium
- [3775. Reverse Words With Same Vowel Count](https://leetcode.com/problems/reverse-words-with-same-vowel-count/) - Medium
- [3794. Reverse String Prefix](https://leetcode.com/problems/reverse-string-prefix/) - Easy
- [3801. Minimum Cost to Merge Sorted Lists](https://leetcode.com/problems/minimum-cost-to-merge-sorted-lists/) - Hard
- [3814. Maximum Capacity Within Budget](https://leetcode.com/problems/maximum-capacity-within-budget/) - Medium
- [3823. Reverse Letters Then Special Characters in a String](https://leetcode.com/problems/reverse-letters-then-special-characters-in-a-string/) - Easy
- [3844. Longest Almost-Palindromic Substring](https://leetcode.com/problems/longest-almost-palindromic-substring/) - Medium
- [3865. Reverse K Subarrays](https://leetcode.com/problems/reverse-k-subarrays/) - Medium
- [3867. Sum of GCD of Formed Pairs](https://leetcode.com/problems/sum-of-gcd-of-formed-pairs/) - Medium
- [3884. First Matching Character From Both Ends](https://leetcode.com/problems/first-matching-character-from-both-ends/) - Easy
- [3896. Minimum Operations to Transform Array into Alternating Prime](https://leetcode.com/problems/minimum-operations-to-transform-array-into-alternating-prime/) - Medium
- [3936. Minimum Swaps to Move Zeros to End](https://leetcode.com/problems/minimum-swaps-to-move-zeros-to-end/) - Easy
- [3940. Limit Occurrences in Sorted Array](https://leetcode.com/problems/limit-occurrences-in-sorted-array/) - Easy
- [3983. Subsequence After One Replacement](https://leetcode.com/problems/subsequence-after-one-replacement/) - Medium
- [3991. Sort Array Using Prefix Reversals](https://leetcode.com/problems/sort-array-using-prefix-reversals/) - Medium
- [3992. Rearrange String to Avoid Character Pair](https://leetcode.com/problems/rearrange-string-to-avoid-character-pair/) - Easy
- [3998. Transform Binary String Using Subsequence Sort](https://leetcode.com/problems/transform-binary-string-using-subsequence-sort/) - Medium
- [3999. Minimum Number of String Groups Through Transformations](https://leetcode.com/problems/minimum-number-of-string-groups-through-transformations/) - Hard
- [4001. Aggregate Two Time Series](https://leetcode.com/problems/aggregate-two-time-series/) - Medium
- [4014. Minimum Total Price After Applying Discounts](https://leetcode.com/problems/minimum-total-price-after-applying-discounts/) - Medium
- [4026. Maximum Gap Between Stations](https://leetcode.com/problems/maximum-gap-between-stations/) - Medium
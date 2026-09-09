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
- sorted arrays
- “find pair / triplet / quadruplet”
- “remove duplicates”
- “palindrome”
- “reverse / partition / reorder in-place”
- “middle of linked list”
- “cycle detection”
- “minimum/maximum subarray with monotonic condition”
- “merge two sorted sequences”

### Typical interview questions to ask yourself:
- Is the data ordered or partially ordered?
- Can I shrink the search space with a pointer move?
- Is there an invariant I can maintain while scanning?
- Does moving one pointer reduce the remaining possibilities?
- Can I avoid O(n^2) by eliminating one dimension?

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

## 9. Remaining problems from the attached Two Pointers list

These 165 problems were present in the attachment but do not yet have a direct solution above. They are listed here as the next solution backlog.

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

- 948. Bag of Tokens — Medium
- 962. Maximum Width Ramp — Medium
- 969. Pancake Sorting — Medium
- 1023. Camelcase Matching — Medium
- 1048. Longest String Chain — Medium
- 1055. Shortest Way to Form String — Medium
- 1089. Duplicate Zeros — Easy
- 1099. Two Sum Less Than K — Easy
- 1147. Longest Chunked Palindrome Decomposition — Hard
- 1163. Last Substring in Lexicographical Order — Hard
- 1214. Two Sum BSTs — Medium
- 1229. Meeting Scheduler — Medium
- 1237. Find Positive Integer Solution for a Given Equation — Medium
- 1265. Print Immutable Linked List in Reverse — Medium
- 1332. Remove Palindromic Subsequences — Easy
- 1346. Check If N and Its Double Exist — Easy
- 1385. Find the Distance Value Between Two Arrays — Easy
- 1455. Check If a Word Occurs As a Prefix of Any Word in a Sentence — Easy
- 1471. The k Strongest Values in an Array — Medium
- 1498. Number of Subsequences That Satisfy the Given Sum Condition — Medium
- 1508. Range Sum of Sorted Subarray Sums — Medium
- 1537. Get the Maximum Score — Hard
- 1570. Dot Product of Two Sparse Vectors — Medium
- 1574. Shortest Subarray to be Removed to Make Array Sorted — Medium
- 1577. Number of Ways Where Square of Number Is Equal to Product of Two Numbers — Medium
- 1616. Split Two Strings to Make Palindrome — Medium
- 1634. Add Two Polynomials Represented as Linked Lists — Medium
- 1650. Lowest Common Ancestor of a Binary Tree III — Medium
- 1679. Max Number of K-Sum Pairs — Medium
- 1697. Checking Existence of Edge Length Limited Paths — Hard
- 1712. Ways to Split Array Into Three Subarrays — Medium
- 1721. Swapping Nodes in a Linked List — Medium
- 1750. Minimum Length of String After Deleting Similar Ends — Medium
- 1754. Largest Merge Of Two Strings — Medium
- 1755. Closest Subsequence Sum — Hard
- 1764. Form Array by Concatenating Subarrays of Another Array — Medium
- 1768. Merge Strings Alternately — Easy
- 1782. Count Pairs Of Nodes — Hard
- 1793. Maximum Score of a Good Subarray — Hard
- 1813. Sentence Similarity III — Medium
- 1826. Faulty Sensor — Easy
- 1842. Next Palindrome Using Same Digits — Hard
- 1850. Minimum Adjacent Swaps to Reach the Kth Smallest Number — Medium
- 1855. Maximum Distance Between a Pair of Values — Medium
- 1861. Rotating the Box — Medium
- 1868. Product of Two Run-Length Encoded Arrays — Medium
- 1877. Minimize Maximum Pair Sum in Array — Medium
- 1885. Count Pairs in Two Arrays — Medium
- 1898. Maximum Number of Removable Characters — Medium
- 1960. Maximum Product of the Length of Two Palindromic Substrings — Hard
- 1961. Check If String Is a Prefix of Array — Easy
- 1963. Minimum Number of Swaps to Make the String Balanced — Medium
- 1989. Maximum Number of People That Can Be Caught in Tag — Medium
- 2000. Reverse Prefix of Word — Easy
- 2014. Longest Subsequence Repeated k Times — Hard
- 2035. Partition Array Into Two Arrays to Minimize Sum Difference — Hard
- 2046. Sort Linked List Already Sorted Using Absolute Values — Medium
- 2071. Maximum Number of Tasks You Can Assign — Hard
- 2095. Delete the Middle Node of a Linked List — Medium
- 2105. Watering Plants II — Medium
- 2108. Find First Palindromic String in the Array — Easy
- 2109. Adding Spaces to a String — Medium
- 2110. Number of Smooth Descent Periods of a Stock — Medium
- 2122. Recover the Original Array — Hard
- 2130. Maximum Twin Sum of a Linked List — Medium
- 2149. Rearrange Array Elements by Sign — Medium
- 2161. Partition Array According to Given Pivot — Medium
- 2193. Minimum Number of Moves to Make Palindrome — Hard
- 2200. Find All K-Distant Indices in an Array — Easy
- 2234. Maximum Total Beauty of the Gardens — Hard
- 2300. Successful Pairs of Spells and Potions — Medium
- 2330. Valid Palindrome IV — Medium
- 2332. The Latest Time to Catch a Bus — Medium
- 2337. Move Pieces to Obtain a String — Medium
- 2367. Number of Arithmetic Triplets — Easy
- 2396. Strictly Palindromic Number — Medium
- 2406. Divide Intervals Into Minimum Number of Groups — Medium
- 2410. Maximum Matching of Players With Trainers — Medium
- 2422. Merge Operations to Turn Array Into a Palindrome — Medium
- 2441. Largest Positive Integer That Exists With Its Negative — Easy
- 2460. Apply Operations to an Array — Easy
- 2462. Total Cost to Hire K Workers — Medium
- 2465. Number of Distinct Averages — Easy
- 2472. Maximum Number of Non-overlapping Palindrome Substrings — Hard
- 2486. Append Characters to String to Make Subsequence — Medium
- 2491. Divide Players Into Teams of Equal Skill — Medium
- 2503. Maximum Number of Points From Grid Queries — Hard
- 2511. Maximum Enemy Forts That Can Be Captured — Easy
- 2540. Minimum Common Value — Easy
- 2562. Find the Array Concatenation Value — Easy
- 2563. Count the Number of Fair Pairs — Medium
- 2565. Subsequence With the Minimum Score — Hard
- 2570. Merge Two 2D Arrays by Summing Values — Easy
- 2576. Find the Maximum Number of Marked Indices — Medium
- 2592. Maximize Greatness of an Array — Medium
- 2604. Minimum Time to Eat All Grains — Hard
- 2674. Split a Circular Linked List — Medium
- 2697. Lexicographically Smallest Palindrome — Easy
- 2824. Count Pairs Whose Sum is Less than Target — Easy
- 2825. Make String a Subsequence Using Cyclic Increments — Medium
- 2838. Maximum Coins Heroes Can Collect — Medium
- 2856. Minimum Array Length After Pair Removals — Medium
- 2868. The Wording Game — Hard
- 2903. Find Indices With Index and Value Difference I — Easy
- 2905. Find Indices With Index and Value Difference II — Medium
- 2911. Minimum Changes to Make K Semi-palindromes — Hard
- 2938. Separate Black and White Balls — Medium
- 2970. Count the Number of Incremovable Subarrays I — Easy
- 2972. Count the Number of Incremovable Subarrays II — Hard
- 3006. Find Beautiful Indices in the Given Array I — Medium
- 3008. Find Beautiful Indices in the Given Array II — Hard
- 3132. Find the Integer Added to Array II — Medium
- 3186. Maximum Total Damage With Spell Casting — Medium
- 3194. Minimum Average of Smallest and Largest Elements — Easy
- 3218. Minimum Cost for Cutting Cake I — Medium
- 3239. Minimum Number of Flips to Make Binary Grid Palindromic I — Medium
- 3240. Minimum Number of Flips to Make Binary Grid Palindromic II — Medium
- 3284. Sum of Consecutive Subarrays — Medium
- 3302. Find the Lexicographically Smallest Valid Sequence — Medium
- 3316. Find Maximum Removals From Source String — Medium
- 3356. Zero Array Transformation II — Medium
- 3362. Zero Array Transformation III — Medium
- 3400. Maximum Number of Matching Indices After Right Shifts — Medium
- 3403. Find the Lexicographically Largest String From the Box I — Medium
- 3406. Find the Lexicographically Largest String From the Box II — Hard
- 3455. Shortest Matching Substring — Hard
- 3460. Longest Common Prefix After at Most One Removal — Medium
- 3503. Longest Palindrome After Substring Concatenation I — Medium
- 3504. Longest Palindrome After Substring Concatenation II — Hard
- 3534. Path Existence Queries in a Graph II — Hard
- 3555. Smallest Subarray to Sort in Every Sliding Window — Medium
- 3584. Maximum Product of First and Last Elements of a Subsequence — Medium
- 3633. Earliest Finish Time for Land and Water Rides I — Easy
- 3635. Earliest Finish Time for Land and Water Rides II — Medium
- 3643. Flip Square Submatrix Vertically — Easy
- 3645. Maximum Total from Optimal Activation Order — Medium
- 3649. Number of Perfect Pairs — Medium
- 3667. Sort Array By Absolute Value — Easy
- 3685. Subsequence Sum After Capping Elements — Medium
- 3722. Lexicographically Smallest String After Reverse — Medium
- 3730. Maximum Calories Burnt from Jumps — Medium
- 3734. Lexicographically Smallest Palindromic Permutation Greater Than Target — Hard
- 3750. Minimum Number of Flips to Reverse Binary String — Easy
- 3752. Lexicographically Smallest Negated Permutation that Sums to Target — Medium
- 3766. Minimum Operations to Make Binary Palindrome — Medium
- 3775. Reverse Words With Same Vowel Count — Medium
- 3794. Reverse String Prefix — Easy
- 3801. Minimum Cost to Merge Sorted Lists — Hard
- 3814. Maximum Capacity Within Budget — Medium
- 3823. Reverse Letters Then Special Characters in a String — Easy
- 3844. Longest Almost-Palindromic Substring — Medium
- 3865. Reverse K Subarrays — Medium
- 3867. Sum of GCD of Formed Pairs — Medium
- 3884. First Matching Character From Both Ends — Easy
- 3896. Minimum Operations to Transform Array into Alternating Prime — Medium
- 3936. Minimum Swaps to Move Zeros to End — Easy
- 3940. Limit Occurrences in Sorted Array — Easy
- 3983. Subsequence After One Replacement — Medium
- 3991. Sort Array Using Prefix Reversals — Medium
- 3992. Rearrange String to Avoid Character Pair — Easy
- 3998. Transform Binary String Using Subsequence Sort — Medium
- 3999. Minimum Number of String Groups Through Transformations — Hard
- 4001. Aggregate Two Time Series — Medium
- 4014. Minimum Total Price After Applying Discounts — Medium
- 4026. Maximum Gap Between Stations — Medium
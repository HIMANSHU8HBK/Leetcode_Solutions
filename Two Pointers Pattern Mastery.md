# Two Pointers Pattern Mastery

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
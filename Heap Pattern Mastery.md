# Heap (Priority Queue) Pattern Mastery

A practical notes document for studying Heap and Priority Queue problems on LeetCode.

> A heap is useful when the next decision must always use the smallest or largest currently available item. The pattern appears in top-k selection, streaming medians, scheduling, greedy resource allocation, graph exploration, and merging sorted sources.

---

## 1. What is the Heap pattern?

Use a heap when:
- you repeatedly need the minimum or maximum remaining value
- items arrive over time and the best current item must be selected
- a problem asks for top k, kth, median, or running priority
- multiple sorted streams must be merged
- tasks, intervals, or resources compete by earliest deadline or finish time
- a greedy choice must be revisited as better information becomes available

Python provides a min-heap through `heapq`. Use negative values to simulate a max-heap.

The central invariant is:

> The heap contains exactly the currently available candidates, and its root is the next candidate that the algorithm must consider.

---

## 2. Sub-pattern map

### A. Top-k selection and kth-element problems

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [215. Kth Largest Element in an Array](https://leetcode.com/problems/kth-largest-element-in-an-array/) | Medium | Keep only the k largest values. |
| [347. Top K Frequent Elements](https://leetcode.com/problems/top-k-frequent-elements/) | Medium | Select values by frequency. |
| [692. Top K Frequent Words](https://leetcode.com/problems/top-k-frequent-words/) | Medium | Priority by frequency and lexicographic order. |
| [703. Kth Largest Element in a Stream](https://leetcode.com/problems/kth-largest-element-in-a-stream/) | Easy | Maintain a size-k min-heap while values arrive. |
| [973. K Closest Points to Origin](https://leetcode.com/problems/k-closest-points-to-origin/) | Medium | Keep the k smallest distances. |
| [1046. Last Stone Weight](https://leetcode.com/problems/last-stone-weight/) | Easy | Repeatedly remove the two largest stones. |
| [378. Kth Smallest Element in a Sorted Matrix](https://leetcode.com/problems/kth-smallest-element-in-a-sorted-matrix/) | Medium | Merge sorted matrix rows with a heap. |

#### Solution: [215. Kth Largest Element in an Array](https://leetcode.com/problems/kth-largest-element-in-an-array/) - Medium

```python
import heapq

class Solution:
    def findKthLargest(self, nums, k):
        heap = []
        for value in nums:
            heapq.heappush(heap, value)
            if len(heap) > k:
                heapq.heappop(heap)
        return heap[0]
```

Why it works: the heap stores only the k largest values seen so far, so its smallest value is the kth largest overall.

#### Solution: [347. Top K Frequent Elements](https://leetcode.com/problems/top-k-frequent-elements/) - Medium

```python
import heapq
from collections import Counter

class Solution:
    def topKFrequent(self, nums, k):
        counts = Counter(nums)
        heap = []

        for value, frequency in counts.items():
            heapq.heappush(heap, (frequency, value))
            if len(heap) > k:
                heapq.heappop(heap)

        return [value for frequency, value in heap]
```

Why it works: maintain a min-heap of the k most frequent values and discard the weakest frequency whenever the heap grows too large.

#### Solution: [692. Top K Frequent Words](https://leetcode.com/problems/top-k-frequent-words/) - Medium

```python
from collections import Counter

class Solution:
    def topKFrequent(self, words, k):
        counts = Counter(words)
        ordered = sorted(counts, key=lambda word: (-counts[word], word))
        return ordered[:k]
```

Why it works: sort by descending frequency and ascending word order, exactly matching the required priority.

#### Solution: [703. Kth Largest Element in a Stream](https://leetcode.com/problems/kth-largest-element-in-a-stream/) - Easy

```python
import heapq

class KthLargest:
    def __init__(self, k, nums):
        self.k = k
        self.heap = []
        for value in nums:
            self.add(value)

    def add(self, val):
        heapq.heappush(self.heap, val)
        if len(self.heap) > self.k:
            heapq.heappop(self.heap)
        return self.heap[0]
```

Why it works: after every insertion, a size-k min-heap keeps the k largest stream values and exposes the kth largest at its root.

#### Solution: [973. K Closest Points to Origin](https://leetcode.com/problems/k-closest-points-to-origin/) - Medium

```python
import heapq

class Solution:
    def kClosest(self, points, k):
        heap = []
        for x, y in points:
            distance = x * x + y * y
            heapq.heappush(heap, (-distance, x, y))
            if len(heap) > k:
                heapq.heappop(heap)
        return [[x, y] for distance, x, y in heap]
```

Why it works: use a max-heap of size k so the farthest point among the kept candidates is removed first.

#### Solution: [1046. Last Stone Weight](https://leetcode.com/problems/last-stone-weight/) - Easy

```python
import heapq

class Solution:
    def lastStoneWeight(self, stones):
        heap = [-stone for stone in stones]
        heapq.heapify(heap)

        while len(heap) > 1:
            heaviest = -heapq.heappop(heap)
            second = -heapq.heappop(heap)
            if heaviest != second:
                heapq.heappush(heap, -(heaviest - second))

        return -heap[0] if heap else 0
```

Why it works: a negative min-heap acts as a max-heap, so each operation gets the two heaviest remaining stones.

#### Solution: [378. Kth Smallest Element in a Sorted Matrix](https://leetcode.com/problems/kth-smallest-element-in-a-sorted-matrix/) - Medium

```python
import heapq

class Solution:
    def kthSmallest(self, matrix, k):
        heap = []
        for row in range(min(k, len(matrix))):
            heapq.heappush(heap, (matrix[row][0], row, 0))

        value = 0
        for _ in range(k):
            value, row, column = heapq.heappop(heap)
            if column + 1 < len(matrix[row]):
                heapq.heappush(heap, (matrix[row][column + 1], row, column + 1))

        return value
```

Why it works: each matrix row is sorted, so the heap merges the rows and repeatedly extracts the next smallest element.

---

### B. Merge k sorted sources

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [23. Merge k Sorted Lists](https://leetcode.com/problems/merge-k-sorted-lists/) | Hard | Heap selects the smallest current list node. |
| [373. Find K Pairs with Smallest Sums](https://leetcode.com/problems/find-k-pairs-with-smallest-sums/) | Medium | Heap explores sorted pair candidates. |
| [632. Smallest Range Covering Elements from K Lists](https://leetcode.com/problems/smallest-range-covering-elements-from-k-lists/) | Hard | Track the current minimum and maximum across lists. |
| [786. K-th Smallest Prime Fraction](https://leetcode.com/problems/k-th-smallest-prime-fraction/) | Medium | Heap orders fraction candidates. |

#### Solution: [23. Merge k Sorted Lists](https://leetcode.com/problems/merge-k-sorted-lists/) - Hard

```python
import heapq

class Solution:
    def mergeKLists(self, lists):
        heap = []
        for index, node in enumerate(lists):
            if node:
                heapq.heappush(heap, (node.val, index, node))

        dummy = ListNode(0)
        tail = dummy
        while heap:
            value, index, node = heapq.heappop(heap)
            tail.next = node
            tail = node
            if node.next:
                heapq.heappush(heap, (node.next.val, index, node.next))

        return dummy.next
```

Why it works: the heap contains the smallest unmerged node from every non-empty list.

#### Solution: [373. Find K Pairs with Smallest Sums](https://leetcode.com/problems/find-k-pairs-with-smallest-sums/) - Medium

```python
import heapq

class Solution:
    def kSmallestPairs(self, nums1, nums2, k):
        if not nums1 or not nums2:
            return []

        heap = [(nums1[i] + nums2[0], i, 0) for i in range(min(k, len(nums1)))]
        heapq.heapify(heap)
        result = []

        while heap and len(result) < k:
            total, i, j = heapq.heappop(heap)
            result.append([nums1[i], nums2[j]])
            if j + 1 < len(nums2):
                heapq.heappush(heap, (nums1[i] + nums2[j + 1], i, j + 1))

        return result
```

Why it works: each row of pair sums is sorted, so the heap performs a k-way merge over those implicit rows.

#### Solution: [632. Smallest Range Covering Elements from K Lists](https://leetcode.com/problems/smallest-range-covering-elements-from-k-lists/) - Hard

```python
import heapq

class Solution:
    def smallestRange(self, nums):
        heap = []
        current_max = float('-inf')

        for list_index, values in enumerate(nums):
            heapq.heappush(heap, (values[0], list_index, 0))
            current_max = max(current_max, values[0])

        best = [heap[0][0], current_max]
        while True:
            current_min, list_index, value_index = heapq.heappop(heap)
            if current_max - current_min < best[1] - best[0]:
                best = [current_min, current_max]

            if value_index + 1 == len(nums[list_index]):
                break
            next_value = nums[list_index][value_index + 1]
            current_max = max(current_max, next_value)
            heapq.heappush(heap, (next_value, list_index, value_index + 1))

        return best
```

Why it works: the heap supplies the current range minimum, while current_max tracks the largest value represented by the range.

---

### C. Two heaps and streaming order statistics

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [295. Find Median from Data Stream](https://leetcode.com/problems/find-median-from-data-stream/) | Hard | Two heaps split the lower and upper halves. |
| [480. Sliding Window Median](https://leetcode.com/problems/sliding-window-median/) | Hard | Ordered window median with delayed removal. |
| [502. IPO](https://leetcode.com/problems/ipo/) | Hard | Move affordable projects into a max-heap. |
| [1825. Finding MK Average](https://leetcode.com/problems/finding-mk-average/) | Hard | Maintain ordered partitions for a trimmed average. |

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

Why it works: the max-heap lower half and min-heap upper half remain balanced, so the median is always at their roots.

#### Solution: [502. IPO](https://leetcode.com/problems/ipo/) - Hard

```python
import heapq

class Solution:
    def findMaximizedCapital(self, k, w, profits, capital):
        projects = sorted(zip(capital, profits))
        available = []
        index = 0

        for _ in range(k):
            while index < len(projects) and projects[index][0] <= w:
                heapq.heappush(available, -projects[index][1])
                index += 1
            if not available:
                break
            w -= heapq.heappop(available)

        return w
```

Why it works: add every currently affordable project to a max-heap and always choose the one with the greatest profit.

---

### D. Scheduling and resource allocation

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [253. Meeting Rooms II](https://leetcode.com/problems/meeting-rooms-ii/) | Medium | Min-heap tracks the earliest room release. |
| [621. Task Scheduler](https://leetcode.com/problems/task-scheduler/) | Medium | Max-heap schedules the most frequent remaining task. |
| [630. Course Schedule III](https://leetcode.com/problems/course-schedule-iii/) | Hard | Replace the longest course when needed. |
| [1834. Single-Threaded CPU](https://leetcode.com/problems/single-threaded-cpu/) | Medium | Select the available task by processing time and index. |
| [2402. Meeting Rooms III](https://leetcode.com/problems/meeting-rooms-iii/) | Hard | Heaps track available rooms and occupied rooms. |
| [2532. Time to Cross a Bridge](https://leetcode.com/problems/time-to-cross-a-bridge/) | Hard | Priority queues model workers waiting and crossing. |

#### Solution: [253. Meeting Rooms II](https://leetcode.com/problems/meeting-rooms-ii/) - Medium

```python
import heapq

class Solution:
    def minMeetingRooms(self, intervals):
        intervals.sort()
        ending_times = []

        for start, end in intervals:
            if ending_times and ending_times[0] <= start:
                heapq.heappop(ending_times)
            heapq.heappush(ending_times, end)

        return len(ending_times)
```

Why it works: reuse the room that finishes earliest whenever it is available; otherwise a new room is required.

#### Solution: [621. Task Scheduler](https://leetcode.com/problems/task-scheduler/) - Medium

```python
import heapq
from collections import Counter

class Solution:
    def leastInterval(self, tasks, n):
        counts = Counter(tasks)
        heap = [-frequency for frequency in counts.values()]
        heapq.heapify(heap)
        time = 0

        while heap:
            waiting = []
            for _ in range(n + 1):
                time += 1
                if heap:
                    remaining = -heapq.heappop(heap) - 1
                    if remaining:
                        waiting.append(remaining)
                if not heap and not waiting:
                    break
            for remaining in waiting:
                heapq.heappush(heap, -remaining)

        return time
```

Why it works: each cycle has n+1 slots, and the most frequent remaining tasks should occupy its earliest slots.

#### Solution: [630. Course Schedule III](https://leetcode.com/problems/course-schedule-iii/) - Hard

```python
import heapq

class Solution:
    def scheduleCourse(self, courses):
        courses.sort(key=lambda course: course[1])
        selected = []
        elapsed = 0

        for duration, deadline in courses:
            heapq.heappush(selected, -duration)
            elapsed += duration
            if elapsed > deadline:
                elapsed += heapq.heappop(selected)

        return len(selected)
```

Why it works: when a schedule misses a deadline, remove the longest selected course, preserving the maximum possible number of courses.

#### Solution: [1834. Single-Threaded CPU](https://leetcode.com/problems/single-threaded-cpu/) - Medium

```python
import heapq

class Solution:
    def getOrder(self, tasks):
        ordered = sorted((start, duration, index) for index, (start, duration) in enumerate(tasks))
        available = []
        result = []
        time = 0
        index = 0

        while index < len(ordered) or available:
            if not available and time < ordered[index][0]:
                time = ordered[index][0]

            while index < len(ordered) and ordered[index][0] <= time:
                start, duration, task_index = ordered[index]
                heapq.heappush(available, (duration, task_index))
                index += 1

            duration, task_index = heapq.heappop(available)
            time += duration
            result.append(task_index)

        return result
```

Why it works: once tasks are available, the heap enforces the CPU rule of shortest duration, then lowest index.

#### Solution: [2402. Meeting Rooms III](https://leetcode.com/problems/meeting-rooms-iii/) - Hard

```python
import heapq

class Solution:
    def mostBooked(self, n, meetings):
        meetings.sort()
        available = list(range(n))
        occupied = []
        used = [0] * n

        for start, end in meetings:
            duration = end - start
            while occupied and occupied[0][0] <= start:
                finish, room = heapq.heappop(occupied)
                heapq.heappush(available, room)

            if available:
                room = heapq.heappop(available)
                finish = end
            else:
                finish, room = heapq.heappop(occupied)
                finish += duration

            heapq.heappush(occupied, (finish, room))
            used[room] += 1

        return max(range(n), key=lambda room: used[room])
```

Why it works: one heap chooses the lowest-numbered free room, while the other chooses the room that becomes free earliest when all rooms are occupied.

---

### E. Greedy resource allocation and graph exploration

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [1642. Furthest Building You Can Reach](https://leetcode.com/problems/furthest-building-you-can-reach/) | Medium | Use ladders on the largest climbs and bricks on smaller ones. |
| [871. Minimum Number of Refueling Stops](https://leetcode.com/problems/minimum-number-of-refueling-stops/) | Hard | Max-heap chooses the best previous fuel station. |
| [857. Minimum Cost to Hire K Workers](https://leetcode.com/problems/minimum-cost-to-hire-k-workers/) | Hard | Maintain the k smallest qualities under a ratio threshold. |
| [1383. Maximum Performance of a Team](https://leetcode.com/problems/maximum-performance-of-a-team/) | Hard | Heap keeps the best k speeds for each efficiency threshold. |
| [1094. Car Pooling](https://leetcode.com/problems/car-pooling/) | Medium | Events and capacity can be processed in time order. |

#### Solution: [1642. Furthest Building You Can Reach](https://leetcode.com/problems/furthest-building-you-can-reach/) - Medium

```python
import heapq

class Solution:
    def furthestBuilding(self, heights, bricks, ladders):
        climbs = []

        for index in range(len(heights) - 1):
            climb = heights[index + 1] - heights[index]
            if climb <= 0:
                continue

            heapq.heappush(climbs, climb)
            if len(climbs) > ladders:
                bricks -= heapq.heappop(climbs)
            if bricks < 0:
                return index

        return len(heights) - 1
```

Why it works: reserve ladders for the largest climbs; the min-heap identifies the smallest climb to pay with bricks whenever too many climbs are stored.

#### Solution: [871. Minimum Number of Refueling Stops](https://leetcode.com/problems/minimum-number-of-refueling-stops/) - Hard

```python
import heapq

class Solution:
    def minRefuelStops(self, target, startFuel, stations):
        stations = stations + [[target, 0]]
        fuel_heap = []
        previous = 0
        fuel = startFuel
        stops = 0

        for position, amount in stations:
            fuel -= position - previous
            while fuel < 0 and fuel_heap:
                fuel += -heapq.heappop(fuel_heap)
                stops += 1
            if fuel < 0:
                return -1
            heapq.heappush(fuel_heap, -amount)
            previous = position

        return stops
```

Why it works: when fuel is insufficient, take the largest fuel amount from all stations already passed.

#### Solution: [857. Minimum Cost to Hire K Workers](https://leetcode.com/problems/minimum-cost-to-hire-k-workers/) - Hard

```python
import heapq

class Solution:
    def mincostToHireWorkers(self, quality, wage, k):
        workers = sorted((w / q, q) for q, w in zip(quality, wage))
        qualities = []
        quality_sum = 0
        best = float('inf')

        for ratio, worker_quality in workers:
            heapq.heappush(qualities, -worker_quality)
            quality_sum += worker_quality
            if len(qualities) > k:
                quality_sum += heapq.heappop(qualities)
            if len(qualities) == k:
                best = min(best, quality_sum * ratio)

        return best
```

Why it works: for a fixed highest wage-to-quality ratio, select the k smallest qualities to minimize total payment.

#### Solution: [1383. Maximum Performance of a Team](https://leetcode.com/problems/maximum-performance-of-a-team/) - Hard

```python
import heapq

class Solution:
    def maxPerformance(self, n, speed, efficiency, k):
        engineers = sorted(zip(efficiency, speed), reverse=True)
        speeds = []
        speed_sum = 0
        best = 0
        modulo = 10**9 + 7

        for current_efficiency, current_speed in engineers:
            heapq.heappush(speeds, current_speed)
            speed_sum += current_speed
            if len(speeds) > k:
                speed_sum -= heapq.heappop(speeds)
            best = max(best, speed_sum * current_efficiency)

        return best % modulo
```

Why it works: process engineers by descending efficiency, so the current efficiency is the team minimum; keep the fastest k speeds with a min-heap.

---

#### Solution: [1094. Car Pooling](https://leetcode.com/problems/car-pooling/) - Medium

```python
class Solution:
    def carPooling(self, trips, capacity):
        difference = [0] * 1001
        for passengers, start, end in trips:
            difference[start] += passengers
            difference[end] -= passengers

        current = 0
        for change in difference:
            current += change
            if current > capacity:
                return False
        return True
```

Why it works: each trip adds passengers at its start and removes them at its end; the running total is the number of passengers in the vehicle.

#### Solution: [1825. Finding MK Average](https://leetcode.com/problems/finding-mk-average/) - Hard

```python
from bisect import bisect_left, insort
from collections import deque

class MKAverage:
    def __init__(self, m, k):
        self.m = m
        self.k = k
        self.values = deque()
        self.sorted_values = []

    def addElement(self, num):
        self.values.append(num)
        insort(self.sorted_values, num)
        if len(self.values) > self.m:
            outgoing = self.values.popleft()
            self.sorted_values.pop(bisect_left(self.sorted_values, outgoing))

    def calculateMKAverage(self):
        if len(self.values) < self.m:
            return -1
        middle = self.sorted_values[self.k:self.m - self.k]
        return sum(middle) // len(middle)
```

Why it works: keep the last m values in arrival order and sorted order, then sum the middle values after excluding the k smallest and k largest.

#### Solution: [2532. Time to Cross a Bridge](https://leetcode.com/problems/time-to-cross-a-bridge/) - Hard

```python
import heapq

class Solution:
    def findCrossingTime(self, n, k, time):
        waiting_left = [(-time[i][0] - time[i][2], -i) for i in range(k)]
        waiting_right = []
        working_left = []
        working_right = []
        heapq.heapify(waiting_left)
        current = 0

        while n > 0 or working_left or working_right or waiting_right:
            while working_left and working_left[0][0] <= current:
                finish, worker = heapq.heappop(working_left)
                heapq.heappush(waiting_left, (-time[worker][0] - time[worker][2], -worker))
            while working_right and working_right[0][0] <= current:
                finish, worker = heapq.heappop(working_right)
                heapq.heappush(waiting_right, (-time[worker][0] - time[worker][2], -worker))

            if waiting_right:
                _, negative_worker = heapq.heappop(waiting_right)
                worker = -negative_worker
                current += time[worker][2]
                heapq.heappush(working_left, (current + time[worker][3], worker))
            elif n > 0 and waiting_left:
                _, negative_worker = heapq.heappop(waiting_left)
                worker = -negative_worker
                current += time[worker][0]
                n -= 1
                heapq.heappush(working_right, (current + time[worker][1], worker))
            else:
                next_time = []
                if working_left:
                    next_time.append(working_left[0][0])
                if working_right:
                    next_time.append(working_right[0][0])
                current = min(next_time)

        return current
```

Why it works: workers waiting on the right have priority, while heaps track workers becoming available on each side and the bridge simulation advances to the next event.

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

Why it works: maintain the active window in sorted order, remove the outgoing item, insert the incoming item, and read its center.

#### Solution: [786. K-th Smallest Prime Fraction](https://leetcode.com/problems/k-th-smallest-prime-fraction/) - Medium

```python
import heapq

class Solution:
    def kthSmallestPrimeFraction(self, arr, k):
        heap = [(arr[i] / arr[-1], i, len(arr) - 1) for i in range(len(arr) - 1)]
        heapq.heapify(heap)

        for _ in range(k - 1):
            fraction, numerator, denominator = heapq.heappop(heap)
            if denominator - 1 > numerator:
                next_denominator = denominator - 1
                heapq.heappush(heap, (arr[numerator] / arr[next_denominator], numerator, next_denominator))

        _, numerator, denominator = heapq.heappop(heap)
        return [arr[numerator], arr[denominator]]
```

Why it works: each numerator generates a sorted sequence of fractions as the denominator moves left, and the heap performs a k-way merge of those sequences.

---

## 3. Quick pattern recognition guide

### Use a min-heap when you see:
- kth largest with a bounded k
- k smallest candidates
- earliest finish time
- smallest current value across sorted streams

### Use a max-heap when you see:
- repeatedly choose the largest available item
- maximize profit or fuel from available options
- repeatedly combine the two largest values

### Use two heaps when you see:
- running median
- lower and upper halves of an ordered stream
- insertion and removal around a moving median

### Use multiple heaps when you see:
- resources becoming available over time
- tasks ordered by one priority after becoming eligible
- rooms, machines, or workers with different availability states

---

## 4. Core templates

### Size-k min-heap

```python
import heapq

heap = []
for value in values:
    heapq.heappush(heap, value)
    if len(heap) > k:
        heapq.heappop(heap)
```

### Max-heap in Python

```python
heapq.heappush(heap, -value)
largest = -heapq.heappop(heap)
```

### Two heaps for median

```python
lower = []
upper = []

heapq.heappush(lower, -value)
heapq.heappush(upper, -heapq.heappop(lower))
if len(upper) > len(lower):
    heapq.heappush(lower, -heapq.heappop(upper))
```

### Available versus occupied resources

```python
while occupied and occupied[0].finish <= current_time:
    resource = heapq.heappop(occupied)
    heapq.heappush(available, resource.id)
```

---

## 5. Practice order

1. [215. Kth Largest Element in an Array](https://leetcode.com/problems/kth-largest-element-in-an-array/)
2. [1046. Last Stone Weight](https://leetcode.com/problems/last-stone-weight/)
3. [703. Kth Largest Element in a Stream](https://leetcode.com/problems/kth-largest-element-in-a-stream/)
4. [347. Top K Frequent Elements](https://leetcode.com/problems/top-k-frequent-elements/)
5. [23. Merge k Sorted Lists](https://leetcode.com/problems/merge-k-sorted-lists/)
6. [295. Find Median from Data Stream](https://leetcode.com/problems/find-median-from-data-stream/)
7. [253. Meeting Rooms II](https://leetcode.com/problems/meeting-rooms-ii/)
8. [621. Task Scheduler](https://leetcode.com/problems/task-scheduler/)
9. [1642. Furthest Building You Can Reach](https://leetcode.com/problems/furthest-building-you-can-reach/)
10. [857. Minimum Cost to Hire K Workers](https://leetcode.com/problems/minimum-cost-to-hire-k-workers/)

---

## 6. Cheat sheet

- Size-k selection: keep a heap bounded at k.
- Kth largest: use a size-k min-heap.
- K closest: use a size-k max-heap.
- Median: balance a max-heap lower half and min-heap upper half.
- Merge sorted sources: push one head from each source.
- Scheduling: move eligible tasks into a priority heap, then process the best one.
- Resource allocation: separate available resources from occupied resources.
- Greedy capacity: use a heap to retain the most valuable choices that remain feasible.

---

## 7. Interview trigger

Reach for a Heap when the statement includes:

- kth, top k, closest k, or most frequent k
- continuously arriving values
- next task, earliest room, smallest cost, or largest profit
- merge several sorted lists or streams
- choose the best currently available option
- median or percentile over a changing collection

Before coding, define what each heap contains and why its root is the next valid decision.

---

## 8. Common mistakes

- using a max-heap when a bounded min-heap is required for kth largest
- forgetting to negate values when simulating a max-heap
- comparing heap entries without a deterministic tie-breaker
- failing to add newly eligible tasks or resources
- forgetting to remove expired or occupied resources
- using a heap when sorting once is simpler and sufficient
- storing mutable objects in heap tuples without a comparable tie-breaker

---

## 9. Current coverage

Every problem currently listed in the Heap sub-pattern tables and practice order has a direct solution above.

Current mapped inventory:

- 26 unique Heap problems
- 26 direct solutions
- 0 unsolved entries in the current file

The attached Heap export is now represented in the backlog below. Existing solved problems are excluded from that backlog.

---

## 10. Remaining problems from the attached Heap list

These 195 problems were present in the attachment but do not yet have direct solutions above. They are listed here as the next solution backlog. Existing solved problems are intentionally excluded.

- [218. The Skyline Problem](https://leetcode.com/problems/the-skyline-problem/) - Hard
- [239. Sliding Window Maximum](https://leetcode.com/problems/sliding-window-maximum/) - Hard
- [264. Ugly Number II](https://leetcode.com/problems/ugly-number-ii/) - Medium
- [272. Closest Binary Search Tree Value II](https://leetcode.com/problems/closest-binary-search-tree-value-ii/) - Hard
- [332. Reconstruct Itinerary](https://leetcode.com/problems/reconstruct-itinerary/) - Hard
- [355. Design Twitter](https://leetcode.com/problems/design-twitter/) - Medium
- [358. Rearrange String k Distance Apart](https://leetcode.com/problems/rearrange-string-k-distance-apart/) - Hard
- [407. Trapping Rain Water II](https://leetcode.com/problems/trapping-rain-water-ii/) - Hard
- [420. Strong Password Checker](https://leetcode.com/problems/strong-password-checker/) - Hard
- [451. Sort Characters By Frequency](https://leetcode.com/problems/sort-characters-by-frequency/) - Medium
- [499. The Maze III](https://leetcode.com/problems/the-maze-iii/) - Hard
- [505. The Maze II](https://leetcode.com/problems/the-maze-ii/) - Medium
- [506. Relative Ranks](https://leetcode.com/problems/relative-ranks/) - Easy
- [642. Design Search Autocomplete System](https://leetcode.com/problems/design-search-autocomplete-system/) - Hard
- [658. Find K Closest Elements](https://leetcode.com/problems/find-k-closest-elements/) - Medium
- [659. Split Array into Consecutive Subsequences](https://leetcode.com/problems/split-array-into-consecutive-subsequences/) - Medium
- [675. Cut Off Trees for Golf Event](https://leetcode.com/problems/cut-off-trees-for-golf-event/) - Hard
- [683. K Empty Slots](https://leetcode.com/problems/k-empty-slots/) - Hard
- [743. Network Delay Time](https://leetcode.com/problems/network-delay-time/) - Medium
- [759. Employee Free Time](https://leetcode.com/problems/employee-free-time/) - Hard
- [767. Reorganize String](https://leetcode.com/problems/reorganize-string/) - Medium
- [778. Swim in Rising Water](https://leetcode.com/problems/swim-in-rising-water/) - Hard
- [787. Cheapest Flights Within K Stops](https://leetcode.com/problems/cheapest-flights-within-k-stops/) - Medium
- [855. Exam Room](https://leetcode.com/problems/exam-room/) - Medium
- [862. Shortest Subarray with Sum at Least K](https://leetcode.com/problems/shortest-subarray-with-sum-at-least-k/) - Hard
- [882. Reachable Nodes In Subdivided Graph](https://leetcode.com/problems/reachable-nodes-in-subdivided-graph/) - Hard
- [912. Sort an Array](https://leetcode.com/problems/sort-an-array/) - Medium
- [1054. Distant Barcodes](https://leetcode.com/problems/distant-barcodes/) - Medium
- [1057. Campus Bikes](https://leetcode.com/problems/campus-bikes/) - Medium
- [1086. High Five](https://leetcode.com/problems/high-five/) - Easy
- [1102. Path With Maximum Minimum Value](https://leetcode.com/problems/path-with-maximum-minimum-value/) - Medium
- [1135. Connecting Cities With Minimum Cost](https://leetcode.com/problems/connecting-cities-with-minimum-cost/) - Medium
- [1167. Minimum Cost to Connect Sticks](https://leetcode.com/problems/minimum-cost-to-connect-sticks/) - Medium
- [1168. Optimize Water Distribution in a Village](https://leetcode.com/problems/optimize-water-distribution-in-a-village/) - Hard
- [1172. Dinner Plate Stacks](https://leetcode.com/problems/dinner-plate-stacks/) - Hard
- [1183. Maximum Number of Ones](https://leetcode.com/problems/maximum-number-of-ones/) - Hard
- [1199. Minimum Time to Build Blocks](https://leetcode.com/problems/minimum-time-to-build-blocks/) - Hard
- [1263. Minimum Moves to Move a Box to Their Target Location](https://leetcode.com/problems/minimum-moves-to-move-a-box-to-their-target-location/) - Hard
- [1268. Search Suggestions System](https://leetcode.com/problems/search-suggestions-system/) - Medium
- [1337. The K Weakest Rows in a Matrix](https://leetcode.com/problems/the-k-weakest-rows-in-a-matrix/) - Easy
- [1338. Reduce Array Size to The Half](https://leetcode.com/problems/reduce-array-size-to-the-half/) - Medium
- [1353. Maximum Number of Events That Can Be Attended](https://leetcode.com/problems/maximum-number-of-events-that-can-be-attended/) - Medium
- [1354. Construct Target Array With Multiple Sums](https://leetcode.com/problems/construct-target-array-with-multiple-sums/) - Hard
- [1368. Minimum Cost to Make at Least One Valid Path in a Grid](https://leetcode.com/problems/minimum-cost-to-make-at-least-one-valid-path-in-a-grid/) - Hard
- [1388. Pizza With 3n Slices](https://leetcode.com/problems/pizza-with-3n-slices/) - Hard
- [1405. Longest Happy String](https://leetcode.com/problems/longest-happy-string/) - Medium
- [1424. Diagonal Traverse II](https://leetcode.com/problems/diagonal-traverse-ii/) - Medium
- [1425. Constrained Subsequence Sum](https://leetcode.com/problems/constrained-subsequence-sum/) - Hard
- [1438. Longest Continuous Subarray With Absolute Diff Less Than or Equal to Limit](https://leetcode.com/problems/longest-continuous-subarray-with-absolute-diff-less-than-or-equal-to-limit/) - Medium
- [1439. Find the Kth Smallest Sum of a Matrix With Sorted Rows](https://leetcode.com/problems/find-the-kth-smallest-sum-of-a-matrix-with-sorted-rows/) - Hard
- [1464. Maximum Product of Two Elements in an Array](https://leetcode.com/problems/maximum-product-of-two-elements-in-an-array/) - Easy
- [1488. Avoid Flood in The City](https://leetcode.com/problems/avoid-flood-in-the-city/) - Medium
- [1499. Max Value of Equation](https://leetcode.com/problems/max-value-of-equation/) - Hard
- [1500. Design a File Sharing System](https://leetcode.com/problems/design-a-file-sharing-system/) - Medium
- [1514. Path with Maximum Probability](https://leetcode.com/problems/path-with-maximum-probability/) - Medium
- [1606. Find Servers That Handled Most Number of Requests](https://leetcode.com/problems/find-servers-that-handled-most-number-of-requests/) - Hard
- [1631. Path With Minimum Effort](https://leetcode.com/problems/path-with-minimum-effort/) - Medium
- [1648. Sell Diminishing-Valued Colored Balls](https://leetcode.com/problems/sell-diminishing-valued-colored-balls/) - Medium
- [1675. Minimize Deviation in Array](https://leetcode.com/problems/minimize-deviation-in-array/) - Hard
- [1686. Stone Game VI](https://leetcode.com/problems/stone-game-vi/) - Medium
- [1687. Delivering Boxes from Storage to Ports](https://leetcode.com/problems/delivering-boxes-from-storage-to-ports/) - Hard
- [1696. Jump Game VI](https://leetcode.com/problems/jump-game-vi/) - Medium
- [1705. Maximum Number of Eaten Apples](https://leetcode.com/problems/maximum-number-of-eaten-apples/) - Medium
- [1724. Checking Existence of Edge Length Limited Paths II](https://leetcode.com/problems/checking-existence-of-edge-length-limited-paths-ii/) - Hard
- [1738. Find Kth Largest XOR Coordinate Value](https://leetcode.com/problems/find-kth-largest-xor-coordinate-value/) - Medium
- [1753. Maximum Score From Removing Stones](https://leetcode.com/problems/maximum-score-from-removing-stones/) - Medium
- [1776. Car Fleet II](https://leetcode.com/problems/car-fleet-ii/) - Hard
- [1786. Number of Restricted Paths From First to Last Node](https://leetcode.com/problems/number-of-restricted-paths-from-first-to-last-node/) - Medium
- [1792. Maximum Average Pass Ratio](https://leetcode.com/problems/maximum-average-pass-ratio/) - Medium
- [1801. Number of Orders in the Backlog](https://leetcode.com/problems/number-of-orders-in-the-backlog/) - Medium
- [1810. Minimum Path Cost in a Hidden Grid](https://leetcode.com/problems/minimum-path-cost-in-a-hidden-grid/) - Medium
- [1845. Seat Reservation Manager](https://leetcode.com/problems/seat-reservation-manager/) - Medium
- [1851. Minimum Interval to Include Each Query](https://leetcode.com/problems/minimum-interval-to-include-each-query/) - Hard
- [1878. Get Biggest Three Rhombus Sums in a Grid](https://leetcode.com/problems/get-biggest-three-rhombus-sums-in-a-grid/) - Medium
- [1882. Process Tasks Using Servers](https://leetcode.com/problems/process-tasks-using-servers/) - Medium
- [1912. Design Movie Rental System](https://leetcode.com/problems/design-movie-rental-system/) - Hard
- [1942. The Number of the Smallest Unoccupied Chair](https://leetcode.com/problems/the-number-of-the-smallest-unoccupied-chair/) - Medium
- [1962. Remove Stones to Minimize the Total](https://leetcode.com/problems/remove-stones-to-minimize-the-total/) - Medium
- [1985. Find the Kth Largest Integer in the Array](https://leetcode.com/problems/find-the-kth-largest-integer-in-the-array/) - Medium
- [2015. Average Height of Buildings in Each Segment](https://leetcode.com/problems/average-height-of-buildings-in-each-segment/) - Medium
- [2034. Stock Price Fluctuation](https://leetcode.com/problems/stock-price-fluctuation/) - Medium
- [2054. Two Best Non-Overlapping Events](https://leetcode.com/problems/two-best-non-overlapping-events/) - Medium
- [2093. Minimum Cost to Reach City With Discounts](https://leetcode.com/problems/minimum-cost-to-reach-city-with-discounts/) - Medium
- [2099. Find Subsequence of Length K With the Largest Sum](https://leetcode.com/problems/find-subsequence-of-length-k-with-the-largest-sum/) - Easy
- [2102. Sequentially Ordinal Rank Tracker](https://leetcode.com/problems/sequentially-ordinal-rank-tracker/) - Hard
- [2146. K Highest Ranked Items Within a Price Range](https://leetcode.com/problems/k-highest-ranked-items-within-a-price-range/) - Medium
- [2163. Minimum Difference in Sums After Removal of Elements](https://leetcode.com/problems/minimum-difference-in-sums-after-removal-of-elements/) - Hard
- [2182. Construct String With Repeat Limit](https://leetcode.com/problems/construct-string-with-repeat-limit/) - Medium
- [2203. Minimum Weighted Subgraph With the Required Paths](https://leetcode.com/problems/minimum-weighted-subgraph-with-the-required-paths/) - Hard
- [2208. Minimum Operations to Halve Array Sum](https://leetcode.com/problems/minimum-operations-to-halve-array-sum/) - Medium
- [2231. Largest Number After Digit Swaps by Parity](https://leetcode.com/problems/largest-number-after-digit-swaps-by-parity/) - Easy
- [2233. Maximum Product After K Increments](https://leetcode.com/problems/maximum-product-after-k-increments/) - Medium
- [2254. Design Video Sharing Platform](https://leetcode.com/problems/design-video-sharing-platform/) - Hard
- [2263. Make Array Non-decreasing or Non-increasing](https://leetcode.com/problems/make-array-non-decreasing-or-non-increasing/) - Hard
- [2285. Maximum Total Importance of Roads](https://leetcode.com/problems/maximum-total-importance-of-roads/) - Medium
- [2290. Minimum Obstacle Removal to Reach Corner](https://leetcode.com/problems/minimum-obstacle-removal-to-reach-corner/) - Hard
- [2333. Minimum Sum of Squared Difference](https://leetcode.com/problems/minimum-sum-of-squared-difference/) - Medium
- [2335. Minimum Amount of Time to Fill Cups](https://leetcode.com/problems/minimum-amount-of-time-to-fill-cups/) - Easy
- [2336. Smallest Number in Infinite Set](https://leetcode.com/problems/smallest-number-in-infinite-set/) - Medium
- [2342. Max Sum of a Pair With Equal Sum of Digits](https://leetcode.com/problems/max-sum-of-a-pair-with-equal-sum-of-digits/) - Medium
- [2343. Query Kth Smallest Trimmed Number](https://leetcode.com/problems/query-kth-smallest-trimmed-number/) - Medium
- [2344. Minimum Deletions to Make Array Divisible](https://leetcode.com/problems/minimum-deletions-to-make-array-divisible/) - Hard
- [2349. Design a Number Container System](https://leetcode.com/problems/design-a-number-container-system/) - Medium
- [2353. Design a Food Rating System](https://leetcode.com/problems/design-a-food-rating-system/) - Medium
- [2357. Make Array Zero by Subtracting Equal Amounts](https://leetcode.com/problems/make-array-zero-by-subtracting-equal-amounts/) - Easy
- [2386. Find the K-Sum of an Array](https://leetcode.com/problems/find-the-k-sum-of-an-array/) - Hard
- [2398. Maximum Number of Robots Within Budget](https://leetcode.com/problems/maximum-number-of-robots-within-budget/) - Hard
- [2406. Divide Intervals Into Minimum Number of Groups](https://leetcode.com/problems/divide-intervals-into-minimum-number-of-groups/) - Medium
- [2424. Longest Uploaded Prefix](https://leetcode.com/problems/longest-uploaded-prefix/) - Medium
- [2454. Next Greater Element IV](https://leetcode.com/problems/next-greater-element-iv/) - Hard
- [2456. Most Popular Video Creator](https://leetcode.com/problems/most-popular-video-creator/) - Medium
- [2462. Total Cost to Hire K Workers](https://leetcode.com/problems/total-cost-to-hire-k-workers/) - Medium
- [2473. Minimum Cost to Buy Apples](https://leetcode.com/problems/minimum-cost-to-buy-apples/) - Medium
- [2497. Maximum Star Sum of a Graph](https://leetcode.com/problems/maximum-star-sum-of-a-graph/) - Medium
- [2500. Delete Greatest Value in Each Row](https://leetcode.com/problems/delete-greatest-value-in-each-row/) - Easy
- [2503. Maximum Number of Points From Grid Queries](https://leetcode.com/problems/maximum-number-of-points-from-grid-queries/) - Hard
- [2512. Reward Top K Students](https://leetcode.com/problems/reward-top-k-students/) - Medium
- [2530. Maximal Score After Applying K Operations](https://leetcode.com/problems/maximal-score-after-applying-k-operations/) - Medium
- [2542. Maximum Subsequence Score](https://leetcode.com/problems/maximum-subsequence-score/) - Medium
- [2551. Put Marbles in Bags](https://leetcode.com/problems/put-marbles-in-bags/) - Hard
- [2558. Take Gifts From the Richest Pile](https://leetcode.com/problems/take-gifts-from-the-richest-pile/) - Easy
- [2577. Minimum Time to Visit a Cell In a Grid](https://leetcode.com/problems/minimum-time-to-visit-a-cell-in-a-grid/) - Hard
- [2593. Find Score of an Array After Marking All Elements](https://leetcode.com/problems/find-score-of-an-array-after-marking-all-elements/) - Medium
- [2599. Make the Prefix Sum Non-negative](https://leetcode.com/problems/make-the-prefix-sum-non-negative/) - Medium
- [2611. Mice and Cheese](https://leetcode.com/problems/mice-and-cheese/) - Medium
- [2617. Minimum Number of Visited Cells in a Grid](https://leetcode.com/problems/minimum-number-of-visited-cells-in-a-grid/) - Hard
- [2642. Design Graph With Shortest Path Calculator](https://leetcode.com/problems/design-graph-with-shortest-path-calculator/) - Hard
- [2662. Minimum Cost of a Path With Special Roads](https://leetcode.com/problems/minimum-cost-of-a-path-with-special-roads/) - Medium
- [2679. Sum in a Matrix](https://leetcode.com/problems/sum-in-a-matrix/) - Medium
- [2699. Modify Graph Edge Weights](https://leetcode.com/problems/modify-graph-edge-weights/) - Hard
- [2714. Find Shortest Path with K Hops](https://leetcode.com/problems/find-shortest-path-with-k-hops/) - Hard
- [2737. Find the Closest Marked Node](https://leetcode.com/problems/find-the-closest-marked-node/) - Medium
- [2762. Continuous Subarrays](https://leetcode.com/problems/continuous-subarrays/) - Medium
- [2812. Find the Safest Path in a Grid](https://leetcode.com/problems/find-the-safest-path-in-a-grid/) - Medium
- [2813. Maximum Elegance of a K-Length Subsequence](https://leetcode.com/problems/maximum-elegance-of-a-k-length-subsequence/) - Hard
- [2931. Maximum Spending After Buying Items](https://leetcode.com/problems/maximum-spending-after-buying-items/) - Hard
- [2940. Find Building Where Alice and Bob Can Meet](https://leetcode.com/problems/find-building-where-alice-and-bob-can-meet/) - Hard
- [2944. Minimum Number of Coins for Fruits](https://leetcode.com/problems/minimum-number-of-coins-for-fruits/) - Medium
- [2959. Number of Possible Sets of Closing Branches](https://leetcode.com/problems/number-of-possible-sets-of-closing-branches/) - Hard
- [2969. Minimum Number of Coins for Fruits II](https://leetcode.com/problems/minimum-number-of-coins-for-fruits-ii/) - Hard
- [2973. Find Number of Coins to Place in Tree Nodes](https://leetcode.com/problems/find-number-of-coins-to-place-in-tree-nodes/) - Hard
- [2974. Minimum Number Game](https://leetcode.com/problems/minimum-number-game/) - Easy
- [3013. Divide an Array Into Subarrays With Minimum Cost II](https://leetcode.com/problems/divide-an-array-into-subarrays-with-minimum-cost-ii/) - Hard
- [3049. Earliest Second to Mark Indices II](https://leetcode.com/problems/earliest-second-to-mark-indices-ii/) - Hard
- [3066. Minimum Operations to Exceed Threshold Value II](https://leetcode.com/problems/minimum-operations-to-exceed-threshold-value-ii/) - Medium
- [3080. Mark Elements on Array by Performing Queries](https://leetcode.com/problems/mark-elements-on-array-by-performing-queries/) - Medium
- [3081. Replace Question Marks in String to Minimize Its Value](https://leetcode.com/problems/replace-question-marks-in-string-to-minimize-its-value/) - Medium
- [3092. Most Frequent IDs](https://leetcode.com/problems/most-frequent-ids/) - Medium
- [3112. Minimum Time to Visit Disappearing Nodes](https://leetcode.com/problems/minimum-time-to-visit-disappearing-nodes/) - Medium
- [3123. Find Edges in Shortest Paths](https://leetcode.com/problems/find-edges-in-shortest-paths/) - Hard
- [3170. Lexicographically Minimum String After Removing Stars](https://leetcode.com/problems/lexicographically-minimum-string-after-removing-stars/) - Medium
- [3264. Final Array State After K Multiplication Operations I](https://leetcode.com/problems/final-array-state-after-k-multiplication-operations-i/) - Easy
- [3266. Final Array State After K Multiplication Operations II](https://leetcode.com/problems/final-array-state-after-k-multiplication-operations-ii/) - Hard
- [3275. K-th Nearest Obstacle Queries](https://leetcode.com/problems/k-th-nearest-obstacle-queries/) - Medium
- [3286. Find a Safe Walk Through a Grid](https://leetcode.com/problems/find-a-safe-walk-through-a-grid/) - Medium
- [3296. Minimum Number of Seconds to Make Mountain Height Zero](https://leetcode.com/problems/minimum-number-of-seconds-to-make-mountain-height-zero/) - Medium
- [3318. Find X-Sum of All K-Long Subarrays I](https://leetcode.com/problems/find-x-sum-of-all-k-long-subarrays-i/) - Easy
- [3321. Find X-Sum of All K-Long Subarrays II](https://leetcode.com/problems/find-x-sum-of-all-k-long-subarrays-ii/) - Hard
- [3341. Find Minimum Time to Reach Last Room I](https://leetcode.com/problems/find-minimum-time-to-reach-last-room-i/) - Medium
- [3342. Find Minimum Time to Reach Last Room II](https://leetcode.com/problems/find-minimum-time-to-reach-last-room-ii/) - Medium
- [3362. Zero Array Transformation III](https://leetcode.com/problems/zero-array-transformation-iii/) - Medium
- [3369. Design an Array Statistics Tracker](https://leetcode.com/problems/design-an-array-statistics-tracker/) - Hard
- [3377. Digit Operations to Make Two Integers Equal](https://leetcode.com/problems/digit-operations-to-make-two-integers-equal/) - Medium
- [3391. Design a 3D Binary Matrix with Efficient Layer Tracking](https://leetcode.com/problems/design-a-3d-binary-matrix-with-efficient-layer-tracking/) - Medium
- [3408. Design Task Manager](https://leetcode.com/problems/design-task-manager/) - Medium
- [3422. Minimum Operations to Make Subarray Elements Equal](https://leetcode.com/problems/minimum-operations-to-make-subarray-elements-equal/) - Medium
- [3462. Maximum Sum With at Most K Elements](https://leetcode.com/problems/maximum-sum-with-at-most-k-elements/) - Medium
- [3476. Maximize Profit from Task Assignment](https://leetcode.com/problems/maximize-profit-from-task-assignment/) - Medium
- [3478. Choose K Elements With Maximum Sum](https://leetcode.com/problems/choose-k-elements-with-maximum-sum/) - Medium
- [3505. Minimum Operations to Make Elements Within K Subarrays Equal](https://leetcode.com/problems/minimum-operations-to-make-elements-within-k-subarrays-equal/) - Hard
- [3506. Find Time Required to Eliminate Bacterial Strains](https://leetcode.com/problems/find-time-required-to-eliminate-bacterial-strains/) - Hard
- [3507. Minimum Pair Removal to Sort Array I](https://leetcode.com/problems/minimum-pair-removal-to-sort-array-i/) - Easy
- [3510. Minimum Pair Removal to Sort Array II](https://leetcode.com/problems/minimum-pair-removal-to-sort-array-ii/) - Hard
- [3572. Maximize Y‑Sum by Picking a Triplet of Distinct X‑Values](https://leetcode.com/problems/maximize-y-sum-by-picking-a-triplet-of-distinct-x-values/) - Medium
- [3594. Minimum Time to Transport All Individuals](https://leetcode.com/problems/minimum-time-to-transport-all-individuals/) - Hard
- [3604. Minimum Time to Reach Destination in Directed Graph](https://leetcode.com/problems/minimum-time-to-reach-destination-in-directed-graph/) - Medium
- [3607. Power Grid Maintenance](https://leetcode.com/problems/power-grid-maintenance/) - Medium
- [3620. Network Recovery Pathways](https://leetcode.com/problems/network-recovery-pathways/) - Hard
- [3645. Maximum Total from Optimal Activation Order](https://leetcode.com/problems/maximum-total-from-optimal-activation-order/) - Medium
- [3650. Minimum Cost Path with Edge Reversals](https://leetcode.com/problems/minimum-cost-path-with-edge-reversals/) - Medium
- [3691. Maximum Total Subarray Value II](https://leetcode.com/problems/maximum-total-subarray-value-ii/) - Hard
- [3711. Maximum Transactions Without Negative Balance](https://leetcode.com/problems/maximum-transactions-without-negative-balance/) - Medium
- [3763. Maximum Total Sum with Threshold Constraints](https://leetcode.com/problems/maximum-total-sum-with-threshold-constraints/) - Medium
- [3767. Maximize Points After Choosing K Tasks](https://leetcode.com/problems/maximize-points-after-choosing-k-tasks/) - Medium
- [3780. Maximum Sum of Three Numbers Divisible by Three](https://leetcode.com/problems/maximum-sum-of-three-numbers-divisible-by-three/) - Medium
- [3781. Maximum Score After Binary Swaps](https://leetcode.com/problems/maximum-score-after-binary-swaps/) - Medium
- [3815. Design Auction System](https://leetcode.com/problems/design-auction-system/) - Medium
- [3885. Design Event Manager](https://leetcode.com/problems/design-event-manager/) - Medium
- [3928. Minimum Cost to Buy Apples II](https://leetcode.com/problems/minimum-cost-to-buy-apples-ii/) - Hard
- [3935. Power Update After K-th Largest Insertion I](https://leetcode.com/problems/power-update-after-k-th-largest-insertion-i/) - Medium
- [3947. Maximum Number of Items From Sale II](https://leetcode.com/problems/maximum-number-of-items-from-sale-ii/) - Medium
- [3962. Maximum Subarray Sum After at Most K Swaps](https://leetcode.com/problems/maximum-subarray-sum-after-at-most-k-swaps/) - Hard
- [3970. Shortest Path With At Most K Consecutive Identical Characters](https://leetcode.com/problems/shortest-path-with-at-most-k-consecutive-identical-characters/) - Medium
- [3977. Minimum Time to Reach Target With Limited Power](https://leetcode.com/problems/minimum-time-to-reach-target-with-limited-power/) - Hard
- [4003. Minimum Cost Path with Alternating Directions III](https://leetcode.com/problems/minimum-cost-path-with-alternating-directions-iii/) - Hard
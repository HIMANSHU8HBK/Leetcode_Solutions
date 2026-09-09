# Queue Pattern Mastery

A practical notes document for studying Queue and Deque problems on LeetCode.

> A queue is the right abstraction when items must be processed in arrival order. A deque extends that idea by allowing efficient operations at both ends, which makes it useful for sliding windows, breadth-first search, monotonic optimization, and simulations.

---

## 1. What is the Queue pattern?

Use a queue when:
- the oldest available item must be processed first
- a problem asks for level-order or breadth-first traversal
- tasks arrive and wait for service
- events must be simulated chronologically
- a sliding window needs both expiration and insertion
- a monotonic deque can keep only useful candidates

Typical idea:
- enqueue newly discovered or arriving items
- dequeue the oldest item to process it
- use a deque when both front and back operations matter
- preserve arrival order or a queue-specific invariant

The central invariant is:

> The queue contains the currently waiting items in the order in which the algorithm is allowed to process them.

---

## 2. Sub-pattern map

### A. Breadth-first search and level-order traversal

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [102. Binary Tree Level Order Traversal](https://leetcode.com/problems/binary-tree-level-order-traversal/) | Medium | Queue processes nodes level by level. |
| [103. Binary Tree Zigzag Level Order Traversal](https://leetcode.com/problems/binary-tree-zigzag-level-order-traversal/) | Medium | Queue traversal with alternating output direction. |
| [107. Binary Tree Level Order Traversal II](https://leetcode.com/problems/binary-tree-level-order-traversal-ii/) | Medium | BFS levels returned bottom-up. |
| [111. Minimum Depth of Binary Tree](https://leetcode.com/problems/minimum-depth-of-binary-tree/) | Easy | First BFS leaf gives the shortest depth. |
| [116. Populating Next Right Pointers in Each Node](https://leetcode.com/problems/populating-next-right-pointers-in-each-node/) | Medium | Level-order connections. |
| [200. Number of Islands](https://leetcode.com/problems/number-of-islands/) | Medium | Queue-based grid flood fill. |
| [994. Rotting Oranges](https://leetcode.com/problems/rotting-oranges/) | Medium | Multi-source BFS by time layers. |

#### Solution: [102. Binary Tree Level Order Traversal](https://leetcode.com/problems/binary-tree-level-order-traversal/) - Medium

```python
from collections import deque

class Solution:
    def levelOrder(self, root):
        if not root:
            return []

        result = []
        queue = deque([root])
        while queue:
            level = []
            for _ in range(len(queue)):
                node = queue.popleft()
                level.append(node.val)
                if node.left:
                    queue.append(node.left)
                if node.right:
                    queue.append(node.right)
            result.append(level)

        return result
```

Why it works: process exactly the nodes already in the queue before adding their children, which isolates one tree level at a time.

#### Solution: [103. Binary Tree Zigzag Level Order Traversal](https://leetcode.com/problems/binary-tree-zigzag-level-order-traversal/) - Medium

```python
from collections import deque

class Solution:
    def zigzagLevelOrder(self, root):
        if not root:
            return []

        result = []
        queue = deque([root])
        reverse = False

        while queue:
            level = []
            for _ in range(len(queue)):
                node = queue.popleft()
                level.append(node.val)
                if node.left:
                    queue.append(node.left)
                if node.right:
                    queue.append(node.right)
            if reverse:
                level.reverse()
            result.append(level)
            reverse = not reverse

        return result
```

Why it works: BFS still discovers nodes left to right, while reversing only the collected level creates the zigzag output.

#### Solution: [107. Binary Tree Level Order Traversal II](https://leetcode.com/problems/binary-tree-level-order-traversal-ii/) - Medium

```python
from collections import deque

class Solution:
    def levelOrderBottom(self, root):
        if not root:
            return []

        result = []
        queue = deque([root])
        while queue:
            level = []
            for _ in range(len(queue)):
                node = queue.popleft()
                level.append(node.val)
                if node.left:
                    queue.append(node.left)
                if node.right:
                    queue.append(node.right)
            result.append(level)

        return result[::-1]
```

Why it works: ordinary BFS creates levels top-down; reversing the completed list gives bottom-up order.

#### Solution: [111. Minimum Depth of Binary Tree](https://leetcode.com/problems/minimum-depth-of-binary-tree/) - Easy

```python
from collections import deque

class Solution:
    def minDepth(self, root):
        if not root:
            return 0

        queue = deque([(root, 1)])
        while queue:
            node, depth = queue.popleft()
            if not node.left and not node.right:
                return depth
            if node.left:
                queue.append((node.left, depth + 1))
            if node.right:
                queue.append((node.right, depth + 1))
```

Why it works: BFS visits nodes by increasing depth, so the first leaf encountered is the shallowest leaf.

#### Solution: [200. Number of Islands](https://leetcode.com/problems/number-of-islands/) - Medium

```python
from collections import deque

class Solution:
    def numIslands(self, grid):
        rows, columns = len(grid), len(grid[0])
        islands = 0

        for row in range(rows):
            for column in range(columns):
                if grid[row][column] != '1':
                    continue

                islands += 1
                grid[row][column] = '0'
                queue = deque([(row, column)])
                while queue:
                    current_row, current_column = queue.popleft()
                    for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        next_row = current_row + dr
                        next_column = current_column + dc
                        if (0 <= next_row < rows and 0 <= next_column < columns
                                and grid[next_row][next_column] == '1'):
                            grid[next_row][next_column] = '0'
                            queue.append((next_row, next_column))

        return islands
```

Why it works: every unvisited land cell starts one BFS flood fill, and marking cells when enqueued prevents duplicate visits.

#### Solution: [994. Rotting Oranges](https://leetcode.com/problems/rotting-oranges/) - Medium

```python
from collections import deque

class Solution:
    def orangesRotting(self, grid):
        rows, columns = len(grid), len(grid[0])
        queue = deque()
        fresh = 0

        for row in range(rows):
            for column in range(columns):
                if grid[row][column] == 2:
                    queue.append((row, column))
                elif grid[row][column] == 1:
                    fresh += 1

        minutes = 0
        while queue and fresh:
            for _ in range(len(queue)):
                row, column = queue.popleft()
                for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    next_row = row + dr
                    next_column = column + dc
                    if (0 <= next_row < rows and 0 <= next_column < columns
                            and grid[next_row][next_column] == 1):
                        grid[next_row][next_column] = 2
                        fresh -= 1
                        queue.append((next_row, next_column))
            minutes += 1

        return -1 if fresh else minutes
```

Why it works: all rotten oranges at the same minute are processed together, making each BFS layer one minute of spread.

---

### B. Shortest path and state-space BFS

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [127. Word Ladder](https://leetcode.com/problems/word-ladder/) | Hard | Queue explores transformations by distance. |
| [752. Open the Lock](https://leetcode.com/problems/open-the-lock/) | Medium | BFS over lock states. |
| [773. Sliding Puzzle](https://leetcode.com/problems/sliding-puzzle/) | Hard | Queue explores board configurations. |
| [815. Bus Routes](https://leetcode.com/problems/bus-routes/) | Hard | BFS over stops and routes. |
| [909. Snakes and Ladders](https://leetcode.com/problems/snakes-and-ladders/) | Medium | BFS finds minimum dice moves. |
| [1091. Shortest Path in Binary Matrix](https://leetcode.com/problems/shortest-path-in-binary-matrix/) | Medium | Grid BFS shortest path. |

#### Solution: [127. Word Ladder](https://leetcode.com/problems/word-ladder/) - Hard

```python
from collections import deque

class Solution:
    def ladderLength(self, beginWord, endWord, wordList):
        words = set(wordList)
        if endWord not in words:
            return 0

        queue = deque([(beginWord, 1)])
        while queue:
            word, distance = queue.popleft()
            if word == endWord:
                return distance

            for index in range(len(word)):
                for letter in 'abcdefghijklmnopqrstuvwxyz':
                    candidate = word[:index] + letter + word[index + 1:]
                    if candidate in words:
                        words.remove(candidate)
                        queue.append((candidate, distance + 1))

        return 0
```

Why it works: every edge changes one character, and BFS guarantees the first visit to the target uses the fewest transformations.

#### Solution: [752. Open the Lock](https://leetcode.com/problems/open-the-lock/) - Medium

```python
from collections import deque

class Solution:
    def openLock(self, deadends, target):
        blocked = set(deadends)
        if '0000' in blocked:
            return -1

        queue = deque([('0000', 0)])
        visited = {'0000'}

        while queue:
            state, moves = queue.popleft()
            if state == target:
                return moves

            for index in range(4):
                digit = int(state[index])
                for change in (-1, 1):
                    next_digit = (digit + change) % 10
                    candidate = state[:index] + str(next_digit) + state[index + 1:]
                    if candidate not in blocked and candidate not in visited:
                        visited.add(candidate)
                        queue.append((candidate, moves + 1))

        return -1
```

Why it works: each state has eight one-wheel neighbors, and BFS explores them in increasing move count.

#### Solution: [909. Snakes and Ladders](https://leetcode.com/problems/snakes-and-ladders/) - Medium

```python
from collections import deque

class Solution:
    def snakesAndLadders(self, board):
        n = len(board)

        def coordinates(square):
            row_from_bottom, column = divmod(square - 1, n)
            row = n - 1 - row_from_bottom
            if row_from_bottom % 2:
                column = n - 1 - column
            return row, column

        queue = deque([(1, 0)])
        visited = {1}
        target = n * n

        while queue:
            square, moves = queue.popleft()
            if square == target:
                return moves
            for next_square in range(square + 1, min(square + 6, target) + 1):
                row, column = coordinates(next_square)
                destination = board[row][column]
                if destination != -1:
                    next_square = destination
                if next_square not in visited:
                    visited.add(next_square)
                    queue.append((next_square, moves + 1))

        return -1
```

Why it works: each dice roll is one edge in the state graph, and BFS finds the minimum number of rolls.

---

### C. Multi-source BFS and time simulation

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [542. 01 Matrix](https://leetcode.com/problems/01-matrix/) | Medium | Start simultaneously from every zero. |
| [1162. As Far from Land as Possible](https://leetcode.com/problems/as-far-from-land-as-possible/) | Medium | Expand from all land cells at once. |
| [934. Shortest Bridge](https://leetcode.com/problems/shortest-bridge/) | Medium | Mark one island, then expand to the other. |
| [1926. Nearest Exit from Entrance in Maze](https://leetcode.com/problems/nearest-exit-from-entrance-in-maze/) | Medium | BFS distance to the first boundary exit. |
| [2258. Escape the Spreading Fire](https://leetcode.com/problems/escape-the-spreading-fire/) | Hard | Compare player arrival times with fire arrival times. |

#### Solution: [542. 01 Matrix](https://leetcode.com/problems/01-matrix/) - Medium

```python
from collections import deque

class Solution:
    def updateMatrix(self, mat):
        rows, columns = len(mat), len(mat[0])
        queue = deque()
        distance = [[-1] * columns for _ in range(rows)]

        for row in range(rows):
            for column in range(columns):
                if mat[row][column] == 0:
                    distance[row][column] = 0
                    queue.append((row, column))

        while queue:
            row, column = queue.popleft()
            for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                next_row, next_column = row + dr, column + dc
                if (0 <= next_row < rows and 0 <= next_column < columns
                        and distance[next_row][next_column] == -1):
                    distance[next_row][next_column] = distance[row][column] + 1
                    queue.append((next_row, next_column))

        return distance
```

Why it works: all zeros enter the queue at distance zero, so the first time a cell is reached is from its closest zero.

#### Solution: [1162. As Far from Land as Possible](https://leetcode.com/problems/as-far-from-land-as-possible/) - Medium

```python
from collections import deque

class Solution:
    def maxDistance(self, grid):
        n = len(grid)
        queue = deque()
        for row in range(n):
            for column in range(n):
                if grid[row][column] == 1:
                    queue.append((row, column))

        if not queue or len(queue) == n * n:
            return -1

        distance = -1
        while queue:
            for _ in range(len(queue)):
                row, column = queue.popleft()
                for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    next_row, next_column = row + dr, column + dc
                    if 0 <= next_row < n and 0 <= next_column < n and grid[next_row][next_column] == 0:
                        grid[next_row][next_column] = 1
                        queue.append((next_row, next_column))
            distance += 1

        return distance
```

Why it works: wavefront expansion starts from all land and the final layer reached is the farthest water distance.

#### Solution: [1926. Nearest Exit from Entrance in Maze](https://leetcode.com/problems/nearest-exit-from-entrance-in-maze/) - Medium

```python
from collections import deque

class Solution:
    def nearestExit(self, maze, entrance):
        rows, columns = len(maze), len(maze[0])
        queue = deque([(entrance[0], entrance[1], 0)])
        maze[entrance[0]][entrance[1]] = '+'

        while queue:
            row, column, distance = queue.popleft()
            if distance > 0 and (row in {0, rows - 1} or column in {0, columns - 1}):
                return distance

            for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                next_row, next_column = row + dr, column + dc
                if (0 <= next_row < rows and 0 <= next_column < columns
                        and maze[next_row][next_column] == '.'):
                    maze[next_row][next_column] = '+'
                    queue.append((next_row, next_column, distance + 1))

        return -1
```

Why it works: BFS explores cells by distance, so the first boundary cell other than the entrance is the nearest exit.

---

### D. Queue and deque design/simulation

| Problem | Difficulty | Why it belongs |
|---|---:|---|
| [232. Implement Queue using Stacks](https://leetcode.com/problems/implement-queue-using-stacks/) | Easy | Two stacks simulate FIFO order. |
| [622. Design Circular Queue](https://leetcode.com/problems/design-circular-queue/) | Medium | Fixed-capacity queue with wraparound indices. |
| [641. Design Circular Deque](https://leetcode.com/problems/design-circular-deque/) | Medium | Both-end insertion and removal. |
| [933. Number of Recent Calls](https://leetcode.com/problems/number-of-recent-calls/) | Easy | Remove timestamps outside a moving range. |
| [1670. Design Front Middle Back Queue](https://leetcode.com/problems/design-front-middle-back-queue/) | Medium | Two deques maintain balanced halves. |

#### Solution: [622. Design Circular Queue](https://leetcode.com/problems/design-circular-queue/) - Medium

```python
class MyCircularQueue:
    def __init__(self, k):
        self.values = [0] * k
        self.capacity = k
        self.front = 0
        self.size = 0

    def enQueue(self, value):
        if self.isFull():
            return False
        index = (self.front + self.size) % self.capacity
        self.values[index] = value
        self.size += 1
        return True

    def deQueue(self):
        if self.isEmpty():
            return False
        self.front = (self.front + 1) % self.capacity
        self.size -= 1
        return True

    def Front(self):
        return -1 if self.isEmpty() else self.values[self.front]

    def Rear(self):
        if self.isEmpty():
            return -1
        return self.values[(self.front + self.size - 1) % self.capacity]

    def isEmpty(self):
        return self.size == 0

    def isFull(self):
        return self.size == self.capacity
```

Why it works: front and size uniquely identify the occupied circular segment, so every operation is O(1).

#### Solution: [933. Number of Recent Calls](https://leetcode.com/problems/number-of-recent-calls/) - Easy

```python
from collections import deque

class RecentCounter:
    def __init__(self):
        self.requests = deque()

    def ping(self, t):
        self.requests.append(t)
        while self.requests[0] < t - 3000:
            self.requests.popleft()
        return len(self.requests)
```

Why it works: timestamps arrive in increasing order, so expired requests can be removed only from the front.

---

#### Solution: [1091. Shortest Path in Binary Matrix](https://leetcode.com/problems/shortest-path-in-binary-matrix/) - Medium

```python
from collections import deque

class Solution:
    def shortestPathBinaryMatrix(self, grid):
        n = len(grid)
        if grid[0][0] or grid[-1][-1]:
            return -1

        queue = deque([(0, 0, 1)])
        grid[0][0] = 1
        directions = ((1, 0), (-1, 0), (0, 1), (0, -1),
                      (1, 1), (1, -1), (-1, 1), (-1, -1))

        while queue:
            row, column, distance = queue.popleft()
            if row == n - 1 and column == n - 1:
                return distance
            for dr, dc in directions:
                next_row, next_column = row + dr, column + dc
                if (0 <= next_row < n and 0 <= next_column < n
                        and grid[next_row][next_column] == 0):
                    grid[next_row][next_column] = 1
                    queue.append((next_row, next_column, distance + 1))

        return -1
```

Why it works: every valid move has equal cost, so BFS reaches the bottom-right cell using the fewest steps.

#### Solution: [116. Populating Next Right Pointers in Each Node](https://leetcode.com/problems/populating-next-right-pointers-in-each-node/) - Medium

```python
from collections import deque

class Solution:
    def connect(self, root):
        if not root:
            return root

        queue = deque([root])
        while queue:
            previous = None
            for _ in range(len(queue)):
                node = queue.popleft()
                if previous:
                    previous.next = node
                previous = node
                if node.left:
                    queue.append(node.left)
                if node.right:
                    queue.append(node.right)
            previous.next = None

        return root
```

Why it works: nodes dequeued in one BFS layer are adjacent in next-pointer order, so connect each node to the next node from that same layer.

#### Solution: [1670. Design Front Middle Back Queue](https://leetcode.com/problems/design-front-middle-back-queue/) - Medium

```python
from collections import deque

class FrontMiddleBackQueue:
    def __init__(self):
        self.left = deque()
        self.right = deque()

    def _balance(self):
        while len(self.left) > len(self.right) + 1:
            self.right.appendleft(self.left.pop())
        while len(self.left) < len(self.right):
            self.left.append(self.right.popleft())

    def pushFront(self, val):
        self.left.appendleft(val)
        self._balance()

    def pushMiddle(self, val):
        if len(self.left) > len(self.right):
            self.right.appendleft(self.left.pop())
        self.left.append(val)

    def pushBack(self, val):
        self.right.append(val)
        self._balance()

    def popFront(self):
        if not self.left and not self.right:
            return -1
        value = self.left.popleft() if self.left else self.right.popleft()
        self._balance()
        return value

    def popMiddle(self):
        if not self.left and not self.right:
            return -1
        value = self.left.pop()
        self._balance()
        return value

    def popBack(self):
        if not self.left and not self.right:
            return -1
        value = self.right.pop() if self.right else self.left.pop()
        self._balance()
        return value
```

Why it works: two balanced deques keep the middle boundary explicit while preserving front-to-back order.

#### Solution: [2258. Escape the Spreading Fire](https://leetcode.com/problems/escape-the-spreading-fire/) - Hard

```python
from collections import deque

class Solution:
    def maximumMinutes(self, grid):
        rows, columns = len(grid), len(grid[0])
        fire_time = [[float('inf')] * columns for _ in range(rows)]
        queue = deque()

        for row in range(rows):
            for column in range(columns):
                if grid[row][column] == 1:
                    fire_time[row][column] = 0
                    queue.append((row, column))

        while queue:
            row, column = queue.popleft()
            for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                next_row, next_column = row + dr, column + dc
                if (0 <= next_row < rows and 0 <= next_column < columns
                        and grid[next_row][next_column] != 2
                        and fire_time[next_row][next_column] == float('inf')):
                    fire_time[next_row][next_column] = fire_time[row][column] + 1
                    queue.append((next_row, next_column))

        def can_escape(wait):
            if wait >= fire_time[0][0]:
                return False
            queue = deque([(0, 0, wait)])
            visited = {(0, 0)}
            while queue:
                row, column, time = queue.popleft()
                if row == rows - 1 and column == columns - 1:
                    return time <= fire_time[row][column]
                for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    next_row, next_column = row + dr, column + dc
                    next_time = time + 1
                    if not (0 <= next_row < rows and 0 <= next_column < columns):
                        continue
                    if grid[next_row][next_column] == 2 or (next_row, next_column) in visited:
                        continue
                    if next_time >= fire_time[next_row][next_column] and not (next_row == rows - 1 and next_column == columns - 1):
                        continue
                    visited.add((next_row, next_column))
                    queue.append((next_row, next_column, next_time))
            return False

        low, high = 0, 10**9
        answer = -1
        while low <= high:
            middle = (low + high) // 2
            if can_escape(middle):
                answer = middle
                low = middle + 1
            else:
                high = middle - 1

        return answer
```

Why it works: compute fire arrival times first, then binary-search the waiting time using a BFS that never enters a cell after the fire.

#### Solution: [232. Implement Queue using Stacks](https://leetcode.com/problems/implement-queue-using-stacks/) - Easy

```python
class MyQueue:
    def __init__(self):
        self.in_stack = []
        self.out_stack = []

    def _move(self):
        if not self.out_stack:
            while self.in_stack:
                self.out_stack.append(self.in_stack.pop())

    def push(self, x):
        self.in_stack.append(x)

    def pop(self):
        self._move()
        return self.out_stack.pop()

    def peek(self):
        self._move()
        return self.out_stack[-1]

    def empty(self):
        return not self.in_stack and not self.out_stack
```

Why it works: the output stack reverses the input order only when needed, making the oldest queued item accessible first.

#### Solution: [641. Design Circular Deque](https://leetcode.com/problems/design-circular-deque/) - Medium

```python
class MyCircularDeque:
    def __init__(self, k):
        self.values = [0] * k
        self.capacity = k
        self.front = 0
        self.size = 0

    def insertFront(self, value):
        if self.isFull():
            return False
        self.front = (self.front - 1) % self.capacity
        self.values[self.front] = value
        self.size += 1
        return True

    def insertLast(self, value):
        if self.isFull():
            return False
        index = (self.front + self.size) % self.capacity
        self.values[index] = value
        self.size += 1
        return True

    def deleteFront(self):
        if self.isEmpty():
            return False
        self.front = (self.front + 1) % self.capacity
        self.size -= 1
        return True

    def deleteLast(self):
        if self.isEmpty():
            return False
        self.size -= 1
        return True

    def getFront(self):
        return -1 if self.isEmpty() else self.values[self.front]

    def getRear(self):
        if self.isEmpty():
            return -1
        return self.values[(self.front + self.size - 1) % self.capacity]

    def isEmpty(self):
        return self.size == 0

    def isFull(self):
        return self.size == self.capacity
```

Why it works: front and size identify the occupied circular segment, so insertion and deletion at either end are constant time.

#### Solution: [773. Sliding Puzzle](https://leetcode.com/problems/sliding-puzzle/) - Hard

```python
from collections import deque

class Solution:
    def slidingPuzzle(self, board):
        start = ''.join(str(value) for row in board for value in row)
        target = '123450'
        neighbors = {
            0: (1, 3), 1: (0, 2, 4), 2: (1, 5),
            3: (0, 4), 4: (1, 3, 5), 5: (2, 4)
        }
        queue = deque([(start, start.index('0'), 0)])
        visited = {start}

        while queue:
            state, blank, moves = queue.popleft()
            if state == target:
                return moves
            for next_blank in neighbors[blank]:
                values = list(state)
                values[blank], values[next_blank] = values[next_blank], values[blank]
                candidate = ''.join(values)
                if candidate not in visited:
                    visited.add(candidate)
                    queue.append((candidate, next_blank, moves + 1))

        return -1
```

Why it works: each board arrangement is a graph state and each blank swap is one edge, so BFS finds the minimum number of moves.

#### Solution: [815. Bus Routes](https://leetcode.com/problems/bus-routes/) - Hard

```python
from collections import defaultdict, deque

class Solution:
    def numBusesToDestination(self, routes, source, target):
        if source == target:
            return 0

        stop_to_routes = defaultdict(list)
        for route_index, route in enumerate(routes):
            for stop in route:
                stop_to_routes[stop].append(route_index)

        queue = deque([(source, 0)])
        visited_stops = {source}
        visited_routes = set()

        while queue:
            stop, buses = queue.popleft()
            for route_index in stop_to_routes[stop]:
                if route_index in visited_routes:
                    continue
                visited_routes.add(route_index)
                for next_stop in routes[route_index]:
                    if next_stop == target:
                        return buses + 1
                    if next_stop not in visited_stops:
                        visited_stops.add(next_stop)
                        queue.append((next_stop, buses + 1))

        return -1
```

Why it works: BFS expands one bus route at a time, and each stop records the fewest buses needed to reach it.

#### Solution: [934. Shortest Bridge](https://leetcode.com/problems/shortest-bridge/) - Medium

```python
from collections import deque

class Solution:
    def shortestBridge(self, grid):
        n = len(grid)
        queue = deque()
        found = False

        def mark(row, column):
            if not (0 <= row < n and 0 <= column < n) or grid[row][column] != 1:
                return
            grid[row][column] = 2
            queue.append((row, column))
            for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                mark(row + dr, column + dc)

        for row in range(n):
            if found:
                break
            for column in range(n):
                if grid[row][column] == 1:
                    mark(row, column)
                    found = True
                    break

        distance = 0
        while queue:
            for _ in range(len(queue)):
                row, column = queue.popleft()
                for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    next_row, next_column = row + dr, column + dc
                    if not (0 <= next_row < n and 0 <= next_column < n):
                        continue
                    if grid[next_row][next_column] == 1:
                        return distance
                    if grid[next_row][next_column] == 0:
                        grid[next_row][next_column] = 2
                        queue.append((next_row, next_column))
            distance += 1

        return -1
```

Why it works: mark one island first, then BFS outward through water until the other island is reached.

---

## 3. Quick pattern recognition guide

### Use BFS when you see:
- minimum number of moves in an unweighted graph
- level order or distance by layers
- a grid with equal-cost moves
- all starting sources spreading at the same time

### Use a deque when you see:
- sliding expiration from the front
- insertion and removal at both ends
- a moving window over time or indices
- a fixed-capacity circular structure

### Use a queue simulation when you see:
- tasks processed in arrival order
- timestamps entering and expiring
- resources waiting for service

---

## 4. Core templates

### Tree level-order BFS

```python
from collections import deque

queue = deque([root])
while queue:
    for _ in range(len(queue)):
        node = queue.popleft()
        process(node)
        add_children(node, queue)
```

### Grid BFS

```python
queue = deque([(start_row, start_column)])
visited = {(start_row, start_column)}
while queue:
    row, column = queue.popleft()
    for next_row, next_column in neighbors(row, column):
        if valid(next_row, next_column) and (next_row, next_column) not in visited:
            visited.add((next_row, next_column))
            queue.append((next_row, next_column))
```

### Multi-source BFS

```python
queue = deque(all_sources)
while queue:
    for _ in range(len(queue)):
        expand(queue.popleft())
```

### Sliding deque

```python
from collections import deque

window = deque()
for right, value in enumerate(values):
    window.append(value)
    while expired(window):
        window.popleft()
```

---

## 5. Practice order

1. [102. Binary Tree Level Order Traversal](https://leetcode.com/problems/binary-tree-level-order-traversal/)
2. [200. Number of Islands](https://leetcode.com/problems/number-of-islands/)
3. [994. Rotting Oranges](https://leetcode.com/problems/rotting-oranges/)
4. [127. Word Ladder](https://leetcode.com/problems/word-ladder/)
5. [752. Open the Lock](https://leetcode.com/problems/open-the-lock/)
6. [542. 01 Matrix](https://leetcode.com/problems/01-matrix/)
7. [622. Design Circular Queue](https://leetcode.com/problems/design-circular-queue/)
8. [909. Snakes and Ladders](https://leetcode.com/problems/snakes-and-ladders/)
9. [815. Bus Routes](https://leetcode.com/problems/bus-routes/)
10. [2258. Escape the Spreading Fire](https://leetcode.com/problems/escape-the-spreading-fire/)

---

## 6. Cheat sheet

- FIFO processing: append new work and pop from the front.
- BFS distance: process one queue layer per distance step.
- Multi-source BFS: seed every source before starting the search.
- Grid BFS: mark visited when enqueuing, not when dequeuing.
- Queue simulation: remove expired or completed items from the front.
- Deque: use both ends when a moving window or circular structure requires it.

---

## 7. Interview trigger

Reach for a Queue when the statement includes:

- minimum moves or shortest unweighted path
- level order, layers, or time steps
- spreading from multiple starting points
- arrival order or first-in-first-out processing
- recent events inside a time interval
- circular buffer or operations at both ends

Before coding, define what one queue layer represents: one edge, one minute, one tree level, or one processing round.

---

## 8. Common mistakes

- marking nodes visited only after dequeueing, causing duplicates
- mixing nodes from different BFS levels when a distance is required
- forgetting to seed all sources in multi-source BFS
- treating a weighted graph as ordinary BFS
- failing to handle the entrance as a non-exit in maze problems
- mishandling wraparound indices in circular queues
- forgetting to remove expired timestamps from a recent-call queue

---

## 9. Current coverage

Every problem currently listed in the Queue sub-pattern tables and practice order has a direct solution above.

Current mapped inventory:

- 23 unique Queue problems
- 23 direct solutions
- 0 unsolved entries in the current file

When a larger Queue problem export is supplied, new problems can be appended as a numbered backlog and solved one by one in the same format.

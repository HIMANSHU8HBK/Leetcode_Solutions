# Copilot Instructions for LeetCode and Interview Solutions

## Commenting style

Write comments that explain intent, reasoning, and invariants, not obvious syntax.

Prefer:
- why the window is valid or invalid
- what state is being tracked
- why a shrink/expand operation happens
- what the key observation is
- what edge cases are protected

Avoid:
- comments like `i += 1  # increment i`
- comments that merely restate the code
- commenting every line with low-value text
- explanation that is too short to teach the pattern

## Good comprehensive comments

For algorithmic solutions, use a small number of high-value comments:

- one comment at the start of a logical block
- one comment for a non-obvious update rule
- one comment for a tricky condition or invariant
- one comment for formulas or transformations when they clarify the reasoning

Examples:
- `# Keep the window valid by allowing at most k zeros.`
- `# Store indices because expired elements must be removed when they leave the window.`
- `# Replacements needed = window length - highest frequency.`
- `# Add incoming value and drop the outgoing value to keep the window moving in O(1).`

## Solution structure

When solving a LeetCode problem, include:
1. problem title and pattern
2. what state is maintained
3. intuition in plain English
4. brute force and why it is slow
5. key observation
6. raw code
7. commented code
8. complexity
9. cheat sheet
10. interview trigger
11. common mistakes

## Interview quality

Write as if teaching a strong candidate:
- clear but concise
- practical and reusable
- pattern-focused
- emphasis on when to use the technique, not just the final code

## Lean toward quality over quantity

A good comment should help someone understand the next decision in the algorithm.
If the comment does not teach or clarify, it is not worth writing.

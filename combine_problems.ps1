$orderedFiles = @(
    'Prefix Sum Pattern Mastery.md',
    'Backtracking Pattern Mastery.md',
    'Recursion Pattern Mastery.md',
    'Divide and Conquer Pattern Mastery.md',
    'Queue Pattern Mastery.md',
    'Heap Pattern Mastery.md',
    'Sliding Window Pattern Mastery.md',
    'Stack Pattern Mastery.md',
    'Two Pointers Pattern Mastery.md'
)

$output = [System.Collections.Generic.List[string]]::new()

function Add-LeetCodeSolutions([string]$path) {
    $lines = Get-Content -LiteralPath $path -Encoding UTF8

    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -notmatch '^#### Solution: (.+)$') {
            continue
        }

        $problem = [regex]::Replace($Matches[1], '\[([^\]]+)\]\([^\)]+\)', '$1')
        $codeStart = $index + 1
        while ($codeStart -lt $lines.Count -and $lines[$codeStart] -notmatch '^```') {
            $codeStart++
        }

        if ($codeStart -ge $lines.Count) {
            continue
        }

        $codeEnd = $codeStart + 1
        while ($codeEnd -lt $lines.Count -and $lines[$codeEnd] -notmatch '^```') {
            $codeEnd++
        }

        if ($codeEnd -ge $lines.Count) {
            continue
        }

        $output.Add("## Problem: $problem")
        $output.AddRange([string[]]$lines[$codeStart..$codeEnd])
        $output.Add('')
    }
}

foreach ($file in $orderedFiles) {
    Add-LeetCodeSolutions $file
}

$deepMlPath = 'Deep-ML\01 - Matrix-Vector Dot Product.md'
$deepMlLines = Get-Content -LiteralPath $deepMlPath -Encoding UTF8
$problemStart = [Array]::IndexOf($deepMlLines, '## Problem statement') + 1
$templateStart = [Array]::IndexOf($deepMlLines, '## Required template')
$solutionStart = [Array]::IndexOf($deepMlLines, '## Solution') + 1
$solutionCodeStart = $solutionStart
while ($solutionCodeStart -lt $deepMlLines.Count -and $deepMlLines[$solutionCodeStart] -notmatch '^```') {
    $solutionCodeStart++
}
$solutionCodeEnd = $solutionCodeStart + 1
while ($solutionCodeEnd -lt $deepMlLines.Count -and $deepMlLines[$solutionCodeEnd] -notmatch '^```') {
    $solutionCodeEnd++
}

$output.Add('## Problem: Matrix-Vector Dot Product')
$output.AddRange([string[]]$deepMlLines[$problemStart..($templateStart - 1)])
$output.AddRange([string[]]$deepMlLines[$solutionCodeStart..$solutionCodeEnd])

$compactOutput = [System.Collections.Generic.List[string]]::new()
foreach ($line in $output) {
    if ([string]::IsNullOrWhiteSpace($line)) {
        continue
    }
    if ($line -match '^## Problem:' -and $compactOutput.Count -gt 0) {
        $compactOutput.Add('')
    }
    $compactOutput.Add($line)
}

[System.IO.File]::WriteAllText(
    'Problems and Solutions.md',
    ($compactOutput -join [Environment]::NewLine) + [Environment]::NewLine,
    [System.Text.UTF8Encoding]::new($false)
)
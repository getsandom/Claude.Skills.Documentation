<#
.SYNOPSIS
    Mechanical check of a documentation tree in the repo-docs structure. Read-only.

.DESCRIPTION
    Without -NextId, checks the structure and prints one line per problem,
    "ERROR|WARNING <path>: <message>", with the path relative to the
    documentation folder, in ordinal order, followed by "Summary: N error(s), M warning(s)."
    With -NextId PRE, prints the next free identifier for the given prefix; with
    -NextId PRE_NNN, the next sub-identifier PRE_NNN.XX of the folder document.
    Exit code: 0 without errors, 1 with errors, 2 on invalid usage or missing folder.
    The output is identical to that of audit.sh for the same tree.

.PARAMETER Docs
    Documentation folder. Default: ./docs.

.PARAMETER NextId
    Prefix (e.g. DEC) whose next free identifier should be printed, or
    identifier of a folder document (e.g. TSK_001) whose next
    sub-identifier should be printed.
#>
param(
    [Parameter(Position = 0)] [string] $Docs = 'docs',
    [string] $NextId = ''
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
$OutputEncoding = [Console]::OutputEncoding

if (-not (Test-Path -LiteralPath $Docs -PathType Container)) {
    [Console]::Error.WriteLine("Documentation folder not found: $Docs")
    exit 2
}
$root = (Resolve-Path -LiteralPath $Docs).ProviderPath.TrimEnd('\', '/')

function Get-Rel([string] $path) {
    $p = $path.Substring($root.Length).TrimStart('\', '/')
    return $p.Replace('\', '/')
}

function Get-Children([string] $dir) {
    return @(Get-ChildItem -LiteralPath $dir -Force | Where-Object { -not $_.Name.StartsWith('.') })
}

function Read-Lines([string] $path) {
    return @([System.IO.File]::ReadAllLines($path, [System.Text.Encoding]::UTF8))
}

$ordinal = [System.StringComparer]::Ordinal

# Next free identifier: highest number used in file or folder names or in any
# index, plus one. For PRE_NNN, the highest XX of the sub-identifiers PRE_NNN.XX
# in file names or in any index, plus one.
if ($NextId -ne '') {
    if ($NextId -cnotmatch '^[A-Z][A-Z0-9]*(_[0-9]{3})?$') {
        [Console]::Error.WriteLine("Invalid prefix: $NextId")
        exit 2
    }
    $sub = $NextId.Contains('_')
    $max = 0
    $all = @(Get-ChildItem -LiteralPath $root -Recurse -Force)
    $e = [regex]::Escape($NextId)
    if ($sub) {
        $nameRx = "^$e\.([0-9]{2})-"
        $rx = "(^|[^A-Z0-9])$e\.([0-9]{2})"
    } else {
        $nameRx = "^${e}_([0-9]{3})-"
        $rx = "(^|[^A-Z0-9])${e}_([0-9]{3})"
    }
    foreach ($f in $all) {
        if (-not ($sub -and $f.PSIsContainer) -and $f.Name -cmatch $nameRx) {
            $n = [int]$Matches[1]; if ($n -gt $max) { $max = $n }
        }
        if (-not $f.PSIsContainer -and $f.Name -eq 'index.md' -and $f.Directory.Name -eq '.meta') {
            foreach ($line in (Read-Lines $f.FullName)) {
                foreach ($m in [regex]::Matches($line, $rx)) {
                    $n = [int]$m.Groups[2].Value; if ($n -gt $max) { $max = $n }
                }
            }
        }
    }
    if ($sub) { '{0}.{1:D2}' -f $NextId, ($max + 1) } else { '{0}_{1:D3}' -f $NextId, ($max + 1) }
    exit 0
}

$out = New-Object System.Collections.Generic.List[string]
$ids = New-Object System.Collections.Generic.List[object]
$closed = New-Object System.Collections.Generic.List[object]
function Add-Report([string] $level, [string] $path, [string] $msg) {
    $out.Add("$level ${path}: $msg")
}

# Topics: the root and every subfolder that does not start with a dot, outside .meta.
$topics = New-Object System.Collections.Generic.List[string]
$stack = New-Object System.Collections.Generic.Stack[string]
$stack.Push($root)
while ($stack.Count -gt 0) {
    $d = $stack.Pop()
    $topics.Add($d)
    foreach ($c in (Get-Children $d)) { if ($c.PSIsContainer) { $stack.Push($c.FullName) } }
}

foreach ($T in $topics) {
    $rt = Get-Rel $T
    if ($rt -ne '') { $rt = "$rt/" }

    foreach ($f in @('README.md', '.meta/index.md', '.meta/rules.md')) {
        if (-not (Test-Path -LiteralPath (Join-Path $T $f) -PathType Leaf)) {
            Add-Report 'ERROR' "$rt$f" 'required file missing'
        }
    }

    $children = Get-Children $T
    $actual = New-Object System.Collections.Generic.List[string]
    foreach ($c in $children) {
        if ($c.PSIsContainer) { $actual.Add("$($c.Name)/") }
        elseif ($c.Name -ne 'README.md') { $actual.Add($c.Name) }
        if ($c.Name -cmatch '^([A-Z][A-Z0-9]*_[0-9]{3})-') {
            $p = "$rt$($c.Name)"; if ($c.PSIsContainer) { $p = "$p/" }
            $ids.Add([pscustomobject]@{ Id = $Matches[1]; Path = $p })
        } elseif (-not $c.PSIsContainer -and $c.Name -cmatch '^([A-Z][A-Z0-9]*_[0-9]{3}\.[0-9]{2})-') {
            $ids.Add([pscustomobject]@{ Id = $Matches[1]; Path = "$rt$($c.Name)" })
        }
    }

    $indexPath = Join-Path $T '.meta/index.md'
    if (Test-Path -LiteralPath $indexPath -PathType Leaf) {
        $items = New-Object System.Collections.Generic.List[string]
        $enc = $false
        foreach ($line in (Read-Lines $indexPath)) {
            if ($line -cmatch '^## Closed\s*$') { $enc = $true; continue }
            if ($line.StartsWith('## ')) { $enc = $false }
            if (-not $enc -and $line -cmatch '^- \[([^\]]+)\]\(([^)]+)\)') {
                $text = $Matches[1]; $target = $Matches[2]
                $items.Add($text)
                if ($target -cne "../$text") {
                    Add-Report 'ERROR' "$rt.meta/index.md" "the link of item $text should point to ../$text"
                }
            }
            if ($enc -and $line -cmatch '^- `([^`]+)`') {
                if ($Matches[1] -cmatch '^([A-Z][A-Z0-9]*_[0-9]{3})') {
                    $closed.Add([pscustomobject]@{ Id = $Matches[1]; Where = "$rt.meta/index.md" })
                }
            }
        }

        $seen = New-Object 'System.Collections.Generic.HashSet[string]' $ordinal
        $dups = New-Object 'System.Collections.Generic.SortedSet[string]' $ordinal
        foreach ($i in $items) { if (-not $seen.Add($i)) { [void]$dups.Add($i) } }
        foreach ($d in $dups) { Add-Report 'ERROR' "$rt.meta/index.md" "duplicate item: $d" }

        $actualSet = New-Object 'System.Collections.Generic.HashSet[string]' $ordinal
        foreach ($a in $actual) { [void]$actualSet.Add($a) }
        foreach ($i in $seen) {
            if (-not $actualSet.Contains($i)) { Add-Report 'ERROR' "$rt.meta/index.md" "lists $i, which does not exist" }
        }
        foreach ($a in $actualSet) {
            if (-not $seen.Contains($a)) { Add-Report 'ERROR' "$rt.meta/index.md" "does not list $a" }
        }

        $sorted = $items.ToArray()
        [Array]::Sort($sorted, $ordinal)
        if (($sorted -join "`n") -cne ($items.ToArray() -join "`n")) {
            Add-Report 'WARNING' "$rt.meta/index.md" 'items out of alphabetical order'
        }
    }

    # Name pattern and title in topics with an identifier. With `PRE_NNN`, the
    # files and folders (folder documents) that start with the prefix; with
    # `PRE_NNN.XX`, the topic is a folder document and the files that start with the
    # prefix are the numbered inner files (the others are supporting files).
    $rulesPath = Join-Path $T '.meta/rules.md'
    if (Test-Path -LiteralPath $rulesPath -PathType Leaf) {
        $prefix = ''
        $subMode = $false
        foreach ($line in (Read-Lines $rulesPath)) {
            if ($line.StartsWith('- **Identifier:**')) {
                if ($line -cmatch '^[^`]*`([A-Z][A-Z0-9]*)_NNN(\.XX)?`') {
                    $prefix = $Matches[1]
                    $subMode = $Matches.ContainsKey(2)
                }
                break
            }
        }
        $ep = [regex]::Escape($prefix)
        if ($prefix -ne '' -and -not $subMode) {
            foreach ($c in $children) {
                if ($c.Name -eq 'README.md') { continue }
                if ($c.PSIsContainer) {
                    if (-not $c.Name.StartsWith("${prefix}_", [System.StringComparison]::Ordinal)) { continue }
                    if ($c.Name -cnotmatch "^${ep}_[0-9]{3}-[a-z0-9-]+$") {
                        Add-Report 'ERROR' "$rt$($c.Name)/" "name does not match ${prefix}_NNN-title/"
                        continue
                    }
                    $readme = Join-Path $c.FullName 'README.md'
                    if (-not (Test-Path -LiteralPath $readme -PathType Leaf)) { continue }
                    $file = $readme; $shown = "$rt$($c.Name)/README.md"
                } else {
                    if ($c.Name -cnotmatch "^${ep}_[0-9]{3}-[a-z0-9-]+\.md$") {
                        Add-Report 'ERROR' "$rt$($c.Name)" "name does not match ${prefix}_NNN-title.md"
                        continue
                    }
                    $file = $c.FullName; $shown = "$rt$($c.Name)"
                }
                $id = $c.Name.Substring(0, $c.Name.IndexOf('-'))
                $first = ''
                $lines = @(Read-Lines $file)
                if ($lines.Count -gt 0) { $first = $lines[0] }
                if (-not $first.StartsWith("# ${id}:", [System.StringComparison]::Ordinal)) {
                    Add-Report 'ERROR' $shown "the title should start with '# ${id}:'"
                }
            }
        }
        if ($prefix -ne '' -and $subMode) {
            $dirName = Split-Path -Leaf $T
            if ($dirName -cnotmatch "^${ep}_([0-9]{3})-") {
                Add-Report 'ERROR' "$rt.meta/rules.md" "identifier ${prefix}_NNN.XX in a folder that does not match ${prefix}_NNN-title/"
            } else {
                $num = $Matches[1]
                foreach ($c in $children) {
                    if ($c.PSIsContainer -or $c.Name -eq 'README.md') { continue }
                    if (-not $c.Name.StartsWith("${prefix}_", [System.StringComparison]::Ordinal)) { continue }
                    if ($c.Name -cnotmatch "^${ep}_${num}\.[0-9]{2}-[a-z0-9-]+\.md$") {
                        Add-Report 'ERROR' "$rt$($c.Name)" "name does not match ${prefix}_${num}.XX-title.md"
                        continue
                    }
                    $id = $c.Name.Substring(0, $c.Name.IndexOf('-'))
                    $first = ''
                    $lines = @(Read-Lines $c.FullName)
                    if ($lines.Count -gt 0) { $first = $lines[0] }
                    if (-not $first.StartsWith("# ${id}:", [System.StringComparison]::Ordinal)) {
                        Add-Report 'ERROR' "$rt$($c.Name)" "the title should start with '# ${id}:'"
                    }
                }
            }
        }
    }
}

# Identifiers repeated across files.
$byId = @{}
foreach ($e in $ids) {
    if (-not $byId.ContainsKey($e.Id)) { $byId[$e.Id] = New-Object System.Collections.Generic.List[string] }
    $byId[$e.Id].Add($e.Path)
}
foreach ($k in $byId.Keys) {
    $paths = $byId[$k].ToArray()
    if ($paths.Count -gt 1) {
        [Array]::Sort($paths, $ordinal)
        $rest = ($paths | Select-Object -Skip 1) -join ', '
        Add-Report 'ERROR' $paths[0] "identifier $k also used in $rest"
    }
}

# Closed identifiers that exist again.
$closedSeen = New-Object 'System.Collections.Generic.HashSet[string]' $ordinal
foreach ($c in $closed) {
    if (-not $closedSeen.Add("$($c.Id)`t$($c.Where)")) { continue }
    if ($byId.ContainsKey($c.Id)) {
        foreach ($p in $byId[$c.Id]) {
            Add-Report 'ERROR' $c.Where "closed identifier $($c.Id) reused in $p"
        }
    }
}

# Broken relative links, outside code blocks and code spans.
$mdFiles = @(Get-ChildItem -LiteralPath $root -Recurse -Force -File -Filter '*.md')
foreach ($file in $mdFiles) {
    $code = $false
    foreach ($line in (Read-Lines $file.FullName)) {
        if ($line -match '^\s*(```|~~~)') { $code = -not $code; continue }
        if ($code) { continue }
        $l = [regex]::Replace($line, '`[^`]*`', '')
        foreach ($m in [regex]::Matches($l, '\]\(([^)\s]+)')) {
            $t = $m.Groups[1].Value
            if ($t -match '^(http:|https:|mailto:|#)') { continue }
            $p = $t
            $hash = $p.IndexOf('#')
            if ($hash -ge 0) { $p = $p.Substring(0, $hash) }
            $p = $p.Replace('%20', ' ')
            if ($p -eq '') { continue }
            if (-not (Test-Path -LiteralPath (Join-Path $file.DirectoryName $p))) {
                Add-Report 'ERROR' (Get-Rel $file.FullName) "broken link: $t"
            }
        }
    }
}

$final = $out.ToArray()
[Array]::Sort($final, $ordinal)
foreach ($line in $final) { $line }
$errors = @($final | Where-Object { $_.StartsWith('ERROR ') }).Count
$warnings = @($final | Where-Object { $_.StartsWith('WARNING ') }).Count
"Summary: $errors error(s), $warnings warning(s)."
if ($errors -gt 0) { exit 1 } else { exit 0 }

<#
.SYNOPSIS
    Inventário de documentação, pendências no código e referências, para a migração
    para a estrutura repo-docs. Só leitura.

.DESCRIPTION
    Executado a partir da raiz do repositório, em um dos modos:
    -Markdown  Documentos de texto (.md, .markdown, .adoc, .rst) fora da documentação
               já estruturada; uma linha "MD <caminho> <linhas> <título>".
    -Todos     Ocorrências de TODO e FIXME (palavra inteira, maiúsculas) nos arquivos
               informados ou, sem arquivos, em todos os arquivos do repositório; uma
               linha "TODO <caminho>:<linha>: <texto>".
    -Refs      Ocorrências literais do padrão fora de Docs e de Docs-legado; uma linha
               "REF <caminho>:<linha>: <texto>".
    Docs só é excluída de -Markdown e -Todos quando já está estruturada
    (Docs/.meta/regras.md existe). Pastas .git, node_modules, bin e obj são sempre
    ignoradas, assim como arquivos binários. A lista do repositório vem do git
    (rastreados e não rastreados não ignorados) ou, fora de um repositório git, de
    todos os arquivos. Saída em ordem ordinal do caminho e numérica da linha.
    Código de saída: 0, ou 2 em uso inválido. A saída é idêntica à de inventory.sh.

.PARAMETER Files
    Arquivos a verificar no modo -Todos.
#>
param(
    [switch] $Markdown,
    [switch] $Todos,
    [string] $Refs = '',
    [string] $Docs = 'docs',
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)] [string[]] $Files = @()
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
$OutputEncoding = [Console]::OutputEncoding

$modes = @($Markdown.IsPresent, $Todos.IsPresent, ($Refs -ne '')) | Where-Object { $_ }
if (@($modes).Count -ne 1) {
    [Console]::Error.WriteLine('Uso: inventory.ps1 -Markdown | -Todos [arquivo...] | -Refs PADRÃO [-Docs DIR]')
    exit 2
}

$Docs = $Docs.Replace('\', '/')
if ($Docs.StartsWith('./')) { $Docs = $Docs.Substring(2) }
$Docs = $Docs.TrimEnd('/')
$structured = Test-Path -LiteralPath (Join-Path $Docs '.meta/regras.md') -PathType Leaf
$utf8 = New-Object System.Text.UTF8Encoding $false

function Get-Norm([string] $p) {
    $p = $p.Replace('\', '/')
    if ($p.StartsWith('./')) { $p = $p.Substring(2) }
    return $p
}

function Test-Excluded([string] $p, [string] $kind) {
    $s = "/$p"
    foreach ($d in @('/.git/', '/node_modules/', '/bin/', '/obj/')) {
        if ($s.Contains($d)) { return $true }
    }
    if ($kind -eq 'docs' -and $structured -and $p.StartsWith("$Docs/", [System.StringComparison]::Ordinal)) { return $true }
    if ($kind -eq 'refs' -and ($p.StartsWith("$Docs/", [System.StringComparison]::Ordinal) -or
            $p.StartsWith("$Docs-legado/", [System.StringComparison]::Ordinal))) { return $true }
    return $false
}

function Get-AllFiles {
    $inside = $false
    try {
        $r = & git rev-parse --is-inside-work-tree 2>$null
        if ($LASTEXITCODE -eq 0 -and $r -eq 'true') { $inside = $true }
    } catch { }
    if ($inside) {
        return @(& git -c core.quotepath=off ls-files --cached --others --exclude-standard)
    }
    $root = (Get-Location).ProviderPath
    return @(Get-ChildItem -LiteralPath $root -Recurse -Force -File |
        ForEach-Object { $_.FullName.Substring($root.Length).TrimStart('\', '/') })
}

function Test-Text([string] $p) {
    $info = Get-Item -LiteralPath $p -Force
    if ($info.Length -eq 0) { return $false }
    $stream = [System.IO.File]::OpenRead($info.FullName)
    try {
        $buf = New-Object byte[] 8000
        $n = $stream.Read($buf, 0, 8000)
        for ($i = 0; $i -lt $n; $i++) { if ($buf[$i] -eq 0) { return $false } }
        return $true
    } finally { $stream.Dispose() }
}

function Read-Lines([string] $p) {
    $text = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $p).ProviderPath, $utf8)
    $lines = $text -split "`n"
    if ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -eq '') {
        $lines = $lines[0..($lines.Count - 2)]
    }
    return @($lines | ForEach-Object { $_.TrimEnd("`r") })
}

$results = New-Object System.Collections.Generic.List[object]

if ($Markdown) {
    foreach ($f0 in (Get-AllFiles)) {
        $f = Get-Norm $f0
        if ($f -notmatch '\.(md|markdown|adoc|rst)$') { continue }
        if (Test-Excluded $f 'docs') { continue }
        if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { continue }
        $info = Get-Item -LiteralPath $f -Force
        $lines = @()
        if ($info.Length -gt 0) { $lines = @(Read-Lines $f) }
        $title = '-'
        foreach ($l in $lines) {
            if ($l -cmatch '^#[ \t]+(.*)$') { $title = $Matches[1].TrimEnd(' ', "`t"); break }
        }
        if ($title -eq '') { $title = '-' }
        $results.Add("MD $f $($lines.Count) $title")
    }
    $arr = $results.ToArray()
    [Array]::Sort($arr, [System.StringComparer]::Ordinal)
    foreach ($r in $arr) { $r }
    exit 0
}

$list = $Files
if ($Todos -and @($Files).Count -eq 0) { $list = Get-AllFiles }
if ($Refs -ne '') { $list = Get-AllFiles }
$space = [char[]]@(' ', "`t", "`n", "`v", "`f", "`r")
$rxTodo = New-Object System.Text.RegularExpressions.Regex '(?<![A-Za-z0-9_])(TODO|FIXME)(?![A-Za-z0-9_])'

foreach ($f0 in $list) {
    $f = Get-Norm $f0
    if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { continue }
    if ($Todos) { if (Test-Excluded $f 'docs') { continue } }
    else { if (Test-Excluded $f 'refs') { continue } }
    if (-not (Test-Text $f)) { continue }
    $lines = @(Read-Lines $f)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $l = $lines[$i]
        $hit = $false
        if ($Todos) { $hit = $rxTodo.IsMatch($l) } else { $hit = $l.Contains($Refs) }
        if ($hit) {
            $results.Add([pscustomobject]@{ Path = $f; Line = $i + 1; Text = $l.Trim($space) })
        }
    }
}

$arr = $results.ToArray()
[Array]::Sort($arr, [System.Comparison[object]] {
    param($a, $b)
    $c = [string]::CompareOrdinal($a.Path, $b.Path)
    if ($c -ne 0) { return $c }
    return $a.Line.CompareTo($b.Line)
})
$tag = 'REF'
if ($Todos) { $tag = 'TODO' }
foreach ($r in $arr) { "$tag $($r.Path):$($r.Line): $($r.Text)" }
exit 0

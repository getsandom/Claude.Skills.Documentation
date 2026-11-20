<#
.SYNOPSIS
    Verificação mecânica de uma documentação na estrutura repo-docs. Só leitura.

.DESCRIPTION
    Sem -NextId, verifica a estrutura e imprime uma linha por problema,
    "ERRO|AVISO <caminho>: <mensagem>", com o caminho relativo à pasta de
    documentação, em ordem ordinal, seguida de "Resumo: N erro(s), M aviso(s)."
    Com -NextId PRE, imprime o próximo identificador livre do prefixo informado; com
    -NextId PRE_NNN, o próximo sub-identificador PRE_NNN.XX do documento em pasta.
    Código de saída: 0 sem erros, 1 com erros, 2 em uso inválido ou pasta inexistente.
    A saída é idêntica à de audit.sh para a mesma árvore.

.PARAMETER Docs
    Pasta de documentação. Padrão: ./docs.

.PARAMETER NextId
    Prefixo (ex.: DEC) cujo próximo identificador livre deve ser impresso, ou
    identificador de documento em pasta (ex.: TAR_001) cujo próximo
    sub-identificador deve ser impresso.
#>
param(
    [Parameter(Position = 0)] [string] $Docs = 'docs',
    [string] $NextId = ''
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
$OutputEncoding = [Console]::OutputEncoding

if (-not (Test-Path -LiteralPath $Docs -PathType Container)) {
    [Console]::Error.WriteLine("Pasta de documentação não encontrada: $Docs")
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

# Próximo identificador livre: maior número usado em nomes de arquivo ou de pasta ou
# em qualquer índice, mais um. Para PRE_NNN, o maior XX dos sub-identificadores
# PRE_NNN.XX em nomes de arquivo ou em qualquer índice, mais um.
if ($NextId -ne '') {
    if ($NextId -cnotmatch '^[A-Z][A-Z0-9]*(_[0-9]{3})?$') {
        [Console]::Error.WriteLine("Prefixo inválido: $NextId")
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

# Tópicos: a raiz e toda subpasta que não comece por ponto, fora de .meta.
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

    foreach ($f in @('README.md', '.meta/index.md', '.meta/regras.md')) {
        if (-not (Test-Path -LiteralPath (Join-Path $T $f) -PathType Leaf)) {
            Add-Report 'ERRO' "$rt$f" 'arquivo obrigatório ausente'
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
            if ($line -cmatch '^## Encerrados\s*$') { $enc = $true; continue }
            if ($line.StartsWith('## ')) { $enc = $false }
            if (-not $enc -and $line -cmatch '^- \[([^\]]+)\]\(([^)]+)\)') {
                $text = $Matches[1]; $target = $Matches[2]
                $items.Add($text)
                if ($target -cne "../$text") {
                    Add-Report 'ERRO' "$rt.meta/index.md" "o link do item $text deveria apontar para ../$text"
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
        foreach ($d in $dups) { Add-Report 'ERRO' "$rt.meta/index.md" "item repetido: $d" }

        $actualSet = New-Object 'System.Collections.Generic.HashSet[string]' $ordinal
        foreach ($a in $actual) { [void]$actualSet.Add($a) }
        foreach ($i in $seen) {
            if (-not $actualSet.Contains($i)) { Add-Report 'ERRO' "$rt.meta/index.md" "lista $i, que não existe" }
        }
        foreach ($a in $actualSet) {
            if (-not $seen.Contains($a)) { Add-Report 'ERRO' "$rt.meta/index.md" "não lista $a" }
        }

        $sorted = $items.ToArray()
        [Array]::Sort($sorted, $ordinal)
        if (($sorted -join "`n") -cne ($items.ToArray() -join "`n")) {
            Add-Report 'AVISO' "$rt.meta/index.md" 'itens fora da ordem alfabética'
        }
    }

    # Padrão de nome e título nos tópicos com identificador. Com `PRE_NNN`, os
    # arquivos e as pastas (documentos em pasta) que começam pelo prefixo; com
    # `PRE_NNN.XX`, o tópico é um documento em pasta e os arquivos que começam pelo
    # prefixo são os internos numerados (os demais são de apoio).
    $rulesPath = Join-Path $T '.meta/regras.md'
    if (Test-Path -LiteralPath $rulesPath -PathType Leaf) {
        $prefix = ''
        $subMode = $false
        foreach ($line in (Read-Lines $rulesPath)) {
            if ($line.StartsWith('- **Identificador:**')) {
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
                        Add-Report 'ERRO' "$rt$($c.Name)/" "nome fora do padrão ${prefix}_NNN-titulo/"
                        continue
                    }
                    $readme = Join-Path $c.FullName 'README.md'
                    if (-not (Test-Path -LiteralPath $readme -PathType Leaf)) { continue }
                    $file = $readme; $shown = "$rt$($c.Name)/README.md"
                } else {
                    if ($c.Name -cnotmatch "^${ep}_[0-9]{3}-[a-z0-9-]+\.md$") {
                        Add-Report 'ERRO' "$rt$($c.Name)" "nome fora do padrão ${prefix}_NNN-titulo.md"
                        continue
                    }
                    $file = $c.FullName; $shown = "$rt$($c.Name)"
                }
                $id = $c.Name.Substring(0, $c.Name.IndexOf('-'))
                $first = ''
                $lines = @(Read-Lines $file)
                if ($lines.Count -gt 0) { $first = $lines[0] }
                if (-not $first.StartsWith("# ${id}:", [System.StringComparison]::Ordinal)) {
                    Add-Report 'ERRO' $shown "o título deveria começar por '# ${id}:'"
                }
            }
        }
        if ($prefix -ne '' -and $subMode) {
            $dirName = Split-Path -Leaf $T
            if ($dirName -cnotmatch "^${ep}_([0-9]{3})-") {
                Add-Report 'ERRO' "$rt.meta/regras.md" "identificador ${prefix}_NNN.XX em pasta fora do padrão ${prefix}_NNN-titulo/"
            } else {
                $num = $Matches[1]
                foreach ($c in $children) {
                    if ($c.PSIsContainer -or $c.Name -eq 'README.md') { continue }
                    if (-not $c.Name.StartsWith("${prefix}_", [System.StringComparison]::Ordinal)) { continue }
                    if ($c.Name -cnotmatch "^${ep}_${num}\.[0-9]{2}-[a-z0-9-]+\.md$") {
                        Add-Report 'ERRO' "$rt$($c.Name)" "nome fora do padrão ${prefix}_${num}.XX-titulo.md"
                        continue
                    }
                    $id = $c.Name.Substring(0, $c.Name.IndexOf('-'))
                    $first = ''
                    $lines = @(Read-Lines $c.FullName)
                    if ($lines.Count -gt 0) { $first = $lines[0] }
                    if (-not $first.StartsWith("# ${id}:", [System.StringComparison]::Ordinal)) {
                        Add-Report 'ERRO' "$rt$($c.Name)" "o título deveria começar por '# ${id}:'"
                    }
                }
            }
        }
    }
}

# Identificadores repetidos entre arquivos.
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
        Add-Report 'ERRO' $paths[0] "identificador $k também usado em $rest"
    }
}

# Identificadores encerrados que voltaram a existir.
$closedSeen = New-Object 'System.Collections.Generic.HashSet[string]' $ordinal
foreach ($c in $closed) {
    if (-not $closedSeen.Add("$($c.Id)`t$($c.Where)")) { continue }
    if ($byId.ContainsKey($c.Id)) {
        foreach ($p in $byId[$c.Id]) {
            Add-Report 'ERRO' $c.Where "identificador encerrado $($c.Id) reutilizado em $p"
        }
    }
}

# Links relativos quebrados, fora de blocos e trechos de código.
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
                Add-Report 'ERRO' (Get-Rel $file.FullName) "link quebrado: $t"
            }
        }
    }
}

$final = $out.ToArray()
[Array]::Sort($final, $ordinal)
foreach ($line in $final) { $line }
$errors = @($final | Where-Object { $_.StartsWith('ERRO ') }).Count
$warnings = @($final | Where-Object { $_.StartsWith('AVISO ') }).Count
"Resumo: $errors erro(s), $warnings aviso(s)."
if ($errors -gt 0) { exit 1 } else { exit 0 }

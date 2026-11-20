#!/usr/bin/env bash
# inventory.sh: inventário de documentação, pendências no código e referências,
# para a migração para a estrutura repo-docs. Só leitura: não altera nenhum arquivo.
#
# Uso, a partir da raiz do repositório:
#   inventory.sh --markdown [--docs DIR]
#       Documentos de texto (.md, .markdown, .adoc, .rst) fora da documentação já
#       estruturada; uma linha "MD <caminho> <linhas> <título>".
#   inventory.sh --todos [--docs DIR] [arquivo...]
#       Ocorrências de TODO e FIXME (palavra inteira, maiúsculas) nos arquivos
#       informados ou, sem arquivos, em todos os arquivos do repositório; uma linha
#       "TODO <caminho>:<linha>: <texto>".
#   inventory.sh --refs PADRÃO [--docs DIR]
#       Ocorrências literais de PADRÃO fora de DIR e de DIR-legado; uma linha
#       "REF <caminho>:<linha>: <texto>".
#
# DIR é a pasta de documentação (padrão: docs). Ela só é excluída de --markdown e
# --todos quando já está estruturada (DIR/.meta/regras.md existe). Pastas .git,
# node_modules, bin e obj são sempre ignoradas, assim como arquivos binários.
# A lista do repositório vem do git (rastreados e não rastreados não ignorados) ou,
# fora de um repositório git, de todos os arquivos.
# Saída em ordem de bytes do caminho e numérica da linha. Código de saída: 0, ou 2
# em uso inválido. A saída é idêntica à de inventory.ps1.

set -u
export LC_ALL=C

usage() { echo "Uso: inventory.sh --markdown|--todos [arquivo...]|--refs PADRÃO [--docs DIR]" >&2; exit 2; }

mode=""
pattern=""
docs="docs"
files=()
while [ $# -gt 0 ]; do
    case "$1" in
        --markdown) mode=markdown; shift ;;
        --todos) mode=todos; shift ;;
        --refs) [ $# -ge 2 ] || usage; mode=refs; pattern="$2"; shift 2 ;;
        --docs) [ $# -ge 2 ] || usage; docs="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) files+=("$1"); shift ;;
    esac
done
[ -n "$mode" ] || usage
[ "$mode" = refs ] && [ -z "$pattern" ] && usage
docs="${docs#./}"
docs="${docs%/}"

structured=0
[ -f "$docs/.meta/regras.md" ] && structured=1

# Normaliza um caminho: barras normais, sem "./" inicial.
norm() { local p="${1//\\//}"; p="${p#./}"; printf '%s' "$p"; }

# Verdadeiro se o caminho deve ser ignorado.
excluded() {
    local p="/$1"
    case "$p" in
        */.git/*|*/node_modules/*|*/bin/*|*/obj/*) return 0 ;;
    esac
    case "$2" in
        docs) [ "$structured" -eq 1 ] && case "$1" in "$docs"/*) return 0 ;; esac ;;
        refs) case "$1" in "$docs"/*|"$docs-legado"/*) return 0 ;; esac ;;
    esac
    return 1
}

# Lista os arquivos do repositório, um por linha.
all_files() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git -c core.quotepath=off ls-files --cached --others --exclude-standard
    else
        find . -type f
    fi
}

# Verdadeiro se o arquivo não é vazio e não tem byte nulo nos primeiros 8000 bytes.
is_text() {
    [ -s "$1" ] || return 1
    [ "$(head -c 8000 "$1" | wc -c)" -eq "$(head -c 8000 "$1" | tr -d '\000' | wc -c)" ]
}

case "$mode" in
markdown)
    all_files | while IFS= read -r f; do
        f=$(norm "$f")
        case "$f" in *.md|*.markdown|*.adoc|*.rst) ;; *) continue ;; esac
        excluded "$f" docs && continue
        [ -f "$f" ] || continue
        n=$(awk 'END { print NR }' "$f")
        t=$(awk '{ sub(/\r$/, "") } /^#[ \t]+/ { sub(/^#[ \t]+/, ""); sub(/[ \t]+$/, ""); print; exit }' "$f")
        [ -n "$t" ] || t="-"
        printf 'MD %s %s %s\n' "$f" "$n" "$t"
    done | sort
    ;;
todos|refs)
    {
        if [ "$mode" = todos ] && [ ${#files[@]} -gt 0 ]; then
            printf '%s\n' "${files[@]}"
        else
            all_files
        fi
    } | while IFS= read -r f; do
        f=$(norm "$f")
        [ -f "$f" ] || continue
        if [ "$mode" = todos ]; then excluded "$f" docs && continue; else excluded "$f" refs && continue; fi
        is_text "$f" || continue
        if [ "$mode" = todos ]; then
            grep -nwE 'TODO|FIXME' -- "$f" 2>/dev/null
        else
            grep -nF -- "$pattern" "$f" 2>/dev/null
        fi | while IFS= read -r line; do
            num="${line%%:*}"
            text="${line#*:}"
            text="${text%$'\r'}"
            text=$(printf '%s' "$text" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
            printf '%s\t%s\t%s\n' "$f" "$num" "$text"
        done
    done | sort -t $'\t' -k1,1 -k2,2n | while IFS=$'\t' read -r f num text; do
        if [ "$mode" = todos ]; then printf 'TODO %s:%s: %s\n' "$f" "$num" "$text"
        else printf 'REF %s:%s: %s\n' "$f" "$num" "$text"; fi
    done
    ;;
esac
exit 0

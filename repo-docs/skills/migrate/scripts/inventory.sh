#!/usr/bin/env bash
# inventory.sh: inventory of documentation, pending items in code and references,
# for the migration to the repo-docs structure. Read-only: does not change any file.
#
# Usage, from the repository root:
#   inventory.sh --markdown [--docs DIR]
#       Text documents (.md, .markdown, .adoc, .rst) outside the already structured
#       documentation; one line "MD <path> <lines> <title>".
#   inventory.sh --todos [--docs DIR] [file...]
#       Occurrences of TODO and FIXME (whole word, uppercase) in the given files
#       or, without files, in all repository files; one line
#       "TODO <path>:<line>: <text>".
#   inventory.sh --refs PATTERN [--docs DIR]
#       Literal occurrences of PATTERN outside DIR and DIR-legacy; one line
#       "REF <path>:<line>: <text>".
#
# DIR is the documentation folder (default: docs). It is only excluded from --markdown
# and --todos when it is already structured (DIR/.meta/rules.md exists). The .git,
# node_modules, bin and obj folders are always ignored, as are binary files.
# The repository list comes from git (tracked, and untracked not ignored) or,
# outside a git repository, from all files.
# Output in byte order of the path and numeric order of the line. Exit code: 0, or 2
# on invalid usage. The output is identical to that of inventory.ps1.

set -u
export LC_ALL=C

usage() { echo "Usage: inventory.sh --markdown|--todos [file...]|--refs PATTERN [--docs DIR]" >&2; exit 2; }

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
[ -f "$docs/.meta/rules.md" ] && structured=1

# Normalizes a path: forward slashes, no leading "./".
norm() { local p="${1//\\//}"; p="${p#./}"; printf '%s' "$p"; }

# True if the path must be ignored.
excluded() {
    local p="/$1"
    case "$p" in
        */.git/*|*/node_modules/*|*/bin/*|*/obj/*) return 0 ;;
    esac
    case "$2" in
        docs) [ "$structured" -eq 1 ] && case "$1" in "$docs"/*) return 0 ;; esac ;;
        refs) case "$1" in "$docs"/*|"$docs-legacy"/*) return 0 ;; esac ;;
    esac
    return 1
}

# Lists the repository files, one per line.
all_files() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git -c core.quotepath=off ls-files --cached --others --exclude-standard
    else
        find . -type f
    fi
}

# True if the file is not empty and has no null byte in the first 8000 bytes.
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

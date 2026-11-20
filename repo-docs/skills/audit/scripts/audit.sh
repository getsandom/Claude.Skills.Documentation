#!/usr/bin/env bash
# audit.sh: mechanical check of a documentation tree in the repo-docs structure.
# Read-only: does not change any file.
#
# Usage:
#   audit.sh [docs-dir]                     checks the structure (default: ./docs)
#   audit.sh --next-id PRE [docs-dir]       prints the next free identifier for prefix PRE
#   audit.sh --next-id PRE_NNN [docs-dir]   prints the next sub-identifier PRE_NNN.XX
#                                           of the folder document PRE_NNN
#
# Check output: one line per problem, "ERROR|WARNING <path>: <message>",
# with the path relative to the documentation folder, in byte order, followed by
# "Summary: N error(s), M warning(s)."
# Exit code: 0 without errors, 1 with errors, 2 on invalid usage or missing folder.
# The output is identical to that of audit.ps1 for the same tree.

set -u
export LC_ALL=C

docs="docs"
next=""
while [ $# -gt 0 ]; do
    case "$1" in
        --next-id)
            [ $# -ge 2 ] || { echo "Usage: audit.sh [--next-id PRE] [docs-dir]" >&2; exit 2; }
            next="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: audit.sh [--next-id PRE] [docs-dir]"; exit 0 ;;
        *)
            docs="$1"; shift ;;
    esac
done
docs="${docs%/}"
[ -d "$docs" ] || { echo "Documentation folder not found: $docs" >&2; exit 2; }

# Next free identifier: highest number used in file or folder names or in any
# index, plus one. For PRE_NNN, the highest XX of the sub-identifiers PRE_NNN.XX
# in file names or in any index, plus one.
if [ -n "$next" ]; then
    printf '%s' "$next" | grep -Eq '^[A-Z][A-Z0-9]*(_[0-9]{3})?$' || { echo "Invalid prefix: $next" >&2; exit 2; }
    case "$next" in
        *_*)
            max=$(
                {
                    find "$docs" -type f -name "${next}.[0-9][0-9]-*" | sed 's#.*/##'
                    find "$docs" -type f -path '*/.meta/index.md' -exec cat {} +
                } | tr -d '\r' | grep -oE "(^|[^A-Z0-9])${next}\.[0-9]{2}" | grep -oE '[0-9]{2}$' | sort | tail -n 1
            )
            [ -n "$max" ] || max=00
            printf '%s.%02d\n' "$next" $((10#$max + 1))
            ;;
        *)
            max=$(
                {
                    find "$docs" \( -type f -o -type d \) -name "${next}_[0-9][0-9][0-9]-*" | sed 's#.*/##'
                    find "$docs" -type f -path '*/.meta/index.md' -exec cat {} +
                } | grep -oE "(^|[^A-Z0-9])${next}_[0-9]{3}" | grep -oE '[0-9]{3}$' | sort | tail -n 1
            )
            [ -n "$max" ] || max=000
            printf '%s_%03d\n' "$next" $((10#$max + 1))
            ;;
    esac
    exit 0
fi

out=$(mktemp)
ids=$(mktemp)
closed=$(mktemp)
trap 'rm -f "$out" "$ids" "$closed"' EXIT

rel() {
    local p="${1#"$docs"}"
    p="${p#/}"
    printf '%s' "$p"
}
report() { printf '%s %s: %s\n' "$1" "$2" "$3" >> "$out"; }

# Topics: the root and every subfolder that does not start with a dot, outside .meta.
topics=$( { printf '%s\n' "$docs"; find "$docs" -mindepth 1 -type d -name '.*' -prune -o -type d -print; } | sort )

while IFS= read -r T; do
    [ -n "$T" ] || continue
    rt=$(rel "$T"); [ -n "$rt" ] && rt="$rt/"

    for f in README.md .meta/index.md .meta/rules.md; do
        [ -f "$T/$f" ] || report ERROR "$rt$f" "required file missing"
    done

    # Actual items: content files and immediate subtopics.
    actual=""
    for e in "$T"/*; do
        [ -e "$e" ] || continue
        n="${e##*/}"
        if [ -d "$e" ]; then
            actual+="$n/"$'\n'
        elif [ "$n" != "README.md" ]; then
            actual+="$n"$'\n'
        fi
    done

    # Identifiers of content files, folder documents and numbered inner files
    # (global check further below).
    for e in "$T"/*; do
        [ -e "$e" ] || continue
        n="${e##*/}"
        id=$(printf '%s' "$n" | grep -oE '^[A-Z][A-Z0-9]*_[0-9]{3}-' | sed 's/-$//')
        if [ -n "$id" ]; then
            if [ -d "$e" ]; then
                printf '%s\t%s\n' "$id" "$rt$n/" >> "$ids"
            else
                printf '%s\t%s\n' "$id" "$rt$n" >> "$ids"
            fi
        elif [ -f "$e" ]; then
            id=$(printf '%s' "$n" | grep -oE '^[A-Z][A-Z0-9]*_[0-9]{3}\.[0-9]{2}-' | sed 's/-$//')
            [ -n "$id" ] && printf '%s\t%s\n' "$id" "$rt$n" >> "$ids"
        fi
    done

    if [ -f "$T/.meta/index.md" ]; then
        parsed=$(awk '
            { sub(/\r$/, "") }
            /^## Closed[[:space:]]*$/ { enc = 1; next }
            /^## / { enc = 0 }
            !enc && match($0, /^- \[[^]]+\]\([^)]+\)/) {
                s = substr($0, 4, RLENGTH - 3)
                i = index(s, "](")
                print "I\t" substr(s, 1, i - 1) "\t" substr(s, i + 2, length(s) - i - 2)
            }
            enc && match($0, /^- `[^`]+`/) {
                print "E\t" substr($0, 4, RLENGTH - 4)
            }' "$T/.meta/index.md")
        items=$(printf '%s\n' "$parsed" | awk -F '\t' '$1 == "I" { print $2 }')

        while IFS=$'\t' read -r kind text target; do
            [ "$kind" = "I" ] || continue
            [ "$target" = "../$text" ] || report ERROR "$rt.meta/index.md" "the link of item $text should point to ../$text"
        done <<< "$parsed"

        printf '%s\n' "$items" | grep -v '^$' | sort | uniq -d | while IFS= read -r d; do
            report ERROR "$rt.meta/index.md" "duplicate item: $d"
        done
        comm -13 <(printf '%s' "$actual" | sort -u) <(printf '%s\n' "$items" | grep -v '^$' | sort -u) | while IFS= read -r m; do
            report ERROR "$rt.meta/index.md" "lists $m, which does not exist"
        done
        comm -23 <(printf '%s' "$actual" | sort -u) <(printf '%s\n' "$items" | grep -v '^$' | sort -u) | while IFS= read -r m; do
            report ERROR "$rt.meta/index.md" "does not list $m"
        done
        if [ "$(printf '%s\n' "$items" | grep -v '^$')" != "$(printf '%s\n' "$items" | grep -v '^$' | sort)" ]; then
            report WARNING "$rt.meta/index.md" "items out of alphabetical order"
        fi

        printf '%s\n' "$parsed" | awk -F '\t' '$1 == "E" { print $2 }' | while IFS= read -r c; do
            id=$(printf '%s' "$c" | grep -oE '^[A-Z][A-Z0-9]*_[0-9]{3}')
            [ -n "$id" ] && printf '%s\t%s\n' "$id" "$rt.meta/index.md" >> "$closed"
        done
    fi

    # Name pattern and title in topics with an identifier. With `PRE_NNN`, the
    # files and folders (folder documents) that start with the prefix; with
    # `PRE_NNN.XX`, the topic is a folder document and the files that start with the
    # prefix are the numbered inner files (the others are supporting files).
    if [ -f "$T/.meta/rules.md" ]; then
        ident=$(grep -m 1 '^- \*\*Identifier:\*\*' "$T/.meta/rules.md" | tr -d '\r' \
            | sed -n 's/^[^`]*`\([A-Z][A-Z0-9]*\)_NNN\(\.XX\)\{0,1\}`.*/\1\2/p')
        prefix="${ident%.XX}"
        if [ -n "$prefix" ] && [ "$ident" = "$prefix" ]; then
            for e in "$T"/*; do
                [ -e "$e" ] || continue
                n="${e##*/}"
                [ "$n" = "README.md" ] && continue
                if [ -d "$e" ]; then
                    case "$n" in "${prefix}_"*) ;; *) continue ;; esac
                    if ! printf '%s' "$n" | grep -Eq "^${prefix}_[0-9]{3}-[a-z0-9-]+$"; then
                        report ERROR "$rt$n/" "name does not match ${prefix}_NNN-title/"
                        continue
                    fi
                    [ -f "$e/README.md" ] || continue
                    file="$e/README.md"; shown="$rt$n/README.md"
                else
                    if ! printf '%s' "$n" | grep -Eq "^${prefix}_[0-9]{3}-[a-z0-9-]+\.md$"; then
                        report ERROR "$rt$n" "name does not match ${prefix}_NNN-title.md"
                        continue
                    fi
                    file="$e"; shown="$rt$n"
                fi
                id="${n%%-*}"
                first=$(head -n 1 "$file" | tr -d '\r')
                case "$first" in
                    "# $id:"*) ;;
                    *) report ERROR "$shown" "the title should start with '# $id:'" ;;
                esac
            done
        elif [ -n "$prefix" ]; then
            dname="${T##*/}"
            num=$(printf '%s' "$dname" | sed -n "s/^${prefix}_\([0-9][0-9][0-9]\)-.*/\1/p")
            if [ -z "$num" ]; then
                report ERROR "$rt.meta/rules.md" "identifier ${prefix}_NNN.XX in a folder that does not match ${prefix}_NNN-title/"
            else
                for e in "$T"/*; do
                    [ -f "$e" ] || continue
                    n="${e##*/}"
                    [ "$n" = "README.md" ] && continue
                    case "$n" in "${prefix}_"*) ;; *) continue ;; esac
                    if ! printf '%s' "$n" | grep -Eq "^${prefix}_${num}\.[0-9]{2}-[a-z0-9-]+\.md$"; then
                        report ERROR "$rt$n" "name does not match ${prefix}_${num}.XX-title.md"
                        continue
                    fi
                    id="${n%%-*}"
                    first=$(head -n 1 "$e" | tr -d '\r')
                    case "$first" in
                        "# $id:"*) ;;
                        *) report ERROR "$rt$n" "the title should start with '# $id:'" ;;
                    esac
                done
            fi
        fi
    fi
done <<< "$topics"

# Identifiers repeated across files.
sort "$ids" | awk -F '\t' '
    { paths[$1] = (paths[$1] == "" ? $2 : paths[$1] "\t" $2); count[$1]++ }
    END { for (k in count) if (count[k] > 1) print k "\t" paths[k] }' \
| while IFS=$'\t' read -r id firstp rest; do
    report ERROR "$firstp" "identifier $id also used in $(printf '%s' "$rest" | sed 's/\t/, /g')"
done

# Closed identifiers that exist again.
sort -u "$closed" | while IFS=$'\t' read -r id where; do
    awk -F '\t' -v id="$id" '$1 == id { print $2 }' "$ids" | sort | while IFS= read -r p; do
        report ERROR "$where" "closed identifier $id reused in $p"
    done
done

# Broken relative links, outside code blocks and code spans.
find "$docs" -type f -name '*.md' | sort | while IFS= read -r file; do
    dir="${file%/*}"
    awk '
        { sub(/\r$/, "") }
        /^[[:space:]]*(```|~~~)/ { code = !code; next }
        code { next }
        {
            line = $0
            gsub(/`[^`]*`/, "", line)
            while (match(line, /\]\([^)[:space:]]+/)) {
                print substr(line, RSTART + 2, RLENGTH - 2)
                line = substr(line, RSTART + RLENGTH)
            }
        }' "$file" | while IFS= read -r t; do
        case "$t" in
            http:*|https:*|mailto:*|\#*) continue ;;
        esac
        p="${t%%#*}"
        p="${p//%20/ }"
        [ -n "$p" ] || continue
        [ -e "$dir/$p" ] || report ERROR "$(rel "$file")" "broken link: $t"
    done
done

sort "$out"
errors=$(grep -c '^ERROR ' "$out")
warnings=$(grep -c '^WARNING ' "$out")
echo "Summary: $errors error(s), $warnings warning(s)."
[ "$errors" -eq 0 ]

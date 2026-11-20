#!/usr/bin/env bash
# audit.sh: verificação mecânica de uma documentação na estrutura repo-docs.
# Só leitura: não altera nenhum arquivo.
#
# Uso:
#   audit.sh [pasta-docs]                   verifica a estrutura (padrão: ./docs)
#   audit.sh --next-id PRE [pasta-docs]     imprime o próximo identificador livre do prefixo PRE
#   audit.sh --next-id PRE_NNN [pasta-docs] imprime o próximo sub-identificador PRE_NNN.XX
#                                           do documento em pasta PRE_NNN
#
# Saída da verificação: uma linha por problema, "ERRO|AVISO <caminho>: <mensagem>",
# com o caminho relativo à pasta de documentação, em ordem de bytes, seguida de
# "Resumo: N erro(s), M aviso(s)."
# Código de saída: 0 sem erros, 1 com erros, 2 em uso inválido ou pasta inexistente.
# A saída é idêntica à de audit.ps1 para a mesma árvore.

set -u
export LC_ALL=C

docs="docs"
next=""
while [ $# -gt 0 ]; do
    case "$1" in
        --next-id)
            [ $# -ge 2 ] || { echo "Uso: audit.sh [--next-id PRE] [pasta-docs]" >&2; exit 2; }
            next="$2"; shift 2 ;;
        -h|--help)
            echo "Uso: audit.sh [--next-id PRE] [pasta-docs]"; exit 0 ;;
        *)
            docs="$1"; shift ;;
    esac
done
docs="${docs%/}"
[ -d "$docs" ] || { echo "Pasta de documentação não encontrada: $docs" >&2; exit 2; }

# Próximo identificador livre: maior número usado em nomes de arquivo ou de pasta ou
# em qualquer índice, mais um. Para PRE_NNN, o maior XX dos sub-identificadores
# PRE_NNN.XX em nomes de arquivo ou em qualquer índice, mais um.
if [ -n "$next" ]; then
    printf '%s' "$next" | grep -Eq '^[A-Z][A-Z0-9]*(_[0-9]{3})?$' || { echo "Prefixo inválido: $next" >&2; exit 2; }
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

# Tópicos: a raiz e toda subpasta que não comece por ponto, fora de .meta.
topics=$( { printf '%s\n' "$docs"; find "$docs" -mindepth 1 -type d -name '.*' -prune -o -type d -print; } | sort )

while IFS= read -r T; do
    [ -n "$T" ] || continue
    rt=$(rel "$T"); [ -n "$rt" ] && rt="$rt/"

    for f in README.md .meta/index.md .meta/regras.md; do
        [ -f "$T/$f" ] || report ERRO "$rt$f" "arquivo obrigatório ausente"
    done

    # Itens reais: arquivos de conteúdo e subtópicos imediatos.
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

    # Identificadores dos arquivos de conteúdo, dos documentos em pasta e dos
    # arquivos internos numerados (verificação global adiante).
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
            /^## Encerrados[[:space:]]*$/ { enc = 1; next }
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
            [ "$target" = "../$text" ] || report ERRO "$rt.meta/index.md" "o link do item $text deveria apontar para ../$text"
        done <<< "$parsed"

        printf '%s\n' "$items" | grep -v '^$' | sort | uniq -d | while IFS= read -r d; do
            report ERRO "$rt.meta/index.md" "item repetido: $d"
        done
        comm -13 <(printf '%s' "$actual" | sort -u) <(printf '%s\n' "$items" | grep -v '^$' | sort -u) | while IFS= read -r m; do
            report ERRO "$rt.meta/index.md" "lista $m, que não existe"
        done
        comm -23 <(printf '%s' "$actual" | sort -u) <(printf '%s\n' "$items" | grep -v '^$' | sort -u) | while IFS= read -r m; do
            report ERRO "$rt.meta/index.md" "não lista $m"
        done
        if [ "$(printf '%s\n' "$items" | grep -v '^$')" != "$(printf '%s\n' "$items" | grep -v '^$' | sort)" ]; then
            report AVISO "$rt.meta/index.md" "itens fora da ordem alfabética"
        fi

        printf '%s\n' "$parsed" | awk -F '\t' '$1 == "E" { print $2 }' | while IFS= read -r c; do
            id=$(printf '%s' "$c" | grep -oE '^[A-Z][A-Z0-9]*_[0-9]{3}')
            [ -n "$id" ] && printf '%s\t%s\n' "$id" "$rt.meta/index.md" >> "$closed"
        done
    fi

    # Padrão de nome e título nos tópicos com identificador. Com `PRE_NNN`, os
    # arquivos e as pastas (documentos em pasta) que começam pelo prefixo; com
    # `PRE_NNN.XX`, o tópico é um documento em pasta e os arquivos que começam pelo
    # prefixo são os internos numerados (os demais são de apoio).
    if [ -f "$T/.meta/regras.md" ]; then
        ident=$(grep -m 1 '^- \*\*Identificador:\*\*' "$T/.meta/regras.md" | tr -d '\r' \
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
                        report ERRO "$rt$n/" "nome fora do padrão ${prefix}_NNN-titulo/"
                        continue
                    fi
                    [ -f "$e/README.md" ] || continue
                    file="$e/README.md"; shown="$rt$n/README.md"
                else
                    if ! printf '%s' "$n" | grep -Eq "^${prefix}_[0-9]{3}-[a-z0-9-]+\.md$"; then
                        report ERRO "$rt$n" "nome fora do padrão ${prefix}_NNN-titulo.md"
                        continue
                    fi
                    file="$e"; shown="$rt$n"
                fi
                id="${n%%-*}"
                first=$(head -n 1 "$file" | tr -d '\r')
                case "$first" in
                    "# $id:"*) ;;
                    *) report ERRO "$shown" "o título deveria começar por '# $id:'" ;;
                esac
            done
        elif [ -n "$prefix" ]; then
            dname="${T##*/}"
            num=$(printf '%s' "$dname" | sed -n "s/^${prefix}_\([0-9][0-9][0-9]\)-.*/\1/p")
            if [ -z "$num" ]; then
                report ERRO "$rt.meta/regras.md" "identificador ${prefix}_NNN.XX em pasta fora do padrão ${prefix}_NNN-titulo/"
            else
                for e in "$T"/*; do
                    [ -f "$e" ] || continue
                    n="${e##*/}"
                    [ "$n" = "README.md" ] && continue
                    case "$n" in "${prefix}_"*) ;; *) continue ;; esac
                    if ! printf '%s' "$n" | grep -Eq "^${prefix}_${num}\.[0-9]{2}-[a-z0-9-]+\.md$"; then
                        report ERRO "$rt$n" "nome fora do padrão ${prefix}_${num}.XX-titulo.md"
                        continue
                    fi
                    id="${n%%-*}"
                    first=$(head -n 1 "$e" | tr -d '\r')
                    case "$first" in
                        "# $id:"*) ;;
                        *) report ERRO "$rt$n" "o título deveria começar por '# $id:'" ;;
                    esac
                done
            fi
        fi
    fi
done <<< "$topics"

# Identificadores repetidos entre arquivos.
sort "$ids" | awk -F '\t' '
    { paths[$1] = (paths[$1] == "" ? $2 : paths[$1] "\t" $2); count[$1]++ }
    END { for (k in count) if (count[k] > 1) print k "\t" paths[k] }' \
| while IFS=$'\t' read -r id firstp rest; do
    report ERRO "$firstp" "identificador $id também usado em $(printf '%s' "$rest" | sed 's/\t/, /g')"
done

# Identificadores encerrados que voltaram a existir.
sort -u "$closed" | while IFS=$'\t' read -r id where; do
    awk -F '\t' -v id="$id" '$1 == id { print $2 }' "$ids" | sort | while IFS= read -r p; do
        report ERRO "$where" "identificador encerrado $id reutilizado em $p"
    done
done

# Links relativos quebrados, fora de blocos e trechos de código.
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
        [ -e "$dir/$p" ] || report ERRO "$(rel "$file")" "link quebrado: $t"
    done
done

sort "$out"
errors=$(grep -c '^ERRO ' "$out")
warnings=$(grep -c '^AVISO ' "$out")
echo "Resumo: $errors erro(s), $warnings aviso(s)."
[ "$errors" -eq 0 ]

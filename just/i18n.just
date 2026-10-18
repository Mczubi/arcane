set working-directory := '..'

[default]
[private]
list:
    @{{ just_executable() }} --justfile {{ justfile() }} --list i18n

# Add a locale. Example: just i18n add es "Español"
[script('bash')]
add locale native_name settings="frontend/project.inlang/settings.json" picker="frontend/src/lib/components/locale-picker.svelte" messages_dir="frontend/messages" base_locale="en":
    set -euo pipefail

    settings_path="{{ settings }}"
    picker_path="{{ picker }}"
    messages_dir="{{ messages_dir }}"
    base_locale="{{ base_locale }}"
    base_file="${messages_dir}/${base_locale}.json"
    target_file="${messages_dir}/{{ locale }}.json"

    if [ ! -f "$settings_path" ]; then
        echo "Settings file not found: $settings_path"
        exit 1
    fi

    if [ ! -f "$picker_path" ]; then
        echo "Locale picker file not found: $picker_path"
        exit 1
    fi

    if [ ! -f "$base_file" ]; then
        echo "Base messages file not found: $base_file"
        exit 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo "jq is required to update $settings_path"
        exit 1
    fi

    jq_tab="--tab"
    if ! jq --tab -n '{}' >/dev/null 2>&1; then
        jq_tab=""
    fi

    settings_tmp="$(mktemp)"
    jq $jq_tab --arg locale "{{ locale }}" \
        '.locales |= ( . + [$locale] | unique | sort_by(ascii_downcase) )' \
        "$settings_path" > "$settings_tmp"
    mv "$settings_tmp" "$settings_path"

    if ! command -v rg >/dev/null 2>&1; then
        echo "rg (ripgrep) is required to update $picker_path"
        exit 1
    fi

    start_line="$(rg -n -F "const locales: Record<string, string> = {" "$picker_path" | head -n1 | cut -d: -f1)"
    if [ -z "$start_line" ]; then
        echo "Unable to find locales map in $picker_path"
        exit 1
    fi

    end_line="$(awk -v s="$start_line" 'NR>=s && $0 ~ /^[[:space:]]*};/ { print NR; exit }' "$picker_path")"
    if [ -z "$end_line" ]; then
        echo "Unable to find end of locales map in $picker_path"
        exit 1
    fi

    const_indent="$(sed -n "${start_line}p" "$picker_path" | sed -E 's/^([[:space:]]*).*/\1/')"
    entry_indent="$(sed -n "$((start_line+1)),$((end_line-1))p" "$picker_path" | awk 'NF { match($0, /^[[:space:]]*/); print substr($0, RSTART, RLENGTH); exit }')"
    if [ -z "$entry_indent" ]; then
        entry_indent="${const_indent}\t"
    fi

    entries_tmp="$(mktemp)"
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*\'?([^\'\":]+)\'?[[:space:]]*:[[:space:]]*\'(.*)\'[[:space:]]*,[[:space:]]*$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            if [ "$key" != "{{ locale }}" ]; then
                printf '%s\t%s\n' "$key" "$value" >> "$entries_tmp"
            fi
        fi
    done < <(sed -n "$((start_line+1)),$((end_line-1))p" "$picker_path")

    printf '%s\t%s\n' "{{ locale }}" "{{ native_name }}" >> "$entries_tmp"

    new_block="${const_indent}const locales: Record<string, string> = {"
    new_block+=$'\n'
    while IFS=$'\t' read -r key value; do
        [ -z "$key" ] && continue
        if [[ $key =~ ^[A-Za-z_$][A-Za-z0-9_$]*$ ]]; then
            out_key="$key"
        else
            esc_key="${key//\\/\\\\}"
            esc_key="${esc_key//\'/\\\'}"
            out_key="'${esc_key}'"
        fi
        esc_value="${value//\\/\\\\}"
        esc_value="${esc_value//\'/\\\'}"
        new_block+="${entry_indent}${out_key}: '${esc_value}',"
        new_block+=$'\n'
    done < <(LC_ALL=C sort -f -t $'\t' -k1,1 "$entries_tmp")
    new_block+="${const_indent}};"
    rm -f "$entries_tmp"

    block_tmp="$(mktemp)"
    printf '%s\n' "$new_block" > "$block_tmp"

    picker_tmp="$(mktemp)"
    sed -n "1,$((start_line-1))p" "$picker_path" > "$picker_tmp"
    cat "$block_tmp" >> "$picker_tmp"
    tail -n "+$((end_line+1))" "$picker_path" >> "$picker_tmp"
    mv "$picker_tmp" "$picker_path"
    rm -f "$block_tmp"

    formatting_path="frontend/src/lib/utils/formatting.ts"
    if [ ! -f "$formatting_path" ]; then
        echo "Warning: $formatting_path not found; add the date-fns loader for '{{ locale }}' manually."
    elif rg -q "date-fns/locale/{{ locale }}'" "$formatting_path"; then
        echo "date-fns loader for '{{ locale }}' already present in $formatting_path"
    else
        f_start="$(rg -n -F "const dateFnsLocaleLoaders" "$formatting_path" | head -n1 | cut -d: -f1)"
        if [ -z "$f_start" ]; then
            echo "Warning: unable to find dateFnsLocaleLoaders in $formatting_path; add '{{ locale }}' manually."
        else
            f_end="$(awk -v s="$f_start" 'NR>s && $0 ~ /^[[:space:]]*};/ { print NR; exit }' "$formatting_path")"
            if [ -z "$f_end" ]; then
                echo "Warning: unable to find end of dateFnsLocaleLoaders in $formatting_path; add '{{ locale }}' manually."
            else
                f_const_indent="$(sed -n "${f_start}p" "$formatting_path" | sed -E 's/^([[:space:]]*).*/\1/')"
                f_entry_indent="$(sed -n "$((f_start+1)),$((f_end-1))p" "$formatting_path" | awk 'NF { match($0, /^[[:space:]]*/); print substr($0, RSTART, RLENGTH); exit }')"
                if [ -z "$f_entry_indent" ]; then
                    f_entry_indent="${f_const_indent}	"
                fi

                f_entries="$(mktemp)"
                while IFS= read -r line; do
                    if [[ $line =~ ^[[:space:]]*\'?([^\'\":]+)\'?:.*date-fns/locale/([A-Za-z-]+) ]]; then
                        key="${BASH_REMATCH[1]}"
                        mod="${BASH_REMATCH[2]}"
                        if [ "$key" != "{{ locale }}" ]; then
                            printf '%s\t%s\n' "$key" "$mod" >> "$f_entries"
                        fi
                    fi
                done < <(sed -n "$((f_start+1)),$((f_end-1))p" "$formatting_path")
                printf '%s\t%s\n' "{{ locale }}" "{{ locale }}" >> "$f_entries"

                f_block="$(sed -n "${f_start}p" "$formatting_path")"
                f_block+=$'\n'
                while IFS=$'\t' read -r key mod; do
                    [ -z "$key" ] && continue
                    if [[ $key =~ ^[A-Za-z_$][A-Za-z0-9_$]*$ ]]; then
                        out_key="$key"
                    else
                        out_key="'${key}'"
                    fi
                    f_block+="${f_entry_indent}${out_key}: () => resolveDateFnsLocale(() => import('date-fns/locale/${mod}')),"
                    f_block+=$'\n'
                done < <(LC_ALL=C sort -f -t $'\t' -k1,1 "$f_entries")
                f_block+="${f_const_indent}};"
                rm -f "$f_entries"

                f_tmp="$(mktemp)"
                sed -n "1,$((f_start-1))p" "$formatting_path" > "$f_tmp"
                printf '%s\n' "$f_block" >> "$f_tmp"
                tail -n "+$((f_end+1))" "$formatting_path" >> "$f_tmp"
                mv "$f_tmp" "$formatting_path"
                echo "Added date-fns loader for '{{ locale }}' to $formatting_path"

                if [ ! -e "frontend/node_modules/date-fns/locale/{{ locale }}.js" ] && [ ! -d "frontend/node_modules/date-fns/locale/{{ locale }}" ]; then
                    echo "Warning: date-fns may not ship a '{{ locale }}' locale (check the module name, e.g. en uses en-US)."
                fi
            fi
        fi
    fi

    if [ -f "$target_file" ]; then
        echo "Messages file already exists, not overwriting: $target_file"
    else
        cp "$base_file" "$target_file"
        echo "Created messages file: $target_file"
    fi

#!/usr/bin/env bash
# No Python, C compiler, or testing framework is required.
set -euo pipefail
cd "$(dirname "$0")/.."
group=${1:-}
if [[ ! $group =~ ^[a-z0-9-]*$ ]]; then
    echo 'Group must contain only lowercase letters, digits, and hyphens.' >&2
    exit 2
fi
make --no-print-directory test-binaries
mkdir -p build/logs
passed=0
total=0
cases=()
rows=()
for binary in build/tests/*; do
    [[ -f $binary && -x $binary && $binary != *.o ]] || continue
    name=${binary##*/}
    [[ -z $group || $name == "$group"-* ]] || continue
    total=$((total + 1))
    status=0
    timeout "${TEST_TIMEOUT:-3}s" qemu-aarch64 "$binary" > "build/logs/$name.log" 2>&1 || status=$?
    if [[ $status == 0 ]]; then
        passed=$((passed + 1))
        outcome=PASS
    elif [[ $status == 124 ]]; then
        outcome=TIMEOUT
    elif [[ $status == 99 ]]; then
        outcome=TODO
    else
        outcome=FAIL
    fi
    printf '%-48s %s\n' "$name" "$outcome"
    if [[ $status != 0 ]]; then cat "build/logs/$name.log"; fi
    cases+=("{\"name\":\"$name\",\"status\":\"$outcome\",\"exit_code\":$status}")
    rows+=("| $name | $outcome |")
done
if [[ $total == 0 ]]; then
    echo 'No tests matched. See tests/ for group names.' >&2
    exit 2
fi
score=$((passed * 80 / total))
{
    printf '{"passed":%d,"total":%d,"score":%d,"max_score":80,"manual_max_score":20,"cases":[' "$passed" "$total" "$score"
    sep=''
    for item in "${cases[@]}"; do printf '%s%s' "$sep" "$item"; sep=,; done
    printf ']}\n'
} > build/grade.json
{
    printf '# Assembly test results\n\n%d / %d passed. Automated score: **%d / 80** (rounded down).\n\n' "$passed" "$total" "$score"
    printf 'An instructor awards the remaining 20 points using the rubric.\n\n'
    if [[ -n $group ]]; then printf 'Filtered practice run: `%s`. This is not the full assignment score.\n\n' "$group"; fi
    printf '| Test | Result |\n| --- | --- |\n'
    printf '%s\n' "${rows[@]}"
} > build/grade.md
printf '\n%d/%d passed; automated score %d/80.\n' "$passed" "$total" "$score"
[[ $passed == "$total" ]]

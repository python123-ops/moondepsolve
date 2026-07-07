#!/usr/bin/env sh
set -eu

moon_bin="${MOON:-moon}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

"$moon_bin" run cmd/cli --target native --deny-warn -- \
  resolve \
  --registry examples/registry.txt \
  --root 'app:^1.0.0' \
  --format lock > "$tmp_dir/resolve.lock"

"$moon_bin" run cmd/cli --target native --deny-warn -- \
  resolve \
  --registry examples/registry.txt \
  --root 'app:^1.0.0' \
  --format dot > "$tmp_dir/dependency-graph.dot"

"$moon_bin" run cmd/cli --target native --deny-warn -- \
  plan \
  --registry examples/registry.txt \
  --lock examples/current.lock \
  --root 'app:^1.0.0' \
  --strategy minimal \
  --max-states 100000 > "$tmp_dir/minimal-plan.txt"

"$moon_bin" run cmd/cli --target native --deny-warn -- \
  plan \
  --registry examples/registry.txt \
  --lock examples/current.lock \
  --root 'app:^1.0.0' \
  --strategy highest > "$tmp_dir/highest-plan.txt"

diff -u examples/expected/resolve.lock "$tmp_dir/resolve.lock"
diff -u examples/expected/dependency-graph.dot "$tmp_dir/dependency-graph.dot"
diff -u examples/expected/minimal-plan.txt "$tmp_dir/minimal-plan.txt"
diff -u examples/expected/highest-plan.txt "$tmp_dir/highest-plan.txt"

printf '%s\n' 'MoonDepSolve v0.3 CLI demo passed.'

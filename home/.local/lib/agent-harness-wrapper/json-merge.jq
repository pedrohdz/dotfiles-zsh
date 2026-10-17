# json-merge.jq -- used by agent-harness-wrapper --apply-defaults.
#
#   jq -n --argjson acct "$(<settings.json)" --argjson defs "$(<defaults.json)" \
#      -f json-merge.jq
#
# prints {"settings": <merged>, "changes": [<one line per difference>]}.
#
# Merge rules: objects merge key by key; arrays are a union (the account's
# entries first, then default entries it lacks); anything else is replaced by
# the default. Keys and entries only the account has are kept.

def merge($a; $b):
  if ($a | type) == "object" and ($b | type) == "object" then
    reduce ($b | keys_unsorted[]) as $k ($a; .[$k] = merge($a[$k]; $b[$k]))
  elif ($a | type) == "array" and ($b | type) == "array" then
    $a + ($b - $a)
  else $b end;

# One line per difference between old ($o) and new ($n), for the summary.
def changes($o; $n; $path):
  if ($n | type) == "object" then
    ($n | keys_unsorted[]) as $k
    | changes((if ($o | type) == "object" then $o[$k] else null end);
              $n[$k]; $path + [$k])
  elif ($n | type) == "array" then
    (($n - (if ($o | type) == "array" then $o else [] end))
      | select(length > 0))
    | "\($path | join(".")): added \(. | tojson)"
  elif $o != $n then
    "\($path | join(".")): \($o | tojson) -> \($n | tojson)"
  else empty end;

merge($acct; $defs) as $new
| {settings: $new, changes: [changes($acct; $new; [])]}

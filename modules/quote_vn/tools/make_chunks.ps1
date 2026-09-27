# build labeling chunks for subagents: windows around hero-name mentions
param([string]$prep, [string]$work, [string]$heroRe, [int]$maxUtt = 360, [int]$chunk = 90)
$j = [IO.File]::ReadAllText("$prep\$work.json", [Text.Encoding]::UTF8) | ConvertFrom-Json
$U = $j.utterances
$keep = New-Object 'System.Collections.Generic.SortedSet[int]'
for ($i = 0; $i -lt $U.Count; $i++) {
  if ($U[$i].ctx -match $heroRe) { for ($k = [Math]::Max(0,$i-2); $k -le [Math]::Min($U.Count-1,$i+6); $k++) { [void]$keep.Add($k) } }
  if ($keep.Count -ge $maxUtt) { break }
}
$sel = @($keep)
$n = 0
for ($c = 0; $c -lt $sel.Count; $c += $chunk) {
  $lines = @()
  foreach ($k in $sel[$c..([Math]::Min($sel.Count-1,$c+$chunk-1))]) {
    $u = $U[$k]; $lines += "### u=$($u.u) p=$($u.p)"; $lines += "CTX: $($u.ctx)"; $i2 = 0
    foreach ($pt in $u.parts) { $lines += "Q$($i2): $pt"; $i2++ }
  }
  [IO.File]::WriteAllText("$prep\chunk_${work}_$n.txt", ($lines -join "`n"), (New-Object Text.UTF8Encoding($false))); $n++
}
"$work selected=$($sel.Count) chunks=$n"

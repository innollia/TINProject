# extract utterances per paragraph in source order`n# usage: extract.ps1 <raw> <out.json> <gutenberg|wiki>
param([string]$src, [string]$out, [string]$kind)
$t = [IO.File]::ReadAllText($src, [Text.Encoding]::UTF8)
if ($kind -eq 'gutenberg') {
  $s = $t.IndexOf('*** START OF'); $s = $t.IndexOf("`n", $s) + 1
  $e = $t.IndexOf('*** END OF'); $t = $t.Substring($s, $e - $s)
} else {
  $t = [regex]::Replace($t, '(?s)\{\{.*?\}\}', '')
  $t = [regex]::Replace($t, '\[\[(?:[^\]|]*\|)?([^\]]*)\]\]', '$1')
  $t = [regex]::Replace($t, "'''?|<[^>]+>|^=+.*?=+\s*$", '', 'Multiline')
}
$t = $t -replace "`r", ''
$paras = [regex]::Split($t, "\n\s*\n") | ForEach-Object { ($_ -replace '\s*\n\s*', ' ').Trim() } | Where-Object { $_ -ne '' }
$qre = [regex]'\u201C([^\u201D]+)\u201D|"([^"]+)"|\u300E([^\u300F]+)\u300F'
$utt = New-Object System.Collections.ArrayList
$narr = New-Object System.Collections.ArrayList
$pi = 0
foreach ($p in $paras) {
  $ms = $qre.Matches($p)
  if ($ms.Count -eq 0) { if ($p.Length -ge 30) { [void]$narr.Add(@{p=$pi; text=$p}) } }
  else {
    $parts = @(); foreach ($m in $ms) { $v = if ($m.Groups[1].Success) { $m.Groups[1].Value } elseif ($m.Groups[2].Success) { $m.Groups[2].Value } else { $m.Groups[3].Value }; $parts += $v.Trim() }
    $ctx = $qre.Replace($p, '[Q]'); if ($ctx.Length -gt 220) { $ctx = $ctx.Substring(0,220) }
    [void]$utt.Add(@{u=$utt.Count; p=$pi; parts=$parts; ctx=$ctx})
  }
  $pi++
}
$obj = @{utterances=$utt; narration=$narr; para_count=$pi}
[IO.File]::WriteAllText($out, ($obj | ConvertTo-Json -Depth 6 -Compress), (New-Object Text.UTF8Encoding($false)))
"$src utt=$($utt.Count) narr=$($narr.Count)"

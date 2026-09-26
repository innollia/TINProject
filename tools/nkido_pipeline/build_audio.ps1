<#
.SYNOPSIS
    Renders every situation-based sound event in audio_events.json with nkido.

.DESCRIPTION
    One WAV per event, offline, no sample bank. Hard licensing rules enforced here:

      * every nkido call carries --no-default-bank
      * the manifest must declare "default_bank": false
      * no "bank" key is accepted anywhere, remote or bundled
      * "sample" is accepted only as a relative path under samples/

    The script never deletes anything. Re-running it overwrites only the WAV files
    it owns, so a partial run is safe to repeat.

.PARAMETER NkidoPath
    Full path to the nkido executable. Leave empty to search PATH, then the usual
    clone locations from docs/research/round_2026_09_26/ROUND_PLAN.md.

.PARAMETER OutputRoot
    Where WAV files are written. Default <this folder>\build\wav, which reproduces the
    "wav" paths recorded in the manifest exactly.

.PARAMETER CheckFirst
    Run `nkido check` on every patch before rendering. Use this once the grammar of the
    draft patches is confirmed against a real build.

.PARAMETER DryRun
    Print every command that would run and exit. Does not require nkido to exist.

.EXAMPLE
    .\build_audio.ps1 -DryRun
    .\build_audio.ps1
    .\build_audio.ps1 -NkidoPath 'C:\projects\_tools\nkido\build\nkido.exe' -CheckFirst
#>
param(
    [string]$NkidoPath = '',
    [string]$ManifestPath = '',
    [string]$OutputRoot = '',
    [switch]$CheckFirst,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$PipelineRoot = $PSScriptRoot
$DefaultOutputRoot = Join-Path $PipelineRoot 'build\wav'
$SampleRoot = Join-Path $PipelineRoot 'samples'
$CloneCandidates = @(
    'C:\projects\_tools\nkido\build\nkido.exe',
    'C:\projects\_tools\nkido\build\Release\nkido.exe',
    'C:\projects\_tools\nkido\nkido.exe'
)

$EXIT_OK = 0
$EXIT_EVENT_FAILED = 1
$EXIT_REFUSED = 2

function Write-Refuse {
    param([string]$Reason)
    Write-Host "REFUSED: $Reason" -ForegroundColor Red
    exit $EXIT_REFUSED
}

function Resolve-Nkido {
    if (-not [string]::IsNullOrWhiteSpace($NkidoPath)) {
        if (-not (Test-Path -LiteralPath $NkidoPath -PathType Leaf)) {
            Write-Refuse "-NkidoPath does not exist: $NkidoPath"
        }
        return (Resolve-Path -LiteralPath $NkidoPath).Path
    }
    $onPath = Get-Command -Name 'nkido' -CommandType Application -ErrorAction SilentlyContinue
    if ($onPath) {
        return $onPath.Source
    }
    foreach ($candidate in $CloneCandidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return $candidate
        }
    }
    Write-Refuse 'nkido not found. Pass -NkidoPath, or add it to PATH, or build the clone at C:\projects\_tools\nkido.'
}

function Get-OwnSamplePath {
    param([string]$Raw, [string]$KitId, [string]$EventId)
    if ([string]::IsNullOrWhiteSpace($Raw)) {
        return ''
    }
    if ($Raw -match '://' -or $Raw -match '^github:' -or [System.IO.Path]::IsPathRooted($Raw)) {
        Write-Refuse "event '$KitId/$EventId': sample '$Raw' is remote or absolute. Only our own files under tools/nkido_pipeline/samples are allowed."
    }
    $full = [System.IO.Path]::GetFullPath((Join-Path $PipelineRoot $Raw))
    $samples = [System.IO.Path]::GetFullPath($SampleRoot)
    if (-not $full.StartsWith($samples, [System.StringComparison]::OrdinalIgnoreCase)) {
        Write-Refuse "event '$KitId/$EventId': sample '$Raw' must live under tools/nkido_pipeline/samples."
    }
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        Write-Refuse "event '$KitId/$EventId': sample file not found: $Raw"
    }
    return $full
}

function Format-Command {
    param([string]$Exe, [string[]]$Arguments)
    $parts = @()
    foreach ($argument in $Arguments) {
        if ($argument -match '\s') {
            $parts += '"' + $argument + '"'
        } else {
            $parts += $argument
        }
    }
    return ($Exe + ' ' + ($parts -join ' '))
}

if ([string]::IsNullOrWhiteSpace($ManifestPath)) {
    $ManifestPath = Join-Path $PipelineRoot 'audio_events.json'
}
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = $DefaultOutputRoot
}
if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
    Write-Refuse "manifest not found: $ManifestPath"
}

try {
    $manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
} catch {
    Write-Refuse "manifest is not valid JSON: $($_.Exception.Message)"
}

if ($manifest.default_bank -ne $false) {
    Write-Refuse 'manifest must declare "default_bank": false. The built in 808 kit mixes CC-BY-SA 4.0 and unlicensed samples.'
}
if (-not ($manifest.PSObject.Properties.Name -contains 'kits')) {
    Write-Refuse 'manifest has no "kits" array.'
}
$rate = if ($manifest.PSObject.Properties.Name -contains 'sample_rate') { [int]$manifest.sample_rate } else { 48000 }
$allowedBus = @('Music', 'SFX', 'UI', 'Voice')

$exe = if ($DryRun) { 'nkido' } else { Resolve-Nkido }
$customRoot = [System.IO.Path]::GetFullPath($OutputRoot) -ne [System.IO.Path]::GetFullPath($DefaultOutputRoot)

Write-Host "nkido   : $exe"
Write-Host "manifest: $ManifestPath"
Write-Host "output  : $OutputRoot"
Write-Host "rules   : --no-default-bank always, own samples only, no remote bank, nothing is deleted"
if ($customRoot) {
    Write-Warning 'custom -OutputRoot: the "wav" paths in audio_events.json no longer match where files land.'
}
if ($DryRun) {
    Write-Host 'mode    : dry run, nothing is executed'
}
Write-Host ''

$rows = New-Object System.Collections.Generic.List[object]

foreach ($kit in $manifest.kits) {
    $kitId = [string]$kit.id
    $bus = [string]$kit.bus
    if ($allowedBus -notcontains $bus) {
        Write-Refuse "kit '$kitId': bus '$bus' is not one of $($allowedBus -join ', ')"
    }
    $kitOutput = Join-Path $OutputRoot ([System.IO.Path]::GetFileName($kit.wav_dir))
    if (-not $DryRun) {
        New-Item -ItemType Directory -Force -Path $kitOutput | Out-Null
    }

    foreach ($event in $kit.events) {
        $eventId = [string]$event.id
        $qualified = "$($kit.id_prefix).$eventId"
        $patch = Join-Path $PipelineRoot $event.akkado
        $output = Join-Path $kitOutput "$eventId.wav"
        $seconds = [double]$event.duration_seconds
        $bpm = if ($event.PSObject.Properties.Name -contains 'bpm' -and $null -ne $event.bpm) { [double]$event.bpm } else { 120.0 }
        $sample = ''
        if ($event.PSObject.Properties.Name -contains 'sample') {
            $sample = Get-OwnSamplePath -Raw ([string]$event.sample) -KitId $kitId -EventId $eventId
        }

        $arguments = @()
        if ($CheckFirst) {
            $arguments += @('check', $patch)
        }
        $arguments += @('render', $patch, '-o', $output, '--seconds', ('{0:0.###}' -f $seconds), '--rate', $rate, '--bpm', ('{0:0.##}' -f $bpm), '--no-default-bank')
        if ($sample -ne '') {
            $arguments += @('--sample', "name=$sample")
        }

        $command = Format-Command -Exe $exe -Arguments $arguments

        if (-not (Test-Path -LiteralPath $patch -PathType Leaf)) {
            $rows.Add([pscustomobject]@{ Id = $qualified; Status = 'FAIL'; Detail = "patch not found: $($event.akkado)"; Command = $command })
            continue
        }
        if ($seconds -le 0.0) {
            $rows.Add([pscustomobject]@{ Id = $qualified; Status = 'FAIL'; Detail = "duration_seconds must be > 0, got $seconds"; Command = $command })
            continue
        }
        if ($DryRun) {
            Write-Host $command
            $rows.Add([pscustomobject]@{ Id = $qualified; Status = 'DRY'; Detail = 'not executed'; Command = $command })
            continue
        }

        Write-Host $command
        $output_text = & $exe @arguments 2>&1
        $code = $LASTEXITCODE
        $detail = ''
        if ($code -ne 0) {
            $detail = "exit $code " + (($output_text | Select-Object -Last 3) -join ' / ')
        } elseif (-not (Test-Path -LiteralPath $output -PathType Leaf)) {
            $detail = 'nkido reported success but wrote no wav'
            $code = 1
        } elseif ((Get-Item -LiteralPath $output).Length -le 44) {
            $detail = 'wav is smaller than a 44 byte header'
            $code = 1
        }
        $status = if ($code -eq 0) { 'PASS' } else { 'FAIL' }
        $rows.Add([pscustomobject]@{ Id = $qualified; Status = $status; Detail = $detail; Command = $command })
    }
}

Write-Host ''
Write-Host '---- per event ----'
foreach ($row in $rows) {
    if ($row.Status -eq 'PASS') {
        Write-Host ("  PASS  {0}" -f $row.Id) -ForegroundColor Green
    } else {
        Write-Host ("  {0}  {1}  {2}" -f $row.Status, $row.Id, $row.Detail) -ForegroundColor Red
    }
}

$passed = @($rows | Where-Object { $_.Status -eq 'PASS' }).Count
$failed = @($rows | Where-Object { $_.Status -eq 'FAIL' }).Count
$dry = @($rows | Where-Object { $_.Status -eq 'DRY' }).Count

Write-Host ''
Write-Host '---- summary ----'
foreach ($kit in $manifest.kits) {
    $kitRows = @($rows | Where-Object { $_.Id.StartsWith("$($kit.id_prefix).") })
    $kitPass = @($kitRows | Where-Object { $_.Status -eq 'PASS' }).Count
    $kitFail = @($kitRows | Where-Object { $_.Status -eq 'FAIL' }).Count
    Write-Host ("  {0,-5} {1,-28} {2} events  pass {3}  fail {4}" -f $kit.label, $kit.id, $kitRows.Count, $kitPass, $kitFail)
}
Write-Host ("  total {0} events  pass {1}  fail {2}  dry {3}" -f $rows.Count, $passed, $failed, $dry)
Write-Host ("  exit code: {0}" -f $(if ($DryRun) { $EXIT_OK } elseif ($failed -gt 0) { $EXIT_EVENT_FAILED } else { $EXIT_OK }))

if ($DryRun) {
    exit $EXIT_OK
}
exit $(if ($failed -gt 0) { $EXIT_EVENT_FAILED } else { $EXIT_OK })

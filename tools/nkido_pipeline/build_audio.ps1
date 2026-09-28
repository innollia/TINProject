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
    [switch]$DryRun,
    [switch]$SkipAmbient,
    [switch]$SkipAnalysis,
    [switch]$SkipMusic,
    [string]$AmbientManifestPath = ''
)

$ErrorActionPreference = 'Stop'

$PipelineRoot = $PSScriptRoot
# <repo>/tools/nkido_pipeline -> <repo>. Every res:// path is relative to this.
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$DefaultOutputRoot = Join-Path $PipelineRoot 'build\wav'
$SampleRoot = Join-Path $PipelineRoot 'samples'
$CloneCandidates = @(
    # The clang-cl build is the only working one. The MSVC build links and
    # launches, but the akkado compiler asks malloc for 0x0102011600000037
    # bytes on every input, so check/render die with 0xC0000409. See the
    # README section "nkido on Windows" before moving a path around.
    'C:\projects\_tools\nkido\build-clang\bin\nkido.exe',
    'C:\projects\_tools\nkido\build\bin\Release\nkido.exe',
    'C:\projects\_tools\nkido\build\nkido.exe',
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

        $arguments = @('render', $patch, '-o', $output, '--seconds', ('{0:0.###}' -f $seconds), '--rate', $rate, '--bpm', ('{0:0.##}' -f $bpm), '--no-default-bank')
        if ($sample -ne '') {
            $arguments += @('--sample', "name=$sample")
        }

        $command = Format-Command -Exe $exe -Arguments $arguments
        $checkCommand = Format-Command -Exe $exe -Arguments @('check', $patch)

        if (-not (Test-Path -LiteralPath $patch -PathType Leaf)) {
            $rows.Add([pscustomobject]@{ Id = $qualified; Status = 'FAIL'; Detail = "patch not found: $($event.akkado)"; Command = $command })
            continue
        }
        if ($seconds -le 0.0) {
            $rows.Add([pscustomobject]@{ Id = $qualified; Status = 'FAIL'; Detail = "duration_seconds must be > 0, got $seconds"; Command = $command })
            continue
        }
        if ($DryRun) {
            if ($CheckFirst) { Write-Host $checkCommand }
            Write-Host $command
            $rows.Add([pscustomobject]@{ Id = $qualified; Status = 'DRY'; Detail = 'not executed'; Command = $command })
            continue
        }

        # check and render are two separate programs invocations of the same
        # binary, not one command line. nkido takes a single mode per run.
        if ($CheckFirst) {
            Write-Host $checkCommand
            $checkText = & $exe check $patch 2>&1
            if ($LASTEXITCODE -ne 0) {
                $rows.Add([pscustomobject]@{ Id = $qualified; Status = 'FAIL'; Detail = (($checkText | Select-Object -Last 3) -join ' / '); Command = $checkCommand })
                continue
            }
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

# ---------------------------------------------------------------------------
# Dynamic ambience stems.
#
# A stem is a seamless loop, not an event. nkido writes exactly --seconds and
# stops, so each stem is rendered loop+fade and then folded back over its own
# head by tool/loopify.py. Gains live in ambient.json "profiles" and are the
# Kit's business at runtime; this script only produces the audio.
# ---------------------------------------------------------------------------
$ambientRows = New-Object System.Collections.Generic.List[object]
$ambientManifest = $null
$analysisFailed = $false
$musicFailed = $false

if (-not $SkipAmbient) {
    if ([string]::IsNullOrWhiteSpace($AmbientManifestPath)) {
        $AmbientManifestPath = Join-Path $PipelineRoot 'ambient.json'
    }
    if (-not (Test-Path -LiteralPath $AmbientManifestPath -PathType Leaf)) {
        Write-Refuse "ambient manifest not found: $AmbientManifestPath (pass -SkipAmbient to ignore)"
    }
    try {
        $ambientManifest = Get-Content -LiteralPath $AmbientManifestPath -Raw | ConvertFrom-Json
    } catch {
        Write-Refuse "ambient manifest is not valid JSON: $($_.Exception.Message)"
    }
    if ($ambientManifest.default_bank -ne $false) {
        Write-Refuse 'ambient manifest must declare "default_bank": false.'
    }
    if ($allowedBus -notcontains [string]$ambientManifest.stems[0].bus) {
        Write-Refuse "ambient stem bus '$($ambientManifest.stems[0].bus)' is not one of $($allowedBus -join ', ')"
    }
    foreach ($profile in $ambientManifest.profiles.PSObject.Properties) {
        foreach ($gain in $profile.Value.gains.PSObject.Properties) {
            if ($null -eq ($ambientManifest.stems | Where-Object { $_.id -eq $gain.Name })) {
                Write-Refuse "profile '$($profile.Name)' names stem '$($gain.Name)' which is not in "stems"."
            }
            if ([double]$gain.Value -lt 0.0 -or [double]$gain.Value -gt 1.0) {
                Write-Refuse "profile '$($profile.Name)' stem '$($gain.Name)' gain $($gain.Value) is outside 0..1."
            }
        }
    }
    foreach ($stem in $ambientManifest.stems) {
        $unused = $ambientManifest.profiles.PSObject.Properties | Where-Object { $null -eq $_.Value.gains.PSObject.Properties[$stem.id] }
        if ($unused) {
            Write-Refuse "stem '$($stem.id)' is in no profile. A stem nobody mixes is dead content."
        }
    }

    $ambientOutput = Join-Path $OutputRoot 'ambient'
    $rawOutput = Join-Path $ambientOutput 'raw'
    $python = ''
    if (-not $DryRun) {
        New-Item -ItemType Directory -Force -Path $rawOutput | Out-Null
        # Get-Command finds the Microsoft Store alias in WindowsApps, which is a
        # zero-byte re-launcher, not an interpreter. Only accept a candidate
        # that answers --version.
        foreach ($name in @('py', 'python', 'python3')) {
            $found = Get-Command -Name $name -CommandType Application -ErrorAction SilentlyContinue |
                Where-Object { $_.Source -notlike '*\WindowsApps\*' } |
                Select-Object -First 1
            if (-not $found) { continue }
            $version = & $found.Source --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                $python = $found.Source
                Write-Host ("python  : {0} ({1})" -f $python, ($version | Select-Object -First 1))
                break
            }
        }
        if (-not $python) {
            Write-Refuse 'no usable python found. It is needed to fold the loop crossfade, and the render stops here.'
        }
    }
    $loopify = Join-Path $PipelineRoot 'tool\loopify.py'

    Write-Host ''
    Write-Host "---- stems (nkido: $exe) ----"

    foreach ($stem in $ambientManifest.stems) {
        $stemId = [string]$stem.id
        $patch = Join-Path $PipelineRoot $stem.akkado
        $target = Join-Path $ambientOutput "$stemId.wav"
        $raw = Join-Path $rawOutput "$stemId.wav"
        $loop = [double]$stem.loop_seconds
        $fade = [double]$stem.fade_seconds
        # nkido renders whole audio blocks, so asking for exactly loop+fade can
        # come up a fraction of a sample short. The margin is headroom only:
        # loopify reads its crossfade tail at the loop point, not at the end of
        # the file, so anything past loop+fade is unused.
        $render = $loop + $fade + 0.25

        if (-not (Test-Path -LiteralPath $patch -PathType Leaf)) {
            $ambientRows.Add([pscustomobject]@{ Id = $stemId; Status = 'FAIL'; Detail = "patch not found: $($stem.akkado)" })
            continue
        }
        if ($loop -le 0.0 -or $fade -le 0.0 -or $fade -ge $loop) {
            $ambientRows.Add([pscustomobject]@{ Id = $stemId; Status = 'FAIL'; Detail = "loop/fade invalid: loop $loop fade $fade" })
            continue
        }

        $arguments = @('render', $patch, '-o', $raw, '--seconds', ('{0:0.###}' -f $render), '--rate', $rate, '--bpm', ('{0:0.##}' -f [double]$stem.bpm), '--no-default-bank')

        $command = Format-Command -Exe $exe -Arguments $arguments
        $checkCommand = Format-Command -Exe $exe -Arguments @('check', $patch)
        if ($DryRun) {
            if ($CheckFirst) { Write-Host $checkCommand }
            Write-Host $command
            Write-Host "    loopify -> $target  loop=$loop fade=$fade"
            $ambientRows.Add([pscustomobject]@{ Id = $stemId; Status = 'DRY'; Detail = 'not executed' })
            continue
        }

        if ($CheckFirst) {
            Write-Host $checkCommand
            $checkText = & $exe check $patch 2>&1
            if ($LASTEXITCODE -ne 0) {
                $ambientRows.Add([pscustomobject]@{ Id = $stemId; Status = 'FAIL'; Detail = (($checkText | Select-Object -Last 3) -join ' / ') })
                continue
            }
        }

        Write-Host $command
        $render_output = & $exe @arguments 2>&1
        $code = $LASTEXITCODE
        $detail = ''
        if ($code -ne 0) {
            $detail = "render exit $code " + (($render_output | Select-Object -Last 3) -join ' / ')
            $ambientRows.Add([pscustomobject]@{ Id = $stemId; Status = 'FAIL'; Detail = $detail })
            continue
        }

        $fold_output = & $python $loopify $raw $target --loop-seconds $loop --fade-seconds $fade 2>&1
        $code = $LASTEXITCODE
        $detail = (($fold_output | Select-Object -Last 1) -join '')
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
            $detail = 'loopify wrote no wav'
            $code = 1
        }
        $status = if ($code -eq 0) { 'PASS' } else { 'FAIL' }
        $ambientRows.Add([pscustomobject]@{ Id = $stemId; Status = $status; Detail = $detail })

        if ($code -eq 0 -and $null -ne $stem.res_file) {
            $resPath = ([string]$stem.res_file) -replace '^res://', ''
            $resFull = Join-Path $ProjectRoot ($resPath -replace '/', '\')
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $resFull) | Out-Null
            Copy-Item -LiteralPath $target -Destination $resFull -Force
        }
    }

    # Runtime view for the Kit. ambient.json stays the only authored source; this
    # is derived, so a stem can never exist in the audio and be missing from the mix.
    $runtimeStems = @()
    foreach ($stem in $ambientManifest.stems) {
        $runtimeStems += [ordered]@{
            id            = [string]$stem.id
            file          = [string]$stem.res_file
            bus           = [string]$stem.bus
            volume_db     = [double]$stem.volume_db
            role          = [string]$stem.role
            loop_seconds  = [double]$stem.loop_seconds
        }
    }
    $runtimeProfiles = [ordered]@{}
    foreach ($profile in $ambientManifest.profiles.PSObject.Properties) {
        $gains = [ordered]@{}
        foreach ($gain in $profile.Value.gains.PSObject.Properties) {
            $gains[[string]$gain.Name] = [double]$gain.Value
        }
        $runtimeProfiles[[string]$profile.Name] = [ordered]@{
            note  = [string]$profile.Value.note
            gains = $gains
        }
    }

    # Music layers. music/identity.yaml plus music/states/*.yaml compile to one
    # patch per (state, layer); the stem table is the same shape as the ambience
    # table, so the runtime manifest and the mixer need no special case.
    # The runtime manifest is written after this, not before: the music stems
    # have to be in hand before the manifest is built, and an [ordered]
    # hashtable holds the array it was given rather than a reference to it.
    $musicRows = New-Object System.Collections.Generic.List[object]
    $musicStems = @()
    $musicManifest = $null
    if (-not $SkipMusic) {
        $musicRoot = Join-Path $PipelineRoot 'music'
        $musicOut = Join-Path $PipelineRoot 'build\music'
        $musicTable = Join-Path $musicOut 'stems.json'
        $compiler = Join-Path $PipelineRoot 'tool\compile_music.py'
        Write-Host ''
        Write-Host '---- music (compile) ----'
        $compileOutput = & $python $compiler --identity (Join-Path $musicRoot 'identity.yaml') `
            --states (Join-Path $musicRoot 'states') --out $musicOut --stem-table $musicTable 2>&1
        $compileCode = $LASTEXITCODE
        Write-Host $compileOutput
        if ($compileCode -ne 0) {
            Write-Refuse 'compile_music.py failed. The music layers are not renderable and the build stops.'
        }

        $musicManifest = Get-Content -LiteralPath $musicTable -Raw -Encoding utf8 | ConvertFrom-Json
        $musicRaw = Join-Path $musicOut 'raw'
        New-Item -ItemType Directory -Force -Path $musicRaw | Out-Null
        $musicDest = Join-Path $ProjectRoot ("modules\{0}\audio\music" -f [string]$ambientManifest.target)
        New-Item -ItemType Directory -Force -Path $musicDest | Out-Null

        foreach ($stem in $musicManifest.stems) {
            $stemId = [string]$stem.id
            $patch = Join-Path $musicOut ([string]$stem.akkado)
            $loop = [double]$stem.loop_seconds
            $fade = [double]$stem.fade_seconds
            $render = $loop + $fade + 0.25
            $raw = Join-Path $musicRaw "$stemId.wav"
            $target = Join-Path $musicDest "$stemId.wav"

            $arguments = @('render', $patch, '-o', $raw, '--seconds', ('{0:0.###}' -f $render), '--rate', $rate, '--bpm', ('{0:0.##}' -f [double]$stem.bpm), '--no-default-bank')
            # nkido writes warnings to stderr. Under Stop that is a terminating
            # error even when the render succeeded, so read the exit code.
            $ErrorActionPreference = 'Continue'
            $renderOutput = & $exe @arguments 2>&1
            $code = $LASTEXITCODE
            $ErrorActionPreference = 'Stop'
            if ($code -ne 0) {
                $musicRows.Add([pscustomobject]@{ Id = $stemId; Status = 'FAIL'; Detail = "render exit $code" })
                continue
            }
            $ErrorActionPreference = 'Continue'
            $foldOutput = & $python $loopify $raw $target --loop-seconds $loop --fade-seconds $fade 2>&1
            $code = $LASTEXITCODE
            $ErrorActionPreference = 'Stop'
            $status = if ($code -eq 0) { 'PASS' } else { 'FAIL' }
            $musicRows.Add([pscustomobject]@{ Id = $stemId; Status = $status; Detail = (($foldOutput | Select-Object -Last 1) -join '') })
            $musicStems += [ordered]@{
                id           = $stemId
                file         = "res://modules/$([string]$ambientManifest.target)/audio/music/$stemId.wav"
                bus          = [string]$stem.bus
                volume_db    = [double]$stem.volume_db
                role         = [string]$stem.layer
                loop_seconds = $loop
            }
        }

        Write-Host ''
        Write-Host '---- music (stems) ----'
        foreach ($row in $musicRows) {
            if ($row.Status -eq 'PASS') {
                Write-Host ("  PASS  {0}  {1}" -f $row.Id, $row.Detail)
            } else {
                Write-Host ("  FAIL  {0}  {1}" -f $row.Id, $row.Detail) -ForegroundColor Red
                $musicFailed = $true
            }
        }
        Write-Host ("  total {0} music stems" -f $musicRows.Count)
    }

    if ($musicFailed) { $analysisFailed = $true }

    # One runtime manifest from both authored sources. Music layers land in the
    # same stems list and the same profiles, so the mixer treats them as music
    # and needs no special case.
    foreach ($entry in $musicStems) {
        $runtimeStems += $entry
    }
    if ($null -ne $musicManifest) {
        foreach ($stateName in $musicManifest.gains.PSObject.Properties.Name) {
            if (-not $runtimeProfiles.Contains($stateName)) { continue }
            foreach ($gain in $musicManifest.gains.$stateName.PSObject.Properties) {
                $runtimeProfiles[$stateName].gains[[string]$gain.Name] = [double]$gain.Value
            }
        }
    }
    $runtime = [ordered]@{
        generator = 'nkido'
        target    = [string]$ambientManifest.target
        mix_trim_db = [double]$ambientManifest.mix_trim_db
        note      = 'Generated by tools/nkido_pipeline/build_audio.ps1 from ambient.json and music/states. Do not edit by hand.'
        stems     = $runtimeStems
        profiles  = $runtimeProfiles
    }

    $runtimePath = Join-Path $ProjectRoot ("modules\{0}\ambient_stems.json" -f [string]$ambientManifest.target)
    # Windows PowerShell 5.1's `Set-Content -Encoding utf8` writes a BOM, and
    # Python's json.load rejects one. This file is machine input, so it goes out
    # as plain UTF-8.
    $runtimeJson = $runtime | ConvertTo-Json -Depth 8
    [System.IO.File]::WriteAllText($runtimePath, $runtimeJson, (New-Object System.Text.UTF8Encoding $false))
    Write-Host ("  wrote {0}" -f $runtimePath)

    # Measure what was rendered. A render that succeeds is not yet a render
    # that is right, and the person who has to listen is not the person who
    # writes the patch. Failures print; anything already on the open list
    # prints as KNOWN and does not stop the build.
    if (-not $DryRun -and -not $SkipAnalysis) {
        $analyzer = Join-Path $PipelineRoot 'tool\analyze_audio.py'
        $targets = Join-Path $PipelineRoot 'analysis_targets.json'
        $reportDir = Join-Path $PipelineRoot 'build\analysis'
        New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
        $stemGlobs = @()
        foreach ($stem in $ambientManifest.stems) {
            $relative = (([string]$stem.res_file) -replace '^res://', '') -replace '/', '\'
            $stemGlobs += (Join-Path $ProjectRoot $relative)
        }
        foreach ($stem in $musicStems) {
            $stemGlobs += (Join-Path $ProjectRoot ((([string]$stem.file) -replace '^res://', '') -replace '/', '\'))
        }

        # The analyzer reports findings on stderr on purpose. With
        # ErrorActionPreference = Stop a native command writing to stderr
        # becomes a terminating error, so relax it around these calls and read
        # the real exit code instead.
        $ErrorActionPreference = 'Continue'

        $selfTestText = & $python $analyzer --selftest 2>&1
        $selfTestCode = $LASTEXITCODE
        Write-Host ''
        Write-Host '---- analysis (objective gate) ----'
        Write-Host $selfTestText
        if ($selfTestCode -ne 0) {
            $ErrorActionPreference = 'Stop'
            Write-Refuse 'the analyzer failed its own selftest. The gate is not trustworthy, so the build stops.'
        }

        $analysisOutput = & $python $analyzer $targets @stemGlobs --json-out (Join-Path $reportDir 'ambience.json') 2>&1
        $analysisCode = $LASTEXITCODE
        Write-Host $analysisOutput
        if ($analysisCode -ne 0) {
            $analysisFailed = $true
        }

        $ErrorActionPreference = 'Stop'
    }

    # One WAV per profile, so a mix can be judged as a single file instead of by
    # holding three stems in the head at once. The sum is the same arithmetic
    # the runtime mixer does, so what is measured here is what the player hears.
    $mixer = Join-Path $PipelineRoot 'tool\mix_profiles.py'
    Write-Host ''
    Write-Host '---- profile mixes (objektive gate) ----'
    $mixOutput = & $python $mixer --manifest $runtimePath --targets $targets `
        --project-root $ProjectRoot --out (Join-Path $PipelineRoot 'build\mix') 2>&1
    $mixCode = $LASTEXITCODE
    Write-Host $mixOutput
    if ($mixCode -ne 0) {
        $analysisFailed = $true
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

if ($null -ne $ambientManifest) {
    $stemPass = @($ambientRows | Where-Object { $_.Status -eq 'PASS' }).Count
    $stemFail = @($ambientRows | Where-Object { $_.Status -eq 'FAIL' }).Count
    $stemDry = @($ambientRows | Where-Object { $_.Status -eq 'DRY' }).Count
    Write-Host ("  total {0} stems  pass {1}  fail {2}  dry {3}   target {4}" -f $ambientRows.Count, $stemPass, $stemFail, $stemDry, $ambientManifest.target)
    Write-Host ("  profiles {0}" -f (($ambientManifest.profiles.PSObject.Properties.Name) -join ', '))
}

$totalFailed = $failed + @($ambientRows | Where-Object { $_.Status -eq 'FAIL' }).Count
Write-Host ("  exit code: {0}" -f $(if ($DryRun) { $EXIT_OK } elseif ($totalFailed -gt 0) { $EXIT_EVENT_FAILED } else { $EXIT_OK }))

$ErrorActionPreference = 'Stop'

if ($analysisFailed) {
    Write-Host '  objektive gate failed; see the analysis report above.' -ForegroundColor Red
    $totalFailed = $totalFailed + 1
}
if ($DryRun) {
    exit $EXIT_OK
}
exit $(if ($totalFailed -gt 0) { $EXIT_EVENT_FAILED } else { $EXIT_OK })





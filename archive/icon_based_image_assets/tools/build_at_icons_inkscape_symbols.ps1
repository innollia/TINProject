param(
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$InstallDirectory = (Join-Path $env:APPDATA 'inkscape\symbols')
)

$sourceRoot = Join-Path $ProjectRoot 'addons\at-icons'
$outputRoot = Join-Path $ProjectRoot 'assets\shared_art_study\inkscape_symbols'
$categories = @('node2d')

New-Item -ItemType Directory -Force -Path $outputRoot, $InstallDirectory | Out-Null

Get-ChildItem -LiteralPath $outputRoot, $InstallDirectory -Filter 'tin-at-icons-*.svg' -File -ErrorAction SilentlyContinue |
    Remove-Item -Force

foreach ($category in $categories) {
    $builder = [System.Text.StringBuilder]::new()
    [void]$builder.AppendLine('<?xml version="1.0" encoding="UTF-8" standalone="no"?>')
    [void]$builder.AppendLine('<svg xmlns="http://www.w3.org/2000/svg" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape">')
    [void]$builder.AppendLine('  <defs>')

    $files = Get-ChildItem -LiteralPath (Join-Path $sourceRoot $category) -Filter '*.svg' -File | Sort-Object Name
    foreach ($file in $files) {
        [xml]$document = Get-Content -LiteralPath $file.FullName -Raw
        $root = $document.DocumentElement
        $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $id = 'at-' + $category + '-' + ($name -replace '[^A-Za-z0-9_.-]', '-')
        $label = [System.Security.SecurityElement]::Escape(($name -replace '_', ' '))
        $viewBox = $root.GetAttribute('viewBox')
        if ([string]::IsNullOrWhiteSpace($viewBox)) {
            $viewBox = "0 0 $($root.GetAttribute('width')) $($root.GetAttribute('height'))"
        }

        [void]$builder.AppendLine("    <symbol id=`"$id`" viewBox=`"$viewBox`" inkscape:label=`"$label`" inkscape:stockid=`"$id`">")
        foreach ($child in $root.ChildNodes) {
            [void]$builder.AppendLine('      ' + $child.OuterXml)
        }
        [void]$builder.AppendLine('    </symbol>')
    }

    [void]$builder.AppendLine('  </defs>')
    [void]$builder.AppendLine('</svg>')

    $fileName = "tin-at-icons-$category.svg"
    $projectOutput = Join-Path $outputRoot $fileName
    $installedOutput = Join-Path $InstallDirectory $fileName
    [System.IO.File]::WriteAllText($projectOutput, $builder.ToString(), [System.Text.UTF8Encoding]::new($false))
    Copy-Item -LiteralPath $projectOutput -Destination $installedOutput -Force
    Write-Output "$category $($files.Count) $installedOutput"
}

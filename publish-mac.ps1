#!/usr/bin/pwsh
Clear-Host

if ($PSVersionTable.PSVersion.Major -lt 6)
{
    Write-Host 'Restarting using pwsh...'
    pwsh $PSCommandPath
    return
}

Write-Host 'Clearing bin/obj...' -ForegroundColor Cyan
Remove-Item -LiteralPath UI.Avalonia/bin -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath UI.Avalonia/obj -Recurse -Force -ErrorAction SilentlyContinue

Write-Host 'Building macOS binary...' -ForegroundColor Cyan
dotnet publish -v:q -t:BundleApp -r osx-arm64 -f net10.0 --self-contained -c MacOS -o distrib/gui/mac/ UI.Avalonia/UI.Avalonia.csproj /p:PublishTrimmed=False /p:PublishSingleFile=True

Write-Host 'Clearing extra files in distrib...' -ForegroundColor Cyan
Get-ChildItem -LiteralPath distrib -Include *.pdb,*.config -Recurse | Remove-Item

if (($LASTEXITCODE -eq 0) -and ($IsMacOS -or ($PSVersionTable.Platform -eq 'Unix')))
{
    chmod +x distrib/gui/mac/PS3-Game-Dumper
    # The final app bundle needs to be re-signed as a whole.
    codesign --deep -fs - 'distrib/gui/mac/PS3-Game-Dumper.app'
}

Write-Host 'Bundling...' -ForegroundColor Cyan
if (Test-Path -LiteralPath 'distrib/gui/mac/PS3-Game-Dumper.app')
{
    # tar to preserve file permissions.
    tar -C distrib/gui/mac -cvzf distrib/PS3-Game-Dumper_macos_NEW.tar.gz 'PS3-Game-Dumper.app'
}

Write-Host 'Done' -ForegroundColor Cyan



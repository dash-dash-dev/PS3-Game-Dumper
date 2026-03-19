#!/usr/bin/pwsh
Clear-Host
$trim = $true

if ($PSVersionTable.PSVersion.Major -lt 6)
{
    Write-Host 'Restarting using pwsh...'
    pwsh $PSCommandPath
    return
}

Write-Host 'Clearing bin/obj...' -ForegroundColor Cyan
Remove-Item -LiteralPath UI.Avalonia/bin -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath UI.Avalonia/obj -Recurse -Force -ErrorAction SilentlyContinue

if ($IsWindows -or ($PSVersionTable.Platform -eq 'Win32NT'))
{
    Write-Host 'Building Windows binaries...' -ForegroundColor Cyan
    dotnet publish -v:q -r win-x64 -f net10.0-windows --self-contained -c Release -o distrib/gui/win/ UI.Avalonia/UI.Avalonia.csproj /p:PublishTrimmed=$trim /p:PublishSingleFile=True
}

Write-Host 'Building Linux binary...' -ForegroundColor Cyan
dotnet publish -v:q -r linux-x64 -f net10.0 --self-contained -c Linux -o distrib/gui/lin/ UI.Avalonia/UI.Avalonia.csproj /p:PublishTrimmed=$trim /p:PublishSingleFile=True
if (($LASTEXITCODE -eq 0) -and ($IsLinux -or ($PSVersionTable.Platform -eq 'Unix')))
{
    chmod +x distrib/gui/lin/PS3-Game-Dumper
}

Write-Host 'Clearing extra files in distrib...' -ForegroundColor Cyan
Get-ChildItem -LiteralPath distrib -Include *.pdb,*.config -Recurse | Remove-Item

Write-Host 'Zipping...' -ForegroundColor Cyan
if (Test-Path -LiteralPath distrib/gui/win/PS3-Game-Dumper.exe)
{
    Compress-Archive -LiteralPath distrib/gui/win/PS3-Game-Dumper.exe -DestinationPath distrib/PS3-Game-Dumper_windows_NEW.zip -CompressionLevel Optimal -Force
}
if (Test-Path -LiteralPath distrib/gui/lin/PS3-Game-Dumper)
{
    Compress-Archive -LiteralPath distrib/gui/lin/PS3-Game-Dumper -DestinationPath distrib/PS3-Game-Dumper_linux_NEW.zip -CompressionLevel Optimal -Force
}

Write-Host 'Done' -ForegroundColor Cyan



[CmdletBinding()]
param(
    [ValidateSet('win-x64', 'win-arm64')]
    [string]$RuntimeIdentifier = 'win-x64',
    [string]$DotNetPath = 'dotnet',
    [switch]$SkipTests
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$projectPath = Join-Path $projectRoot 'ZhenxingHardwareEditor.csproj'
$testProjectPath = Join-Path $projectRoot 'tests/ZhenxingHardwareEditor.Tests.csproj'
$projectXml = [xml](Get-Content -LiteralPath $projectPath -Raw)
$packageVersion = [string]$projectXml.Project.PropertyGroup.Version
if ($packageVersion -notmatch '^\d+\.\d+\.\d+(?:-[A-Za-z0-9.-]+)?$') {
    throw "Unsupported package version: $packageVersion"
}
$platform = if ($RuntimeIdentifier -eq 'win-arm64') { 'ARM64' } else { 'x64' }
$packageName = "ZhenxingHardwareEditor-$packageVersion-$RuntimeIdentifier"
$runId = (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N').Substring(0, 8)
$artifactsRoot = Join-Path $projectRoot 'artifacts/portable'
$runDirectory = Join-Path $artifactsRoot $runId
$publishDirectory = Join-Path $runDirectory $packageName
New-Item -ItemType Directory -Path $publishDirectory -Force | Out-Null

Push-Location -LiteralPath $projectRoot
try {
    if (-not $SkipTests) {
        & $DotNetPath test $testProjectPath -c Release --nologo
        if ($LASTEXITCODE -ne 0) { throw 'Tests failed; portable package was not published.' }
    }

    & $DotNetPath publish $projectPath -c Release -r $RuntimeIdentifier `
        "-p:Platform=$platform" -p:SelfContained=true -p:WindowsAppSDKSelfContained=true `
        -p:DebugType=None -p:DebugSymbols=false -o $publishDirectory --nologo
    if ($LASTEXITCODE -ne 0) { throw 'Publish failed; portable archive was not created.' }
}
finally {
    Pop-Location
}

$requiredFiles = @(
    'ZhenxingHardwareEditor.exe', 'ZhenxingHardwareEditor.dll',
    'ZhenxingHardwareEditor.runtimeconfig.json', 'ZhenxingHardwareEditor.pri',
    'Microsoft.UI.Xaml.dll', 'coreclr.dll', 'LICENSE', 'NOTICE', 'README.md',
    'Assets/AppIcon.ico', 'App.xbf', 'MainWindow.xbf',
    'Controls/ToolPageHeader.xbf', 'Pages/HardwareSpooferPage.xbf',
    'docs/releases/v0.1.0.md', 'docs/images/config-editor-light.png',
    'docs/images/config-editor-dark.png'
)
foreach ($relativePath in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $publishDirectory $relativePath) -PathType Leaf)) {
        throw "Portable package is missing a required file: $relativePath"
    }
}

$runtimeConfiguration = Get-Content -LiteralPath (Join-Path $publishDirectory 'ZhenxingHardwareEditor.runtimeconfig.json') -Raw | ConvertFrom-Json
$runtimeNames = @($runtimeConfiguration.runtimeOptions.includedFrameworks | ForEach-Object { $_.name })
if ($runtimeNames -notcontains 'Microsoft.NETCore.App') {
    throw 'Portable package does not contain the .NET application runtime.'
}
if ($runtimeNames -contains 'Microsoft.WindowsDesktop.App') {
    throw 'Unexpected Windows Desktop runtime dependency in this WinUI application.'
}

$packageManifest = [ordered]@{
    product = '枕星配置修改器'
    version = $packageVersion
    runtime = $RuntimeIdentifier
    builtUtc = [DateTime]::UtcNow.ToString('o')
    modelCatalogVerifiedOn = '2026-10-06'
    includedFrameworks = @($runtimeConfiguration.runtimeOptions.includedFrameworks)
    contents = 'Unpackaged WinUI 3 application with .NET and Windows App SDK runtimes'
}
$manifestPath = Join-Path $publishDirectory 'portable-package.json'
$packageManifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archivePath = Join-Path $runDirectory "$packageName.zip"
[System.IO.Compression.ZipFile]::CreateFromDirectory(
    $publishDirectory, $archivePath, [System.IO.Compression.CompressionLevel]::Optimal, $true)
$archiveHash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
$checksumPath = "$archivePath.sha256"
"$archiveHash  $packageName.zip" | Set-Content -LiteralPath $checksumPath -Encoding ASCII

Write-Host "Portable archive: $archivePath"
Write-Host "SHA256: $archiveHash"
[pscustomobject]@{
    ArchivePath = $archivePath
    ChecksumPath = $checksumPath
    PublishDirectory = $publishDirectory
    Version = $packageVersion
    RuntimeIdentifier = $RuntimeIdentifier
}

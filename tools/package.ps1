param([string]$OutputName='SNES-Jukebox-Album-Edition-v1.1.pk3')
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
Set-Location $root
& node tools/build.js
if($LASTEXITCODE -ne 0){throw 'Catalog generation failed'}
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression
$output=Join-Path $root $OutputName
if(Test-Path -LiteralPath $output){Remove-Item -LiteralPath $output}
$zip=[IO.Compression.ZipFile]::Open($output,[IO.Compression.ZipArchiveMode]::Create)
try {
 foreach($folder in @('original','src')) {
  foreach($file in Get-ChildItem (Join-Path $root $folder) -File -Recurse) {
   $rel=$file.FullName.Substring((Join-Path $root $folder).Length+1).Replace('\','/')
   if($folder -eq 'original' -and $rel -notmatch '^(music/|sounds/|SNDINFO.txt$|LANGUAGE.txt$|info.txt$)'){continue}
   [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,$file.FullName,$rel,[IO.Compression.CompressionLevel]::Optimal) | Out-Null
  }
 }
 [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,(Join-Path $root 'README.txt'),'README-ALBUM-EDITION.txt',[IO.Compression.CompressionLevel]::Optimal) | Out-Null
} finally {$zip.Dispose()}
Get-Item -LiteralPath $output | Select-Object Name,Length

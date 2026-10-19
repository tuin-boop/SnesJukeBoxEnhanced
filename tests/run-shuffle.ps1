param(
 [Parameter(Mandatory=$true)][string]$Engine,
 [Parameter(Mandatory=$true)][string]$IWAD,
 [switch]$TrackEnd
)
$ErrorActionPreference='Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
& powershell -NoProfile -ExecutionPolicy Bypass -File tools/package.ps1
if($LASTEXITCODE -ne 0){throw 'Build failed'}
New-Item -ItemType Directory -Force test | Out-Null
$probe=if($TrackEnd){'tests/track-end'}else{'tests/shuffle'}
$arguments='-iwad "'+$IWAD+'" -file SNES-Jukebox-Album-Edition-v1.3.pk3 '+$probe+' -config test/shuffle.ini -stdout +i_pauseinbackground false +i_soundinbackground true +vid_activeinbackground true +vid_fullscreen false +map map01'
$p=Start-Process -FilePath $Engine -ArgumentList $arguments -PassThru -WindowStyle Hidden -RedirectStandardOutput test/shuffle.log -RedirectStandardError test/shuffle-errors.log
try {
 for($i=0;$i -lt 100;$i++){
  if($p.HasExited){break}
  Start-Sleep -Milliseconds 500
  $log=Get-Content test/shuffle.log -Raw
  if($log -match 'SJ TEST COMPLETE|Script error|Execution could not continue|VM execution aborted'){break}
 }
} finally {if(!$p.HasExited){Stop-Process -Id $p.Id -Force}}
$log=Get-Content test/shuffle.log -Raw
$log -split "`n" | Select-Object -Last 30
if($log -notmatch 'SJ TEST COMPLETE' -or $log -match 'SJ TEST FAIL|Script error|VM execution aborted'){throw 'Shuffle regression failed'}

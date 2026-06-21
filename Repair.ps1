#requires -Version 5.1
<# Created by Dewald Pretorius. This tool does not delete or override managed Edge policies. #>
[CmdletBinding(SupportsShouldProcess=$true)]
param([ValidateSet('Diagnose','RefreshUserPolicy','ResetBrowserCache','FlushDns')][string]$Action='Diagnose',[string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'Edge_Enterprise_Policy_Repair'))
$ErrorActionPreference='Stop';$cachePath="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null;$stamp=Get-Date -Format yyyyMMdd_HHmmss;$log=Join-Path $OutputPath "Repair_$stamp.log";function Log($m){$l='{0:u} {1}'-f(Get-Date),$m;Write-Host $l;Add-Content $log $l}
$machine=Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -ErrorAction SilentlyContinue;$user=Get-ItemProperty 'HKCU:\SOFTWARE\Policies\Microsoft\Edge' -ErrorAction SilentlyContinue
[ordered]@{Action=$Action;EdgeRunning=[bool](Get-Process msedge -ErrorAction SilentlyContinue);CacheExists=(Test-Path $cachePath);MachinePolicy=$machine;UserPolicy=$user}|ConvertTo-Json -Depth 6|Set-Content (Join-Path $OutputPath "PreRepair_$stamp.json")
if($Action -eq 'Diagnose'){Log '[COMPLETE] Snapshot saved.';exit 0}
try{if($Action -eq 'RefreshUserPolicy' -and $PSCmdlet.ShouldProcess('Current user Group Policy','Run GPUpdate')){$p=Start-Process gpupdate.exe -ArgumentList '/target:user /force' -Wait -PassThru;if($p.ExitCode -notin 0,1){throw "GPUpdate exited with code $($p.ExitCode)."}}
elseif($Action -eq 'ResetBrowserCache' -and $PSCmdlet.ShouldProcess($cachePath,'Back up and reset Edge cache')){if(Get-Process msedge -ErrorAction SilentlyContinue){throw 'Close Microsoft Edge before resetting its cache.'};if(Test-Path $cachePath){$backup="$cachePath.backup-$stamp";Move-Item $cachePath $backup -Force;New-Item -ItemType Directory $cachePath -Force|Out-Null;Log "[BACKUP] $backup"}}
elseif($Action -eq 'FlushDns' -and $PSCmdlet.ShouldProcess('Windows DNS client cache','Clear')){Clear-DnsClientCache}}catch{Log "[FAILED] $($_.Exception.Message)";exit 5};Log '[COMPLETE] Repair completed without changing managed policy values.';exit 0

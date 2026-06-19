#requires -Version 5.1
<# Created by Dewald Pretorius #>
[CmdletBinding()]
param([string]$OutputPath)
$ErrorActionPreference='SilentlyContinue'
if(-not $OutputPath){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'Edge_Enterprise_Policy_Reports'}
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
$txt=Join-Path $OutputPath "Edge_Policy_Report_$stamp.txt"
$csv=Join-Path $OutputPath "Edge_Policy_Findings_$stamp.csv"
function Finding{param($Scope,$Policy,$Source,$Value,$Status,$Recommendation);[pscustomobject]@{Scope=$Scope;Policy=$Policy;Source=$Source;Value=$Value;Status=$Status;Recommendation=$Recommendation}}
$findings=@()
$policyRoots=@(
 @{Scope='Computer';Path='HKLM:\SOFTWARE\Policies\Microsoft\Edge'},
 @{Scope='User';Path='HKCU:\SOFTWARE\Policies\Microsoft\Edge'},
 @{Scope='Computer32';Path='HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge'}
)
foreach($root in $policyRoots){
 if(Test-Path $root.Path){
  $item=Get-ItemProperty $root.Path
  foreach($prop in $item.PSObject.Properties|Where-Object Name -notmatch '^PS'){
   $findings+=Finding $root.Scope $prop.Name $root.Path ($prop.Value -join ';') 'Configured' 'Confirm the configured value matches the intended enterprise baseline and is not duplicated at another scope.'
  }
 }
}
$duplicates=$findings|Group-Object Policy|Where-Object Count -gt 1
foreach($group in $duplicates){
 $values=($group.Group|Select-Object -ExpandProperty Value -Unique)-join ' | '
 $findings+=Finding 'Conflict review' $group.Name 'Multiple registry scopes' $values 'Review' 'A policy exists in multiple scopes. Confirm precedence and remove unintended duplicate configuration through the authoritative management system.'
}
$edgePath=(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe').'(default)'
if(-not $edgePath){$edgePath="$env:ProgramFiles(x86)\Microsoft\Edge\Application\msedge.exe"}
$version=$(if(Test-Path $edgePath){(Get-Item $edgePath).VersionInfo.ProductVersion}else{'Not found'})
$findings+=Finding 'Application' 'EdgeVersion' $edgePath $version ($(if($version -ne 'Not found'){'Detected'}else{'Review'})) 'Confirm the installed Edge build is supported and receiving enterprise updates.'
$update=Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate' -ErrorAction SilentlyContinue
if($update){foreach($prop in $update.PSObject.Properties|Where-Object Name -notmatch '^PS'){$findings+=Finding 'Computer' $prop.Name 'HKLM EdgeUpdate' ($prop.Value -join ';') 'Configured' 'Review Edge Update policy independently from browser policy.'}}
$gpresult=Join-Path $OutputPath "GPResult_$stamp.html"
gpresult.exe /H $gpresult /F 2>$null
$events=Get-WinEvent -FilterHashtable @{LogName='Application';StartTime=(Get-Date).AddDays(-7)}|Where-Object{$_.Message -match 'msedge|Microsoft Edge|EdgeUpdate'}|Select-Object -First 40 TimeCreated,Id,ProviderName,LevelDisplayName,Message
$findings|Export-Csv $csv -NoTypeInformation -Encoding UTF8
@('MICROSOFT EDGE ENTERPRISE POLICY TROUBLESHOOTER','Created by Dewald Pretorius',"Generated: $(Get-Date)","Edge version: $version",'',($findings|Format-Table -AutoSize|Out-String -Width 260),'DUPLICATE POLICY NAMES',($duplicates|Select-Object Name,Count|Format-Table -AutoSize|Out-String -Width 200),'RECENT EVENTS',($events|Format-List|Out-String -Width 240),"GPResult report: $gpresult")|Set-Content $txt -Encoding UTF8
Write-Host "Reports created in: $OutputPath" -ForegroundColor Green

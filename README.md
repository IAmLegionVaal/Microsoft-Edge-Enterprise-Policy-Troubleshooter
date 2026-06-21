# Microsoft Edge Enterprise Policy Troubleshooter

Created by **Dewald Pretorius**.

The repository includes the original read-only policy diagnostics and a new `Repair.ps1` helper.

Supported helper actions:

- `Diagnose`
- `RefreshUserPolicy`
- `ResetBrowserCache`
- `FlushDns`

```powershell
.\Repair.ps1 -Action Diagnose
.\Repair.ps1 -Action RefreshUserPolicy -WhatIf
.\Repair.ps1 -Action ResetBrowserCache -Confirm
```

The helper records current Edge policy evidence before acting. It does not change managed policy registry values. Browser cache data is preserved in a timestamped backup. All changes use PowerShell confirmation and logging. Source-reviewed; not runtime-tested in every managed Edge environment.

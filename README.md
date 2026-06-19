# Microsoft Edge Enterprise Policy Troubleshooter

Created by **Dewald Pretorius**.

A read-only PowerShell toolkit for investigating Microsoft Edge enterprise policy application, registry scope, duplicate configuration, Edge Update policy, Group Policy evidence, and recent Edge-related events.

## Checks

- Computer and user Edge policy registry paths
- 32-bit policy registry path
- Duplicate policy names across multiple scopes
- Installed Microsoft Edge version
- Edge Update policies
- Group Policy Result report
- Recent Edge and Edge Update events

## Run

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\Microsoft_Edge_Enterprise_Policy_Troubleshooter.ps1"
```

Reports are written to `Desktop\Edge_Enterprise_Policy_Reports` as TXT, CSV, and GPResult HTML.

## Scenarios supported

- A managed policy is not applying
- A browser setting says “Managed by your organization” unexpectedly
- User and computer policies conflict
- Edge Update behavior does not match the approved channel
- Extension, startup-page, proxy, download, or security policy appears incorrect
- Policy refresh succeeds but Edge still shows an unexpected value

## Safety

The toolkit does not change registry policies, Group Policy, Edge configuration, extensions, or update settings. Changes should be made through the authoritative management platform after reviewing the evidence.

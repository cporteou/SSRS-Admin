# SSRS Admin Module

### Administration tools for SSRS Operations

This module contains a few scripts and functions to manage SSRS & Migrate content between SSRS Servers/Instances

### Prerequisites

This module relies on two other modules to function:

dbaTools
ReportingServicesTools

`Install-Module -Name ReportingServicesTools`
`Install-Module -Name dbaTools`

### Common Migration Steps

1. Restore the SSRS Database from backup
2. Set the RS Database
3. Restore the Source encryption Key
4. Remove Subscriptions (from Source)
5. Update Data Sources (from reference data)
6. Update Folder Security
7. Reset the Scale out deployment contents
8. Backup the Encryption key




Authored by Craig Porteous




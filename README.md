# SanitizeIT

SanitizeIT is a PowerShell-based tool for securely anonymizing and pseudonymizing organizational data (such as exports and datasets) before sharing it with third parties.

The tool uses a **two-pass workflow**: first, inventory sensitive information; then, apply anonymization based on human review and predefined policies.

## Key Features

- **Supported Formats:** CSV, JSON, CLIXML.
- **Two-Pass Process:** Inventory -> Review -> Anonymization.
- **Smart Detection:**
  - *Schema-based:* Recognizes sensitive fields like `Email`, `ServerName`, `SID`.
  - *Value-based:* Regex engine for IP addresses, Emails, UNC paths, etc.
- **Consistency:** The same original value consistently receives the same alias within a run.
- **Quality Gate:** Automated post-scan that checks if any sensitive data remains.
- **Audit-proof:** Detailed logging and reporting without leaking PII.

## Project Structure

- `src/Public/`: User-facing PowerShell commands.
- `src/Private/`: Internal logic and helpers.
- `policy/`: Contains `rules.psd1` with detection definitions.
- `workspace/`: Used for run-specific data (Inventory, Mappings, Output).

## Usage

### 1. Inventory (Pass 1)
Scan a source folder for sensitive information.
```powershell
Import-Module ".\SanitizeIT.psd1"
$Run = New-SanitizationInventory -InputPath "C:\Data\Export" -ProjectName "SupportCase123"
```

### 2. Review (Human Control)
Export the results to CSV to review them in Excel (or any CSV editor).
```powershell
Export-SanitizationReview -InventoryPath $Run.InventoryFile -OutputPath ".\workspace\$($Run.RunId)\review.csv"
# Adjust the 'Action' column (Replace/Keep) in the CSV and save.
```

### 3. Mapping & Anonymization (Pass 2)
Generate the alias mapping and apply the anonymization.
```powershell
Import-SanitizationDecision -CSVPath ".\workspace\$($Run.RunId)\review.csv" -OutputPath ".\workspace\$($Run.RunId)\decisions.json"
New-SanitizationMapping -InventoryPath $Run.InventoryFile -DecisionsPath ".\workspace\$($Run.RunId)\decisions.json"
Invoke-Anonymization -WorkspacePath $Run.RunFolder
```

### 4. Verification
Check the sanitized output via the Quality Gate.
```powershell
Test-SanitizedOutput -Path "$($Run.RunFolder)\sanitized"
```

### 5. Quick Start (Unified Flow)
Use the orchestrator for a quick automated run (useful for testing).
```powershell
Invoke-FullSanitization -InputPath ".\sample_data" -SkipReview -Verbose
```

## Documentation & Help

All functions are provided with comprehensive **English** Comment-Based Help. You can access this via the standard PowerShell `Get-Help` command:

```powershell
Get-Help New-SanitizationInventory -Detailed
```

## Sample Data

The `sample_data/` folder contains various test files to evaluate the tool:
- `servers.csv`: Server inventory.
- `users.json`: User data.
- `assets.csv`: Asset management with serial numbers.
- `network_config.json`: Network settings.
- `settings.clixml`: PowerShell object export.

## Security

- **Workspace:** The `workspace/` folder is included in `.gitignore`.
- **Salts:** For deterministic pseudonymization, it is recommended to use a secure salt.
- **No Leakage:** Original values are never stored in reports or logs outside of the secure workspace.

## Authors

- **Urrel Monsels**

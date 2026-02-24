# SanitizeIT

SanitizeIT is een PowerShell-gebaseerde tool voor het veilig anonimiseren en pseudonimiseren van organisatiedata (zoals exports en datasets) voordat deze gedeeld worden met externe partijen.

De tool maakt gebruik van een **two-pass workflow**: eerst inventariseren wat gevoelig is, daarna de anonimisering toepassen op basis van menselijke review en beleid.

## Kenmerken

- **Ondersteunde Formaten:** CSV, JSON, CLIXML.
- **Twee-traps proces:** Inventarisatie -> Review -> Anonimisering.
- **Slimme Detectie:**
  - *Schema-based:* Herkent gevoelige velden zoals `Email`, `ServerName`, `SID`.
  - *Value-based:* Regex-engine voor IP-adressen, Emails, UNC-paden, etc.
- **Consistentie:** Dezelfde originele waarde krijgt consequent dezelfde alias binnen een run.
- **Quality Gate:** Automatische post-scan die controleert of er nog gevoelige data is achtergebleven.
- **Audit-proof:** Uitgebreide logging en rapportage zonder PII te lekken.

## Projectstructuur

- `src/Public/`: User-facing PowerShell commando's.
- `src/Private/`: Interne logica en helpers.
- `policy/`: Bevat `rules.psd1` met de detectie-definities.
- `workspace/`: Wordt gebruikt voor run-specifieke data (Inventory, Mappings, Output).

## Gebruik

### 1. Inventarisatie (Pass 1)
Scan een bronmap op gevoelige informatie.
```powershell
Import-Module ".\SanitizeIT.psd1"
$Run = New-SanitizationInventory -InputPath "C:\Data\Export" -ProjectName "SupportCase123"
```

### 2. Review (Menselijke controle)
Exporteer de resultaten naar CSV om ze in Excel te beoordelen.
```powershell
Export-SanitizationReview -InventoryPath $Run.InventoryFile -OutputPath ".\workspace\$($Run.RunId)\review.csv"
# Pas de 'Action' kolom aan (Replace/Keep) in Excel en sla op.
```

### 3. Mapping & Anonimisering (Pass 2)
Genereer de alias-mapping en pas de anonimisering toe.
```powershell
Import-SanitizationDecision -CSVPath ".\workspace\$($Run.RunId)\review.csv" -OutputPath ".\workspace\$($Run.RunId)\decisions.json"
New-SanitizationMapping -InventoryPath $Run.InventoryFile -DecisionsPath ".\workspace\$($Run.RunId)\decisions.json"
Invoke-Anonymization -WorkspacePath $Run.RunFolder
```

### 4. Verificatie
Controleer de gesaneerde output via de Quality Gate.
```powershell
Test-SanitizedOutput -Path "$($Run.RunFolder)\sanitized"
```

## Beveiliging

- **Workspace:** De `workspace/` map is opgenomen in `.gitignore`.
- **Salts:** Voor deterministische pseudonimisering wordt aanbevolen om een secure salt te gebruiken.
- **Geen Leakage:** Originelen worden nooit in rapporten of logs buiten de beveiligde workspace opgeslagen.

## Auteurs

- **Urrel Monsels**

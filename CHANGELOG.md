# Changelog

Alle belangrijke wijzigingen in dit project worden in dit bestand bijgehouden.

## [0.0.1] - 2024-02-24

### Toegevoegd
- **Fase 0: Basis & Architectuur**
  - Projectstructuur en mappen-layout.
  - PowerShell module manifest (`.psd1`) en loader (`.psm1`).
  - `.gitignore` voor bescherming van workspace data.
- **Fase 1: Inventarisatie**
  - `New-SanitizationInventory` voor automatische file discovery.
  - Ondersteuning voor CSV, JSON en CLIXML parsing.
  - Schema-based en Value-based (Regex) detectie van gevoelige data.
  - Confidence scoring mechanisme.
- **Fase 2: Review Gate**
  - `Export-SanitizationReview` voor CSV-gebaseerde menselijke review (Excel workflow).
  - `Import-SanitizationDecision` voor het inladen van review keuzes.
  - `New-SanitizationMapping` voor het genereren van consistente aliassen.
- **Fase 3: Anonimisering**
  - `Invoke-Anonymization` voor de daadwerkelijke data-transformatie.
  - `Invoke-SanitizationApply` voor recursieve vervanging in objecten.
  - `Test-SanitizedOutput` (Quality Gate) voor post-scan verificatie.
- **Fase 4: Operationalisatie**
  - `README.md` en `CHANGELOG.md` toegevoegd.
  - Sample data voor test doeleinden.

### Gewijzigd
- Scanner logica geoptimaliseerd om eigen aliassen (SVR-001, etc.) te negeren in de Quality Gate.
- Path-handling verbeterd voor absolute en relatieve bron-paden.

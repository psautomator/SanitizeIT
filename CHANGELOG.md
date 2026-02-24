# Changelog

All notable changes to this project will be documented in this file.

## [0.0.1] - 2024-02-24

### Added
- **Phase 0: Foundation & Architecture**
  - Project structure and folder layout.
  - PowerShell module manifest (`.psd1`) and loader (`.psm1`).
  - `.gitignore` for workspace data protection.
- **Phase 1: Inventory**
  - `New-SanitizationInventory` for automatic file discovery.
  - Support for CSV, JSON, and CLIXML parsing.
  - Schema-based and Value-based (Regex) detection of sensitive data.
  - Confidence scoring mechanism.
- **Phase 2: Review Gate**
  - `Export-SanitizationReview` for CSV-based human review (Excel workflow).
  - `Import-SanitizationDecision` for importing review choices.
  - `New-SanitizationMapping` for generating consistent aliases.
- **Phase 3: Anonymization**
  - `Invoke-Anonymization` for the actual data transformation.
  - `Invoke-SanitizationApply` for recursive replacement in objects.
  - `Test-SanitizedOutput` (Quality Gate) for post-scan verification.
- **Phase 4 & 5: Optimization & Documentation**
  - Project-wide **English** Comment-Based Help added to all functions.
  - `Invoke-FullSanitization` orchestrator for automated end-to-end runs.
  - Extensive sample data: `assets.csv`, `network_config.json`, `settings.clixml`.
  - `README.md` and `CHANGELOG.md` created and localized to English.

### Changed
- Refined scanner logic to ignore its own aliases (SVR-001, etc.) in the Quality Gate to prevent false positives.
- Improved path handling for absolute and relative source paths in `Get-SanitizationFiles`.
- Added author information to all source files (**Urrel Monsels**).

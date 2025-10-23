# EpicData - Azure IaC Generator

## Project Structure

The application has been refactored for better maintainability with a clean separation of concerns:

```
Website/
├── epicdata-iac-gen-caf.html   # Main HTML file (structure only)
├── css/
│   └── styles.css               # All CSS styles
├── js/
│   ├── pricing.js               # Azure pricing data and usage assumptions
│   └── app.js                   # Application logic and Terraform generators
└── PROJECT_STRUCTURE.md         # This file
```

## File Descriptions

### `epicdata-iac-gen-caf.html` (~470 lines)
Clean HTML markup containing only the page structure with:
- Form wizard steps (0-7)
- Input fields and controls
- Output display sections
- No inline styles or scripts

### `css/styles.css` (~600 lines)
Complete styling including:
- CSS custom properties for theming (light/dark mode)
- Component styles (buttons, forms, progress bar, etc.)
- Range slider styling for cost estimation
- Cost breakdown table styling
- Responsive layout

### `js/pricing.js` (~90 lines)
Azure pricing database for West Europe (EUR):
- Storage, Databricks, Data Factory, Event Hub, SQL Database, Functions
- Supporting services (Key Vault, Private Endpoints, etc.)
- Default usage assumptions (configurable via UI sliders)
- Well-documented with JSDoc comments

### `js/app.js` (~1,800 lines)
Application logic including:
- Wizard navigation (nextStep, prevStep, updateProgress)
- Configuration management (getConfig)
- **Cost estimation functions**
  - `calculateStorageCost()`
  - `calculateDatabricksCost()`
  - `calculateDataFactoryCost()`
  - `calculateEventHubCost()`
  - `calculateSQLDatabaseCost()`
  - `calculateFunctionCost()`
  - `calculateTotalCost()`
  - `updateCostEstimation()`
- Summary generation with cost breakdown (generateSummary)
- Terraform code generators:
  - `generateCAFMain()` - Greenfield deployment
  - `generateBrownfieldMain()` - Brownfield deployment
  - `generateProviders()` - Terraform providers config
  - `generateVariables()` - Variable definitions
  - `generateTfvars()` - Variable values
  - `generateReadme()` - Documentation
- File management (createFileTabs, displayFile, copyCode, downloadZip)
- Theme toggle functionality

## Features

### Cost Estimation (NEW!)
- **Real-time cost calculator** on Step 7 (Review & Generate)
- Interactive **usage sliders** for:
  - Storage capacity (GB)
  - Databricks cluster hours and cores
  - Data Factory pipeline runs
  - Event Hub throughput units
  - SQL Database uptime percentage
  - Function executions
- **Detailed cost breakdown table** showing:
  - Per-resource monthly costs
  - Configuration details
  - **Total estimated monthly cost in EUR**
- Based on **West Europe pricing** (as of 2024)
- Includes disclaimer about estimate accuracy

### Deployment Types
1. **Greenfield (CAF Foundation)**: Complete Azure Cloud Adoption Framework setup
2. **Brownfield (Data Platform)**: Data services only for existing landing zones

### Supported Azure Services
- Storage Account (Data Lake Gen2)
- Azure Databricks (with Unity Catalog support)
- Azure Data Factory
- Azure Event Hub
- Azure SQL Database
- Azure Functions
- Key Vault
- Private Endpoints
- Virtual Networks

## Maintenance Guide

### Updating Prices
Edit `js/pricing.js` to update Azure pricing:
```javascript
const azurePricing = {
    storage: {
        hotLRS: 0.0184, // Update this value
        // ...
    }
};
```

### Modifying Styles
All styles are in `css/styles.css`:
- Use CSS custom properties (`:root`) for colors and themes
- Dark mode overrides in `[data-theme="dark"]`
- Component-specific styles are clearly sectioned

### Adding New Features
1. Add HTML markup to `epicdata-iac-gen-caf.html`
2. Add styles to `css/styles.css`
3. Add JavaScript logic to `js/app.js`
4. If adding new pricing, update `js/pricing.js`

### Testing
Simply open `epicdata-iac-gen-caf.html` in a modern browser:
- Chrome, Edge, Firefox, Safari (latest versions)
- No build process or web server required
- Works offline (except for JSZip CDN)

## Dependencies

### External Libraries
- **JSZip** (CDN): For creating downloadable .zip files of generated Terraform code
  - `https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js`

### Browser Requirements
- Modern browser with ES6+ support
- JavaScript enabled
- Local file access (for downloading generated files)

## Version History

### v2.0 (Current) - Refactored Structure
- Split monolithic HTML into separate files
- Added comprehensive cost estimation feature
- Improved maintainability and code organization

### v1.0 - Initial Release
- Single HTML file with inline styles and scripts
- Terraform code generation for Azure data platform

## License & Disclaimer

The pricing data in `js/pricing.js` is for estimation purposes only and based on public Azure pricing information. Always use the official [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) for production budgeting and accurate cost estimates.

---

**Developed with Azure Cloud Adoption Framework best practices**

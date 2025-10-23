// Global state variables
let currentStep = 0;
let currentFile = 'main.tf';
let generatedFiles = {};

function toggleTheme() {
    const html = document.documentElement;
    const themeToggle = document.getElementById('themeToggle');
    const currentTheme = html.getAttribute('data-theme');
    
    if (currentTheme === 'dark') {
        html.removeAttribute('data-theme');
        themeToggle.textContent = '🌙';
        localStorage.setItem('theme', 'light');
    } else {
        html.setAttribute('data-theme', 'dark');
        themeToggle.textContent = '☀️';
        localStorage.setItem('theme', 'dark');
    }
}

window.addEventListener('DOMContentLoaded', () => {
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'dark') {
        document.documentElement.setAttribute('data-theme', 'dark');
        document.getElementById('themeToggle').textContent = '☀️';
    }
    updateProgress();
});

function nextStep() {
    const currentStepEl = document.getElementById(`step${currentStep}`);
    currentStepEl.classList.remove('active');

    const stepCircle = document.querySelector(`.progress-step[data-step="${currentStep}"]`);
    stepCircle.classList.add('completed');

    currentStep++;
    
    const deploymentType = document.querySelector('input[name="deployment_type"]:checked').value;
    const isGreenfield = deploymentType === 'greenfield';
    
    // Step 2: Show/hide resources based on deployment type
    if (currentStep === 2) {
        if (isGreenfield) {
            document.getElementById('greenfieldNote').style.display = 'block';
            document.getElementById('brownfieldResources').style.display = 'none';
        } else {
            document.getElementById('greenfieldNote').style.display = 'none';
            document.getElementById('brownfieldResources').style.display = 'block';
        }
    }
    
    // For greenfield, skip to review after step 2
    if (isGreenfield && currentStep === 3) {
        currentStep = 7; // Jump to review
    }
    
    // Step 4: Show/hide Databricks config
    if (currentStep === 4) {
        const hasDatabricks = document.getElementById('include_databricks')?.checked;
        if (hasDatabricks) {
            document.getElementById('databricksContent').style.display = 'block';
            document.getElementById('noDatabricksContent').style.display = 'none';
        } else {
            document.getElementById('databricksContent').style.display = 'none';
            document.getElementById('noDatabricksContent').style.display = 'block';
        }
    }
    
    // Step 6: Show/hide resource configs
    if (currentStep === 6) {
        updateResourceConfigVisibility();
    }

    // Step 7: Generate summary
    if (currentStep === 7) {
        generateSummary();
    }

    const nextStepEl = document.getElementById(`step${currentStep}`);
    nextStepEl.classList.add('active');

    updateProgress();
}

function prevStep() {
    const currentStepEl = document.getElementById(`step${currentStep}`);
    currentStepEl.classList.remove('active');

    const stepCircle = document.querySelector(`.progress-step[data-step="${currentStep}"]`);
    stepCircle.classList.remove('completed');

    const deploymentType = document.querySelector('input[name="deployment_type"]:checked').value;
    const isGreenfield = deploymentType === 'greenfield';
    
    // For greenfield jumping back from review
    if (isGreenfield && currentStep === 7) {
        currentStep = 2; // Jump back to resources
    } else {
        currentStep--;
    }

    const prevStepEl = document.getElementById(`step${currentStep}`);
    prevStepEl.classList.add('active');

    updateProgress();
}

function updateProgress() {
    document.querySelectorAll('.progress-step').forEach(step => {
        const stepNum = parseInt(step.dataset.step);
        step.classList.remove('active');
        if (stepNum === currentStep) {
            step.classList.add('active');
        }
    });

    const progress = (currentStep / 7) * 100;
    document.getElementById('progressLine').style.width = `${progress}%`;
}

function updateNetworkingVisibility() {
    const enabled = document.getElementById('include_networking').checked;
    document.getElementById('networkingContent').style.display = enabled ? 'block' : 'none';
    document.getElementById('noNetworkingContent').style.display = enabled ? 'none' : 'block';
}

function updateResourceConfigVisibility() {
    const eventhubEnabled = document.getElementById('include_eventhub')?.checked;
    const sqlEnabled = document.getElementById('include_sql_database')?.checked;
    const functionEnabled = document.getElementById('include_azure_function')?.checked;
    
    document.getElementById('eventhubConfig').style.display = eventhubEnabled ? 'block' : 'none';
    document.getElementById('sqlConfig').style.display = sqlEnabled ? 'block' : 'none';
    document.getElementById('functionConfig').style.display = functionEnabled ? 'block' : 'none';
    
    const anyConfigShown = eventhubEnabled || sqlEnabled || functionEnabled;
    document.getElementById('noResourceConfig').style.display = anyConfigShown ? 'none' : 'block';
}

function toggleCheckbox(id) {
    const checkbox = document.getElementById(id);
    checkbox.checked = !checkbox.checked;
}

function selectRadio(name, value) {
    document.getElementById(`${name.split('_')[0]}_${value}`).checked = true;
}

function generateSummary() {
    const config = getConfig();
    const isGreenfield = config.deployment_type === 'greenfield';
    
    let summaryHtml = '<div style="margin-bottom: 24px;">';
    
    if (isGreenfield) {
        summaryHtml += `
            <div class="info-box info">
                <div class="info-box-title">🌱 Greenfield Deployment - CAF Foundation</div>
                <div style="margin-top: 8px;">
                    Your infrastructure will include:<br><br>
                    <strong>Management & Governance:</strong><br>
                    • Management group hierarchy (Platform, Landing Zones, Decommissioned, Sandboxes)<br>
                    • Azure Policy baseline with 100+ policies<br>
                    • RBAC assignments and security baseline<br><br>
                    
                    <strong>Networking:</strong><br>
                    • Hub-spoke network topology (10.100.0.0/16)<br>
                    • Azure Firewall (Standard tier, 3 zones)<br>
                    • Private DNS zones for all PaaS services<br><br>
                    
                    <strong>Security & Monitoring:</strong><br>
                    • Microsoft Defender for Cloud<br>
                    • Log Analytics workspace (30-day retention)<br>
                    • Diagnostic settings<br><br>
                    
                    <strong>Identity:</strong><br>
                    • Managed identities configuration<br>
                    • Azure AD integration<br>
                </div>
            </div>
        `;
    } else {
        summaryHtml += `
            <div class="info-box info">
                <div class="info-box-title">🏗️ Brownfield Deployment - Data Platform</div>
                <div style="margin-top: 8px;">
                    <strong>Selected Resources:</strong><br>
                    ${config.include_storage_account ? '✓ Storage Account (Data Lake Gen2)<br>' : ''}
                    ${config.include_databricks ? '✓ Azure Databricks<br>' : ''}
                    ${config.include_data_factory ? '✓ Azure Data Factory<br>' : ''}
                    ${config.include_eventhub ? '✓ Azure Event Hub (' + config.eventhub_sku + ')<br>' : ''}
                    ${config.include_sql_database ? '✓ Azure SQL Database (' + config.sql_database_sku + ')<br>' : ''}
                    ${config.include_azure_function ? '✓ Azure Function (' + config.function_plan_type + ')<br>' : ''}
                    <br>
                    <strong>Identity:</strong> ${config.identity_type === 'user_assigned' ? 'User Assigned Managed Identity' : 'System Assigned Managed Identity'}<br>
                    ${config.include_networking ? '<strong>Networking:</strong> ✓ Private networking enabled<br>' : '<strong>Networking:</strong> Public access (not recommended for production)<br>'}
                    ${config.include_databricks && config.databricks_uc_metastore_id ? '<strong>Databricks:</strong> Unity Catalog enabled<br>' : ''}
                </div>
            </div>
        `;
    }
    
    summaryHtml += `
        <div style="background: var(--bg-secondary); padding: 16px; border-radius: 8px; margin-top: 16px;">
            <div style="font-weight: 600; margin-bottom: 12px;">Configuration Details</div>
            <div style="font-size: 13px; color: var(--text-secondary);">
                <div style="margin-bottom: 8px;"><strong>Organization:</strong> ${config.company_abbreviation}</div>
                <div style="margin-bottom: 8px;"><strong>Project:</strong> ${config.project_name}</div>
                <div style="margin-bottom: 8px;"><strong>Environment:</strong> ${config.environment}</div>
                <div style="margin-bottom: 8px;"><strong>Region:</strong> ${config.location}</div>
                <div><strong>Deployment Type:</strong> ${isGreenfield ? 'Greenfield (CAF Foundation)' : 'Brownfield (Existing Landing Zone)'}</div>
            </div>
        </div>
    `;
    
    if (!isGreenfield && config.include_networking) {
        summaryHtml += `
            <div style="background: var(--bg-secondary); padding: 16px; border-radius: 8px; margin-top: 16px;">
                <div style="font-weight: 600; margin-bottom: 12px;">Networking Configuration</div>
                <div style="font-size: 13px; color: var(--text-secondary);">
                    <div style="margin-bottom: 8px;"><strong>VNet:</strong> ${config.vnet_name} (${config.vnet_address_space})</div>
                    <div style="margin-bottom: 8px;"><strong>Data Platform Subnet:</strong> ${config.data_platform_subnet_cidr_block}</div>
                    <div><strong>Private Endpoints:</strong> Enabled for all resources</div>
                </div>
            </div>
        `;
    }

    // Add Cost Estimation Section
    summaryHtml += `
        <div style="background: linear-gradient(135deg, rgba(59, 130, 246, 0.05) 0%, rgba(16, 185, 129, 0.05) 100%); padding: 20px; border-radius: 12px; margin-top: 24px; border: 2px solid var(--accent-primary);">
            <div style="font-weight: 700; font-size: 18px; margin-bottom: 16px; color: var(--accent-primary); display: flex; align-items: center; gap: 8px;">
                <span>💰</span> Cost Estimation
            </div>

            <div class="info-box info" style="margin-bottom: 16px;">
                <div style="font-size: 12px;">
                    <strong>Region:</strong> West Europe | <strong>Currency:</strong> EUR (€) | <strong>Billing:</strong> Monthly<br>
                    <span style="color: var(--text-tertiary); font-size: 11px;">Adjust the sliders below to customize usage assumptions and see real-time cost updates.</span>
                </div>
            </div>

            <div id="usageSliders" style="background: var(--bg-primary); padding: 16px; border-radius: 8px; margin-bottom: 16px;">
                <div style="font-weight: 600; margin-bottom: 12px; font-size: 14px;">Usage Assumptions</div>
                ${!isGreenfield && config.include_storage_account ? `
                <div style="margin-bottom: 16px;">
                    <label style="font-size: 12px; font-weight: 600; display: block; margin-bottom: 4px;">
                        Storage Capacity: <span id="storageGbValue">${usageAssumptions.storage_gb}</span> GB
                    </label>
                    <input type="range" id="storageGbSlider" min="100" max="10000" step="100" value="${usageAssumptions.storage_gb}"
                           oninput="usageAssumptions.storage_gb = parseInt(this.value); document.getElementById('storageGbValue').textContent = this.value; updateCostEstimation();"
                           style="width: 100%;">
                </div>
                ` : ''}
                ${!isGreenfield && config.include_databricks ? `
                <div style="margin-bottom: 16px;">
                    <label style="font-size: 12px; font-weight: 600; display: block; margin-bottom: 4px;">
                        Databricks Cluster Hours/Month: <span id="databricksHoursValue">${usageAssumptions.databricks_hours}</span> hours
                    </label>
                    <input type="range" id="databricksHoursSlider" min="0" max="730" step="10" value="${usageAssumptions.databricks_hours}"
                           oninput="usageAssumptions.databricks_hours = parseInt(this.value); document.getElementById('databricksHoursValue').textContent = this.value; updateCostEstimation();"
                           style="width: 100%;">
                </div>
                <div style="margin-bottom: 16px;">
                    <label style="font-size: 12px; font-weight: 600; display: block; margin-bottom: 4px;">
                        Databricks Cluster Cores: <span id="databricksCoresValue">${usageAssumptions.databricks_cores}</span> cores
                    </label>
                    <input type="range" id="databricksCoresSlider" min="2" max="32" step="2" value="${usageAssumptions.databricks_cores}"
                           oninput="usageAssumptions.databricks_cores = parseInt(this.value); document.getElementById('databricksCoresValue').textContent = this.value; updateCostEstimation();"
                           style="width: 100%;">
                </div>
                ` : ''}
                ${!isGreenfield && config.include_data_factory ? `
                <div style="margin-bottom: 16px;">
                    <label style="font-size: 12px; font-weight: 600; display: block; margin-bottom: 4px;">
                        Data Factory Pipeline Runs/Month: <span id="datafactoryRunsValue">${usageAssumptions.datafactory_pipeline_runs}</span>
                    </label>
                    <input type="range" id="datafactoryRunsSlider" min="100" max="10000" step="100" value="${usageAssumptions.datafactory_pipeline_runs}"
                           oninput="usageAssumptions.datafactory_pipeline_runs = parseInt(this.value); document.getElementById('datafactoryRunsValue').textContent = this.value; updateCostEstimation();"
                           style="width: 100%;">
                </div>
                ` : ''}
                ${!isGreenfield && config.include_eventhub && config.eventhub_sku === 'Standard' ? `
                <div style="margin-bottom: 16px;">
                    <label style="font-size: 12px; font-weight: 600; display: block; margin-bottom: 4px;">
                        Event Hub Throughput Units: <span id="eventhubTUValue">${usageAssumptions.eventhub_throughput_units}</span>
                    </label>
                    <input type="range" id="eventhubTUSlider" min="1" max="20" step="1" value="${usageAssumptions.eventhub_throughput_units}"
                           oninput="usageAssumptions.eventhub_throughput_units = parseInt(this.value); document.getElementById('eventhubTUValue').textContent = this.value; updateCostEstimation();"
                           style="width: 100%;">
                </div>
                ` : ''}
                ${!isGreenfield && config.include_sql_database ? `
                <div style="margin-bottom: 16px;">
                    <label style="font-size: 12px; font-weight: 600; display: block; margin-bottom: 4px;">
                        SQL Database Uptime: <span id="sqlUptimeValue">${usageAssumptions.sql_uptime_percent}</span>%
                    </label>
                    <input type="range" id="sqlUptimeSlider" min="10" max="100" step="10" value="${usageAssumptions.sql_uptime_percent}"
                           oninput="usageAssumptions.sql_uptime_percent = parseInt(this.value); document.getElementById('sqlUptimeValue').textContent = this.value; updateCostEstimation();"
                           style="width: 100%;">
                </div>
                ` : ''}
                ${!isGreenfield && config.include_azure_function && config.function_plan_type === 'Consumption' ? `
                <div style="margin-bottom: 16px;">
                    <label style="font-size: 12px; font-weight: 600; display: block; margin-bottom: 4px;">
                        Function Executions/Month: <span id="functionExecsValue">${(usageAssumptions.function_executions / 1000000).toFixed(1)}</span>M
                    </label>
                    <input type="range" id="functionExecsSlider" min="100000" max="10000000" step="100000" value="${usageAssumptions.function_executions}"
                           oninput="usageAssumptions.function_executions = parseInt(this.value); document.getElementById('functionExecsValue').textContent = (this.value / 1000000).toFixed(1) + 'M'; updateCostEstimation();"
                           style="width: 100%;">
                </div>
                ` : ''}
            </div>

            <div style="background: var(--bg-primary); padding: 16px; border-radius: 8px;">
                <div style="font-weight: 600; margin-bottom: 12px; font-size: 14px;">Cost Breakdown</div>
                <div id="costBreakdown"></div>
            </div>

            <div class="info-box warning" style="margin-top: 16px;">
                <div style="font-size: 11px;">
                    <strong>Disclaimer:</strong> These are estimated costs based on West Europe pricing (as of 2024) and your usage assumptions.
                    Actual costs may vary based on actual usage, data transfer, and other factors.
                    Always use the official Azure Pricing Calculator for production budgeting.
                </div>
            </div>
        </div>
    `;

    summaryHtml += '</div>';

    document.getElementById('summaryContent').innerHTML = summaryHtml;

    // Update cost estimation after rendering
    setTimeout(() => updateCostEstimation(), 100);
}

function getConfig() {
    return {
        deployment_type: document.querySelector('input[name="deployment_type"]:checked').value,
        tenant_id: document.getElementById('tenant_id').value,
        subscription_id: document.getElementById('subscription_id').value,
        owner: document.getElementById('owner').value,
        company_abbreviation: document.getElementById('company_abbreviation').value,
        project_name: document.getElementById('project_name').value,
        environment: document.getElementById('environment').value,
        location: document.getElementById('location').value,
        // Resources
        include_storage_account: document.getElementById('include_storage_account')?.checked || false,
        include_databricks: document.getElementById('include_databricks')?.checked || false,
        include_data_factory: document.getElementById('include_data_factory')?.checked || false,
        include_eventhub: document.getElementById('include_eventhub')?.checked || false,
        include_sql_database: document.getElementById('include_sql_database')?.checked || false,
        include_azure_function: document.getElementById('include_azure_function')?.checked || false,
        // Identity
        identity_type: document.querySelector('input[name="identity_type"]:checked')?.value || 'user_assigned',
        // Databricks
        databricks_uc_metastore_id: document.getElementById('databricks_uc_metastore_id')?.value || '',
        databricks_account_id: document.getElementById('databricks_account_id')?.value || '',
        first_environment: document.getElementById('first_environment')?.checked || false,
        databricks_schema_names: document.getElementById('databricks_schema_names')?.value || 'bronze,silver,gold',
        // Networking
        include_networking: document.getElementById('include_networking')?.checked || false,
        networking_resource_group_name: document.getElementById('networking_resource_group_name')?.value || '',
        vnet_name: document.getElementById('vnet_name')?.value || '',
        vnet_address_space: document.getElementById('vnet_address_space')?.value || '10.0.0.0/16',
        data_platform_subnet_cidr_block: document.getElementById('data_platform_subnet_cidr_block')?.value || '10.0.5.0/24',
        // Event Hub
        eventhub_sku: document.getElementById('eventhub_sku')?.value || 'Standard',
        eventhub_partition_count: document.getElementById('eventhub_partition_count')?.value || '4',
        eventhub_message_retention: document.getElementById('eventhub_message_retention')?.value || '1',
        eventhub_enable_capture: document.getElementById('eventhub_enable_capture')?.checked || false,
        // SQL Database
        sql_server_admin_login_username: document.getElementById('sql_server_admin_login_username')?.value || '',
        sql_server_admin_object_id: document.getElementById('sql_server_admin_object_id')?.value || '',
        sql_database_type: document.getElementById('sql_database_type')?.value || 'DTU',
        sql_database_sku: document.getElementById('sql_database_sku')?.value || 'Basic',
        // Azure Function
        function_plan_type: document.getElementById('function_plan_type')?.value || 'Consumption',
        function_runtime: document.getElementById('function_runtime')?.value || 'python'
    };
}

// Cost Calculation Functions
function calculateStorageCost() {
    const storageCost = (usageAssumptions.storage_gb * azurePricing.storage.hotLRS) +
                       (usageAssumptions.storage_operations * azurePricing.storage.operations);
    return storageCost;
}

function calculateDatabricksCost() {
    // Databricks cost = DBU cost + VM cost
    // Premium tier: 2 DBU per core-hour
    const dbuCost = usageAssumptions.databricks_hours * usageAssumptions.databricks_cores * 2 * azurePricing.databricks.premiumDBU;
    const vmCost = usageAssumptions.databricks_hours * usageAssumptions.databricks_cores * azurePricing.databricks.standardVMCore;
    return dbuCost + vmCost;
}

function calculateDataFactoryCost() {
    const pipelineCost = (usageAssumptions.datafactory_pipeline_runs / 1000) * azurePricing.dataFactory.orchestrationActivity;
    const diuCost = usageAssumptions.datafactory_diu_hours * azurePricing.dataFactory.dataMovementDIU;
    const baseCost = azurePricing.dataFactory.pipelineWithNoActivity;
    return pipelineCost + diuCost + baseCost;
}

function calculateEventHubCost(sku) {
    if (sku === 'Basic') {
        return 730 * azurePricing.eventHub.basic;
    } else if (sku === 'Standard') {
        return (730 * azurePricing.eventHub.standard) +
               (usageAssumptions.eventhub_throughput_units * azurePricing.eventHub.standardThroughput);
    } else if (sku === 'Premium') {
        return azurePricing.eventHub.premium.processingUnit;
    }
    return 0;
}

function calculateSQLDatabaseCost(sku) {
    const skuMap = {
        'Basic': azurePricing.sqlDatabase.basic,
        'S0': azurePricing.sqlDatabase.S0,
        'S1': azurePricing.sqlDatabase.S1,
        'S2': azurePricing.sqlDatabase.S2,
        'S3': azurePricing.sqlDatabase.S3,
        'P1': azurePricing.sqlDatabase.P1,
        'P2': azurePricing.sqlDatabase.P2,
        'GP_Gen5_2': azurePricing.sqlDatabase.gpGen5_2,
        'GP_Gen5_4': azurePricing.sqlDatabase.gpGen5_4
    };
    const monthlyCost = skuMap[sku] || azurePricing.sqlDatabase.basic;
    return monthlyCost * (usageAssumptions.sql_uptime_percent / 100);
}

function calculateFunctionCost(planType) {
    if (planType === 'Consumption') {
        const executionCost = (usageAssumptions.function_executions / 1000000) * azurePricing.functions.consumption.execution;
        const computeCost = usageAssumptions.function_gb_seconds * azurePricing.functions.consumption.gbSeconds;
        return executionCost + computeCost;
    } else if (planType === 'Premium') {
        return azurePricing.functions.premium.EP1;
    }
    return 0;
}

function calculateTotalCost(config) {
    let costs = [];
    let total = 0;

    const isGreenfield = config.deployment_type === 'greenfield';

    if (isGreenfield) {
        // Greenfield includes CAF resources
        const firewallCost = 730 * azurePricing.azureFirewall.deployment;
        costs.push({ resource: 'Azure Firewall (Standard)', config: '3 zones, 24/7', cost: firewallCost });
        total += firewallCost;

        const logAnalyticsCost = 20; // Estimated 20 EUR/month for basic monitoring
        costs.push({ resource: 'Log Analytics Workspace', config: '30-day retention', cost: logAnalyticsCost });
        total += logAnalyticsCost;

        const policyCost = 0; // Azure Policy is included
        costs.push({ resource: 'Azure Policy & Management Groups', config: '100+ policies', cost: 0 });
    } else {
        // Brownfield - calculate based on selected resources
        if (config.include_storage_account) {
            const storageCost = calculateStorageCost();
            costs.push({
                resource: 'Storage Account (Data Lake Gen2)',
                config: `${usageAssumptions.storage_gb} GB, Hot LRS`,
                cost: storageCost
            });
            total += storageCost;
        }

        if (config.include_databricks) {
            const databricksCost = calculateDatabricksCost();
            costs.push({
                resource: 'Azure Databricks',
                config: `Premium, ${usageAssumptions.databricks_cores} cores, ${usageAssumptions.databricks_hours}h/month`,
                cost: databricksCost
            });
            total += databricksCost;
        }

        if (config.include_data_factory) {
            const datafactoryCost = calculateDataFactoryCost();
            costs.push({
                resource: 'Azure Data Factory',
                config: `${usageAssumptions.datafactory_pipeline_runs} runs/month`,
                cost: datafactoryCost
            });
            total += datafactoryCost;
        }

        if (config.include_eventhub) {
            const eventhubCost = calculateEventHubCost(config.eventhub_sku);
            costs.push({
                resource: 'Azure Event Hub',
                config: `${config.eventhub_sku} SKU`,
                cost: eventhubCost
            });
            total += eventhubCost;
        }

        if (config.include_sql_database) {
            const sqlCost = calculateSQLDatabaseCost(config.sql_database_sku);
            costs.push({
                resource: 'Azure SQL Database',
                config: `${config.sql_database_sku}, ${usageAssumptions.sql_uptime_percent}% uptime`,
                cost: sqlCost
            });
            total += sqlCost;
        }

        if (config.include_azure_function) {
            const functionCost = calculateFunctionCost(config.function_plan_type);
            costs.push({
                resource: 'Azure Function',
                config: `${config.function_plan_type} plan`,
                cost: functionCost
            });
            total += functionCost;
        }

        // Key Vault (always included in brownfield)
        const keyVaultCost = 10 * azurePricing.keyVault.secrets; // Assume 10 secrets
        costs.push({
            resource: 'Azure Key Vault',
            config: '10 secrets',
            cost: keyVaultCost
        });
        total += keyVaultCost;

        // Private Endpoints (if networking enabled)
        if (config.include_networking) {
            let endpointCount = 1; // Key Vault
            if (config.include_storage_account) endpointCount++;
            if (config.include_sql_database) endpointCount++;
            if (config.include_eventhub) endpointCount++;

            const privateEndpointCost = endpointCount * azurePricing.privateEndpoint;
            costs.push({
                resource: 'Private Endpoints',
                config: `${endpointCount} endpoints`,
                cost: privateEndpointCost
            });
            total += privateEndpointCost;
        }
    }

    return { costs, total };
}

function updateCostEstimation() {
    const config = getConfig();
    const { costs, total } = calculateTotalCost(config);

    let costHtml = '<table style="width: 100%; font-size: 13px;">';
    costHtml += '<thead><tr style="border-bottom: 2px solid var(--border-color);"><th style="text-align: left; padding: 8px;">Resource</th><th style="text-align: left; padding: 8px;">Configuration</th><th style="text-align: right; padding: 8px;">Monthly Cost (EUR)</th></tr></thead>';
    costHtml += '<tbody>';

    costs.forEach(item => {
        costHtml += `<tr style="border-bottom: 1px solid var(--border-color);">
            <td style="padding: 8px; font-weight: 500;">${item.resource}</td>
            <td style="padding: 8px; color: var(--text-secondary);">${item.config}</td>
            <td style="padding: 8px; text-align: right; font-family: monospace;">€${item.cost.toFixed(2)}</td>
        </tr>`;
    });

    costHtml += `<tr style="font-weight: 700; font-size: 15px; background: var(--bg-tertiary);">
        <td style="padding: 12px;" colspan="2">Total Estimated Monthly Cost</td>
        <td style="padding: 12px; text-align: right; font-family: monospace; color: var(--accent-primary);">€${total.toFixed(2)}</td>
    </tr>`;
    costHtml += '</tbody></table>';

    document.getElementById('costBreakdown').innerHTML = costHtml;
}

function generateTerraform() {
    const config = getConfig();
    generatedFiles = {};
    
    if (config.deployment_type === 'greenfield') {
        generatedFiles['main.tf'] = generateCAFMain(config);
        generatedFiles['variables.tf'] = generateCAFVariables(config);
        generatedFiles['terraform.tfvars'] = generateCAFTfvars(config);
    } else {
        generatedFiles['main.tf'] = generateBrownfieldMain(config);
        generatedFiles['variables.tf'] = generateBrownfieldVariables(config);
        generatedFiles['terraform.tfvars'] = generateBrownfieldTfvars(config);
    }
    
    generatedFiles['providers.tf'] = generateProviders(config);
    generatedFiles['README.md'] = generateReadme(config);

    createFileTabs();
    displayFile('main.tf');
}

function generateCAFMain(config) {
    return `# Azure Cloud Adoption Framework - Enterprise-Scale Landing Zone
# Generated by EpicData IaC Generator
# Deployment Type: Greenfield

terraform {
  required_version = ">= 1.3"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Use the official Azure Landing Zone Terraform module
module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "~> 6.0"

  # Root management group configuration
  default_location = var.location
  root_parent_id   = data.azurerm_client_config.current.tenant_id
  root_id          = "\${var.company_abbreviation}-\${var.environment}"
  root_name        = "\${var.company_abbreviation}-\${var.environment}"

  # Deploy core landing zone resources
  deploy_core_landing_zones = true
  
  # Deploy demo landing zones (Corp, Online, SAP)
  deploy_demo_landing_zones = true

  # Enable management resources (Log Analytics, Automation)
  deploy_management_resources = true
  
  subscription_id_management = var.subscription_id
  
  configure_management_resources = {
    settings = {
      log_analytics = {
enabled = true
config = {
  retention_in_days = 30
  sku               = "PerGB2018"
}
      }
      security_center = {
enabled = true
config = {
  email_security_contact = var.owner
}
      }
    }
  }

  # Enable connectivity resources (Hub networking, Firewall, VPN Gateway)
  deploy_connectivity_resources = true
  
  subscription_id_connectivity = var.subscription_id
  
  configure_connectivity_resources = {
    settings = {
      hub_networks = [
{
  enabled = true
  config = {
    address_space                = ["10.100.0.0/16"]
    location                     = var.location
    enable_hub_network_mesh_peering = false
    
    azure_firewall = {
      enabled = true
      config = {
        sku_name              = "AZFW_VNet"
        sku_tier              = "Standard"
        enable_dns_proxy      = true
        availability_zones = {
          zone_1 = true
          zone_2 = true
          zone_3 = true
        }
      }
    }
    
    dns = {
      enabled = true
      config = {
        private_dns_zones = [
          "privatelink.blob.core.windows.net",
          "privatelink.dfs.core.windows.net",
          "privatelink.database.windows.net",
          "privatelink.azuredatabricks.net",
          "privatelink.datafactory.azure.net",
          "privatelink.vaultcore.azure.net"
        ]
      }
    }
  }
}
      ]
      
      ddos_protection_plan = {
enabled = false
      }
    }
  }

  # Enable identity resources
  deploy_identity_resources = false

  # Custom library path for additional policies
  library_path = "\${path.root}/lib"

  # Tags applied to all resources
  default_tags = {
    Owner       = var.owner
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform-CAF"
    DeploymentType = "Greenfield"
  }
}

# Data source to get current client config
data "azurerm_client_config" "current" {}

# Outputs
output "root_management_group_id" {
  description = "ID of the root management group"
  value       = module.enterprise_scale.azurerm_management_group.level_1["\${var.company_abbreviation}-\${var.environment}"].id
}

output "management_subscription_id" {
  description = "Management subscription ID"
  value       = var.subscription_id
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = module.enterprise_scale.azurerm_log_analytics_workspace.management[0].id
}

output "hub_virtual_network_id" {
  description = "Hub virtual network ID"
  value       = try(module.enterprise_scale.azurerm_virtual_network.connectivity[0].id, null)
}

output "azure_firewall_id" {
  description = "Azure Firewall ID"
  value       = try(module.enterprise_scale.azurerm_firewall.connectivity[0].id, null)
}
`;
}

function generateCAFVariables(config) {
    return `# Variables for CAF Enterprise-Scale Landing Zone

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID for management and connectivity resources"
  type        = string
}

variable "owner" {
  description = "Resource owner email"
  type        = string
}

variable "company_abbreviation" {
  description = "Company abbreviation for naming"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{2,8}$", var.company_abbreviation))
    error_message = "Company abbreviation must be 2-8 lowercase alphanumeric characters."
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/test/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westeurope"
}
`;
}

function generateCAFTfvars(config) {
    return `# Terraform Variables for CAF Landing Zone

tenant_id            = "${config.tenant_id}"
subscription_id      = "${config.subscription_id}"
owner                = "${config.owner}"
company_abbreviation = "${config.company_abbreviation}"
project_name         = "${config.project_name}"
environment          = "${config.environment}"
location             = "${config.location}"
`;
}

function generateBrownfieldMain(config) {
    const identityBlock = config.identity_type === 'user_assigned' 
        ? `type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]`
        : `type = "SystemAssigned"`;

    return `# Brownfield Data Platform Deployment
# Generated by EpicData IaC Generator
# Assumes existing Azure Landing Zone
# Identity Type: ${config.identity_type === 'user_assigned' ? 'User Assigned' : 'System Assigned'}

data "azurerm_client_config" "current" {}

locals {
  tags = {
    Owner       = var.owner
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-\${var.company_abbreviation}-\${var.project_name}-\${var.environment}"
  location = var.location
  tags     = local.tags
}

${config.identity_type === 'user_assigned' ? `
# User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "main" {
  name                = "uai-\${var.company_abbreviation}-\${var.project_name}-\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}
` : ''}

${config.include_networking ? `
# Networking Resources
resource "azurerm_resource_group" "networking" {
  name     = var.networking_resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.networking.name
  address_space       = [var.vnet_address_space]
  tags                = local.tags
}

resource "azurerm_subnet" "data_platform" {
  name                 = "snet-data-platform-\${var.environment}"
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.data_platform_subnet_cidr_block]
}

resource "azurerm_network_security_group" "data_platform" {
  name                = "nsg-data-platform-\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.networking.name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "data_platform" {
  subnet_id                 = azurerm_subnet.data_platform.id
  network_security_group_id = azurerm_network_security_group.data_platform.id
}

# Private DNS Zones
resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "kv-vnet-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = local.tags
}
` : ''}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                = "kv-\${var.company_abbreviation}-\${var.project_name}-\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "standard"
  tenant_id           = var.tenant_id
  
  purge_protection_enabled  = true
  enable_rbac_authorization = true
  public_network_access_enabled = ${!config.include_networking}

  identity {
    ${identityBlock}
  }

  tags = local.tags
}

${config.include_networking ? `
resource "azurerm_private_endpoint" "key_vault" {
  name                = "pep-keyvault-\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.networking.name
  subnet_id           = azurerm_subnet.data_platform.id

  private_service_connection {
    name                           = "pep-keyvault-connection"
    private_connection_resource_id = azurerm_key_vault.main.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]
  }

  tags = local.tags
}
` : ''}

${config.include_storage_account ? `
# Storage Account (Data Lake Gen2)
${config.include_networking ? `
resource "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  name                  = "blob-vnet-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = local.tags
}

resource "azurerm_private_dns_zone" "storage_dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_dfs" {
  name                  = "dfs-vnet-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dfs.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = local.tags
}
` : ''}

resource "azurerm_storage_account" "data_lake" {
  name                = "dls\${var.company_abbreviation}\${var.project_name}\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
  
  public_network_access_enabled = ${!config.include_networking}
  
  identity {
    ${identityBlock}
  }
  
  tags = local.tags
}

resource "azurerm_storage_container" "bronze" {
  name                  = "bronze"
  storage_account_id    = azurerm_storage_account.data_lake.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "silver" {
  name                  = "silver"
  storage_account_id    = azurerm_storage_account.data_lake.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "gold" {
  name                  = "gold"
  storage_account_id    = azurerm_storage_account.data_lake.id
  container_access_type = "private"
}

${config.include_networking ? `
resource "azurerm_private_endpoint" "storage_blob" {
  name                = "pep-storage-blob-\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.networking.name
  subnet_id           = azurerm_subnet.data_platform.id

  private_service_connection {
    name                           = "pep-storage-blob-connection"
    private_connection_resource_id = azurerm_storage_account.data_lake.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_blob.id]
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "storage_dfs" {
  name                = "pep-storage-dfs-\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.networking.name
  subnet_id           = azurerm_subnet.data_platform.id

  private_service_connection {
    name                           = "pep-storage-dfs-connection"
    private_connection_resource_id = azurerm_storage_account.data_lake.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_dfs.id]
  }

  tags = local.tags
}
` : ''}
` : ''}

${config.include_databricks ? `
# Azure Databricks
${config.include_networking ? `
resource "azurerm_private_dns_zone" "databricks" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "databricks" {
  name                  = "databricks-vnet-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.databricks.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = local.tags
}
` : ''}

resource "azurerm_databricks_workspace" "main" {
  name                        = "dbr-\${var.company_abbreviation}-\${var.project_name}-\${var.environment}"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.main.name
  managed_resource_group_name = "rg-managed-dbr-\${var.company_abbreviation}-\${var.project_name}-\${var.environment}"
  sku                         = "premium"
  
  public_network_access_enabled = ${!config.include_networking}
  
  tags = local.tags
}

${config.databricks_uc_metastore_id ? `
# Databricks Unity Catalog Configuration
# Note: This requires the Databricks provider to be configured
# See providers.tf for Databricks provider setup
` : ''}

${config.include_networking ? `
resource "azurerm_private_endpoint" "databricks" {
  name                = "pep-databricks-\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.networking.name
  subnet_id           = azurerm_subnet.data_platform.id

  private_service_connection {
    name                           = "pep-databricks-connection"
    private_connection_resource_id = azurerm_databricks_workspace.main.id
    is_manual_connection           = false
    subresource_names              = ["databricks_ui_api"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.databricks.id]
  }

  tags = local.tags
}
` : ''}
` : ''}

${config.include_data_factory ? `
# Azure Data Factory
${config.include_networking ? `
resource "azurerm_private_dns_zone" "data_factory" {
  name                = "privatelink.datafactory.azure.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "data_factory" {
  name                  = "adf-vnet-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.data_factory.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = local.tags
}
` : ''}

resource "azurerm_data_factory" "main" {
  name                            = "adf-\${var.company_abbreviation}-\${var.project_name}-\${var.environment}"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.main.name
  managed_virtual_network_enabled = ${config.include_networking}
  public_network_enabled          = ${!config.include_networking}
  
  identity {
    ${identityBlock}
  }
  
  tags = local.tags
}

${config.include_networking ? `
resource "azurerm_private_endpoint" "data_factory" {
  name                = "pep-datafactory-\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.networking.name
  subnet_id           = azurerm_subnet.data_platform.id

  private_service_connection {
    name                           = "pep-datafactory-connection"
    private_connection_resource_id = azurerm_data_factory.main.id
    is_manual_connection           = false
    subresource_names              = ["dataFactory"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.data_factory.id]
  }

  tags = local.tags
}
` : ''}
` : ''}

${config.include_eventhub ? `
# Event Hub Namespace
${config.include_networking ? `
resource "azurerm_private_dns_zone" "eventhub" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "eventhub" {
  name                  = "eventhub-vnet-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.eventhub.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = local.tags
}
` : ''}

resource "azurerm_eventhub_namespace" "main" {
  name                = "evhns-\${var.company_abbreviation}-\${var.project_name}-\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = var.eventhub_sku
  capacity            = var.eventhub_sku == "Standard" ? 1 : null
  
  local_authentication_enabled  = false
  public_network_access_enabled = ${!config.include_networking}
  
  identity {
    ${identityBlock}
  }
  
  tags = local.tags
}

resource "azurerm_eventhub" "main" {
  name              = "evh-\${var.company_abbreviation}-\${var.project_name}-\${var.environment}"
  namespace_id      = azurerm_eventhub_namespace.main.id
  partition_count   = var.eventhub_partition_count
  message_retention = var.eventhub_message_retention

  ${config.eventhub_enable_capture && config.include_storage_account ? `
  capture_description {
    enabled             = true
    encoding            = "Avro"
    interval_in_seconds = 300

    destination {
      name                = "EventHubArchive.AzureBlockBlob"
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
      storage_account_id  = azurerm_storage_account.data_lake.id
      blob_container_name = "bronze"
    }
  }
  ` : ''}
}

${config.include_networking ? `
resource "azurerm_private_endpoint" "eventhub" {
  name                = "pep-eventhub-\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.networking.name
  subnet_id           = azurerm_subnet.data_platform.id

  private_service_connection {
    name                           = "pep-eventhub-connection"
    private_connection_resource_id = azurerm_eventhub_namespace.main.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.eventhub.id]
  }

  tags = local.tags
}
` : ''}
` : ''}

${config.include_sql_database ? `
# SQL Server and Database
${config.include_networking ? `
resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.networking.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name                  = "sql-vnet-link"
  resource_group_name   = azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = local.tags
}
` : ''}

resource "azurerm_mssql_server" "main" {
  name                = "sql-\${var.company_abbreviation}-\${var.project_name}-\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  version             = "12.0"
  
  azuread_administrator {
    login_username              = var.sql_server_admin_login_username
    object_id                   = var.sql_server_admin_object_id
    tenant_id                   = var.tenant_id
    azuread_authentication_only = true
  }
  
  public_network_access_enabled = ${!config.include_networking}
  
  identity {
    ${identityBlock}
  }
  
  tags = local.tags
}

resource "azurerm_mssql_database" "main" {
  name         = "sqldb-\${var.company_abbreviation}-\${var.project_name}-\${var.environment}"
  server_id    = azurerm_mssql_server.main.id
  license_type = "LicenseIncluded"
  sku_name     = var.sql_database_sku
  max_size_gb  = 10
  
  tags = local.tags
}

${config.include_networking ? `
resource "azurerm_private_endpoint" "sql" {
  name                = "pep-sql-\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.networking.name
  subnet_id           = azurerm_subnet.data_platform.id

  private_service_connection {
    name                           = "pep-sql-connection"
    private_connection_resource_id = azurerm_mssql_server.main.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
  }

  tags = local.tags
}
` : ''}
` : ''}

${config.include_azure_function ? `
# Azure Function
resource "azurerm_service_plan" "function" {
  name                = "asp-\${var.company_abbreviation}-\${var.project_name}-\${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "${config.function_plan_type === 'Consumption' ? 'Y1' : 'P1v2'}"
  
  tags = local.tags
}

resource "azurerm_storage_account" "function" {
  name                     = "stfunc\${var.project_name}\${var.environment}"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.main.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

resource "azurerm_linux_function_app" "main" {
  name                       = "func-\${var.company_abbreviation}-\${var.project_name}-\${var.environment}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.main.name
  service_plan_id            = azurerm_service_plan.function.id
  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key

  identity {
    ${identityBlock}
  }

  site_config {
    application_stack {
      ${config.function_runtime === 'python' ? 'python_version = "3.11"' : ''}
      ${config.function_runtime === 'node' ? 'node_version = "18"' : ''}
      ${config.function_runtime === 'dotnet' ? 'dotnet_version = "8.0"' : ''}
      ${config.function_runtime === 'java' ? 'java_version = "11"' : ''}
    }
  }

  tags = local.tags
}
` : ''}
`;
}

function generateBrownfieldVariables(config) {
    return `# Variables for Brownfield Data Platform

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "owner" {
  description = "Resource owner"
  type        = string
}

variable "company_abbreviation" {
  description = "Company abbreviation"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev/test/prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

${config.include_networking ? `
variable "networking_resource_group_name" {
  description = "Networking resource group name"
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
}

variable "vnet_address_space" {
  description = "VNet address space"
  type        = string
  default     = "10.0.0.0/16"
}

variable "data_platform_subnet_cidr_block" {
  description = "Data platform subnet CIDR"
  type        = string
  default     = "10.0.5.0/24"
}
` : ''}

${config.include_databricks && config.databricks_uc_metastore_id ? `
variable "databricks_uc_metastore_id" {
  description = "Unity Catalog Metastore ID"
  type        = string
  default     = "${config.databricks_uc_metastore_id}"
}

variable "databricks_account_id" {
  description = "Databricks Account ID"
  type        = string
  default     = "${config.databricks_account_id}"
}
` : ''}

${config.include_eventhub ? `
variable "eventhub_sku" {
  description = "Event Hub namespace SKU"
  type        = string
  default     = "${config.eventhub_sku}"
}

variable "eventhub_partition_count" {
  description = "Event Hub partition count"
  type        = number
  default     = ${config.eventhub_partition_count}
}

variable "eventhub_message_retention" {
  description = "Event Hub message retention in days"
  type        = number
  default     = ${config.eventhub_message_retention}
}
` : ''}

${config.include_sql_database ? `
variable "sql_server_admin_login_username" {
  description = "SQL Server admin username"
  type        = string
  default     = "${config.sql_server_admin_login_username || 'sqladmin'}"
}

variable "sql_server_admin_object_id" {
  description = "SQL Server admin object ID"
  type        = string
}

variable "sql_database_sku" {
  description = "SQL Database SKU"
  type        = string
  default     = "${config.sql_database_sku}"
}
` : ''}
`;
}

function generateBrownfieldTfvars(config) {
    return `# Terraform Variables

tenant_id            = "${config.tenant_id}"
subscription_id      = "${config.subscription_id}"
owner                = "${config.owner}"
company_abbreviation = "${config.company_abbreviation}"
project_name         = "${config.project_name}"
environment          = "${config.environment}"
location             = "${config.location}"

${config.include_networking ? `
# Networking
networking_resource_group_name = "${config.networking_resource_group_name}"
vnet_name                      = "${config.vnet_name}"
vnet_address_space             = "${config.vnet_address_space}"
data_platform_subnet_cidr_block = "${config.data_platform_subnet_cidr_block}"
` : ''}

${config.include_databricks && config.databricks_uc_metastore_id ? `
# Databricks Unity Catalog
databricks_uc_metastore_id = "${config.databricks_uc_metastore_id}"
databricks_account_id      = "${config.databricks_account_id}"
` : ''}

${config.include_eventhub ? `
# Event Hub
eventhub_sku               = "${config.eventhub_sku}"
eventhub_partition_count   = ${config.eventhub_partition_count}
eventhub_message_retention = ${config.eventhub_message_retention}
` : ''}

${config.include_sql_database ? `
# SQL Database
sql_server_admin_login_username = "${config.sql_server_admin_login_username || 'sqladmin'}"
sql_server_admin_object_id      = "${config.sql_server_admin_object_id || 'REPLACE_WITH_OBJECT_ID'}"
sql_database_sku                = "${config.sql_database_sku}"
` : ''}
`;
}

function generateProviders(config) {
    return `# Provider Configuration

terraform {
  required_version = ">= 1.3"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  
  subscription_id = var.subscription_id
}
`;
}

function generateReadme(config) {
    const isGreenfield = config.deployment_type === 'greenfield';
    
    return `# ${config.project_name} - Azure Infrastructure

Generated by **EpicData IaC Generator**

## Deployment Type: ${isGreenfield ? '🌱 Greenfield (CAF Foundation)' : '🏗️ Brownfield (Existing Landing Zone)'}

### Configuration
- **Organization**: ${config.company_abbreviation}
- **Project**: ${config.project_name}
- **Environment**: ${config.environment}
- **Region**: ${config.location}

${isGreenfield ? `
## Cloud Adoption Framework Components

This deployment creates a complete Azure landing zone following Microsoft's Cloud Adoption Framework (CAF) best practices:

### Management Groups
- **Root Management Group**: \`${config.company_abbreviation}-${config.environment}\`
  - Platform
    - Management (Log Analytics, Sentinel, Automation)
    - Connectivity (Hub Network, Firewall, VPN)
    - Identity
  - Landing Zones
    - Corp (Corporate workloads with connectivity)
    - Online (Internet-facing workloads)
    - SAP (SAP workloads)
  - Sandboxes (Testing and experimentation)
  - Decommissioned (Deprecated resources)

### Governance & Security
- **Azure Policy**: 100+ policies for security, compliance, and governance
- **RBAC**: Role-based access control assignments
- **Microsoft Defender for Cloud**: Security posture management
- **Azure Sentinel**: SIEM and threat protection

### Networking
- **Hub-Spoke Topology**: Centralized hub network with firewall
- **Azure Firewall**: Network security and traffic filtering
- **Private DNS Zones**: For Azure PaaS services
- **DDoS Protection**: Optional standard protection

### Monitoring & Operations
- **Log Analytics Workspace**: Centralized logging (30-day retention)
- **Diagnostic Settings**: Configured for all resources
- **Azure Monitor**: Metrics and alerts
- **Automation Account**: Runbooks and automation

### Best Practices Implemented
✅ Management group hierarchy for governance at scale
✅ Azure Policy for compliance and security baselines
✅ Hub-spoke network architecture
✅ Centralized logging and monitoring
✅ Security baseline with Defender for Cloud
✅ Private DNS zones for PaaS services
✅ Managed identities (no passwords/keys)
✅ Resource tagging strategy

` : `
## Data Platform Resources

${config.include_storage_account ? '- ✅ Storage Account (Data Lake Gen2)' : ''}
${config.include_databricks ? '- ✅ Azure Databricks' : ''}
${config.include_data_factory ? '- ✅ Azure Data Factory' : ''}
${config.include_eventhub ? '- ✅ Azure Event Hub' : ''}
${config.include_sql_database ? '- ✅ Azure SQL Database' : ''}
- ✅ Azure Key Vault

`}

## Prerequisites

1. **Azure CLI** installed and authenticated
   \`\`\`bash
   az login
   az account set --subscription "${config.subscription_id}"
   \`\`\`

2. **Terraform** >= 1.3
   \`\`\`bash
   terraform version
   \`\`\`

3. **Azure Permissions**: Contributor or Owner role on subscription

${isGreenfield ? `
4. **Management Group Permissions**: Management Group Contributor role
` : ''}

## Deployment Steps

### 1. Initialize Terraform

\`\`\`bash
terraform init
\`\`\`

### 2. Review the Plan

\`\`\`bash
terraform plan
\`\`\`

${isGreenfield ? `
**Expected resources**: ~150-200 resources including:
- Management groups and policies
- Hub network and firewall
- Log Analytics and monitoring
- Security configurations
` : `
**Expected resources**: Varies based on selected components
`}

### 3. Apply Configuration

\`\`\`bash
terraform apply
\`\`\`

This may take 20-30 minutes for the initial deployment.

### 4. Verify Deployment

\`\`\`bash
# View all outputs
terraform output

${isGreenfield ? `# Check management groups
az account management-group list --query "[?contains(name,'${config.company_abbreviation}')].{Name:name,DisplayName:displayName}"

# Verify policy assignments
az policy assignment list --query "[].{Name:name,Scope:scope}" -o table` : ''}
\`\`\`

## Post-Deployment Tasks

${isGreenfield ? `
1. **Configure Azure AD Groups**
   - Create security groups for different roles
   - Assign appropriate RBAC roles

2. **Set Up Workload Landing Zones**
   - Move or create subscriptions under Landing Zones management group
   - Configure subscription-level policies

3. **Enable Additional Security Features**
   - Configure Defender for Cloud plans
   - Set up Azure Sentinel connectors
   - Review and tune policy assignments

4. **Network Configuration**
   - Configure VPN or ExpressRoute (if needed)
   - Set up peering to spoke networks
   - Configure firewall rules

5. **Monitoring Setup**
   - Create alert rules
   - Configure dashboards
   - Set up action groups
` : `
1. **Configure Access**
   - Assign RBAC roles to users/groups
   - Set up Key Vault access policies

2. **Network Integration** (if applicable)
   - Configure VNet integration
   - Set up private endpoints

3. **Data Ingestion**
   - Configure data sources
   - Set up pipelines
`}

## Architecture Diagrams

${isGreenfield ? `
### CAF Landing Zone Architecture
\`\`\`
Management Groups
├── ${config.company_abbreviation}-${config.environment} (Root)
    ├── Platform
    │   ├── Management (Logging, Monitoring)
    │   ├── Connectivity (Hub Network)
    │   └── Identity
    ├── Landing Zones
    │   ├── Corp
    │   ├── Online
    │   └── SAP
    ├── Sandboxes
    └── Decommissioned
\`\`\`

### Network Topology
\`\`\`
Hub VNet (10.100.0.0/16)
├── Azure Firewall
├── VPN Gateway
├── Private DNS Zones
└── Spoke VNets (Peered)
    ├── Corp Landing Zone
    └── Online Landing Zone
\`\`\`
` : ''}

## Cost Estimation

${isGreenfield ? `
**Monthly Estimate**: ~$500-1000 USD

Major components:
- Azure Firewall: ~$350/month
- VPN Gateway: ~$140/month
- Log Analytics: ~$50/month (depending on ingestion)
- Defender for Cloud: Varies by plan
- Storage and compute: As needed
` : `
Costs vary based on selected resources and usage.
`}

## Troubleshooting

${isGreenfield ? `
### Common Issues

**Issue**: Policy assignment errors
\`\`\`bash
# Check policy compliance
az policy state list --filter "complianceState eq 'NonCompliant'"
\`\`\`

**Issue**: Management group permissions
\`\`\`bash
# Verify your permissions
az role assignment list --assignee $(az ad signed-in-user show --query objectId -o tsv) --scope /providers/Microsoft.Management/managementGroups/${config.company_abbreviation}-${config.environment}
\`\`\`
` : ''}

### Getting Help

- [Azure CAF Documentation](https://learn.microsoft.com/azure/cloud-adoption-framework/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Support](https://azure.microsoft.com/support/)

## Learn More

${isGreenfield ? `
- **Cloud Adoption Framework**: https://learn.microsoft.com/azure/cloud-adoption-framework/
- **Enterprise-Scale Landing Zones**: https://learn.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/
- **Azure Landing Zone Terraform Module**: https://github.com/Azure/terraform-azurerm-caf-enterprise-scale
- **Well-Architected Framework**: https://learn.microsoft.com/azure/well-architected/
` : ''}

---

**Generated by**: EpicData IaC Generator  
**Generated on**: ${new Date().toISOString()}  
**Deployment Type**: ${isGreenfield ? 'Greenfield (CAF Foundation)' : 'Brownfield (Data Platform)'}
`;
}

function createFileTabs() {
    const tabs = document.getElementById('fileTabs');
    tabs.innerHTML = '';
    
    Object.keys(generatedFiles).forEach(file => {
        const tab = document.createElement('button');
        tab.className = 'file-tab';
        tab.textContent = file;
        tab.onclick = () => displayFile(file);
        if (file === currentFile) tab.classList.add('active');
        tabs.appendChild(tab);
    });
}

function displayFile(file) {
    currentFile = file;
    document.getElementById('output').textContent = generatedFiles[file];
    
    document.querySelectorAll('.file-tab').forEach(tab => {
        tab.classList.toggle('active', tab.textContent === file);
    });
}

function copyCode() {
    navigator.clipboard.writeText(document.getElementById('output').textContent);
    const btn = document.querySelector('.copy-btn');
    const originalText = btn.textContent;
    btn.textContent = '✓ Copied';
    setTimeout(() => {
        btn.textContent = originalText;
    }, 2000);
}

async function downloadZip() {
    const zip = new JSZip();
    Object.keys(generatedFiles).forEach(file => {
        zip.file(file, generatedFiles[file]);
    });
    
    const content = await zip.generateAsync({type: 'blob'});
    const url = URL.createObjectURL(content);
    const a = document.createElement('a');
    a.href = url;
    const config = getConfig();
    a.download = `${config.company_abbreviation}-${config.project_name}-${config.deployment_type}-terraform.zip`;
    a.click();
    URL.revokeObjectURL(url);
}
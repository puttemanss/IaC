/**
 * Azure Pricing Database
 * Region: West Europe
 * Currency: EUR
 * Last Updated: 2024
 *
 * Note: These are estimated prices for reference only.
 * Always use the official Azure Pricing Calculator for production budgeting.
 */

const azurePricing = {
    storage: {
        hotLRS: 0.0184, // per GB/month
        hotZRS: 0.023, // per GB/month
        coolLRS: 0.01, // per GB/month
        coolZRS: 0.0125, // per GB/month
        operations: 0.00000036 // per operation
    },
    databricks: {
        premiumDBU: 0.489, // per DBU-hour
        standardVMCore: 0.15 // approximate per core-hour for Standard_DS3_v2
    },
    dataFactory: {
        orchestrationActivity: 0.90, // per 1000 activity runs
        dataMovementDIU: 0.225, // per DIU-hour
        pipelineWithNoActivity: 0.45 // per month
    },
    eventHub: {
        basic: 0.0224, // per hour
        standard: 0.0224, // base per hour
        standardThroughput: 11.20, // per throughput unit per month
        premium: {
            processingUnit: 111.85, // per PU per month
            storage: 0.09 // per GB per month
        }
    },
    sqlDatabase: {
        basic: 4.37, // per month
        S0: 13.08, // per month
        S1: 17.45, // per month
        S2: 43.62, // per month
        S3: 87.24, // per month
        P1: 420.00, // per month (Premium)
        P2: 840.00, // per month
        gpGen5_2: 445.00, // General Purpose 2 vCores
        gpGen5_4: 890.00 // General Purpose 4 vCores
    },
    functions: {
        consumption: {
            execution: 0.169, // per million executions
            gbSeconds: 0.000014 // per GB-second
        },
        premium: {
            EP1: 140.16, // per month
            EP2: 280.32,
            EP3: 560.64
        }
    },
    keyVault: {
        operations: 0.0268, // per 10,000 operations
        secrets: 0.0268, // per secret per month
        certificates: 2.68 // per certificate per month
    },
    privateEndpoint: 6.72, // per endpoint per month
    vnet: 0, // VNet itself is free
    subnet: 0,
    logAnalytics: {
        ingestion: 2.42, // per GB
        retention: 0.0896 // per GB per month (beyond 31 days)
    },
    azureFirewall: {
        deployment: 1.075, // per hour (~774 EUR/month)
        dataProcessed: 0.0134 // per GB
    },
    fabric: {
        F2: 222.00, // per month
        F4: 444.00, // per month
        F8: 888.00, // per month
        F16: 1776.00, // per month
        F32: 3552.00, // per month
        F64: 7104.00, // per month
        F128: 14208.00, // per month
        F256: 28416.00, // per month
        F512: 56832.00 // per month
    }
};

/**
 * Default usage assumptions for cost estimation
 * These can be adjusted by the user via UI sliders
 */
let usageAssumptions = {
    storage_gb: 1000, // Storage capacity in GB
    storage_operations: 10000000, // Number of storage operations per month
    databricks_hours: 730, // Databricks cluster hours per month (~1 cluster 24/7)
    databricks_cores: 8, // Number of cores per cluster
    datafactory_pipeline_runs: 1000, // Pipeline runs per month
    datafactory_diu_hours: 100, // Data Integration Unit hours
    eventhub_messages: 10000000, // Messages per month
    eventhub_throughput_units: 1, // Throughput units for Standard tier
    sql_uptime_percent: 100, // SQL Database uptime percentage
    function_executions: 1000000, // Function executions per month
    function_gb_seconds: 400000 // Function GB-seconds
};

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.dto;

import uim.platform.ai_core.domain.types;


// --- Scenario ---

struct CreateScenarioRequest {
  TenantId tenantId;
  string resourceGroupId;
  string id;
  string name;
  string description;
  string[] labels;
}

// --- Executable ---

struct CreateExecutableRequest {
  TenantId tenantId;
  string resourceGroupId;
  string scenarioId;
  string id;
  string name;
  string description;
  string type;
  string versionId;
  string deployable;
}

// --- Configuration ---

struct CreateConfigurationRequest {
  TenantId tenantId;
  string resourceGroupId;
  string scenarioId;
  string executableId;
  string name;
  string[][] parameterValues;
  string[][] inputArtifacts;
}

// --- Execution ---

struct CreateExecutionRequest {
  TenantId tenantId;
  string resourceGroupId;
  string configurationId;
}

struct PatchExecutionRequest {
  TenantId tenantId;
  string resourceGroupId;
  string executionId;
  string targetStatus;
}

struct BulkPatchExecutionRequest {
  TenantId tenantId;
  string resourceGroupId;
  string[] executionIds;
  string targetStatus;
}

// --- Deployment ---

struct CreateDeploymentRequest {
  TenantId tenantId;
  string resourceGroupId;
  string configurationId;
  int ttl;
}

struct PatchDeploymentRequest {
  TenantId tenantId;
  string resourceGroupId;
  string deploymentId;
  string targetStatus;
  string configurationId;
  int ttl;
}

struct BulkPatchDeploymentRequest {
  TenantId tenantId;
  string resourceGroupId;
  string[] deploymentIds;
  string targetStatus;
}

// --- Artifact ---

struct CreateArtifactRequest {
  TenantId tenantId;
  string resourceGroupId;
  string scenarioId;
  string name;
  string description;
  string kind;
  string url;
  string[][] labels;
}

// --- Resource Group ---

struct CreateResourceGroupRequest {
  TenantId tenantId;
  string resourceGroupId;
  string[][] labels;
}

struct PatchResourceGroupRequest {
  TenantId tenantId;
  string resourceGroupId;
  string[][] labels;
}

// --- Docker Registry Secret ---

struct CreateDockerRegistrySecretRequest {
  TenantId tenantId;
  string resourceGroupId;
  string name;
  string server;
  string username;
  string password;
}

// --- Object Store Secret ---

struct CreateObjectStoreSecretRequest {
  TenantId tenantId;
  string resourceGroupId;
  string name;
  string type;
  string bucket;
  string region;
  string endpoint;
  string pathPrefix;
  string accessKey;
  string secretKey;
}

// --- Metrics ---

struct PatchMetricsRequest {
  TenantId tenantId;
  string resourceGroupId;
  string executionId;
  string[][] metrics;
  string[][] tags;
  string[][] customInfo;
  string[][] labels;
}

// --- Execution Schedule ---

struct CreateExecutionScheduleRequest {
  TenantId tenantId;
  string resourceGroupId;
  string configurationId;
  string name;
  string cron;
  long start;
  long end;
}

struct PatchExecutionScheduleRequest {
  TenantId tenantId;
  string resourceGroupId;
  ScheduleId scheduleId;
  string status;
  string cron;
  long start;
  long end;
}

// --- Meta / Capabilities ---

struct CapabilitiesResponse {
  bool logsExecutions;
  bool logsDeployments;
  bool multitenant;
  bool shareable;
  bool staticDeployments;
  bool userDeployments;
  bool userExecutions;
  bool executionSchedules;
  bool bulkUpdates;
  bool timeToLiveDeployments;
  string apiVersion;
}

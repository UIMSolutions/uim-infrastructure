/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.container;

import uim.platform.ai_core.infrastructure.config;

// Repositories
import uim.platform.ai_core.infrastructure.persistence.memory.scenarios;
import uim.platform.ai_core.infrastructure.persistence.memory.executables;
import uim.platform.ai_core.infrastructure.persistence.memory.configurations;
import uim.platform.ai_core.infrastructure.persistence.memory.executions;
import uim.platform.ai_core.infrastructure.persistence.memory.deployments;
import uim.platform.ai_core.infrastructure.persistence.memory.artifacts;
import uim.platform.ai_core.infrastructure.persistence.memory.resource_groups;
import uim.platform.ai_core.infrastructure.persistence.memory.metrics;

// Use Cases
import uim.platform.ai_core.application.usecases.manage.scenarios;
import uim.platform.ai_core.application.usecases.manage.executables;
import uim.platform.ai_core.application.usecases.manage.configurations;
import uim.platform.ai_core.application.usecases.manage.executions;
import uim.platform.ai_core.application.usecases.manage.deployments;
import uim.platform.ai_core.application.usecases.manage.artifacts;
import uim.platform.ai_core.application.usecases.manage.resource_groups;
import uim.platform.ai_core.application.usecases.get_metrics;

// Controllers
import uim.platform.ai_core.presentation.http.controllers.scenario;
import uim.platform.ai_core.presentation.http.controllers.executable;
import uim.platform.ai_core.presentation.http.controllers.configuration;
import uim.platform.ai_core.presentation.http.controllers.execution;
import uim.platform.ai_core.presentation.http.controllers.deployment;
import uim.platform.ai_core.presentation.http.controllers.artifact;
import uim.platform.ai_core.presentation.http.controllers.resource_group;
import uim.platform.ai_core.presentation.http.controllers.metric;
import uim.platform.ai_core.presentation.http.controllers.meta;
import uim.platform.ai_core.presentation.http.controllers.health;

struct Container {
  // Repositories (driven adapters)
  MemoryScenarioRepository scenarioRepo;
  MemoryExecutableRepository executableRepo;
  MemoryConfigurationRepository configurationRepo;
  MemoryExecutionRepository executionRepo;
  MemoryDeploymentRepository deploymentRepo;
  MemoryArtifactRepository artifactRepo;
  MemoryResourceGroupRepository resourceGroupRepo;
  MemoryMetricRepository metricRepo;

  // Use cases (application layer)
  ManageScenariosUseCase manageScenarios;
  ManageExecutablesUseCase manageExecutables;
  ManageConfigurationsUseCase manageConfigurations;
  ManageExecutionsUseCase manageExecutions;
  ManageDeploymentsUseCase manageDeployments;
  ManageArtifactsUseCase manageArtifacts;
  ManageResourceGroupsUseCase manageResourceGroups;
  GetMetricsUseCase getMetrics;

  // Controllers (driving adapters)
  ScenarioController scenarioController;
  ExecutableController executableController;
  ConfigurationController configurationController;
  ExecutionController executionController;
  DeploymentController deploymentController;
  ArtifactController artifactController;
  ResourceGroupController resourceGroupController;
  MetricController metricController;
  MetaController metaController;
  HealthController healthController;
}

Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters
  c.scenarioRepo = new MemoryScenarioRepository();
  c.executableRepo = new MemoryExecutableRepository();
  c.configurationRepo = new MemoryConfigurationRepository();
  c.executionRepo = new MemoryExecutionRepository();
  c.deploymentRepo = new MemoryDeploymentRepository();
  c.artifactRepo = new MemoryArtifactRepository();
  c.resourceGroupRepo = new MemoryResourceGroupRepository();
  c.metricRepo = new MemoryMetricRepository();

  // Application use cases
  c.manageScenarios = new ManageScenariosUseCase(c.scenarioRepo);
  c.manageExecutables = new ManageExecutablesUseCase(c.executableRepo);
  c.manageConfigurations = new ManageConfigurationsUseCase(c.configurationRepo);
  c.manageExecutions = new ManageExecutionsUseCase(c.executionRepo, c.configurationRepo);
  c.manageDeployments = new ManageDeploymentsUseCase(c.deploymentRepo, c.configurationRepo);
  c.manageArtifacts = new ManageArtifactsUseCase(c.artifactRepo);
  c.manageResourceGroups = new ManageResourceGroupsUseCase(c.resourceGroupRepo);
  c.getMetrics = new GetMetricsUseCase(c.metricRepo);

  // Presentation controllers
  c.scenarioController = new ScenarioController(c.manageScenarios);
  c.executableController = new ExecutableController(c.manageExecutables);
  c.configurationController = new ConfigurationController(c.manageConfigurations);
  c.executionController = new ExecutionController(c.manageExecutions);
  c.deploymentController = new DeploymentController(c.manageDeployments);
  c.artifactController = new ArtifactController(c.manageArtifacts);
  c.resourceGroupController = new ResourceGroupController(c.manageResourceGroups);
  c.metricController = new MetricController(c.getMetrics);
  c.metaController = new MetaController();
  c.healthController = new HealthController("ai-core");

  return c;
}

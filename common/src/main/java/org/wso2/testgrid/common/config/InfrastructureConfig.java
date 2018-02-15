/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

package org.wso2.testgrid.common.config;

import org.apache.commons.collections4.ListUtils;

import java.io.Serializable;
import java.util.List;
import java.util.Properties;

/**
 * Defines a model object for a InfrastructureConfig.
 *
 * @since 1.0.0
 */
public class InfrastructureConfig implements Serializable {

    private static final long serialVersionUID = -1660815137752094462L;

    private IACProvider iacProvider;
    private InfrastructureProvider infrastructureProvider;
    private ContainerOrchestrationEngine containerOrchestrationEngine;
    private Properties parameters = new Properties();
    private List<Provisioner> provisioners;

    /**
     * Defines the infrastructure provider types.
     *
     * @since 1.0.0
     */
    public enum IACProvider {
        CLOUDFORMATION("CloudFormation"),
        TERRAFORM("Terraform"),
        None("None");
        private final String iacProvider;

        IACProvider(String iacProvider) {
            this.iacProvider = iacProvider;
        }

        @Override
        public String toString() {
            return this.iacProvider;
        }
    }

    /**
     * Defines the infrastructure provider types.
     *
     * @since 1.0.0
     */
    public enum InfrastructureProvider {
        AWS("AWS"),
        OPENSTACK("OpenStack"),
        GCP("GCP"),
        SHELL("SHELL"),
        LOCAL("LOCAL");

        private final String providerType;

        InfrastructureProvider(String providerType) {
            this.providerType = providerType;
        }

        @Override
        public String toString() {
            return this.providerType;
        }
    }

    /**
     * Defines the ContainerOrchestrationEngine types.
     *
     * @since 1.0.0
     */
    public enum ContainerOrchestrationEngine {
        ECS("ECS"),
        K8S("Kubernetes"),
        None("None");

        private final String clusterType;

        ContainerOrchestrationEngine(String clusterType) {
            this.clusterType = clusterType;
        }

        @Override
        public String toString() {
            return this.clusterType;
        }
    }

    public IACProvider getIacProvider() {
        return iacProvider;
    }

    public void setIacProvider(IACProvider iacProvider) {
        this.iacProvider = iacProvider;
    }

    public InfrastructureProvider getInfrastructureProvider() {
        return infrastructureProvider;
    }

    public void setInfrastructureProvider(
            InfrastructureProvider infrastructureProvider) {
        this.infrastructureProvider = infrastructureProvider;
    }

    public ContainerOrchestrationEngine getContainerOrchestrationEngine() {
        return containerOrchestrationEngine;
    }

    public void setContainerOrchestrationEngine(
            ContainerOrchestrationEngine containerOrchestrationEngine) {
        this.containerOrchestrationEngine = containerOrchestrationEngine;
    }

    public Properties getParameters() {
        return parameters;
    }

    public void setParameters(Properties parameters) {
        this.parameters = parameters;
    }

    public List<Provisioner> getProvisioners() {
        return ListUtils.emptyIfNull(provisioners);
    }

    public void setProvisioners(List<Provisioner> provisioners) {
        this.provisioners = provisioners;
    }

    /**
     * Provisioner has the same behavior as the {@link DeploymentConfig.DeploymentPattern}.
     * todo
     */
    public static class Provisioner extends DeploymentConfig.DeploymentPattern {
        private static final long serialVersionUID = -3937792864579403430L;
    }
}
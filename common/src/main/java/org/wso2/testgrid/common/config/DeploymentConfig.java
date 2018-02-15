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
import java.util.Collections;
import java.util.List;

/**
 * todo.
 *
 */
public class DeploymentConfig implements Serializable {

    private static final long serialVersionUID = -3264052940825641013L;

    private List<DeploymentPattern> deploymentPatterns;

    public DeploymentConfig() {
        this(Collections.emptyList());
    }

    public DeploymentConfig(List<DeploymentPattern> deploymentPatterns) {
        this.deploymentPatterns = deploymentPatterns;
    }

    public List<DeploymentPattern> getDeploymentPatterns() {
        return ListUtils.emptyIfNull(deploymentPatterns);
    }

    public void setDeploymentPatterns(
            List<DeploymentPattern> deploymentPatterns) {
        this.deploymentPatterns = deploymentPatterns;
    }

    /**
     * todo.
      */
    public static class DeploymentPattern implements Serializable {
        private static final long serialVersionUID = 5484623288608884369L;

        private String name;
        private String description;
        private String dir;
        private List<Script> scripts;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }

        public String getDir() {
            return dir;
        }

        public void setDir(String dir) {
            this.dir = dir;
        }

        public List<Script> getScripts() {
            return ListUtils.emptyIfNull(scripts);
        }

        public void setScripts(List<Script> scripts) {
            this.scripts = scripts;
        }

        @Override
        public String toString() {
            return "DeploymentPattern{" +
                    "name='" + name + '\'' +
                    ", description='" + description + '\'' +
                    '}';
        }
    }

}
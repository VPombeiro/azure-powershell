﻿// ----------------------------------------------------------------------------------
//
// Copyright Microsoft Corporation
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

using System;
using System.Management.Automation;
using System.Security.Permissions;
using Microsoft.Azure.Commands.Kusto.Models;
using Microsoft.Azure.Commands.Kusto.Properties;
using Microsoft.Azure.Commands.Kusto.Utilities;

namespace Microsoft.Azure.Commands.Kusto.Commands
{
    [Cmdlet("Suspend", ResourceManager.Common.AzureRMConstants.AzureRMPrefix + "KustoCluster", SupportsShouldProcess = true),
     OutputType(typeof(PSKustoCluster))]
    public class SuspendAzureRmKustoCluster : KustoCmdletBase
    {
        protected const string CmdletParametersSet = "ByNameAndResourceGroup";
        protected const string ObjectParameterSet = "ByInputObject";
        protected const string ResourceIdParameterSet = "ByResourceId";

        [Parameter(
            ParameterSetName = CmdletParametersSet,
            Position = 0,
            Mandatory = true,
            HelpMessage = "Name of cluster to be suspend.")]
        [ValidateNotNullOrEmpty]
        public string Name { get; set; }

        [Parameter(
            ParameterSetName = CmdletParametersSet,
            Mandatory = false,
            HelpMessage = "Name of resource group under which the cluster exists.")]
        [ValidateNotNullOrEmpty]
        public string ResourceGroupName { get; set; }

        [Parameter(
            ParameterSetName = ResourceIdParameterSet,
            Mandatory = true,
            Position = 1,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "Kusto cluster ResourceID.")]
        [ValidateNotNullOrEmpty]
        public string ResourceId { get; set; }

        [Parameter(
            ParameterSetName = ObjectParameterSet,
            Mandatory = true,
            Position = 2,
            ValueFromPipeline = true,
            HelpMessage = "Kusto cluster object.")]
        [ValidateNotNullOrEmpty]
        public PSKustoCluster InputObject { get; set; }

        [PermissionSet(SecurityAction.Demand, Name = "FullTrust")]
        public override void ExecuteCmdlet()
        {
            string clusterName = Name;
            string resourceGroupName = ResourceGroupName;

            if (!string.IsNullOrEmpty(ResourceId))
            {
                KustoUtils.GetResourceGroupNameAndClusterNameFromClusterId(ResourceId, out resourceGroupName, out clusterName);
            }
            else if (InputObject != null)
            {
                KustoUtils.GetResourceGroupNameAndClusterNameFromClusterId(InputObject.Id, out resourceGroupName, out clusterName);
            }

            if (string.IsNullOrEmpty(clusterName))
            {
                WriteExceptionError(new PSArgumentNullException("Name", "Name of cluster not specified"));
            }

            if (ShouldProcess(clusterName, Resources.SuspendingKustoCluster))
            {
                PSKustoCluster cluster = null;
                if (!KustoClient.CheckIfClusterExists(resourceGroupName, clusterName, out cluster))
                {
                    throw new InvalidOperationException(string.Format(Resources.ClusterDoesNotExist, clusterName));
                }

                KustoClient.SuspendKustoCluster(resourceGroupName, clusterName);
            }
        }
    }
}

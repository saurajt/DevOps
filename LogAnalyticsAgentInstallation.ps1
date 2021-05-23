
#Select-AzSubscription -SubscriptionId 0282271d-1a9a-48c4-81c5-2a7c2afc6f41

$vms = Get-AzVM

foreach ($vm in $vms)
{
    # Add the Log Analytics workspace name for which the agents to be installed
    $workspaceName = "la-ah-ukw-monitoring"
    #$VMresourcegroup = $vm.ResourceGroupName
    #$VMresourcename = $vm.Name
    #$VMlocation = $vm.Location

    $workspace = (Get-AzOperationalInsightsWorkspace).Where({$_.Name -eq $workspaceName})

    if ($workspace.Name -ne $workspaceName)
    {
        Write-Error "Unable to find OMS Workspace $workspaceName. Do you need to run Select-AzSubscription?"
    }

    $workspaceId = $workspace.CustomerId
    $workspaceKey = (Get-AzOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $workspace.ResourceGroupName -Name $workspace.Name).PrimarySharedKey

    #$vm = Get-AzVM -ResourceGroupName $VMresourcegroup -Name $VMresourcename
    #$location = $vm.Location

    if ($vm.OsType -eq "Windows")
        {
        # For Windows VM 
        Set-AzVMExtension -ResourceGroupName $VMresourcegroup -VMName $VMresourcename -Name 'MicrosoftMonitoringAgent' -Publisher 'Microsoft.EnterpriseCloud.Monitoring' -ExtensionType 'MicrosoftMonitoringAgent' -TypeHandlerVersion '1.0' -Location $VMlocation -SettingString "{'workspaceId':  '$workspaceId'}" -ProtectedSettingString "{'workspaceKey': '$workspaceKey' }"
        }
    elseif ($vm.OsType -eq "Linux")
        {
        # For Linux VM 
        Set-AzVMExtension -ResourceGroupName $VMresourcegroup -VMName $VMresourcename -Name 'OmsAgentForLinux' -Publisher 'Microsoft.EnterpriseCloud.Monitoring' -ExtensionType 'OmsAgentForLinux' -TypeHandlerVersion '1.0' -Location $VMlocation -SettingString "{'workspaceId':  '$workspaceId'}" -ProtectedSettingString "{'workspaceKey': '$workspaceKey' }"
        }
}
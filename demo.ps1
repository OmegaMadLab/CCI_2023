# Environment preparation

$app1contributorGrpName= "CCI2023_App1_contributors"
$app1readerGrpName= "CCI2023_App1_readers"

$app2contributorGrpName= "CCI2023_App2_contributors"
$app2readerGrpName= "CCI2023_App2_readers"

$rgName = "CCI-2023-RG"
$location = "italynorth"

$rg = Get-AzResourceGroup -Name $rgName -Location $location -ErrorAction SilentlyContinue
if (-not $rg) {
    New-AzResourceGroup -Name $rgName -Location $location
}

# Group creation section, execute it once
New-AzAdGroup -DisplayName $app1contributorGrpName `
    -MailNickname $app1contributorGrpName

New-AzAdGroup -DisplayName $app2contributorGrpName `
    -MailNickname $app2contributorGrpName

New-AzAdGroup -DisplayName $app1readerGrpName `
    -MailNickname $app1readerGrpName

New-AzAdGroup -DisplayName $app2readerGrpName `
    -MailNickname $app2readerGrpName



###########################################################
# DEMO 1: create a Template Spec
New-AzTemplateSpec -Name 'AppEnvironementTemplate-TS' `
    -ResourceGroupName $rg.ResourceGroupName `
    -version '1.0' `
    -Location $location `
    -TemplateFile .\app_ready_rg.bicep

###########################################################
# DEMO 2: deploy an environment for App1 with deployment stack
$app1contributorGrpId = (Get-AzAdGroup -DisplayName $app1contributorGrpName).Id
$app1readerGrpId = (Get-AzAdGroup -DisplayName $app1readerGrpName).Id

$templateSpecId = (Get-AzTemplateSpec -Name 'AppEnvironementTemplate-TS' -ResourceGroupName $rg.ResourceGroupName).Versions[0].Id

New-AzSubscriptionDeploymentStack -Name 'App1-Environment-Stack' `
    -Location $location `
    -DeleteAll `
    -DenySettingsMode DenyDelete `
    -DenySettingsApplyToChildScopes `
    -TemplateSpecId $templateSpecId `
    -TemplateParameterObject @{ 
        'AppName' = 'CCI2023App1'
        'location' = $location
        'contributorGrpId' = $app1contributorGrpId
        'readerGrpId' = $app1readerGrpId
    }

###########################################################
# DEMO 3: create a new version of the template spec, and use it 
#         to deploy an environment for App2 with deployment stack

$app2contributorGrpId = (Get-AzAdGroup -DisplayName $app2contributorGrpName).Id
$app2readerGrpId = (Get-AzAdGroup -DisplayName $app2readerGrpName).Id

# Apply a change to the bicep file
New-AzTemplateSpec -Name 'AppEnvironementTemplate-TS' `
    -ResourceGroupName $rg.ResourceGroupName `
    -version '2.0' `
    -Location $location `
    -TemplateFile .\app_ready_rg.bicep

$templateSpecId = (Get-AzTemplateSpec -Name 'AppEnvironementTemplate-TS' -ResourceGroupName $rg.ResourceGroupName).Versions[1].Id

New-AzSubscriptionDeploymentStack -Name 'App2-Environment-Stack' `
    -Location $location `
    -DeleteAll `
    -DenySettingsMode DenyDelete `
    -DenySettingsApplyToChildScopes `
    -TemplateSpecId $templateSpecId `
    -TemplateParameterObject @{ 
        'AppName' = 'CCI2023App2'
        'location' = $location
        'contributorGrpId' = $app2contributorGrpId
        'readerGrpId' = $app2readerGrpId
    }

###########################################################
# DEMO 4: Update App1 environment by using v2.0 of the template spec

$templateSpecId

Set-AzSubscriptionDeploymentStack -Name 'App1-Environment-Stack' `
    -Location $location `
    -DeleteAll `
    -DenySettingsMode DenyDelete `
    -DenySettingsApplyToChildScopes `
    -TemplateSpecId $templateSpecId `
    -TemplateParameterObject @{ 
        'AppName' = 'CCI2023App1'
        'location' = $location
        'contributorGrpId' = $app1contributorGrpId
        'readerGrpId' = $app1readerGrpId
    }


###########################################################
# DEMO 5: clean up

Remove-AzSubscriptionDeploymentStack -Name 'App1-Environment-Stack' `
    -DeleteAll




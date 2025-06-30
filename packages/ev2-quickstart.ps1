# CAUTION! Please run this script step by step.

$ServiceId = "0b55cc05-7c4d-4c65-919c-d57201d6cabf"  # Cosman
$ServiceGroupName = "Microsoft.O365.Cosman.Ev2Test"
$CosmanNPESubscriptionId = "f3bed3ba-dadc-4f2e-b2e3-e603b756f82b" # Cosman NPE
# $CosmanNonProdSubscriptionId = "595c82ed-d6b5-44fb-827a-5a55fe86dd4e" # Cosman NonProd
# $CosmanSubscriptionId = "90e12bc3-39cc-4ed2-a8bc-8170144f1818" # Cosman Prod
$ArtifactsVersion = "1.0.1"
$SubscriptionKey = "CosmanNPE" # Subscription key
$StageMapName = "Microsoft.Azure.SDP.Standard" # Default stage map name
$StageMapVersion = "0.0.10" # Default stage map version
$Regions = "westus" # Default region
$NpeTenantId = "b1a4f7cb-a159-44a6-ac48-6674e85c4ddc"

# Onetime: register service group
# New-AzureServiceRolloutServiceRegistration -ServiceSpecificationPath "$pwd\serviceSpecification.json" -RolloutInfra Test -GuestAccountTenantId $NpeTenantId

# Each time re-register rollout spec, update the version.txt and $ArtifactsVersion
Register-AzureServiceArtifacts -ServiceGroupRoot "$pwd/ev2-test" -RolloutSpec "rolloutSpec.json" -RolloutInfra Test -GuestAccountTenantId $NpeTenantId # Use your workstation, MSIT account to authenticate

Get-AzureServiceArtifacts -ServiceIdentifier $ServiceId -ServiceGroup $ServiceGroupName -RolloutInfra Test -Version $ArtifactsVersion -GuestAccountTenantId $NpeTenantId # Check if the artifacts are registered

# Onetime: register subscription
# Register-AzureServiceSubscription -ServiceIdentifier $ServiceId -SubscriptionKey $SubscriptionKey -SubscriptionId $CosmanNPESubscriptionId -RolloutInfra Test -GuestAccountTenantId $NpeTenantId

Get-AzureServiceSubscription -ServiceIdentifier $ServiceId -RolloutInfra Test -GuestAccountTenantId $NpeTenantId

Test-AzureServiceRollout -ServiceIdentifier $ServiceId -ServiceGroup $ServiceGroupName -StageMapName $StageMapName -StageMapVersion $StageMapVersion -Select "regions($Regions)" -ArtifactsVersion $ArtifactsVersion -RolloutInfra Test -WaitToComplete -GuestAccountTenantId $NpeTenantId

New-AzureServiceRollout -ServiceIdentifier $ServiceId -ServiceGroup $ServiceGroupName -StageMapName $StageMapName -StageMapVersion $StageMapVersion -Select "regions($Regions)" -ArtifactsVersion $ArtifactsVersion -RolloutInfra Test -WaitToComplete -GuestAccountTenantId $NpeTenantId

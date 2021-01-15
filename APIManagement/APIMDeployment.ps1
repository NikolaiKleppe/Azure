##############################################################################################################################
# Common Variables

$resGroupName = "1_APIManagement"
$ApimName 	  = "nik-apim"
$location     = "West Europe"

$AppGwVnetRG  = "4-hub-vnet-rg"
$ApimVnetRG   = "4-spoke1-vnet-rg"

##############################################################################################################################








##############################################################################################################################
# Cert Variables
# Step 1

$gatewayHostname      	= "api.kleppetest.com"                 							# API gateway host
$portalHostname 		= "portal.kleppetest.com"              							# API developer portal host
$gatewayCertCerPath 	= "/home/nikolai/clouddrive/apim_cert/api_certificate.cer" 		# full path to api.contoso.net .cer file
$gatewayCertPfxPath 	= "/home/nikolai/clouddrive/apim_cert/api_certificate.pfx" 		# full path to api.contoso.net .pfx file
$portalCertPfxPath 		= "/home/nikolai/clouddrive/apim_cert/portal_certificate.pfx"  	# full path to portal.contoso.net .pfx file
$gatewayCertPfxPassword = ""   															# password for api.contoso.net pfx certificate
$portalCertPfxPassword 	= ""    														# password for portal.e.net pfx certificate

$certPwd 		= ConvertTo-SecureString -String $gatewayCertPfxPassword -AsPlainText -Force
$certPortalPwd  = ConvertTo-SecureString -String $portalCertPfxPassword  -AsPlainText -Force

##############################################################################################################################










##############################################################################################################################
# Get existing resources to use

$apimService 			= Get-AzApiManagement  -ResourceGroupName $resGroupName  -Name $ApimName
$AppGwVnet 				= Get-AzVirtualNetwork -ResourceGroupName $AppGwVnetRG   -Name "hub-vnet"
$ApimVnet               = Get-AzVirtualNetwork -ResourceGroupName $ApimVnetRG    -Name "spoke1-vnet"


$appgatewaysubnetdata 	= $AppGwVnet.Subnets | Where-Object Name -Like "*AppGW-BackendSubnet*"
$apimsubnetdata 		= $ApimVnet.Subnets  | Where-Object Name -Like "*ApimSubnet*"
##############################################################################################################################








##############################################################################################################################
# Step 2
# Create and set the hostname configuration objects for the proxy and for the portal.



$proxyHostnameConfig  = New-AzApiManagementCustomHostnameConfiguration -Hostname $gatewayHostname -HostnameType Proxy -PfxPath $gatewayCertPfxPath -PfxPassword $certPwd
$portalHostnameConfig = New-AzApiManagementCustomHostnameConfiguration -Hostname $portalHostname -HostnameType DeveloperPortal -PfxPath $portalCertPfxPath -PfxPassword $certPortalPwd

$apimService.ProxyCustomHostnameConfiguration = $proxyHostnameConfig
$apimService.PortalCustomHostnameConfiguration = $portalHostnameConfig
Set-AzApiManagement -InputObject $apimService








############################################################################################################################################################################################################################################################


# Create a public IP address for the front-end configuration
$publicip = New-AzPublicIpAddress -ResourceGroupName $resGroupName -name "AppGwPublicIP01" -location $location -AllocationMethod Static



# Create application gateway configuration
$gipconfig   	 = New-AzApplicationGatewayIPConfiguration  -Name "gatewayIP01" 			-Subnet $appgatewaysubnetdata
$fp01 	     	 = New-AzApplicationGatewayFrontendPort     -Name "AppGwFrontEndPort01"  	-Port 443
$fipconfig01 	 = New-AzApplicationGatewayFrontendIPConfig -Name "ApPGwFrontEndIpConfig" 	-PublicIPAddress $publicip


$cert       	 = New-AzApplicationGatewaySslCertificate   -Name "GatewayCert" 			-CertificateFile $gatewayCertPfxPath -Password $certPwd
$certPortal 	 = New-AzApplicationGatewaySslCertificate   -Name "Portalcert"  			-CertificateFile $portalCertPfxPath  -Password $certPortalPwd


$listener        = New-AzApplicationGatewayHttpListener 	-Name "GatewayListener" 		-Protocol "Https" -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -SslCertificate $cert       -HostName $gatewayHostname -RequireServerNameIndication true
$portalListener  = New-AzApplicationGatewayHttpListener 	-Name "PortalListener"  		-Protocol "Https" -FrontendIPConfiguration $fipconfig01 -FrontendPort $fp01 -SslCertificate $certPortal -HostName $portalHostname  -RequireServerNameIndication true


$apimprobe       = New-AzApplicationGatewayProbeConfig 		-Name "apimproxyprobe"  		-Protocol "Https" -HostName $gatewayHostname -Path "/status-0123456789abcdef"          -Interval 30 -Timeout 120 -UnhealthyThreshold 8
$apimPortalProbe = New-AzApplicationGatewayProbeConfig 		-Name "apimportalprobe" 		-Protocol "Https" -HostName $portalHostname  -Path "/internal-status-0123456789abcdef" -Interval 60 -Timeout 300 -UnhealthyThreshold 8




$authcert 		 = New-AzApplicationGatewayAuthenticationCertificate -Name "whitelistcert1" -CertificateFile $gatewayCertCerPath

#Remember to choose cookie based affinity here if using azure AD
$apimPoolSetting 	   = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolSetting"       -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimprobe       -AuthenticationCertificates $authcert -RequestTimeout 180
$apimPoolPortalSetting = New-AzApplicationGatewayBackendHttpSettings -Name "apimPoolPortalSetting" -Port 443 -Protocol "Https" -CookieBasedAffinity "Disabled" -Probe $apimPortalProbe -AuthenticationCertificates $authcert -RequestTimeout 180
$apimProxyBackendPool  = New-AzApplicationGatewayBackendAddressPool  -Name "apimbackend" 	       -BackendIPAddresses $apimService.PrivateIPAddresses[0]


$rule01 = New-AzApplicationGatewayRequestRoutingRule -Name "Rule-GatewayListener" -RuleType Basic -HttpListener $listener       -BackendAddressPool $apimProxyBackendPool -BackendHttpSettings $apimPoolSetting
$rule02 = New-AzApplicationGatewayRequestRoutingRule -Name "Rule-PortalListener"  -RuleType Basic -HttpListener $portalListener -BackendAddressPool $apimProxyBackendPool -BackendHttpSettings $apimPoolPortalSetting

#Remember to change SKU here to WAF
$sku = New-AzApplicationGatewaySku -Name "Standard_Small" -Tier "Standard" -Capacity 1

############################################################################################################################################################################################################################################################



# Create Application Gateway


$appgwName = "apim-app-gw"
$appgw     = New-AzApplicationGateway -Name 	$appgwName `
				-ResourceGroupName 				$resGroupName `
				-Location 						$location `
				-BackendAddressPools 			$apimProxyBackendPool `
				-BackendHttpSettingsCollection 	$apimPoolSetting, $apimPoolPortalSetting  `
				-FrontendIpConfigurations 		$fipconfig01 `
				-GatewayIpConfigurations		$gipconfig `
				-FrontendPorts 					$fp01 `
				-HttpListeners 					$listener, $portalListener `
				-RequestRoutingRules 			$rule01, $rule02 `
				-Sku 							$sku `
				-WebApplicationFirewallConfig 	$config `
				-SslCertificates 				$cert, $certPortal `
				-AuthenticationCertificates 	$authcert `
				-Probes 						$apimprobe, $apimPortalProbe










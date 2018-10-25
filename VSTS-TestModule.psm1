<#
.EXTERNALHELP Get-Hello-help.xml
#>
function Get-Hello {
	Write-Host "Hello from VSTS"
}
function Update-AzureVMLicense
{
	
	param (
		[Parameter][string]$Machine,
		[string]$ResourceGroup,
		[switch]$UpdateAll
	)
	BEGIN
	{
		Login-AzureRmAccount
	}
	PROCESS
	{
		
		if ($Machine)
		{
			Write-Host "Updating $($machine.Name) in $($group.ResourceGroupName)"
			#Find the machine
			$wvm = Get-AzureRmVM -ResourceGroupName $ResourceGroup -Name $Machine
			#Set the license
			$wvm.LicenseType = "Windows_Server"
			#Update the Machine
			Update-AzureRmVM -ResourceGroupName $group.ResourceGroupName -VM $wvm
		}
		
		if ($UpdateAll)
		{
			$u = Read-Host "This function will go through every subscription and change their license to Windows Server. Enter Y to confirm"
			if ($u.ToLower() -eq "y")
			{
				#Get all of the subscriptions
				$allSubs = Get-AzureRmSubScription
				#Go through each subscription
				foreach ($sub in $allSubs)
				{
					$resourceGroups = Get-AzureRmResourceGroup
					$count = 0;
					$machines = @();
					foreach ($group in $resourceGroups)
					{
						#Get all of the VMs
						$ret = Get-AzureRMVm -ResourceGroupName $group.ResourceGroupName
						if ($ret)
						{
							Write-Host "Found $($ret.Length) machines in $($group.ResourceGroupName)"
							foreach ($machine in $ret)
							{
								if (-not ($machine.LicenseType -eq "Windows_Server"))
								{
									$count++
									$machines += $machine
									Write-Host "Updating $($machine.Name) in $($group.ResourceGroupName)"
									$wvm = Get-AzureRmVM -ResourceGroupName $group.ResourceGroupName -Name $machine.Name
									$wvm.LicenseType = "Windows_Server"
									Update-AzureRmVM -ResourceGroupName $group.ResourceGroupName -VM $wvm
								}
								else
								{
									Write-Host "$($machine.Name) already has a  Windows Server License"
								}
							}
						}
						else
						{
							Write-Host "No VMS found in $($group.ResourceGroupName)"
						}
					}
				}
			}
			else
			{
				Write-Host "Exiting Process"
				Exit
				
			}
		}
		
		if ($ResourceGroup)
		{
			$rg = Get-AzureRmResourceGroup -Name $ResourceGroup
		}
		else
		{
			$rg = Get-AzureRmResourceGroup
		}
		$count = 0;
		$machines = @();
		foreach ($group in $resourceGroups)
		{
			$ret = Get-AzureRMVm -ResourceGroupName $group.ResourceGroupName
			if ($ret)
			{
				Write-Host "Found $($ret.Length) machines in $($group.ResourceGroupName)"
				foreach ($machine in $ret)
				{
					if (-not ($machine.LicenseType -eq "Windows_Server"))
					{
						$count++
						Write-Host "Updating $($machine.Name) in $($group.ResourceGroupName)"
						$wvm = Get-AzureRmVM -ResourceGroupName $group.ResourceGroupName -Name $machine.Name
						$wvm.LicenseType = "Windows_Server"
						Update-AzureRmVM -ResourceGroupName $group.ResourceGroupName -VM $wvm
						$machines += $wvm
					}
					else
					{
						Write-Host "$($machine.Name) already has a  Windows Server License"
					}
				}
			}
			else
			{
				Write-Host "No VMS found in $($group.ResourceGroupName)"
			}
		}
		
	}
	END
	{
		$date = Get-Date -UFormat "%Y-%m-%d"
		$machines | Export-Csv -Path "$($date)-AzureUpdate.csv"
		Write-Host "Updated the license of $($count) machines"
	}
}
<#	
.SYNOPSIS
This script will add the domain the the list of accepted domains on Azure, email the list of people on that domain and then set the specified SPO site to accept external users.
.DESCRIPTION
A lot of companies will have vendors come in and they will want access to colaborate on Sharepoint Site or Azure resource. This script automates that process
.EXAMPLE
New-DomainToSPOSite -ExternalExtension vendor.com -Users "jon@vendor.com", "susie@vendor.com" -SPOSiteURL mySPOsite.mycompany.com
This will add vendor.com to the list of accepted domains, send and invite to Jon and Sustie from vendor.com to access Azure and then allow them access to mySPOsite.mycompany.com
#>
Function New-DomainToSPOSite
{
	param (
		[Parameter(Mandatory = $true, HelpMessage = 'The extension of the domain we need to add EX: outlook.com')]
		[string]$ExternalExtension,
		[Parameter(Mandatory = $true, HelpMessage = 'A list of users to send the invites to')]
		[string[]]$Users,
		[Parameter(Mandatory = $true, HelpMessage = 'The full URL to the sharepoint site')]
		[string[]]$SPOSiteURL
	);
	BEGIN
	{
		# Add the moduls of Azure and SPOnline
		if (-not (Get-Module -ListAvailable AzureADPreview))
		{
			Write-Host "Azure module not found. Please Install the module by Running Install-Module Azure"
			exit
		}
		
		if (-not (Get-Module -ListAvailable Microsoft.Online.SharePoint.PowerShell))
		{
			Write-Host "Sharepoint Module not found. Please Install the module by Running Install-Module SPOnline"
			exit
		}
		try
		{
			Write-Host "Connecting to Share Point and Azure"
			$userName = ""
			$password = ""
			$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $userName, $(convertto-securestring $password -asplaintext -force)
			# This will need some configuration for accessing your company's Sharepoint admin URL'
			Connect-SPOService -Credential $cred -URL "YOUR COMPANY SHAREPOINT ADMIN URL"
			Connect-MSOLService -Cred $cred
			Connect-AzureAD -Credential $cred
		}
		catch
		{
			Write-Verbose "Did not connect correctly"
			exit
		}
		
	}
	PROCESS
	{
		#Check if the users are in the domain specified
		foreach ($u in $Users)
		{
			if (-not ($u.Contains($ExternalDomainExtension)))
			{
				Write-Host "One of those user is not part of the specified domain"
				exit
			}
			Write-Host "$u is part of the $ExternalDomainExtension "
		}
		
		#Add the domain to the lists of acceptable Domain
		$FoundPolicy = Get-AzureADPolicy | ?{ $_.Type -eq 'B2BManagementPolicy' } | select Definition, ID
		$TheDefinition = $FoundPolicy.Definition
		$ParsedDefinition = $FoundPolicy.Definition -split '(?=:)'
		#Look for the allowed domains portion of the List that comes back.
		foreach ($i in $ParsedDefinition)
		{
			if ($i.Contains("AllowedDomains"))
			{
				$DomainsIndex = $ParsedDefinition.IndexOf($i)
			}
		}
		
		if ($DomainsIndex -and (-not ($ParsedDefinition[$DomainsIndex + 1].Contains($ExternalExtension))))
		{
			$TheAllowedDomains = $ParsedDefinition[$DomainsIndex + 1].Replace("]}", ',"' + $ExternalExtension + '"]}')
			$ParsedDefinition[$DomainsIndex + 1] = $TheAllowedDomains
			[Collections.Generic.List[String]]$lst = $ParsedDefinition -join ""
			Write-Host $lst
			Set-AzureADPolicy -Id $FoundPolicy.ID -Definition $lst
		}
		elseif ($DomainsIndex -and $ParsedDefinition[$DomainsIndex + 1].Contains($ExternalExtension))
		{
			Write-Host "The domain already exists in the allowed domains. Moving onto the invite portion."
		}
		else
		{
			Write-Host "The policy you specified did not contain the Allowed domains."
			exit
		}
		#Send a request to the people that need to be added to the site. These will be people that are now added. 
		foreach ($NewUser in $Users)
		{
			Write-Verbose "Inviting $NewUser to Azure"
			# This will also require the redirect to your Azure invites
			New-AzureADMSInvitation -InvitedUserEmailAddress $NewUser -SendInvitationMessage $True -InviteRedirectUrl "https://myapps.microsoft.com/"
		}
		#Go to the SPO Site
		$theFoundSite = Get-SPOSite -Identity $SPOSiteURL
		if ($theFoundSite)
		{
			Set-SPOSite $theFoundSite.URL -SharingCapability ExistingExternalUserSharingOnly
		}
		else
		{
			Write-Host "The site could not be found.Did you specify the entire url?"
			exit
		}
		
	}
	END
	{
		Write-Host "Added the domain $ExternalExtension to Azure and added $($Users.Count) to $SPOSiteURL"
		
	}
	
}







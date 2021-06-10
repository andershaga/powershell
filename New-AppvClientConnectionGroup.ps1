function New-AppvClientConnectionGroup
{
	<#
	.SYNOPSIS
		Creates a new connection group based on input
	.PARAMETER name
		Name of App-V Connection Group
	.PARAMETER packages
		Array of App-V packages to be included in group
	.EXAMPLE
		New-AppvClientConnectionGroup -packages $packages -name "Something"
	.NOTES
		Creator: github.com/andershaga
	#>

	[cmdletbinding()]

	PARAM
	(
		[parameter(mandatory=$true)][object[]]$Packages,
		[parameter(mandatory=$true)][string]$Name
	)

	BEGIN
	{
		# check input parameters
		if ($wrong = ($packages | % {$_.gettype()}) -ne [Microsoft.AppV.AppvClientPowerShell.AppvClientPackage])
		{
			throw "Packages input error! $($wrong.fullname | % {`"`n - $_`"})"
		}
	}
	PROCESS
	{
		# xml object
		$xml = New-Object System.Xml.XmlDocument

		# declaration
		$xml.AppendChild($xml.CreateXmlDeclaration('1.0',$null,$null)) | Out-Null
	
		# applicationgroup
		$xml_0 = $xml.AppendChild($xml.CreateElement('AppConnectionGroup'))
	
			$xml_0.SetAttribute('DisplayName',$name)
			$xml_0.SetAttribute('AppConnectionGroupId',[guid]::newguid().guid)
			$xml_0.SetAttribute('VersionId',[guid]::newguid().guid)
			$xml_0.SetAttribute('Priority','10')
			$xml_0.SetAttribute('xmlns','http://schemas.microsoft.com/appv/2014/virtualapplicationconnectiongroup')
	
		# applicationgroup\packages
		$xml_1 = $xml_0.AppendChild($xml.CreateElement('Packages'))
	
		# applicationgroup\packages\package
		foreach ($package in $packages)
		{
			$xml_1_1 = $xml_1.AppendChild($xml.CreateElement('Package'))
			$xml_1_1.SetAttribute('DisplayName',$package.Name)
			$xml_1_1.SetAttribute('PackageId',$package.PackageId)
			$xml_1_1.SetAttribute('VersionId',$package.VersionId)
			$xml_1_1.SetAttribute('IsOptional','false')
		}

		# save and make
		$xml.save(($tempfile = [system.io.path]::gettempfilename()))
		$cg = add-appvclientconnectiongroup -path $tempfile -ea stop | enable-appvclientconnectiongroup -global -ea stop
	}
	END
	{
		write-output $cg
	}
}

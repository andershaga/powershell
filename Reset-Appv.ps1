function Reset-Appv
{
	<#
	.DESCRIPTION
		Reset App-V
	.NOTES
		Creator: github.com/andershaga
	#>

	write-host "`nReset App-V:" -f darkcyan

	stop-service appvclient -force -ea stop
					
	stop-appvclientconnectiongroup * -ea stop | % {
		
		write-host " remove group:   " -n; write-host $_.name
		remove-appvclientconnectiongroup $_ | out-null
	}
	stop-appvclientpackage * -ea stop | % {
		
		write-host " remove package: " -n; write-host $_.name
		remove-appvclientpackage $_ | out-null
	}

	stop-service appvclient -force -ea stop

	$data = 
	(
		"c:\programdata\app-v",
		"c:\programdata\microsoft\appv\client\catalog",
		"c:\programdata\microsoft\appv\client\integration",
		"c:\programdata\microsoft\appv\client\vreg",
		"hklm:\software\microsoft\appv\mav",
		"hklm:\software\microsoft\appv\client\integration\packages",
		"hklm:\software\microsoft\appv\client\packagegroups",
		"hklm:\software\microsoft\appv\client\packages",
		"hklm:\software\microsoft\appv\client\streaming\packages",
		"hklm:\software\microsoft\appv\client\virtualization\localvfssecuredusers"
	)

	foreach ($i in (gci "c:\users" | ? {$_.fullname -notlike "c:\users\default*"}))
	{
		$data += "$($i.fullname)\appdata\local\microsoft\appv"
	}

	foreach ($d in $data)
	{           
		if (test-path $d)
		{
			write-host " Remove folder: " -n; write-host $d
			remove-item $d -recurse -force -ea stop | out-null
		}
	}
}

function Start-AsActiveUser
{
	<#
	.DESCRIPTION
		Uses scheduled tasks to start a process as the logged on (active) user
	.NOTES
		Creator: github.com/andershaga
	#>

	param
	(
		[parameter(mandatory=$true)][string]$FilePath,
		[string]$ArgumentList,
		[switch]$Wait,
		[switch]$Hidden
	)

	begin
	{
		if (!(Get-Command -Module scheduledtasks -ea 0))
		{
			throw  "Module `"ScheduledTasks`" not found"
		}

		if (!(Test-Path $filepath) -and !($env:path.split(";") | ? {Test-Path "$_\$filepath.*"}))
		{
			throw "File not found!"
		}

		if (!($quser = (((quser) -replace '\s{2,}', ',' | ConvertFrom-Csv | ? {$_.state -eq 'active'}).username)))
		{
			throw "Can't resolve active users"
		}
		else
		{
			if ($quser.count -eq 1)
			{
				$user = $quser -replace '>',''
			}
			else
			{
				if (($quser | ? {$_.startswith(">")}).count -eq 1)
				{
					$user = ($quser | ? {$_.startswith('>')}) -replace '>',''
				}
				else
				{
					throw "Can't define desktop user"
				}
			}
		}
	}
	process
	{       
		if ($argumentlist)
		{
			$a = New-ScheduledTaskAction -execute "$filepath" -argument $argumentlist
		}
		else 
		{
			$a = New-ScheduledTaskAction -execute "$filepath"
		}

		$p = New-ScheduledTaskPrincipal "$env:userdomain\$user"

		if ($hidden)
		{
			$d = New-ScheduledTask -action $a -principal $p -settings $(New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -compatibility win8 -hidden)
		}
		else
		{
			$d = New-ScheduledTask -action $a -principal $p -settings $(New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -compatibility win8)
		}
		
		$randomhexstring = (1..8 | %{ '{0:x}' -f (Get-Random -max 16) }) -join ''

		Register-ScheduledTask -taskname $randomhexstring -inputobject $d -force -ea stop | Out-Null
		Start-ScheduledTask -taskname $randomhexstring -ea stop
		Unregister-ScheduledTask -taskname $randomhexstring -confirm:$false -ea 0 
	}
	end
	{
	}
}

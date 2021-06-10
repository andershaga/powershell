function Show-Message
{
	<#
	.SYNOPSIS
		Overcomplicated function of a simple command to show a popup, but here it is
	.EXAMPLE
		Show-Message "Hello world!"
	.EXAMPLE
		Show-Message -message "This is a message" -title "Important" -type Exclamation -buttons OkCancel
	.OUTPUTS
		System.Int32
	.NOTES
		Creator: github.com/andershaga
	#>

	[cmdletbinding()]

	param
	(
		[string]$Message="",
		[string]$Title="Message",
		[ValidateSet('Stop','Question','Exclamation','Information')][string]$Type="Information",
		[ValidateSet('Ok','OkCancel','AbortRetryIgnore','YesNoCancel','YesNo','RetryCancel','CancelTryAgainContinue')][string]$Buttons="Ok",
		[int]$Timeout=0,
		[switch]$PrintReturns
	)

	begin
	{
		if ($PrintReturns)
		{
			Write-Output "-1  Timeout`n 1  OK`n 2  Cancel`n 3  Abort`n 4  Retry`n 5  Ignore`n 6  Yes`n 7  No`n 10 Try again`n 11 Continue"
			break
		}
	}
	process
	{
		switch ($buttons)
		{
			'Ok' {$b=0}
			'OkCancel' {$b=1}
			'AbortRetryIgnore' {$b=2}
			'YesNoCancel' {$b=3}
			'YesNo' {$b=4}
			'RetryCancel' {$b=5}
			'CancelTryAgainContinue' {$b=6}
		}

		switch ($type)
		{
			'Stop' {$t=16}
			'Question' {$t=32}
			'Exclamation' {$t=48}
			'Information' {$t=64}
		}

		try
		{
			(New-Object -ComObject Wscript.Shell).Popup($message,$timeout,$title,$t+$b)
		}
		catch
		{
			throw $_
		}
	}
}

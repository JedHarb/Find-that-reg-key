function Get-AllRegValues {
	foreach ($key in ((Get-ChildItem -Path HKCU:\ -Recurse -ErrorAction SilentlyContinue).PsPath -replace [RegEx]::Escape("Microsoft.PowerShell.Core\"))) {
		$Pair = 0
		$Pair = try {
			(Get-ItemProperty -path $key).PSObject.Properties | Where-Object Name -notlike "PS*" | Select-Object Name, Value
		}
		catch { }
		
		foreach ($data in $Pair) {
			[PSCustomObject]@{
				Key = $key -replace [RegEx]::Escape("Registry::")
				Name = $data.Name
				Value = $data.Value
			}
		}
	}
}

"(note this is only set up for HKCU at the moment...)"
Read-Host "Press Enter to take the first registry snapshot"
"Working..."

$1st = Get-AllRegValues

Read-Host "`nDone with first snapshot.`nPlease make any changes necessary and press Enter to take the second registry snapshot"
"Working..."

$2nd = Get-AllRegValues

$Results = Compare-Object $1st $2nd -Property Key, Name, Value | Sort-Object SideIndicator

if ($Results) {
	$Desktoptxt = ([Environment]::GetFolderPath("Desktop")).ToString() + "\RegComparison.txt"
	$i = 0
	$j = 0
	$k = 0

	$Results2 = foreach ($Result in $Results) {
		if ($k -eq 0) {
			"($Desktoptxt)`n`n"
			$k++
		}
		if (($Result.SideIndicator -eq "<=") -and ($i -eq 0)) {
			"     |||---------These values are only in the FIRST snapshot (not the second)---------|||"
			$i++
		}
		if (($Result.SideIndicator -eq "=>") -and ($j -eq 0)) {
			"`n`n     |||---------These values are only in the SECOND snapshot (not the first)---------|||"
			$j++
			$x = 0
		}
		
		if ($x -ne $($Result.Key)){
			"`n`n--------------------------------------------------------------`n|KEY: $($Result.Key)`n--------------------------------------------------------------"
			$x = $($Result.Key)
		}
		else {
			"|"
		}
		"|---VALUE NAME: $($Result.Name)"
		"|----VALUE DATA: $($Result.Value)"
	}

	$Results2 | Out-String -width 9999 | Out-File -Encoding utf8 -FilePath $Desktoptxt
	Invoke-Item $Desktoptxt
}
else {
	Read-Host "The registry snapshots 1 and 2 are identical."
}
# Bitlocking USB keys
# 2017-11-13 : created by Tommy Andersen
# https://github.com/Gitami/Bitlocking-usb-sticks/
#===================================================================
# USAGE example: bitlockusb.ps1 e:
# Otherwise will prompt for driveletter
#===================================================================
param (
	[string]$thisDriveletter = $( Read-Host "What drive do you want to format and bitlock?" )
)
clear
 
# ========================== 
# Setting variables
# ========================== 
 
# Volume label for the USB stick
$thisVolumeLabel = "My USB Stick";
 
# Creating secure password string for use in script
$pass = ConvertTo-SecureString "seCretPassW0rd" -AsPlainText -Force
 
# Getting drive information object
$drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = '$thisDriveletter'"
 
# ========================== 
# Start script
# ========================== 
 
# Ask for confirmation and then format the drive
$message  = "This will erase all data on your $thisDriveletter drive"
$question = "Are you sure you want to proceed?"
 
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
 
$decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
if ($decision -eq 0) {
	Write-Host "Formatting $thisDriveletter..."
 
	# formatting drive
	$drive.Format("FAT32",$true,4096,"$thisVolumeLabel",$false)
	
	# encrypting drive
	Write-Host "Bitlocking $thisDriveletter..."
	Enable-BitLocker -MountPoint $thisDriveletter -EncryptionMethod Aes256 -UsedSpaceOnly -Password $pass -PasswordProtector
 
	# while waiting, show some dots
	while ((Get-BitLockerVolume -MountPoint $thisDriveletter).EncryptionPercentage -lt 100){
		Write-Host "still working on it..."
	}
 
	# when done, show status
	manage-bde -status $thisDriveletter
	
} else {
	Write-Host "Operation cancelled"
}
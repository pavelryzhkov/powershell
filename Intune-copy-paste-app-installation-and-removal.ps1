param (
    [switch]$install,
    [switch]$uninstall
)

function Start-Installation {
    $logFile = "C:\Apps\Exante\bo\installation_log.txt"
    $url = "https://updates.rmrzone.com/boclient_skb-prod/boclient_skb-prod-win.zip"
    $destination = "C:\Apps\Exante\bo"
    $desktopShortcut = "C:\Users\Public\Desktop\Exante BO.lnk"
    New-Item -ItemType Directory 'C:\Apps\Exante\bo' -ErrorAction Ignore -Force

    # Logging
    function Log-Message {
        param (
            [string]$message
        )
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $logEntry = "$timestamp - $message"
        Add-Content -Path $logFile -Value $logEntry
        Write-Output $logEntry
    }

    # Check archive availability
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing
        if ($response.StatusCode -ne 200) {
            Log-Message "Archive not available: $url"
            return
        }
    } catch {
        Log-Message "Error checking archive availability: $_"
        return
    }

    # Download archive
    try {
        Invoke-WebRequest -Uri $url -OutFile "$destination\archive.zip" -UseBasicParsing
        Log-Message "Archive downloaded to $destination\archive.zip"
    } catch {
        Log-Message "Error downloading archive: $_"
        return
    }

    # Extract archive
    try {
        Expand-Archive -Path "$destination\archive.zip" -DestinationPath $destination -Force
        Log-Message "Archive extracted to $destination"
    } catch {
        Log-Message "Error extracting archive: $_"
        return
    }

    # Delete archive after extraction
    try {
        Remove-Item -Path "$destination\archive.zip" -Force
        Log-Message "Archive deleted: $destination\archive.zip"
    } catch {
        Log-Message "Error deleting archive: $_"
    }

    # Find folder with changing name
    $extractedFolder = Get-ChildItem -Path $destination | Where-Object { $_.PSIsContainer } | Sort-Object LastWriteTime -Descending | Select-Object -First 1

    if ($null -eq $extractedFolder) {
        Log-Message "Failed to find extracted folder."
        return
    }

    # Delete existing files and directories before moving
    try {
        Get-ChildItem -Path $destination -Exclude $extractedFolder.Name | Remove-Item -Recurse -Force
        Log-Message "Existing files and directories deleted from $destination"
    } catch {
        Log-Message "Error deleting existing files and directories: $_"
        return
    }

    # Move folder contents
    try {
        Move-Item -Path "$($extractedFolder.FullName)\*" -Destination $destination -Force
        Log-Message "Contents of folder $($extractedFolder.Name) moved to $destination"
    } catch {
        Log-Message "Error moving folder contents: $_"
        return
    }

    # Create shortcut
    try {
        $WScriptShell = New-Object -ComObject WScript.Shell
        $shortcut = $WScriptShell.CreateShortcut($desktopShortcut)
        $shortcut.TargetPath = "C:\Apps\Exante\bo\bin\boclient_skb.exe"
        $shortcut.WorkingDirectory = "C:\Apps\Exante\bo\bin"
        $shortcut.IconLocation = "C:\Apps\Exante\bo\bin\boclient_skb.exe"
        $shortcut.Save()
        Log-Message "Shortcut created: $desktopShortcut"
    } catch {
        Log-Message "Error creating shortcut: $_"
        return
    }

    Log-Message "Installation completed successfully."
}

function Remove-Installation {
    $destination = "C:\Apps\Exante\bo"
    $desktopShortcut = "C:\Users\Public\Desktop\Exante BO.lnk"

    # Delete folder
    try {
        Remove-Item -Path $destination -Recurse -Force
        Write-Output "Folder deleted: $destination"
    } catch {
        Write-Output "Error deleting folder: $_"
        return
    }

    # Delete shortcut
    try {
        Remove-Item -Path $desktopShortcut -Force
        Write-Output "Shortcut deleted: $desktopShortcut"
    } catch {
        Write-Output "Error deleting shortcut: $_"
        return
    }

    Write-Output "Uninstallation completed successfully."
}

function Test-InstallationStatus {
    $filePaths = @(
        "C:\Apps\Exante\bo\bin\boclient_skb.exe",
        "C:\Users\Public\Desktop\Exante BO.lnk"
    )

    $allFilesExist = $true

    foreach ($filePath in $filePaths) {
        if (-Not (Test-Path $filePath)) {
            Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - File not found: $filePath"
            $allFilesExist = $false
        }
    }

    if (-Not $allFilesExist) {
        Start-Installation
    } else {
        Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - All files are in place."
    }
}

if ($uninstall) {
    Remove-Installation
} elseif ($install) {
    Test-InstallationStatus
} else {
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Parameters not specified. Use --install for installation or --uninstall for uninstallation."
}

#Requires -Modules Logging
#Requires -Modules Hooks

Invoke-Hook "PreInstallQuake3"

Write-Log -Message "Installing ioquake3..."

if (-not (Test-Path -Path "${Env:SERVER_DIR}/ioq3ded.x86_64")) {
    Write-Log "Could not find ioq3ded.x86_64 in ${Env:SERVER_DIR}, proceeding with installation."

    $downloadUrl = $Env:IOQUAKE3_URL

    Write-Log "Downloading ioquake3 from $downloadUrl"

    curl --output /tmp/ioquake3.zip "$downloadUrl"

    unzip /tmp/ioquake3.zip -d /tmp

    Move-Item -Path "/tmp/ioquake3" -Destination $Env:SERVER_DIR
} else {
    Write-Log "ioquake3 already installed in ${Env:SERVER_DIR}, skipping installation."
}

Write-Log -Message "ioquake3 installation complete."

Invoke-Hook "PostInstallQuake3"

Invoke-Hook "PreDownloadMods"

if ($Env:EXTRA_MOD_URLS -and $Env:EXTRA_MOD_URLS.Trim().Length -gt 0) {
    Write-Log "Downloading extra mods specified in EXTRA_MOD_URLS..."

    $modUrls = $Env:EXTRA_MOD_URLS -split '[, \n\r]+' | Where-Object { $_.Trim().Length -gt 0 }

    foreach ($url in $modUrls) {
        Write-Log -Message "Downloading mod from URL: $url"
        $fileName = [System.IO.Path]::GetFileName($url)
        $destinationPath = Join-Path -Path $Env:OVERLAY_DIR -ChildPath $fileName

        curl --output $destinationPath $url

        Write-Log -Message "Downloaded mod to: $destinationPath"
    }
} else {
    Write-Log -Message "No EXTRA_MOD_URLS specified, skipping mod download."
}

Invoke-Hook "PostDownloadMods"

Set-Location $Env:SERVER_DIR
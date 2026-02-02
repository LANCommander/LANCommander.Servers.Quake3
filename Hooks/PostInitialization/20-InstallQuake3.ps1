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

    Move-Item -Force -Path "/tmp/ioquake3/*" -Destination $Env:SERVER_DIR
} else {
    Write-Log "ioquake3 already installed in ${Env:SERVER_DIR}, skipping installation."
}

chmod +x "${Env:SERVER_DIR}/ioq3ded.x86_64"

Write-Log -Message "ioquake3 installation complete."

Invoke-Hook "PostInstallQuake3"

Set-Location $Env:SERVER_ROOT
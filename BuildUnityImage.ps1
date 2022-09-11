param(
    [parameter(Mandatory=$true)]
    [ValidatePattern("^\d{4}\.\d+\.\d+.*$")]
    [string]$UnityVersion = "2020.3.17f1",

    [parameter(Mandatory=$true)]
    [ValidatePattern("^[a-fA-F0-9]+$")]
    [string]$UnityChangeset = "a4537701e4ab"
)

$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew(); 

$Modules = "android windows-il2cpp" 

try {

docker build -t pontoco/win-base:latest images/windows/base
if (-not $?) {throw "Failed to build windows base image."}

docker build -t pontoco/hub:latest images/windows/hub
if (-not $?) {throw "Failed to build windows Unity Hub image."}

docker build --progress plain -t gcr.io/project-clockwork/unity-windows:$UnityVersion --build-arg version=$UnityVersion --build-arg changeSet=$UnityChangeset --build-arg module="$Modules" images/windows/editor
if (-not $?) {throw "Failed to build Unity Windows image."}

Write-Output "Pushing built containers to GCR"
gcloud auth configure-docker
if (-not $?) {throw "Could not login to GCloud / Google Container Registery"}

docker push gcr.io/project-clockwork/unity-windows:$UnityVersion
if (-not $?) {throw "Failed to upload image."}

} finally {
    Write-Output "Finished with time:"
    $Stopwatch
}
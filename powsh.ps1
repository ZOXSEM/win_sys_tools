if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb runAs -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"")
    exit
}
Write-Host "--- Запуск глубокой очистки ---" -ForegroundColor Cyan
$services = "wuauserv", "bits", "dosvc"
foreach ($svc in $services) { Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue }
Write-Host "Очистка системных образов и точек монтирования..."
dism /Online /Set-ReservedStorageState /State:Disabled /Quiet
dism /Online /Cleanup-Image /StartComponentCleanup
dism /Cleanup-Mountpoints /Quiet
Write-Host "Удаление кэша обновлений..."
Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Очистка кэша шейдеров NVIDIA..."
$nvPaths = @("$env:LOCALAPPDATA\NVIDIA\DXCache\*", "$env:LOCALAPPDATA\NVIDIA\GLCache\*", "$env:LOCALAPPDATA\NVIDIA Corporation\NV_Cache\*")
foreach ($path in $nvPaths) {
    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host "Очистка временных папок..."
$tempPaths = @("$env:TEMP\*", "C:\Windows\Temp\*", "C:\Windows\Prefetch\*")
foreach ($path in $tempPaths) {
    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
}
if (Get-Command py -ErrorAction SilentlyContinue) {
    py -3.12 -m pip cache purge
}
foreach ($svc in $services) { Start-Service -Name $svc -ErrorAction SilentlyContinue }
dism /Online /Set-ReservedStorageState /State:Enabled /Quiet
Write-Host "--- Очистка завершена! ---" -ForegroundColor Green
pause
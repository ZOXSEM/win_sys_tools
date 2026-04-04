Write-Host "`n--- Запуск поиска VLESS Reality ---" -ForegroundColor Cyan

$Mirrors = @(
    "https://githubusercontent.com/vfarid/v2ray-share/main/all_links.txt",
    "https://githubusercontent.com/peasoft/No-More-Blocked/main/v2ray",
    "https://githubusercontent.com/m-alizadeh/v2ray-reality/main/sub.txt",
    "https://githubusercontent.com/Epodonios/v2ray-configs/main/configs.txt",
    "https://githubusercontent.com/igareck/vpn-configs-for-russia/main/Vless-Reality-White-Lists-Rus-Mobile.txt"
)


$AllKeys = @()

foreach ($url in $Mirrors) {
    Write-Host "Проверяю зеркало: $($url.Substring(38,15))..." -ForegroundColor Gray
    try {
        $data = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 5
        $matches = [regex]::Matches($data, 'vless://[^ \s\r\n]+security=reality[^ \s\r\n]*')
        foreach ($m in $matches) { $AllKeys += $m.Value }
    } catch { continue }
}

$TopKeys = $AllKeys | Select-Object -Unique | Select-Object -First 10

if ($TopKeys) {
    Write-Host "`n[ПОБЕДА] Нашел свежие ключи:`n" -ForegroundColor Green
    $TopKeys | ForEach-Object { Write-Host ">>> $_" -ForegroundColor Yellow; Write-Host "---" -ForegroundColor DarkGray }
    Write-Host "`nВыдели ключ мышкой, нажми Enter." -ForegroundColor Cyan
} else {
    Write-Host "`n[FAIL] Зеркала молчат. Проверь интернет." -ForegroundColor Red
}

Write-Host "`nДля выхода нажми Enter..." -ForegroundColor Gray
Read-Host

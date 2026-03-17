[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# --- ПРОВЕРЬ ЭТУ ССЫЛКУ В БРАУЗЕРЕ ---
$u = 'https://raw.githubusercontent.com/ymkeee/T-Embed/main/assets/edit.mp4'

$f = "$env:TEMP\$([guid]::NewGuid().ToString()).mp4"

Write-Host "Пытаюсь скачать: $u" -ForegroundColor Cyan

try {
    Invoke-WebRequest -Uri $u -OutFile $f -ErrorAction Stop
} catch {
    Write-Host "ОШИБКА: Файл не найден по ссылке (404). Проверь путь на GitHub!" -ForegroundColor Red
    # Если не скачалось, попробуем поискать любой старый файл в TEMP, чтобы хоть что-то запустилось
    $oldFile = Get-ChildItem "$env:TEMP\*.mp4" | Select-Object -First 1
    if ($oldFile) { $f = $oldFile.FullName } else { exit }
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        WindowStyle="None" WindowState="Maximized" Topmost="True" 
        Background="Black" Cursor="None" ShowInTaskbar="False">
    <Grid><MediaElement Name="v" Source="$f" LoadedBehavior="Play" Stretch="Uniform" /></Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$w = [Windows.Markup.XamlReader]::Load($reader)
$v = $w.FindName("v")
$v.add_MediaEnded({ $w.Close() })
$w.Add_Closing({ $_.Cancel = $true })

$w.ShowDialog() | Out-Null

# Очистка
if (Test-Path $f) { Remove-Item $f -Force }

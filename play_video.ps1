Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# Ссылка на новое видео и уникальное имя файла
$u = 'https://github.com/ymkeee/T-Embed/raw/refs/heads/main/edit.mp4'
$f = "$env:TEMP\$(Guid).mp4" # Генерируем случайное имя, чтобы не было конфликтов со старым видео

# Скачивание
try {
    Invoke-WebRequest -Uri $u -OutFile $f
} catch {
    exit # Если не скачалось, тихо выходим
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        WindowStyle="None" WindowState="Maximized" Topmost="True" 
        Background="Black" Cursor="None" ShowInTaskbar="False">
    <Grid>
        <MediaElement Name="v" Source="$f" LoadedBehavior="Play" Stretch="Uniform" />
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$w = [Windows.Markup.XamlReader]::Load($reader)

# Когда видео закончится — закрываем окно
$v = $w.FindName("v")
$v.add_MediaEnded({ $w.Close() })

# Запуск окна
$w.ShowDialog() | Out-Null

# --- ОЧИСТКА СЛЕДОВ ---
# Ждем секунду, чтобы файл освободился процессом
Start-Sleep -Seconds 1

# Удаляем видеофайл
if (Test-Path $f) {
    Remove-Item -Path $f -Force
}

# Очищаем историю команд в текущей сессии, если нужно
Clear-History

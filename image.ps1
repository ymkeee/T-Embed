# 1. hide console window immediately
try {
    $c = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);'
    $t = Add-Type -MemberDefinition $c -Name "W" -Namespace "Win" -PassThru
    $t::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0) | Out-Null
} catch {}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# 2. settings
$u = 'https://github.com/ymkeee/T-Embed/raw/refs/heads/main/image.png'
$f = "$env:TEMP\image.png"

try {
    # download image
    Invoke-WebRequest -Uri $u -OutFile $f -ErrorAction Stop

    # 3. create player ui with image and timer
    $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        WindowStyle="None" WindowState="Maximized" Topmost="True" 
        Background="Black" Cursor="None" ShowInTaskbar="False"
        Loaded="Window_Loaded">
    <Grid>
        <Image Name="img" Source="$f" Stretch="Uniform" />
    </Grid>
</Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader ([xml]$xaml)
    $w = [Windows.Markup.XamlReader]::Load($reader)
    $img = $w.FindName("img")

    # add timer for 67 seconds
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromSeconds(67)
    $timer.Add_Tick({
        $w.Close()
        $timer.Stop()
    })
    $timer.Start()

    # event for loaded
    $loadedEvent = {
        $timer.Start()
    }
    $w.Add_Loaded($loadedEvent)

    # show the window
    $w.ShowDialog() | Out-Null
} 
catch { exit }
finally {
    # 4. cleanup and self-destruct process
    if (Test-Path $f) { Remove-Item $f -Force -ErrorAction SilentlyContinue }
    Stop-Process -Id $pid -Force
}

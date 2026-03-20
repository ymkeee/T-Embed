# 1. Hide console window immediately
try {
    $c = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);'
    $t = Add-Type -MemberDefinition $c -Name "W" -Namespace "Win" -PassThru
    $t::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0) | Out-Null
} catch {}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# 2. Settings
$u = 'https://github.com/ymkeee/T-Embed/raw/refs/heads/main/wallpaper.png'
$f = "$env:TEMP\pusheen.png"

try {
    # Download video
    Invoke-WebRequest -Uri $u -OutFile $f -ErrorAction Stop

    # 3. Create Player UI
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

    # Close window when video ends
    $v.add_MediaEnded({
        $w.Close()
    })

    # Show the window
    $w.ShowDialog() | Out-Null
} 
catch { exit }
finally {
    # 4. Cleanup and self-destruct process
    if (Test-Path $f) { Remove-Item $f -Force -ErrorAction SilentlyContinue }
    Stop-Process -Id $pid -Force
}

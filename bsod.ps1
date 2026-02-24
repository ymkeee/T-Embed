Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

$u = 'https://github.com/ymkeee/bsod/raw/refs/heads/main/assets/video.wmv'
$f = "$env:TEMP\yaroslava.wmv"

if (-not (Test-Path $f)) {
    Invoke-WebRequest -Uri $u -OutFile $f
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        WindowStyle="None"
        WindowState="Maximized"
        ResizeMode="NoResize"
        Topmost="True"
        Background="Black">
    <Grid>
        <MediaElement Name="vid"
                      LoadedBehavior="Manual"
                      UnloadedBehavior="Stop"
                      Stretch="Uniform"/>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$vid = $window.FindName("vid")
$vid.Source = [Uri] $f

$window.Add_SourceInitialized({
    $script:vid.Play()
})

$window.Add_Closed({
    $script:vid.Stop()
})

$window.ShowDialog() | Out-Null

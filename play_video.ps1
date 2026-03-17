# 1. Принудительно включаем TLS 1.2 (без этого iwr может упасть)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 2. Скрываем окно через простой метод (если не сработает - скрипт пойдет дальше)
$ignore = Add-Type -Name "Window" -Namespace "Win" -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);' -PassThru
$ignore::ShowWindow((Get-Process -Id $PID).MainWindowHandle, 0)

# 3. Подгружаем библиотеки для видео
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# 4. Ссылка на видео и создание пути
$url = 'https://raw.githubusercontent.com/ymkeee/T-Embed/main/assets/edit.mp4'
# Прямой вызов .NET для создания Guid во избежание ошибки "ObjectNotFound"
$name = [System.Guid]::NewGuid().ToString()
$tempFile = "$env:TEMP\$name.mp4"

try {
    # Скачивание
    Invoke-WebRequest -Uri $url -OutFile $tempFile -ErrorAction Stop

    # XAML Код окна
    $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        WindowStyle="None" WindowState="Maximized" Topmost="True" 
        Background="Black" Cursor="None" ShowInTaskbar="False">
    <Grid><MediaElement Name="v" Source="$tempFile" LoadedBehavior="Play" Stretch="Uniform" /></Grid>
</Window>
"@
    
    # Запуск окна
    $reader = New-Object System.Xml.XmlNodeReader ([xml]$xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
    $player = $window.FindName("v")

    # Автозакрытие по окончании
    $player.add_MediaEnded({ $window.Close() })
    
    # Защита от закрытия (Alt+F4)
    $window.Add_Closing({ $_.Cancel = $true })

    $window.ShowDialog() | Out-Null
}
catch {
    # Если произошла любая ошибка (нет видео, нет инета), скрипт просто тихо закроется
    exit
}
finally {
    # Удаление файла в любом случае
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
}

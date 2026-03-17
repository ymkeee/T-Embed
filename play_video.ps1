# 1. Скрываем консоль PowerShell (без ошибок WindowStyle)
try {
    $code = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
    $winApi = Add-Type -MemberDefinition $code -Name "Win32ShowWindow" -Namespace "Win32" -PassThru
    $winApi::ShowWindow((Get-Process -Id $pid).MainWindowHandle, 0)
} catch {
    # Если не удалось скрыть системно, продолжаем тихо
}

# 2. Настройка протоколов и библиотек
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# 3. Ссылки и пути (Используем GUID для уникальности имени)
$url = 'https://raw.githubusercontent.com/ymkeee/T-Embed/main/assets/edit.mp4'
$tempFile = "$env:TEMP\$([System.Guid]::NewGuid().ToString()).mp4"

try {
    # 4. Скачивание видео
    Invoke-WebRequest -Uri $url -OutFile $tempFile -ErrorAction Stop

    # 5. XAML-интерфейс (Плеер)
    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        WindowStyle="None" WindowState="Maximized" Topmost="True" 
        Background="Black" Cursor="None" ShowInTaskbar="False">
    <Grid>
        <MediaElement Name="videoPlayer" 
                      Source="$tempFile" 
                      LoadedBehavior="Play" 
                      Stretch="Uniform" />
    </Grid>
</Window>
"@

    # Загрузка окна
    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [Windows.Markup.XamlReader]::Load($reader)
    $player = $window.FindName("videoPlayer")

    # События: закрыть окно, когда видео закончится
    $player.add_MediaEnded({
        $window.Close()
    })

    # Защита: нельзя закрыть на Alt+F4
    $window.Add_Closing({
        $_.Cancel = $true
    })

    # Показ окна
    $window.ShowDialog() | Out-Null

} catch {
    # Если видео не найдено (404) или нет интернета — скрипт просто завершится
} finally {
    # 6. ГАРАНТИРОВАННОЕ УДАЛЕНИЕ СЛЕДОВ
    Start-Sleep -Seconds 2
    if (Test-Path $tempFile) {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}

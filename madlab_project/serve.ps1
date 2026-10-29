$port = 8080
$webDir = Join-Path $PSScriptRoot "build\web"
if (-not (Test-Path $webDir)) {
    Write-Host "Error: build\web folder not found!" -ForegroundColor Red
    exit 1
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Prefixes.Add("http://127.0.0.1:$port/")

try {
    $listener.Start()
} catch {
    Write-Host "Could not start server on port $port: $_" -ForegroundColor Red
    exit 1
}

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "ClubSpace server running at http://localhost:$port" -ForegroundColor Green
Write-Host "Press Ctrl+C in this window to stop the server." -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Cyan

$mimeMap = @{
    ".html" = "text/html; charset=utf-8"
    ".js"   = "application/javascript"
    ".mjs"  = "application/javascript"
    ".json" = "application/json"
    ".css"  = "text/css"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".wasm" = "application/wasm"
    ".ttf"  = "font/ttf"
    ".woff" = "font/woff"
    ".woff2"= "font/woff2"
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $relPath = $request.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrWhiteSpace($relPath)) { $relPath = "index.html" }
        
        $filePath = Join-Path $webDir $relPath
        if (-not (Test-Path $filePath -PathType Leaf)) {
            $filePath = Join-Path $webDir "index.html"
        }

        $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
        $contentType = $mimeMap[$ext]
        if (-not $contentType) { $contentType = "application/octet-stream" }

        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentType = $contentType
        $response.ContentLength64 = $bytes.Length
        $response.AddHeader("Access-Control-Allow-Origin", "*")
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
        $response.Close()
    } catch {
        # continue loop
    }
}

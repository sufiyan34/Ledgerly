$jsonPath = "C:\Users\Admin\.gemini\antigravity-ide\brain\8a7dbbed-4b7f-4c54-9a12-fc369bd5e1a4\.system_generated\steps\17\output.txt"
$outDir = "e:\ledgerly\stitch_assets"

# Create directories
New-Item -ItemType Directory -Force "$outDir\images" | Out-Null
New-Item -ItemType Directory -Force "$outDir\code" | Out-Null

function Get-SanitizedName ($title) {
    $name = $title.ToLower()
    $name = $name -replace ' & ', '_'
    $name = $name -replace ' / ', '_'
    $name = $name -replace '[^a-z0-9]', '_'
    $name = $name -replace '_+', '_'
    $name = $name.Trim('_')
    return $name
}

if (Test-Path $jsonPath) {
    $json = Get-Content -Raw $jsonPath | ConvertFrom-Json
    foreach ($screen in $json.screens) {
        $title = $screen.title
        $sanitized = Get-SanitizedName $title
        Write-Host "Downloading $title as $sanitized..."

        $imgUrl = $screen.screenshot.downloadUrl
        $codeUrl = $screen.htmlCode.downloadUrl

        $imgFile = "$outDir\images\$sanitized.png"
        $codeFile = "$outDir\code\$sanitized.html"

        # Download screenshot
        if ($imgUrl) {
            Write-Host "  -> Image..."
            curl.exe -L -o $imgFile $imgUrl
        }

        # Download HTML code
        if ($codeUrl) {
            Write-Host "  -> Code..."
            curl.exe -L -o $codeFile $codeUrl
        }
    }
    Write-Host "All downloads complete."
} else {
    Write-Error "JSON file not found at $jsonPath"
}

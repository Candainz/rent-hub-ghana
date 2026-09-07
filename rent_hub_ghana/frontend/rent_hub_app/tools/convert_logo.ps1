# Convert assets/logo.svg to assets/icon.png using ImageMagick
# Requires ImageMagick `magick` on PATH (Windows)
# Usage: .\convert_logo.ps1

$svg = "assets/logo.svg"
$png = "assets/icon.png"

if (-not (Test-Path $svg)) {
  Write-Error "Source SVG not found: $svg"
  exit 1
}

$magick = Get-Command magick -ErrorAction SilentlyContinue
if (-not $magick) {
  Write-Host "ImageMagick 'magick' not found on PATH."
  Write-Host "Install ImageMagick or convert the SVG to a 1024x1024 PNG and place it at assets/icon.png"
  exit 1
}

Write-Host "Converting $svg -> $png (1024x1024)..."
magick convert -background none -resize 1024x1024 "$svg" "$png"
if (Test-Path $png) {
  Write-Host "Created $png"
} else {
  Write-Error "Failed to create $png"
  exit 1
}

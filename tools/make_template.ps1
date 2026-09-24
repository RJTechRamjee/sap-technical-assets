<#
.SYNOPSIS
  Regenerate tools/coe-template.pptx from the corporate .thmx theme.

.DESCRIPTION
  build_deck.py starts every deck from tools/coe-template.pptx so it inherits the
  corporate slide master - logo, footer, slide numbers - without needing
  PowerPoint at build time. That .pptx is committed.

  python-pptx cannot open a .thmx, so this script does the one-off conversion
  using PowerPoint COM. Run it only when the theme file changes.

  Note: only the COLOURS are adopted from the theme. build_deck.py deliberately
  keeps Segoe UI as the typeface - the theme's Graphik is wider and overflows the
  fixed title geometry.

.EXAMPLE
  pwsh tools/make_template.ps1
  pwsh tools/make_template.ps1 -Thmx "docs/coe-sessions/decks/Acn Theme.thmx"
#>
param(
  [string]$Thmx = "docs/coe-sessions/decks/Acn Theme.thmx",
  [string]$Out  = "tools/coe-template.pptx"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Thmx)) { throw "Theme not found: $Thmx" }
$thmxPath = (Resolve-Path $Thmx).Path
$outPath  = Join-Path (Get-Location) $Out

Remove-Item $outPath -ErrorAction SilentlyContinue

$pp = New-Object -ComObject PowerPoint.Application
try {
  $pres = $pp.Presentations.Add()
  $pres.ApplyTemplate($thmxPath)
  $pres.SaveAs($outPath, 24)   # 24 = ppSaveAsOpenXMLPresentation
  "Wrote $Out - {0} layouts, {1} slides" -f `
    $pres.Designs(1).SlideMaster.CustomLayouts.Count, $pres.Slides.Count
  $pres.Close()
} finally {
  $pp.Quit()
  [void][Runtime.InteropServices.Marshal]::ReleaseComObject($pp)
}

# build_deck.py looks for a layout literally named "Blank". Fail loudly here
# rather than silently falling back to an unbranded master at build time.
python -c @"
from pptx import Presentation
p = Presentation(r'$Out')
names = [l.name.strip().lower() for l in p.slide_layouts]
assert 'blank' in names, 'no layout named Blank in the generated template'
print('OK - Blank layout present, canvas %.3f x %.1f in' % (p.slide_width/914400, p.slide_height/914400))
"@

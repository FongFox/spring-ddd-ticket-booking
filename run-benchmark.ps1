# =============================================================
# run-benchmark.ps1 - k6 Load Test Runner for vetautet.com
# Usage: .\run-benchmark.ps1 [-Mode <mode>] [-Target <target>]
#
# Modes:
#   quick   - 50 VUs x 5s   (smoke test)
#   normal  - 50 VUs x 30s  (standard benchmark)
#   heavy   - 200 VUs x 30s (stress test)
#
# Targets:
#   local   - http://localhost:1122
#   prod    - https://spring-ddd-ticket-booking.onrender.com
# =============================================================

param(
    [ValidateSet("quick", "normal", "heavy")]
    [string]$Mode = "normal",

    [ValidateSet("local", "prod")]
    [string]$Target = "local"
)

# ---- Config --------------------------------------------------
$LOCAL_URL = "http://localhost:1122"
$PROD_URL  = "https://spring-ddd-ticket-booking.onrender.com"
$ENDPOINT  = "/ticket/1/detail/1"

$MODES = @{
    quick  = @{ vus = 50;  duration = "5s"  }
    normal = @{ vus = 50;  duration = "30s" }
    heavy  = @{ vus = 200; duration = "30s" }
}

# ---- Resolve target URL --------------------------------------
$BASE_URL = if ($Target -eq "prod") { $PROD_URL } else { $LOCAL_URL }
$FULL_URL = "$BASE_URL$ENDPOINT"
$VUS      = $MODES[$Mode].vus
$DURATION = $MODES[$Mode].duration

# ---- Output file ---------------------------------------------
$TIMESTAMP   = Get-Date -Format "yyyyMMdd-HHmmss"
$RESULT_FILE = "benchmark\results\result-${Target}-${Mode}-${TIMESTAMP}.txt"
$TEMP_TEST   = "benchmark\_temp_test.js"

New-Item -ItemType Directory -Force -Path "benchmark\results" | Out-Null

# ---- Banner --------------------------------------------------
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  vetautet.com - k6 Load Test"               -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Mode     : $Mode"                          -ForegroundColor Yellow
Write-Host "  Target   : $Target ($FULL_URL)"            -ForegroundColor Yellow
Write-Host "  VUs      : $VUS"                           -ForegroundColor Yellow
Write-Host "  Duration : $DURATION"                      -ForegroundColor Yellow
Write-Host "  Output   : $RESULT_FILE"                   -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# ---- Generate temp test script -------------------------------
$line1 = "import http from 'k6/http';"
$line2 = "export const options = { vus: $VUS, duration: '$DURATION' };"
$line3 = "export default function () {"
$line4 = "    http.get('$FULL_URL');"
$line5 = "}"

Set-Content -Path $TEMP_TEST -Value $line1 -Encoding UTF8
Add-Content -Path $TEMP_TEST -Value $line2 -Encoding UTF8
Add-Content -Path $TEMP_TEST -Value $line3 -Encoding UTF8
Add-Content -Path $TEMP_TEST -Value $line4 -Encoding UTF8
Add-Content -Path $TEMP_TEST -Value $line5 -Encoding UTF8

# ---- Run k6 --------------------------------------------------
k6 run $TEMP_TEST 2>&1 | Tee-Object -FilePath $RESULT_FILE

# ---- Cleanup -------------------------------------------------
Remove-Item $TEMP_TEST -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Result saved: $RESULT_FILE" -ForegroundColor Green
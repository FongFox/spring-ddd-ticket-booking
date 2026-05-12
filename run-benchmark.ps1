# =============================================================
# run-benchmark.ps1 - k6 Load Test Runner for vetautet.com
# Usage: .\run-benchmark.ps1 [-Mode <mode>] [-Target <target>]
#
# Modes:
#   quick   - 50 VUs x 5s              (smoke test)
#   normal  - 50 VUs x 30s             (standard benchmark)
#   heavy   - 200 VUs x 30s            (stress test)
#   extreme - 2000 VUs x 2m with ramp  (wrk-equivalent stress test)
#
# Targets:
#   local   - http://localhost:1122
#   prod    - https://spring-ddd-ticket-booking.onrender.com
# =============================================================

param(
    [ValidateSet("quick", "normal", "heavy", "extreme")]
    [string]$Mode = "normal",

    [ValidateSet("local", "prod")]
    [string]$Target = "local"
)

# ---- Config --------------------------------------------------
$LOCAL_URL = "http://localhost:1122"
$PROD_URL  = "https://spring-ddd-ticket-booking.onrender.com"
$ENDPOINT  = "/ticket/1/detail/1"

$MODES = @{
    quick   = @{ vus = 50;   duration = "5s"  }
    normal  = @{ vus = 50;   duration = "30s" }
    heavy   = @{ vus = 200;  duration = "30s" }
    extreme = @{ vus = 2000; duration = "2m"  }
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
if ($Mode -eq "extreme") {
    # Extreme mode dung stages de ramp-up dan thay vi spike 2000 VUs cung luc
    # Tranh "connection refused" do OS/Tomcat bi overwhelmed ngay tu dau
    # Giai doan: ramp-up 30s -> sustain 1m -> ramp-down 30s
    $k6Script = @"
import http from 'k6/http';

export const options = {
  stages: [
    { duration: '30s', target: 2000 }, // ramp-up: tang dan len 2000 VUs
    { duration: '1m',  target: 2000 }, // sustain: giu 2000 VUs trong 1 phut
    { duration: '30s', target: 0 },    // ramp-down: giam dan ve 0
  ],
};

export default function () {
    http.get('$FULL_URL');
}
"@
} else {
    # Cac mode khac: flat load don gian
    $k6Script = @"
import http from 'k6/http';

export const options = { vus: $VUS, duration: '$DURATION' };

export default function () {
    http.get('$FULL_URL');
}
"@
}

Set-Content -Path $TEMP_TEST -Value $k6Script -Encoding UTF8

# ---- Run k6 --------------------------------------------------
k6 run $TEMP_TEST 2>&1 | Tee-Object -FilePath $RESULT_FILE

# ---- Cleanup -------------------------------------------------
Remove-Item $TEMP_TEST -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Result saved: $RESULT_FILE" -ForegroundColor Green
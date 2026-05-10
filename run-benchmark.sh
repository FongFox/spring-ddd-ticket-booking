#!/bin/bash
# =============================================================
# run-benchmark.sh — k6 Load Test Runner for vetautet.com
# Usage: ./run-benchmark.sh [mode] [target]
#
# Modes:
#   quick   — 50 VUs x 5s   (smoke test)
#   normal  — 50 VUs x 30s  (standard benchmark)
#   heavy   — 200 VUs x 30s (stress test)
#
# Targets:
#   local   — http://localhost:1122
#   prod    — https://spring-ddd-ticket-booking.onrender.com
# =============================================================

MODE="${1:-normal}"
TARGET="${2:-local}"

# ---- Config --------------------------------------------------
LOCAL_URL="http://localhost:1122"
PROD_URL="https://spring-ddd-ticket-booking.onrender.com"
ENDPOINT="/ticket/1/detail/1"

# ---- Resolve mode --------------------------------------------
case $MODE in
  quick)  VUS=50;  DURATION="5s"  ;;
  normal) VUS=50;  DURATION="30s" ;;
  heavy)  VUS=200; DURATION="30s" ;;
  *)
    echo "Invalid mode: $MODE. Use: quick | normal | heavy"
    exit 1
    ;;
esac

# ---- Resolve target ------------------------------------------
case $TARGET in
  local) BASE_URL=$LOCAL_URL ;;
  prod)  BASE_URL=$PROD_URL  ;;
  *)
    echo "Invalid target: $TARGET. Use: local | prod"
    exit 1
    ;;
esac

FULL_URL="${BASE_URL}${ENDPOINT}"

# ---- Output file ---------------------------------------------
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
RESULT_FILE="benchmark/results/result-${TARGET}-${MODE}-${TIMESTAMP}.txt"
mkdir -p benchmark/results

# ---- Banner --------------------------------------------------
echo ""
echo "============================================="
echo "  vetautet.com — k6 Load Test"
echo "============================================="
echo "  Mode     : $MODE"
echo "  Target   : $TARGET ($FULL_URL)"
echo "  VUs      : $VUS"
echo "  Duration : $DURATION"
echo "  Output   : $RESULT_FILE"
echo "============================================="
echo ""

# ---- Generate temp test script -------------------------------
TEMP_TEST="benchmark/_temp_test.js"
cat > $TEMP_TEST <<EOF
import http from 'k6/http';
export const options = { vus: $VUS, duration: '$DURATION' };
export default function () {
    http.get('$FULL_URL');
}
EOF

# ---- Run k6 --------------------------------------------------
k6 run $TEMP_TEST 2>&1 | tee $RESULT_FILE

# ---- Cleanup -------------------------------------------------
rm -f $TEMP_TEST

echo ""
echo "Result saved: $RESULT_FILE"
#!/bin/bash
# =============================================================
# run-benchmark.sh — k6 Load Test Runner for vetautet.com
# Usage: ./run-benchmark.sh [mode] [target]
#
# Modes:
#   quick   — 50 VUs x 5s              (smoke test)
#   normal  — 50 VUs x 30s             (standard benchmark)
#   heavy   — 200 VUs x 30s            (stress test)
#   extreme — 2000 VUs x 2m with ramp  (wrk-equivalent stress test)
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
  quick)   VUS=50;   DURATION="5s"  ;;
  normal)  VUS=50;   DURATION="30s" ;;
  heavy)   VUS=200;  DURATION="30s" ;;
  extreme) VUS=2000; DURATION="2m"  ;;
  *)
    echo "Invalid mode: $MODE. Use: quick | normal | heavy | extreme"
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

if [ "$MODE" = "extreme" ]; then
    # Extreme mode dung stages de ramp-up dan thay vi spike 2000 VUs cung luc
    # Tranh "connection refused" do OS/Tomcat bi overwhelmed ngay tu dau
    # Giai doan: ramp-up 30s -> sustain 1m -> ramp-down 30s
    cat > $TEMP_TEST <<EOF
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
EOF
else
    # Cac mode khac: flat load don gian
    cat > $TEMP_TEST <<EOF
import http from 'k6/http';

export const options = { vus: $VUS, duration: '$DURATION' };

export default function () {
    http.get('$FULL_URL');
}
EOF
fi

# ---- Run k6 --------------------------------------------------
k6 run $TEMP_TEST 2>&1 | tee $RESULT_FILE

# ---- Cleanup -------------------------------------------------
rm -f $TEMP_TEST

echo ""
echo "Result saved: $RESULT_FILE"
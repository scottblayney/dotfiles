#!/usr/bin/env bash
# Monitor brightness over DDC/CI for waybar.
# Usage: brightness.sh            print JSON for the custom module
#        brightness.sh up|down    change brightness by STEP, then refresh waybar
#        brightness.sh cycle      step down through 100/75/50/25/0%, wrapping to 100%
#        brightness.sh cycle-up   step up through 0/25/50/75/100%, wrapping to 0%

BUS=1
STEP=5
SIGNAL=8
LOCK="${XDG_RUNTIME_DIR:-/tmp}/waybar-brightness.lock"

case "$1" in
    up|down)
        [ "$1" = up ] && op=+ || op=-
        # Serialize DDC writes so fast scrolling doesn't collide on the bus
        flock "$LOCK" ddcutil --bus "$BUS" --noverify setvcp 10 "$op" "$STEP"
        pkill -RTMIN+"$SIGNAL" waybar
        ;;
    cycle|cycle-up)
        (
            flock 9
            read -r _ _ _ cur max < <(ddcutil --bus "$BUS" getvcp 10 --brief)
            [ -z "$max" ] && exit 0
            pct=$(( cur * 100 / max ))
            if [ "$1" = cycle ]; then
                # Next 25% preset below the current level; from 0% wrap back to 100%
                if [ "$pct" -le 0 ]; then next=100; else next=$(( (pct - 1) / 25 * 25 )); fi
            else
                # Next 25% preset above the current level; from 100% wrap back to 0%
                if [ "$pct" -ge 100 ]; then next=0; else next=$(( (pct / 25 + 1) * 25 )); fi
            fi
            ddcutil --bus "$BUS" --noverify setvcp 10 $(( next * max / 100 ))
        ) 9>"$LOCK"
        pkill -RTMIN+"$SIGNAL" waybar
        ;;
    *)
        read -r _ _ _ cur max < <(flock "$LOCK" ddcutil --bus "$BUS" getvcp 10 --brief)
        if [ -z "$max" ]; then
            echo '{"text": "N/A", "tooltip": "ddcutil: monitor not responding"}'
            exit 0
        fi
        pct=$(( cur * 100 / max ))
        printf '{"text": "%s%%", "percentage": %s, "tooltip": "Brightness %s%%"}\n' "$pct" "$pct" "$pct"
        ;;
esac

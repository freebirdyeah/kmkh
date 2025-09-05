#!/bin/bash

# ----------------------------
# HELP FUNCTION
# ----------------------------
show_help() {
    echo "Usage: kmkh [OPTIONS]"
    echo
    echo "Options:"
    echo "  --current       Show the current meal or the next upcoming meal (default)"
    echo "  --next          Show the next upcoming meal"
    echo "  --breakfast     Show today's breakfast only"
    echo "  --lunch         Show today's lunch only"
    echo "  --snacks        Show today's snacks only"
    echo "  --dinner        Show today's dinner only"
    echo "  -h, --help      Show this help message and exit"
    echo
    echo "Example:"
    echo "  kmkh --next       # Shows the next meal from current time"
}

# ----------------------------
# PARSE ARGUMENTS
# ----------------------------
FLAG="--current"
SPECIFIC_MEAL=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --next) FLAG="--next"; shift ;;
        --current) FLAG="--current"; shift ;;
        --breakfast|--lunch|--snacks|--dinner)
            SPECIFIC_MEAL="${1/--/}"; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

# ----------------------------
# CHECK DEPENDENCIES
# ----------------------------
if ! command -v jq &> /dev/null; then
    echo "jq is required. Install it first."
    exit 1
fi

# ----------------------------
# GET TODAY'S MENU
# ----------------------------
TODAY=$(date +%F)
CURRENT_TIME=$(date +%H:%M)
WEEKDAY=$(date +%u)
WEEK_START=$(date -d "$TODAY - $((WEEKDAY - 1)) days" +%F)
WEEK_END=$(date -d "$WEEK_START + 6 days" +%F)
WEEK_LABEL=$(date -d "$WEEK_START" '+%B %-d')"-"$(date -d "$WEEK_END" '+%e, %Y' | sed 's/^ //')
WEEK_LABEL_ENC=$(echo "$WEEK_LABEL" | sed 's/ /%20/g; s/,/%2C/g')

MENU=$(curl -s "https://tikm.coolstuff.work/api/menu?week=$WEEK_LABEL_ENC&weekStart=$WEEK_START&date=$TODAY" | jq -r ".menu.\"$TODAY\"")

# ----------------------------
# PARSE MEALS
# ----------------------------
MEALS=("breakfast" "lunch" "snacks" "dinner")

# If a specific meal is requested, only consider that one
if [[ -n "$SPECIFIC_MEAL" ]]; then
    MEALS=("$SPECIFIC_MEAL")
fi

CURRENT_FOUND=0
NEXT_FOUND=0
NEXT_MEAL=""
CUR_SEC=$(date -d "$CURRENT_TIME" +%s)

for meal in "${MEALS[@]}"; do
    START=$(echo "$MENU" | jq -r ".meals.\"$meal\".startTime")
    END=$(echo "$MENU" | jq -r ".meals.\"$meal\".endTime")
    
    START_SEC=$(date -d "$START" +%s)
    END_SEC=$(date -d "$END" +%s)
    
    # Check current meal
    if [[ $CUR_SEC -ge $START_SEC && $CUR_SEC -le $END_SEC && "$FLAG" == "--current" ]]; then
        CURRENT_FOUND=1
        SELECTED_MEAL="$meal"
        break
    fi
    
    # Track next meal if current time is before it
    if [[ $CUR_SEC -lt $START_SEC && $NEXT_FOUND -eq 0 ]]; then
        NEXT_FOUND=1
        NEXT_MEAL="$meal"
    fi
done

# ----------------------------
# DISPLAY LOGIC
# ----------------------------
MEAL=""
STATUS=""

if [[ $CURRENT_FOUND -eq 1 ]]; then
    MEAL="$SELECTED_MEAL"
    STATUS="current"
elif [[ $NEXT_FOUND -eq 1 ]]; then
    MEAL="$NEXT_MEAL"
    STATUS="upcoming"
else
    # If no next meal, pick the last meal of the day
    if [[ -n "$SPECIFIC_MEAL" ]]; then
        MEAL="$SPECIFIC_MEAL"
    else
        MEAL="dinner"
    fi
    STATUS="done"
fi

NAME=$(echo "$MENU" | jq -r ".meals.\"$MEAL\".name")
START=$(echo "$MENU" | jq -r ".meals.\"$MEAL\".startTime")
END=$(echo "$MENU" | jq -r ".meals.\"$MEAL\".endTime")
ITEMS=$(echo "$MENU" | jq -r ".meals.\"$MEAL\".items[]" | sed 's/^/  - /')

if [[ "$STATUS" == "done" ]]; then
    echo "Hogya $MEAL bhukkad :P"
    echo "Meal: $NAME"
    echo "Time: $START - $END"
    echo "Items:"
    echo "$ITEMS"
elif [[ "$STATUS" == "current" ]]; then
    echo "Meal happening now: $NAME"
    echo "Time: $START - $END"
    echo "Items:"
    echo "$ITEMS"
else
    echo "Next meal: $NAME"
    echo "Time: $START - $END"
    echo "Items:"
    echo "$ITEMS"
fi

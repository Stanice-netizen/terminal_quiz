#!/bin/bash

QUESTIONS_FILE="questions.txt"    
SCORES_FILE="Highscores"         
MAX_QUESTIONS=15                 
PASS_PERCENT=50 

mode_arg=$(echo "$1" | tr '[:upper:]' '[:lower:]')

if [ "$mode_arg" = "highscores" ]; then
  clear
  echo "TOP 5 HIGHSCORES: "
  echo "=========================================================="
  tail -n +2 "$SCORES_FILE" \
    | sort -t',' -k2 -rn \
    | head -5 \
    | awk -F',' '{
        rank = NR "."
        printf "  %-5s %-20s %-8s %-6s %s\n", rank, $1, $2"/"$3, $4, $5
    }'
  exit 0

elif [ "$mode_arg" = "practice" ]; then
    PRACTICE="true"
    echo "  Practice mode -- the correct answer will always be shown."
else
    PRACTICE="false"
    echo "  Normal mode "
fi  

if [ ! -f "$QUESTIONS_FILE" ]; then
    echo "Error: '$QUESTIONS_FILE' was not found."
    echo "Make sure questions.txt is in the same folder as quiz.sh"
    exit 1
fi

total_available=$(wc -l < "$QUESTIONS_FILE")

if [ "$total_available" -lt "$MAX_QUESTIONS" ]; then
    echo "Note: only $total_available questions found."
    echo "The quiz will use all $total_available questions."
    MAX_QUESTIONS=$total_available
fi

if [ "$MAX_QUESTIONS" -eq 0 ]; then
    echo "Error: no questions found in '$QUESTIONS_FILE'."
    exit 1
fi

mapfile -t QUESTIONS < <(sort -R "$QUESTIONS_FILE" | head -n "$MAX_QUESTIONS")

if [ ! -f "$SCORES_FILE" ]; then
    echo "name,Score,MaxScore,Percentage,Date" > "$SCORES_FILE"
fi

clear

echo "======================================================"
echo "              Welcome to the Terminal Quiz!           "
echo "======================================================"
echo ""
echo "  Questions : $MAX_QUESTIONS"
echo "  Pass mark : $PASS_PERCENT%"
echo ""
echo "======================================================="
echo ""
echo -n " Enter Player name: "
read -r name 

if [ -z "$name" ]; then
    name="Anonymous"
fi

echo ""
echo ""

score=0    
q_num=0   
current_streak=0
longest_streak=0 

for raw_line in "${QUESTIONS[@]}"; do

    q_num=$((q_num + 1))
    

    IFS='|' read -r question ans1 ans2 ans3 ans4 correct_letter <<< "$raw_line"


    correct_letter=$(echo "$correct_letter" | tr -d ' ' | tr '[:lower:]' '[:upper:]')

    clear
  if [ "$PRACTICE" = "true" ]; then
    echo "  Mode       : Practice"
  else
    echo "  Mode       : Normal"
  fi

    echo "======================================================"
    echo "  Question $q_num of $MAX_QUESTIONS   |   Score: $score"
    echo "======================================================"
    echo ""
    echo "  $question"
    echo ""
    echo "  $ans1"
    echo "  $ans2"
    echo "  $ans3"
    echo "  $ans4"
    echo ""
    echo "------------------------------------------------------"

    player_answer=""   

    while true; do
        echo -n " choose answer from A-D: "
        read -r player_answer

        player_answer=$(echo "$player_answer" | tr -d ' ' | tr '[:lower:]' '[:upper:]')

        # Check if the answer is one of the four valid letters
        if [ "$player_answer" = "A" ] || [ "$player_answer" = "B" ] || \
           [ "$player_answer" = "C" ] || [ "$player_answer" = "D" ]; then
            break  
        fi

        echo "  Please enter A, B, C or D."
    done

    if [ "$correct_letter" = "A" ]; then
        correct_text="$ans1"
    fi
    if [ "$correct_letter" = "B" ]; then
        correct_text="$ans2"
    fi
    if [ "$correct_letter" = "C" ]; then
        correct_text="$ans3"
    fi
    if [ "$correct_letter" = "D" ]; then
        correct_text="$ans4"
    fi

    echo ""

    if [ "$player_answer" = "$correct_letter" ]; then
        score=$((score + 1))
        echo "  >>> CORRECT! Well done."
        current_streak=$((current_streak + 1))
        if [ "$current_streak" -gt "$longest_streak" ]; then
            longest_streak=$current_streak
        fi

        if [ "$PRACTICE" = "true" ]; then
            echo "  The correct answer was: $correct_text"
        fi

    else
        current_streak=0
        echo "  >>> WRONG!"
        echo "  The correct answer was: $correct_text"

    fi

    echo ""
    if [ "$q_num" -lt "$MAX_QUESTIONS" ]; then
        echo -n "  Press Enter for the next question..."
        read  -r _discard
    fi

done  


incorrect=$((MAX_QUESTIONS - score))
percentage=$((score * 100 / MAX_QUESTIONS))
date=$(date '+%Y-%m-%d %H:%M')

clear

echo "======================================================"
echo "                   QUIZ COMPLETE!                     "
echo "======================================================"
echo ""
echo "  Player     : $name"

# Print the mode name depending on the value of PRACTICE
if [ "$PRACTICE" = "true" ]; then
    echo "  Mode       : Practice"
else
    echo "  Mode       : Normal"
fi

echo "  Correct    :$score out of $MAX_QUESTIONS"
echo "  Incorrect  : $incorrect"
echo "  Percentage score : $percentage%"
echo "  Longest streak : $longest_streak"
echo "  Date       : $date"
echo ""
if [ "$percentage" -ge "$PASS_PERCENT" ]; then
    echo "  PASSED! Congratulations "
 else
    echo "  FAILED. Better luck next time!"
fi

echo ""
echo "------------------------------------------------------"

if [ "$PRACTICE" = "false" ]; then
echo "$name,$score,$MAX_QUESTIONS,$percentage%,$date"  >> "$SCORES_FILE"

echo "  Score saved to $SCORES_FILE"
echo ""

echo "  --- TOP 5 SCORES ---"
echo ""
echo "  Rank  Name                 Score    Pct    Date"
echo "  ----  -------------------  -------  -----  ----------------"

tail -n +2 "$SCORES_FILE" \
    | sort -t',' -k2 -rn \
    | head -5 \
    | awk -F',' '{
        rank = NR "."
        printf "  %-5s %-20s %-8s %-6s %s\n", rank, $1, $2"/"$3, $4, $5
    }'

echo ""
echo "======================================================"
echo ""

else
 echo "End of Practice"
fi
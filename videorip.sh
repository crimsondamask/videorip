#!/bin/bash

[ ! -f "$2" ] && printf "USAGE:\n./videorip VIDEO TIMESTAMPS" && exit 

file="$1"
timestamps="$2"
filename=$(basename -- "$file")
ext="${filename##*.}"
filename=${filename%.*}
mkdir -p output
#linecount=$(wc -l $2 | tr -s ' ' | cut -d ' ' -f 1)
echo $linecount
START="00:00:00"
COUNT=1
while read -r line 
do
    TIME=$(echo $line | tr -s ' ' | cut -d ' ' -f 1)
    word=$(echo $line | tr -s ' ' | cut -d ' ' -f 2)
    title="${filename}${COUNT}-${word}"
    echo "Slicing from $START to $TIME ====> $title"
    ffmpeg -nostdin -y -loglevel -8 -i $1 -ss "$START" -c copy -to "$TIME" -vn "output/$title.$ext" &&
    COUNT=$((COUNT+1))
    START=$TIME
done < "$2"


title="${filename}${COUNT}-${word}"

echo "Slicing from $START to end of file $title"
ffmpeg -nostdin -y -loglevel -8 -i $1 -ss "$START" -c copy -vn "output/$title.$ext" &&
echo "Done! $COUNT files created"



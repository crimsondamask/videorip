#!/bin/bash

[ ! -f "$2" ] && printf "USAGE:\n./videorip VIDEO TIMESTAMPS" && exit 

file="$1"
timestamps="$2"
filename=$(basename -- "$file")
ext="${filename##*.}"
filename=${filename%.*}
safename="$(echo $filename | iconv -cf UTF-8 -t ASCII//TRANSLIT | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed "s/-\+/-/g;s/\(^-\|-\$\)//g")"

mkdir -p output
linecount="$(wc -l $2 | tr -s ' ' | cut -d ' ' -f 1)"
echo $linecount
START="00:00:00"
COUNT=0

stamps=();
sections=();
while read -r line;
do
    TIME=$(echo $line | tr -s ' ' | cut -d ' ' -f 1)
    word=$(echo $line | tr -s ' ' | cut -d ' ' -f 2)
    sections+=("${word}")
    stamps+=("${TIME}")
done < "$2"
echo "${stamps[@]}"
echo "${sections[@]}"

for ((i = 1 ; i < $linecount; i++))
do
#    TIME=$(echo $line | tr -s ' ' | cut -d ' ' -f 1)
#    word=$(echo $line | tr -s ' ' | cut -d ' ' -f 2)
    title="${safename}${COUNT}-${sections[$COUNT]}"
    echo "Slicing from ${stamps[${COUNT}]} to ${stamps[$(( COUNT + 1 ))]} ====> $title"
    ffmpeg -nostdin -y -loglevel -8 -i $1 -ss "${stamps[$COUNT]}" -c copy -to "${stamps[$(( COUNT +1 ))]}" -vn "output/$title.$ext" &&
    COUNT=$((COUNT+1))
#    START=$TIME
done
#
#
title="${safename}${COUNT}-${sections[$COUNT]}"

echo "Slicing from ${stamps[${COUNT}]} to the end of the file ====> $title"

ffmpeg -nostdin -y -loglevel -8 -i $1 -ss "${stamps[$COUNT]}" -c copy -vn "output/$title.$ext" &&
#
#echo "Slicing from $START to end of file $title"
#ffmpeg -nostdin -y -loglevel -8 -i $1 -ss "$START" -c copy -vn "output/$title.$ext" &&
echo "Done! $(( COUNT + 1 )) files created"

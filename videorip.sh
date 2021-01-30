#!/bin/bash

[ ! -f "$2" ] && printf "USAGE:\n./videorip VIDEO TIMESTAMPS" && exit 

#Parsing arguments and cleaning the filename

file="$1"
timestamps="$2"
filename=$(basename -- "$file")
ext="${filename##*.}"
filename=${filename%.*}
safename="$(echo $filename | iconv -cf UTF-8 -t ASCII//TRANSLIT | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed "s/-\+/-/g;s/\(^-\|-\$\)//g")"

#creating a directory for output files
directory="$safename"
mkdir -p $directory

#Getting the total number of lines to control the loop

linecount="$(wc -l $2 | tr -s ' ' | cut -d ' ' -f 1)"
echo "$linecount sections found."

COUNT=0

stamps=();
sections=();

#Parsing the timestamps from the text file

while read -r line;
do
    TIME=$(echo $line | tr -s ' ' | cut -d ' ' -f 1)
    word=$(echo $line | tr -s ' ' | cut -d ' ' -f 2)
    sections+=("${word}")
    stamps+=("${TIME}")
done < "$2"
echo "${stamps[@]}"
echo "${sections[@]}"

#Kicking the tires with the main loop

for ((i = 1 ; i < $linecount; i++))
do
    title="${safename}${COUNT}-${sections[$COUNT]}"
    echo "Slicing from ${stamps[${COUNT}]} to ${stamps[$(( COUNT + 1 ))]} ====> $title"
    ffmpeg -nostdin -y -loglevel -8 -i $1 -ss "${stamps[$COUNT]}" -c copy -to "${stamps[$(( COUNT +1 ))]}" -vn "$directory/$title.$ext" &&
    COUNT=$((COUNT+1))
done

#The last slice is done outside the loop

title="${safename}${COUNT}-${sections[$COUNT]}"

echo "Slicing from ${stamps[${COUNT}]} to the end of the file ====> $title"

ffmpeg -nostdin -y -loglevel -8 -i $1 -ss "${stamps[$COUNT]}" -c copy -vn "output/$title.$ext" &&
echo "Done! $(( COUNT + 1 )) files created"

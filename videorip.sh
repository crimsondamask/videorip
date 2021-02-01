#!/bin/bash

[ ! -f "$2" ] && printf "USAGE:\n./videorip VIDEO TIMESTAMPS DELIMITER" && exit 1 
[ ! -f "$1" ] && printf "USAGE:\n./videorip VIDEO TIMESTAMPS DELIMITER" && exit 1 

#Parsing arguments and cleaning the filename

timestamps="$2"
delimiter="$3"
filename=$(basename -- "$1")
ext="${filename##*.}"
#ext="m4a"
filename=${filename%.*}
safename="$(echo $filename | iconv -cf UTF-8 -t ASCII//TRANSLIT | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed "s|\+|-|g;s|\|||g;s|\$||g;s|&||g")"

#creating a directory for output files
directory="$safename"
mkdir -p $directory

#Getting the total number of lines to control the loop

linecount="$( cat $2 | wc -l )"
echo "$linecount sections found."

COUNT=0

stamps=();
sections=();

#Parsing the timestamps from the text file

while read -r line;
do
    TIME=$(echo $line | tr -s ' ' | cut -d ' ' -f 1)

    #Check if the timing is in a H:M:S format
    if [ "$( echo "$TIME" | grep -o ':' | wc -l )" -eq 1 ]
    then
        TIMESAFE=$( date -d "00:$TIME" +"%T" )
    else
        TIMESAFE=$(date -d "$TIME" +"%T")
    fi
    word="$(echo $line | tr -s ' ' | awk -F "$delimiter" '{print $2, $3, $4, $5, $6}' | sed "s|\ ||g;s|\&||g;s|\$||g;s|\#||g;s|\?||g;s|\/||g;s|\|||g")"
    echo $word
    sections+=("${word}")
    stamps+=("${TIMESAFE}")

done < "$2"

#Kicking the tires with the main loop

for ((i = 1 ; i < $linecount; i++))
do
    title="0${COUNT}-${sections[$COUNT]}"
    echo "Slicing from ${stamps[${COUNT}]} to ${stamps[$(( COUNT + 1 ))]} ====> $title"

    #For audio output add the -vn option 
    ffmpeg -nostdin -y -loglevel -8 -i $1 -ss "${stamps[$COUNT]}" -c copy -to "${stamps[$(( COUNT +1 ))]}" "$directory/$title.$ext" &&
    COUNT=$((COUNT+1))
done

#The last slice is done outside the loop

title="0${COUNT}-${sections[$COUNT]}"

echo "Slicing from ${stamps[${COUNT}]} to the end of the file ====> $title"

ffmpeg -nostdin -y -loglevel -8 -i $1 -ss "${stamps[$COUNT]}" -c copy "output/$title.$ext" &&
echo "Done! $(( COUNT + 1 )) files created"

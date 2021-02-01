# videorip
A script written in bash that takes one big video file and slices it up according to timestamps that you provide in a simple textfile.
It can be useful in case you downloaded a long video, say a music album, an interview or an audiobook, and you want to slice it up into different tracks, sections or chapters.
You can find timestamps on youtube's comments or video descriptions, or even make your own.

## Usage
The script takes three arguments. The first is the input video path, the second is the textfile path, and the third is the delimiter .i.e the character that separates the timestamp from the track/chapter name.

```
./videorip.sh path/to/inputvideo.mp4 path/to/textfile.txt "-"
```
In the example above the delimiter is a hyphen "-" 

Reading the textfile is very robust and can handle messed up timestamps like ```0:5:00``` or ```1:00```
And can handle irrigular delimiters, for example:

```
00:00  -  Introduction
05:20 -First chapter
```

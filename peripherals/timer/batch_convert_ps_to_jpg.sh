#!/bin/bash

PATH=${1:-.}  

for image in ${PATH}/*.ps; do
    echo ${image}
    /usr/bin/gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=jpeg -sPAPERSIZE=a4  \
         -r300 \
        "-sOutputFile=${image%.ps}.jpg" "$image"
done
for image in ${PATH}/*.jpg; do
     /usr/bin/convert ${image} -rotate -270 ${image}
done

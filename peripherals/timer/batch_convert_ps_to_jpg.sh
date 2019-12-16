#!/bin/bash

PATH=${1:-.}  

for image in ${PATH}/*.ps; do
    echo ${image}
    /usr/bin/gs -sDEVICE=jpeg -r300 -sPAPERSIZE=a4 -dBATCH -dNOPAUSE \
        "-sOutputFile=${image%.ps}.jpg" "$image"
done

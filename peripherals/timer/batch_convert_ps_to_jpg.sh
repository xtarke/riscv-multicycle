#!/bin/bash

PATH=${1:-.}  

for image in ${PATH}/*.ps; do
    echo ${image}
    /usr/bin/gs -dSAFER -dBATCH -dNOPAUSE -dAutoRotatePages=/None \
        -c "<</Orientation 3>> setpagedevice" \
        -sDEVICE=jpeg -sPAPERSIZE=a4 -r300 \
        "-sOutputFile=${image%.ps}.jpg" "$image"
done

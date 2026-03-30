#!/bin/bash
cd $1
infile=$(basename *.charsets | cut -d . -f 1)
sed 's/charset/DNA,/g' ${infile}.charsets | sed 's/;//g' | sed 's/ = /=/g' | sed "s/'*'//g" | sed '1d; 2d; $d' | grep -v "charpartition" > ${infile}.partitions
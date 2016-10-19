#!/bin/bash
pathName='../../ImagePreprocess/result/zooscanBinary'
extension='png'
txtName='./zooscan/zooscanBinary.txt'

if [ -f $txtName ]; then
	rm $txtName
fi
touch $txtName
classNum=1
for i in $(ls $pathName); do
	if [ ! -d "$pathName/$i" ]; then
		break
	fi
	for j in $(ls $pathName/$i); do
		if [ ${j##*.} == ${extension} ]; then
			printf $pathName/$i/$j'\n' >> $txtName
		fi
	done
done
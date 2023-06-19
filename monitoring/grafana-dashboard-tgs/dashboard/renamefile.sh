#!/bin/bash
IFS=$'\n'
files_to_change=($(find . -name "*_*.json"))

echo "======================================"
for arg in "${files_to_change[@]}" ; do
	new_file=$(echo "$arg" | tr '_' '.')
	echo "oldfile==$arg"
	echo "newfile==$new_file " 
	mv $arg $new_file
done

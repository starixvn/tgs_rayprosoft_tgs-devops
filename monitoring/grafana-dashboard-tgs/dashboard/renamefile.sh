#!/bin/bash
files_to_change=$(find . -name "* *.json") 
for arg in "$files_to_change" ; do
	new_file=$(echo "$arg" | tr ' ' '_' | tr A-Z a-z)
	mv $arg $new_file
done

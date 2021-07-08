#!/bin/bash
#source each file on the cidata iso starting with a number-
for file in `find /mnt/iso -name "[0-9][0-9]-*" -type f | sort -g`; do
	    echo "running file $file"
	    source $file
done
echo "********************************************************************"
echo "********************************************************************"
echo "All done. All scripts in /mnt/iso/xx-* have been executed "
echo "********************************************************************"
echo "********************************************************************"

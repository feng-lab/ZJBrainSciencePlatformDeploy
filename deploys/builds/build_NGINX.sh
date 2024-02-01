#!/bin/bash

echo -e "\033[32m waiting for taring \033[5m...\033[0m\033[0m"

if [ -f target.tar.gz ] 
then
	rm -f target.tar.gz
fi

tar czf target.tar.gz html

export TAG=`md5sum target.tar.gz | awk '{print $1}'`


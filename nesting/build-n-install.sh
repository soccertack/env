#!/bin/sh

if [ -z "$1" ]; then
	read -p "LOCALVERSION? (Don't forget to put a dash):" LV
else
	LV="$1"
fi

time make -j 40 LOCALVERSION=$LV && sudo make modules_install && sudo make install

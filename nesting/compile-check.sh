#!/bin/bash
while true; do 

	./scripts/checkpatch.pl -g HEAD >> checkpatch_result

	./compile-32.sh
	if [ $? != 0 ]; then
		echo "32bit Compile failed"
		exit
	fi

	./compile-64.sh
	if [ $? != 0 ]; then
		echo "64bit Compile failed"
		exit
	fi

	git rebase --continue
	if [ $? != 0 ]; then
		echo "Rebase done"
		exit
	fi
done

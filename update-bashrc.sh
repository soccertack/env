#!/bin/bash

firstLine=`head -n 1 /root/.bashrc`

if [ "$firstLine" == "/usr/bin/zsh" ]; then
	echo "Already updated - zsh"
else
	sed -i '1 i\exit' /root/.bashrc
	sed -i '1 i\/usr/bin/zsh' /root/.bashrc
fi

lastLine=`tail -n 1 /root/.bashrc`

if [ "$lastLine" == "source /root/.mybashrc" ]; then
	echo "Already updated - mybashrc"
else
	echo "source /root/.mybashrc" >> /root/.bashrc
fi

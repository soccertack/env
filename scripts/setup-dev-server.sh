#!/bin/sh

read -r -p "Please add ssh key to github and press Enter" response
branches="v4.18-l3-opt-l0 v4.18-l3-opt-l1-m v4.18-l3-opt-basic"
echo "Setting up branches: $branches"
read -r -p "Quit if you want to. Press enter otherwise" response

cd /tmp/env/scripts
./mkfs-wisc-sdc.sh

cd /sdc
git clone -o jintack git@github.com:soccertack/nested-v2.git vanilla
cd vanilla
git remote add linus https://github.com/torvalds/linux.git

for branch in $branches; do
	cd /sdc
	cp -r vanilla $branch
	cd $branch
	git checkout $branch
done

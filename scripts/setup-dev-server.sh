#!/bin/sh

cat ~/.ssh/id_rsa.pub
read -r -p "Please add ssh key to github and press Enter" response
branches="v4.18-dvh-L0 v4.18-dvh-full v4.18-dvh-minimal"
echo "Setting up branches: $branches"
read -r -p "Quit if you want to. Press enter otherwise" response

cd /tmp/env/scripts
./mkfs-wisc-sdc.sh

cd /sdc
git clone -o jintack git@github.com:soccertack/nested-v2.git vanilla
cd vanilla
git remote add linus https://github.com/torvalds/linux.git
git fetch linus

for branch in $branches; do
	cd /sdc
	cp -r vanilla $branch
	cd $branch
	git checkout $branch
done

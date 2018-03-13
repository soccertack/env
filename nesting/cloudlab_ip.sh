IP=${1:-"kvm"}

# If the given argument is not valid IP address,
if [ "$(sipcalc $IP | grep ERR)" != "" ]; then
	# search the string in the server list
	echo "Search $IP in the server list"
	IP="$(grep $IP ~/.servers | awk '{print $2}')"
fi

echo $IP

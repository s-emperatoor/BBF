#!/bin/bash

# this function is wrote by "cuonglm" with https://unix.stackexchange.com/users/38906/cuonglm profile at https://unix.stackexchange.com/questions/168476/convert-a-float-to-the-next-integer-up-as-opposed-to-the-nearest
ceil () {
    echo "define ceil (x) {if (x<0) {return x/1} \
         else {if (scale(x)==0) {return x} \
         else {return x/1 + 1 }}} ; ceil($1)" | bc;
}

# get the ip iddresses from the torrc file 
IPs=$(cat /etc/tor/torrc | grep -P "Bridge\sobfs4\s\d+\.\d+\.\d+\.\d+\:\d+\s.+\siat-mode=\d" | awk '{print $3}' | grep -o -P "^\d+\.\d+\.\d+\.\d+")

# if you dont use this the program wont work it is unbleavable but true :)
address=()
for index in $IPs;do
    address+=($index)
done
###########

# get the ping time to compare
Times=()
for i in $IPs; do
    # we consider second ping result 
    if ping -c 2 $i &> /dev/null;then
        # the ping syntax is copied from "Buggabill" with https://stackoverflow.com/users/2106/buggabill profile at https://stackoverflow.com/questions/9634915/extract-average-time-from-ping-c 
        # mapfile -t Times < <(ping -c 4 $i | tail -1| awk '{print $4}' | cut -d '/' -f 2)
        Times+=( $(ping -c 4 $i | tail -1| awk '{print $4}' | cut -d '/' -f 2) )
        echo "time for ip addrss $i : ${Times[-1]}"
        
        # if the ping return null we consider it as 1000 ms 
    else 
        Times+=('1000')
        echo "$i is un reachable !"
    fi
done
# get the minimum time to use it in for loop 
min=$(printf '%s\n' "${Times[@]}" | sort -n | head -1)       

# using counter to access index key
# the are some alternatives for this part but i dont think performance matters 
counter=0
for f in ${Times[@]} ; do
   if [ $(ceil $f) -eq $(ceil $min) ]; then
        echo "the best ip is ${address[$counter]}"
   fi
   ((counter++))
done

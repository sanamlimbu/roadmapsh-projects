#!/bin/bash

display_cpu_stat() {
    # cat /proc/stat 
    #   cpu 8112981 0 6928247 76232215 
    #   cpu0 1033734 0 1201093 9174421 
    #   cpu1 1010640 0 849656 9548875
    #   cpu2 1197953 0 1057656 9153562
    #   cpu3 1139578 0 871875 9397718 
    #   cpu4 1022015 0 854218 9532937
    #   cpu5 847546 0 686328 9875296 
    #   cpu6 998437 0 774609 9636125
    #   cpu7 863078 0 632812 9913281 
    #   page 10519430 1825429
    #   swap 10519430 1808119
    #   intr 91541446 
    #   ctxt 178958579 
    #   btime 1756944008

    # cpu 8112981 0 6928247 76232215
    #   user (8112981) – Time spent running processes in user mode (non-kernel), excluding niced processes.
    #   nice (0) – Time spent running user mode processes with a positive nice value (lower priority).
    #   system (6928247) – Time spent running kernel (system) code.
    #   idle (76232215) – Time spent doing nothing (the CPU is idle).

    grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5); printf "CPU Used: %.2f%%\n", usage}'
}

display_memory_stat() {
    # cat /proc/meminfo
    #   MemTotal:        8044956 kB
    #   MemFree:         1018576 kB
    #   HighTotal:             0 kB
    #   HighFree:              0 kB
    #   LowTotal:        8044956 kB
    #   LowFree:         1018576 kB
    #   SwapTotal:      13107200 kB
    #   SwapFree:       10025440 kB

    total=$(grep 'MemTotal' /proc/meminfo | awk '{print $2}')
    free=$(grep 'MemFree' /proc/meminfo | awk '{print $2}')
    used=$((total - free))
    
    awk -v free=$free -v used=$used -v total=$total '
    BEGIN {
        printf "Memory Free: %.2f MB, %.2f%%\n", (free / 1024), (free * 100 / total)
        printf "Memory Used: %.2f MB, %.2f%%\n", (used / 1024), (used * 100 / total)
    }'
}

display_disk_stat() {
    df -h
}

display_top_processes_by_cpu_usage() {
    # ps aux
    #   USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    #   cloudsh+       1  0.0  1.1 1017756 43016 ?       Ssl  05:38   0:00 node /var/lib/amazon/cloudshell/on-container-launch.js
    #   cloudsh+      35  0.0  0.0   7172  3404 ?        Ss   05:38   0:00 /bin/sh -c sudo dockerd 2>&1 | sudo tee --append /var/log/docker-daemon.log
    #   root          40  0.0  0.2  18904  7908 ?        S    05:38   0:00 sudo dockerd
    #   root          41  0.0  0.2  18904  8000 ?        S    05:38   0:00 sudo tee --append /var/log/docker-daemon.log
    #   root          46  0.0  2.1 1984160 81812 ?       Sl   05:38   0:00 dockerd
    
    echo -e "Top $1 process by CPU usage:"
    ps aux | awk 'NR>1 {print $2, $3 | "sort -nrk 2,2"}' \
    | head -n "$1" \
    | awk '{printf "PID: %s, CPU usage: %s%%\n", $1, $2}'
}

display_top_processes_by_memory_usage() {
    echo -e "Top $1 process by Memory usage:"
    ps aux | awk 'NR>1 {print $2, $4 | "sort -nrk 2,2"}' \
    | head -n "$1" \
    | awk '{printf "PID: %s, CPU usage: %s%%\n", $1, $2}'
}

display_cpu_stat
printf "\n"
display_memory_stat
printf "\n"
display_disk_stat
printf "\n"
display_top_processes_by_cpu_usage 5
printf "\n"
display_top_processes_by_memory_usage 5
#!/bin/sh
#SBATCH --time=1 -c 1
#srun hostname | sort

yes > /dev/null &
yes > /dev/null &
yes > /dev/null &
wait

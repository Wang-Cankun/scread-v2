#!/usr/bin/bash
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=16
#PBS -l mem=80GB
#PBS -m abe
#PBS -j oe
#PBS -A PAS1475
#PBS -S /usr/bin/bash
## for debugging set -x
set -x

cd /users/PAS1475/qiren081/webserver_AD
source ~/.bashrc
ml gnu/9.1.0 mkl/2019.0.3
ml R/3.6.1

for i in {1..32}
do
qsub e$i.sh
sleep 1
done

for i in {34..36}
do
qsub e$i.sh
sleep 1
done

#!/usr/bin/bash
#PBS -l walltime=16:00:00
#PBS -l nodes=1:ppn=8
#PBS -l mem=256GB
#PBS -m abe
#PBS -j oe
#PBS -A PAS1475
#PBS -o /fs/scratch/PAS1475/ad/code/log/run_analysis_${R1}_${R2}.out
#PBS -S /usr/bin/bash
## for debugging set -x
#set -x

cd /fs/scratch/PAS1475/ad/code

ml gnu/9.1.0 mkl/2019.0.5 R/4.0.2

echo $R1
echo $R2

Rscript run_analysis.R /fs/scratch/PAS1475/ad/input $R1 $R2


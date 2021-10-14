#!/usr/bin/bash
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=16
#PBS -l mem=48GB
#PBS -m abe
#PBS -j oe
#PBS -A PAS1475
#PBS -S /usr/bin/bash
## for debugging set -x
set -x

cd /users/PAS1475/qiren081/bulid_healthy_atlas
source ~/.bashrc

ml gnu/9.1.0 mkl/2019.0.3
ml R/3.6.1

Rscript build_healthy_atlas.R /users/PAS1475/qiren081/bulid_healthy_atlas/standard_files  M-H-Cortex-Male-15m.fst AD00302

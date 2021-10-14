#!/usr/bin/bash
#PBS -l walltime=01:00:00
#PBS -l nodes=1:ppn=2:gpus=1
#PBS -l mem=8GB
#PBS -m n
#PBS -j oe
#PBS -S /usr/bin/bash
#PBS -A PCON0022

module load python/3.6 cuda/9.2.88
cd /fs/scratch/PAS1475/ad/code
echo 'Hello world'

#!/usr/bin/bash
#SBATCH --account PCON0022
#SBATCH --time=01:30:00
#SBATCH --nodes=1 
#SBATCH --ntasks=16
#SBATCH --mem=48GB
cd /fs/scratch/PCON0022/ad/new_code

ml gnu/9.1.0 mkl/2019.0.5 R/4.0.2

echo $R1
echo $R2
echo $R3

Rscript project_cell_type.R /fs/scratch/PCON0022/ad/input/fst $R1 $R2

#/bin/bash
while IFS=$'\t' read DATA1 DATA2 DATA3
do
   echo $DATA3
   sbatch --job-name=$DATA3.run --output=./log/$DATA3.out --export=R1=$DATA1,R2=$DATA2,R3=$DATA3 run_transfer_cell_type.sh
   sleep 0.2s
done < input_transfer_cell_type.txt

# format, three columns, separate by tab: 
# control object, disease fst matrix, disease ID
# AD00902.rds	M-AD-cortex_and_hippocampus-Female-7m_002.fst AD00904

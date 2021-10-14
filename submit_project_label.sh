#/bin/bash
while IFS=$'\t' read DATA1 DATA2
do
   echo $DATA2
   sbatch --job-name=$DATA2.run --output=./log/$DATA2.out --export=R1=$DATA1,R2=$DATA2 run_project_label.sh
   sleep 0.1s
done < input_project_label.txt

# format, three columns, separate by tab: 
# control object, disease fst matrix, disease ID
# AD00902.rds	M-AD-cortex_and_hippocampus-Female-7m_002.fst AD00904

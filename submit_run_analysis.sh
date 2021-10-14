#/bin/bash
while IFS=$'\t' read DATA1 DATA2
do
   qsub -v "R1=$DATA1,R2=$DATA2" run_analysis.sh
   sleep 0.2s
done < input_run_analysis.txt


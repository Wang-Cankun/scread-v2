# global variables. 
# ls > ../fastq_list.txt
while IFS=$'\t' read DATA1 DATA2
do
   echo $DATA2
   sbatch --job-name=$DATA2.run --output=./log/$NAME.out --export=R1=$DATA1,R2=$DATA2 run_build_control_atlas.sh
   sleep 0.1s
done < input_control_atlas_test.txt

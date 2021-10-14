# global variables. 
# ls > ../primary_fastq_list.txt
while read DATA1 DATA2
do
   echo $NAME
   qsub -v "R1=$DATA1,R2=$DATA2" -N "$NAME" run_de.sh
   sleep 1s
#done < de_list_error2_06172020.txt
done < de_about_205.txt
#!/bin/bash
# Usage: pooled_CRISPR_screen_Gecko_v2_reorient.sh
# Processes all .fastq.gz files in a folder
# All files must be gzipped and each file pair must be named as follows:
# fastq_filename_R1.fastq.gz, fastq_filename_R2.fastq.gz
# Launch bash script from directory containing the fastq files to be processed

#Create subfolders if they don't exist
mkdir -p fastq_process_delete_when_done
mkdir -p reoriented_reads

#Run operations on each file pair
for file in *_R1.fastq.gz ; do

	#Generate file names
	base="${file%_R1.fastq.gz}"
	file_R1="${base}_R1.fastq"
	file_R2="${base}_R2.fastq"

	echo
	printf "Processing $base:\n" 
	
	file_R1_gzipped="${file_R1}.gz"
	file_R2_gzipped="${file_R2}.gz"
	
	#Check for missing R2 file
	if [ ! -f $file_R2_gzipped ]; then
  		echo "Missing R2 file for $base!"
  		exit 1
	fi
	
	printf "Unzipping:\n" 
	gunzip -c $file_R1_gzipped > $file_R1
	gunzip -c $file_R2_gzipped > $file_R2

	file_FOR_R1_R2_interleaved="./fastq_process_delete_when_done/${base}_FOR_R1_R2_interleaved.fastq"
	file_FOR_R1_filtered="./fastq_process_delete_when_done/${base}_FOR_R1_filtered.fastq"
	file_REV_R1_R2_interleaved="./fastq_process_delete_when_done/${base}_REV_R1_R2_interleaved.fastq"
	file_REV_R1_filtered="./fastq_process_delete_when_done/${base}_REV_R1_filtered.fastq"
	file_reoriented_R1="./reoriented_reads/${base}_reoriented_R1.fastq"

	#Generate interleaved file and filter for forward-facing reads in R1 using a grep query
	echo "Interleaving and filtering R1 for forward-oriented reads"
	paste $file_R1 $file_R2 | paste - - - - | awk -v OFS="\n" -v FS="\t" '{if ($3 ~ /TCTTGTGGAAAGGAC/) print($1,$3,$5,$7,$2,$4,$6,$8)}' > $file_FOR_R1_R2_interleaved

	#Deinterleave file and write the forward-facing R1 reads. Discard the reverse-facing reads.
	echo "De-interleaving for_R1_R2 file"
	paste $file_FOR_R1_R2_interleaved | paste - - - - - - - -  | tee >(cut -f 1-4 | tr "\t" "\n" > $file_FOR_R1_filtered) | cut -f 5-8 | tr "\t" "\n" > /dev/null

	#Generate interleaved file and filter for forward-facing reads in R2
	echo "Interleaving and filtering R2 for forward-oriented reads"
	paste $file_R1 $file_R2 | paste - - - - | awk -v OFS="\n" -v FS="\t" '{if ($4 ~ /TCTTGTGGAAAGGAC/) print($2,$4,$6,$8,$1,$3,$5,$7)}' > $file_REV_R1_R2_interleaved
																								  
	#Deinterleave file and write the forward-facing R2 reads. Discard the reverse-facing reads.
	echo "De-interleaving rev_R1_R2 file"
	paste $file_REV_R1_R2_interleaved | paste - - - - - - - -  | tee >(cut -f 1-4 | tr "\t" "\n" > $file_REV_R1_filtered) | cut -f 5-8 | tr "\t" "\n" > /dev/null

	#Concatenate forward-facing reads and write to file.
	echo "Concatenating reoriented R1 reads"
	cat $file_FOR_R1_filtered $file_REV_R1_filtered > $file_reoriented_R1
	
	# Delete intermediate files
	echo "Delete temp files" 
	rm $file_R1 $file_R2 $file_FOR_R1_R2_interleaved $file_FOR_R1_filtered $file_REV_R1_R2_interleaved $file_REV_R1_filtered

done



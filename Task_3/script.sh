#!/bin/bash

mkdir output
fastqc SRR24631094.fastq --outdir output
mv ./output/SRR24631094_fastqc.html ./output/qcreport.html

./bwa/bwa index -p ./output/ecoli.fna ecoli.fna

./bwa/bwa mem ./output/ecoli.fna SRR24631094.fastq > ./output/alignments.sam

samtools view -b ./output/alignments.sam -o ./output/alignments.bam

samtools flagstat ./output/alignments.bam > ./output/flagstat.txt

result=$(python3 quality.py ./output/flagstat.txt)

echo "Сообщение: $result"

if [ "$result" == "OK" ]
then
  samtools sort -o ./output/alignments.sorted.bam ./output/alignments.bam
  freebayes -f ecoli.fna ./output/alignments.sorted.bam > ./output/result.vcf
  echo "Done"
fi

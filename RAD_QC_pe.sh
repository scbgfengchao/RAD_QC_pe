#!/bin/bash

###___________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________ 
### 
### Program name:	RAD_QC_pe.sh
### Function:		Quality Control of PE RAD-seq
### Citation:		Chao Feng, Meizhen Xu, Chen Feng, Eric J. B. von Wettberg, Ming Kang. The complete chloroplast genome of Primulina and two novel strategies for development of high polymorphic loci for phylogenetic studies. BMC Evolutionary Biology 2017;
### Author:		Chao Feng (chaofeng@scbg.ac.cn)
### Release date:	Jul. 15th, 2017
### Version:		Version 1.0
### Software:		Please make sure that FASTX_Toolkit ("http://hannonlab.cshl.edu/fastx_toolkit") have been installed and avaliable in your directory.
### Preparation:	Put all the PE-end RAD-Seq (fq format), RAD_QC_pe.sh, RAD_QC_pe.pl and q2030.pl in the same folder.
###                         *Read1 (next to restriction site) should be named as $sample_raw.1.fq, the other one as $sample_raw.2.fq, e.g.: CZYX01-2_raw.1.fq, CZYX01-2_raw.2.fq.
### Usage:		nohup sh RAD_QC_pe.sh $ThreadNumber $3'cohesive_end $Read1_len $Read2_len >$Log 2>&1 &
###				$ThreadNumber: Max Thread can be used in this analysis.
###				$Read1_len: the length of read1 in fastq file, e.g. 100.
###				$Read2_len: the length of read2 in fastq file, e.g. 100.
###				$Log: Record of output on the screen.
###				$3'cohesive_end: 3'end of restriction enzyme used in RAD-Seq, e.g. EcoR I (G'AATTC) was used in RAD-Seq, here print AATTC.
###			E.g.: nohup sh RAD_QC_pe.sh 8 100 100 AATTC >Log.txt 2>&1 &
### Note:		If your RAD data was sequenced in order Illumina system with Phred64, please open the file q2030.pl, and exchange the number "53" and "63" in the line 21 and 24 into "84" and "94", respectively.
###			        This pipeline works on the fq file with the id line (line 1 of each 4 lines) which is combined with two parts, the former one is shared by both PE reads, the latter one has difference between PE reads. And these two parts are splited by black (" ") or tab ("	"), sush as "@HWI-D00524:51:C587MANXX:4:1101:3260:1957 1:N:0:AGCAGT" or "@HWI-D00524:51:C587MANXX:4:1101:3260:1957 2:N:0:AGCAGT". Otherwise, this pipeline maybe not suitable for your data, we will adjust the pipeline if you email us.
###                         All the read1 or read2 in a fastq file used in this pipeline should have uniform length.
### Output description:	RefFile
###				$sample_1.fq and $sample_2.fq: the fq files after quality control.
###				$sample_1.fq.q2030 and $sample_2.fq.q2030: the stats files with the infomation of read No., Q20 and Q30 values.
###___________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________
###

Cpu=$1;
Len1=$2;
Len2=$3;
End3=$4;

find -name "*_raw.1.fq" |sed 's/_raw.1.fq//'|sort -n |uniq >Fq.list
files=`cat Fq.list`

ls *.fq | xargs -I {} -P $Cpu fastq_quality_filter -q 20 -p 90% -i {} -o {}.filter

for file in $files
do
	perl RAD_QC_pe.pl ${file} $Len1 $Len2 $End3
done

ls *_1.fq | xargs -I {} -P $Cpu perl q2030.pl {} $Len1
ls *_2.fq | xargs -I {} -P $Cpu perl q2030.pl {} $Len2

rm -rf *.filter


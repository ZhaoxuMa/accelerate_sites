#!/bin/bash
#SBATCH -J wfmash
#SBATCH --comment=WRF
#SBATCH -n 30
#SBATCH -N 1
#SBATCH -p xhacnormalb

##1.file prepare
sample=$1   #A157_H1
ref=$2  #DM
t=30
fmt="%C\\n%Us user %Ss system %P cpu %es total %MKb max memory"
time="/usr/bin/time"
mkdir ${sample}
cd ${sample}
ln -s  ../../01.genome/${sample}/${sample}.fa ./
ln -s ../../01.genome/${ref}/${ref}.fa ./
~/miniconda3/envs/wfmash2/bin/bgzip -@ ${t} ${sample}.fa
~/miniconda3/bin/samtools faidx ${sample}.fa.gz
~/miniconda3/envs/wfmash2/bin/bgzip -@ ${t} ${ref}.fa 
~/miniconda3/bin/samtools faidx ${ref}.fa.gz


##2.wfmash (have to follow panSN)
# identity
p=80
$time -f "$fmt" wfmash -s 5000 -p $p -n 1 -k 19 -H 0.001  -t ${t} --one-to-one --hg-filter-ani-diff 0 ${ref}.fa.gz ${sample
}.fa.gz > ${sample}.paf

##3.file trans-wgatools
#paf to maf
wgatools paf2maf  --target ${ref}.fa.gz --query ${sample}.fa.gz  ${sample}.paf -t ${t} -o ${sample}.maf
# call vcf
wgatools call --sample ${sample} -s -t ${t} ${sample}.maf -o ${sample}.vcf
# sort maf
bash ~/software/maf-sort.sh ${sample}.maf  >${sample}.sort.maf 
wait

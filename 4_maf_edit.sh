#!/bin/bash
###pipeline
#1.single_cov 去除重复
#2.wgatools chunk -l 1000划分窗口
#3.python处理坐标
#4.awk的filter处理，删掉有0的行
#5.加上header
#6.awk处理。maf文件的species与染色体名称之间的连接符_替换为.
species=$1
chr=$2
dir="/work/home/mazhaoxu/epi_small/02.wfmash"
module load single_cov2/v11
mkdir ${chr}
cd ${chr}
ln -s ${dir}/${species}/${species}_${chr}.maf ./
sh ../edit.sh ${species}_${chr}.maf
single_cov2 ${species}_${chr}.maf R=DM > ${species}_${chr}_single1.maf
module load wgatools/0.1.0
wgatools chunk -r  -l 1000 ${species}_${chr}_single1.maf -o ${species}_${chr}_single1_chunk2.maf
python ../python_edit_posi.py ${species}_${chr}_single1_chunk2.maf ${species}_${chr}_single1_chunk2_realPos3.maf
cp ${species}_${chr}_single1_chunk2_realPos3.maf DM.${species}.sing.maf 
sh ../filter.sh DM.${species}.sing.maf  #filter之后的文件名仍然是DM.${species}.sing.maf，在filter.sh里面写的
sed -i '1i ##maf version=1 scoring=multiz' DM.${species}.sing.maf
sh ../awk_sub.sh DM.${species}.sing.maf
rm ${species}_${chr}_single1.maf
rm ${species}_${chr}_single1_chunk2.maf

#1) The dir1 folder contains pep protein sequence files for all genomes
orthofinder -f dir1 -M msa -t 80 -a 8 &>orthofinder .log

##If the run needs to be renewed, the command is as follows
orthofinder -fg ${dir}/OrthoFinder/Results_May31 -M msa  -t 60 -a 8 -X &>orthofiner2_log.txt

#2) 先得到单拷贝同源基因列表
cd Single_Copy_Orthologue_Sequences/
ls ./* > ../orthogroup_gene.txt

#3) 生成批量运行iqtree的文件
vi test_iqtree.sh
'''
#!/bin/bash
#SBATCH -J wrf
#SBATCH --comment=WRF
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -p xhacnormalb
fa=$1
iqtree -s ${fa} -m MFP -nt AUTO -B 1000  --prefix iqtree_results/${fa}
'''
awk '{print "sbatch test_iqtree.sh "$1}' tpm_fa >sbatch.txt

#4) cat多个树，为后边的astral合并做准备
cat iqtree_results/*.treefile > total_gene.tree

#5) 运行ASTRAL得到物种进化树
vi astral.sh
'''
#!/bin/bash
#SBATCH -J astral
#SBATCH --comment=WRF
#SBATCH -n 6
#SBATCH -N 1
#SBATCH -p xhacnormalb
astral4 -t 6 --root Sacule_Sacule  -i total_gene.tree -o genetree_test.nw 2>genetree.nw.log
'''
sbatch astral.sh

#6) 将进化树转换为二进制格式。因为multiz输入的事二进制格式的仅物种名的树
python nw_to_species.py > tpm1_species_tree
sed -i 's/,/ /g' tpm1_species_tree
##结果如下
(((((C351 PG0009) (C445_H1 PG0016_H1)) (C499 C502_H1)) (((((((Slycum Sgalap) Schmie) Scorne) Spenne) Slydes) Sochra) (C357_H1 (C540_H1 (M6_H1 (C410_H1 (((((((((C151_H1 A157) DM) C121_H1) E454) C058_H1) RH_H1) C370_H1) C454_H1) PG6002))))))) Sacule)


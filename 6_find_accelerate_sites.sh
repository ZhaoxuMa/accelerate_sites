###############chr05的PAR位点查找。自合并后的maf开始################
###起始文件
merged_28species_chr05.maf

###1.过滤一下maf，找至少有27个物种比对的上的maf。并sort一下
#1.1筛选除了外群，至少27个比对上的maf
Py文件目录：/work/home/mazhaoxu/epi_small/04.PAR/chr06/maf_filter_27_outgroup.py
python maf_filter_27_outgroup.py merged_28species_chr05.maf merged_28species_chr05_27outgroup.maf
#1.2将筛选出来的进行排序
bash ~/software/maf-sort.sh merged_28species_chr05_27outgroup.maf> merged_28species_chr05_27outgroup.sorted.maf
rm merged_28species_chr05_27outgroup.maf

###2.通过msa_view找到4d位点（2条命令）
#2.1提取4d位点
~/miniconda3/envs/phast/bin/msa_view merged_28species_chr05_27outgroup.sorted.maf --4d --features /work/home/mazhaoxu/epi_small/01.genome/DM/DM_chr05.gff > chr05_4d-codons.ss
#2.2选取外显子中的第三列
~/miniconda3/envs/phast/bin/msa_view chr05_4d-codons.ss --in-format SS --out-format SS --tuple-size 1 > chr05_4d-sites.ss
rm chr05_4d-codons.ss

###3.通过phyloFit基于4d位点，得到非保守模型的mod文件
~/miniconda3/envs/phast/bin/phyloFit --tree "(((((C351,PG0009),(C445_H1,PG0016_H1)),(C499,C502_H1)),(((((((Slycum,Sgalap),Schmie),Scorne),Spenne),Slydes),Sochra),(C357_H1,(C540_H1,(M6_H1,(C410_H1,(((((((((C151_H1,A157),DM),C121_H1),E454),C058_H1),RH_H1),C370_H1),C454_H1),PG6002))))))),Sacule)" --msa-format SS --out-root nonconserved-chr05_4d chr05_4d-sites.ss
'''
Reading alignment from chr05_4d-sites.ss ...
Compacting sufficient statistics ...
Fitting tree model to chr05_4d-sites.ss using REV ...
numpar = 59
Done.  log(likelihood) = -460985.468482 numeval=10838
Writing model to nonconserved-chr05_4d.mod ...
Done.
'''
###4.运行phyloP得到进化加速区。得到每个位点的保守性和加速性.用CONACC模型，筛选加速区域位点。
#4.1分支没有名字，用tree_doctor给分支长度加上名字。
~/miniconda3/envs/phast/bin/tree_doctor --name-ancestors nonconserved-chr05_4d.mod > named_nonconserved-chr05_4d.mod
#4.2一条命令即可得到加速位点，正值代表保守性，负值代表加速性，0代表中性位点。
~/miniconda3/envs/phast/bin/phyloP --method LRT --branch C357_H1-C540_H1 --mode CONACC -w named_nonconserved-chr05_4d.mod merged_28species_chr05_27outgroup.sorted.maf > phyloP_branch.wig
#4.3将wig转为bw，再转为bed
grep "chr05" /work/home/mazhaoxu/epi_small/01.genome/DM/DM.chr_length.txt > chr05.size
sed -i 's/merged_28species_chr05_27outgroup/chr05/g' phyloP_branch.wig
wigToBigWig phyloP_branch.wig chr05.size phyloP_branch.bw
bigWigToBedGraph phyloP_branch.bw phyloP_branch_chr05.bedGraph
rm phyloP_branch.bw

###5.筛选进化加速区，并做FDR检验，选取阈值为0.05的
#5.1筛选score<-1的位点
grep -v "^#" phyloP_branch_chr05.bedGraph | awk -v OFS="\t" '{ if ($4 > 0) print $0, "conserved", 10^-$4; else if ($4 < 0) print $0, "accelerated", 10^$4; else print $0, "neutral", 10^$4 }' > phyloP_branch_chr05_CONACC_anno.bedGraph
grep "accelerated" phyloP_branch_chr05_CONACC_anno.bedGraph |awk '$4<= -1'|sort -k4,4g > tpm_accelerated_sorted_1.bedgraph
/work/home/mazhaoxu/miniconda3/envs/hic/bin/Rscript fdr.R tpm_accelerated_sorted_1.bedgraph  tpm_chr05_accelerated_sorted_1_fdr.bed
#5.2筛选FDR<0.05的，然后按照坐标位置排序一下
le tpm_chr05_accelerated_sorted_1_fdr.bed | awk '$7<0.05'|sort -k2,2n > chr05_accelerated_1_fdr.sorted.txt
rm  tpm_chr05_accelerated_sorted_1_fdr.bed tpm_accelerated_sorted_1.bedgraph

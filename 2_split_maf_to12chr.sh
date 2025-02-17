vi maf_split.sh

#!/bin/bash
#SBATCH -J wrf
#SBATCH --comment=WRF
#SBATCH -n 5
#SBATCH -N 1
#SBATCH -p xhacnormalb
sample=$1
head -n 1 ${sample}.sort.maf >maf_header
grep -A 2 -B 2 "+\s88591686" ${sample}.sort.maf >chr01.maf
grep -A 2 -B 2 "+\s46102915" ${sample}.sort.maf |cat maf_header - >chr02.maf
grep -A 2 -B 2 "+\s60707570" ${sample}.sort.maf |cat maf_header - >chr03.maf
grep -A 2 -B 2 "+\s69236331" ${sample}.sort.maf |cat maf_header - >chr04.maf
grep -A 2 
-B 2 "+\s55599697" ${sample}.sort.maf |cat maf_header - >chr05.maf
grep -A 2 -B 2 "+\s59091578" ${sample}.sort.maf |cat maf_header - >chr06.maf
grep -A 2 -B 2 "+\s57639317" ${sample}.sort.maf |cat maf_header - >chr07.maf
grep -A 2 -B 2 "+\s59226000" ${sample}.sort.maf |cat maf_header - >chr08.maf
grep -A 2 -B 2 "+\s67600300" ${sample}.sort.maf  |cat maf_header ->chr09.maf
grep -A 2 -B 2 "+\s61044151" ${sample}.sort.maf |cat maf_header - >chr10.maf
grep -A 2 -B 2 "+\s46777387" ${sample}.sort.maf |cat maf_header - >chr11.maf
grep -A 2 -B 2 "+\s59670755" ${sample}.sort.maf |cat maf_header - >chr12.maf

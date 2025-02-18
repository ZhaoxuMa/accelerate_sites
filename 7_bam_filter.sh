###在看懂sam文件的基础上，对比对结果sam文件进行过滤
name=$1
threads=$2
#1.过滤没比对上的reads。选取sam文件第三列或者第七列都不为*的行。
awk '($1 ~ /^@/) || ($3 != "*" && $7 != "*")'  ${name}.sam > ${name}_filtered_step1.sam
#2.过滤掉pair reads没有比对到同一条染色体上的。选取sam文件第七列为"="的行。
awk '($1 ~ /^@/) || ($7 == "=")' ${name}_filtered_step1.sam >  ${name}_filtered_step2.sam
#3.过滤掉MAPQ小于10的。sam文件第五列小于等于10的。
awk '($1 ~ /^@/) || ($5 >= 10)' ${name}_filtered_step2.sam > ${name}_filtered_step3.sam
#4.过滤掉比对到叶绿体、线粒体上的reads。质体的染色体号都是MT开头。
awk '($1 ~ /^@/) || ($3 !~ /^MT_/ && $9 <= 1000 && $9 >= -1000) {print $0}' ${name}_filtered_step3.sam > ${name}_filtered_step4.sam
#5.过滤掉pair reads之间的距离绝对值大于1000的
awk '($1 ~ /^@/) || ($9 <= 1000 && $9 >= -1000) {{print $0}}' {wildcards.id}_filtered_step4.sam > {wildcards.id}_filtered_step5.sam
#6.去掉过滤完后只剩下一端的reads。
/public/software/env01/bin/samtools sort -n ${name}_filtered_step5.sam -o ${name}_filtered_step5_sorted.sam #按照第一列排序
awk '($1 ~ /^@/) {print $0; next} {name[$1]++; lines[$1] = lines[$1] "\n" $0} END {for (n in name) if (name[n] == 2) print lines[n]}' ${name}_filtered_step5_sorted.sam > ${name}_intermediate.sam #只读取第一列出现两次的行
grep -v '^$' ${name}_intermediate.sam > ${name}_no_blank_intermediate.sam #去除空白行
/public/software/env01/bin/samtools sort --threads {threads} -O 'bam'  -o ${name}_filtered_final_sorted.bam -T tpm ${name}_no_blank_intermediate.sam#得到的最终文件是${name}_filtered_final_sorted.bam
#最后删掉所有中间文件
rm ${name}_filtered_step1.sam ${name}_filtered_step2.sam ${name}_filtered_step3.sam ${name}_filtered_step4.sam ${name}_filtered_step5.sam  ${name}_filtered_step5_sorted.sam ${name}_intermediate.sam ${name}_no_blank_intermediate.sam

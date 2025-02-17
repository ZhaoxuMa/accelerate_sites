!/bin/bash
file=$1
awk '
BEGIN { OFS="\t" }
/^a / { 
  # 如果之前的块有效，则打印该块
  if (valid_block) {
    print block
  }
  # 初始化新的块
  block = $0
  valid_block = 1
  next_line_count = 3
  next
}
{
  block = block "\n" $0
  if (next_line_count == 3) {
    seq1_len = $4
  } else if (next_line_count == 2) {
    seq2_len = $4
    # 检查比对长度是否小于10
    if (seq1_len < 10 || seq2_len < 10) {
      valid_block = 0
    }
  }
  next_line_count--
}
END {
  # 如果最后一个块有效，则打印该块
  if (valid_block) {
    print block
  }
}
' ${file} > ${file}_filterd.maf
#mv ${file} ${file}_chunk
mv ${file}_filterd.maf ${file}
wait

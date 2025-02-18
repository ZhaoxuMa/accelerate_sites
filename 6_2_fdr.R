# 获取命令行参数
args <- commandArgs(trailingOnly = TRUE)

# 确保提供了两个参数：输入文件和输出文件
if (length(args) != 2) {
  stop("请提供输入和输出文件名，例如：Rscript tpm.R 输入文件 输出文件")
}

input_file <- args[1]
output_file <- args[2]

# 读取输入文件
bed <- read.table(input_file, header = FALSE)

# 提取p-values并计算FDR值
p_values <- bed[,6]
q_values <- p.adjust(p_values, method = "BH")

# 将FDR值添加到数据框
bed[,7] <- q_values

# 添加表头
colnames(bed) <- c("Chr", "Start", "End", "PhyloP_score", "Label", "P-value", "FDR_value")

# 将数据写入输出文件，包含表头
write.table(bed, output_file, quote = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)

# -*- coding: utf-8 -*-

import sys
def process_maf(input_file, output_file):
    def process_block(block, last_start_third, last_start_fourth):
        if len(block) < 4:
            #print(f"Incomplete block: {block}")
            return [], last_start_third, last_start_fourth

        a_line = block[0].strip()
        second_line = block[1].split()
        third_line = block[2].split()
        fourth_line = block[3].strip()
        
        #print(f"Processing block: {block}")
        
        # Update the third column of the second line
        second_line[2] = str(last_start_third)
        last_start_third += int(second_line[3])

        # Update the third column of the third line
        third_line[2] = str(last_start_fourth)
        last_start_fourth += int(third_line[3])

        updated_block = [a_line, "\t".join(second_line), "\t".join(third_line), fourth_line]
        return updated_block, last_start_third, last_start_fourth

    with open(input_file, 'r') as fin, open(output_file, 'w') as fout:
        block = []
        last_start_third = None  #储存前一个块的第二行的第三列的值
        last_start_fourth = None  #储存前一个块的第三行的第三列的值
        last_end_key = None  #存储前一个块的关键值（最后三个字符），判断是否属于一个大块
        last_chr_fourth = None  # 存储前一个块的第三行染色体

        for line in fin:
            if line.startswith('#'):
                fout.write(line)
                continue
            if line.strip() == '':
                continue

            if line.startswith('a'):
                if block:
                    updated_block, last_start_third, last_start_fourth = process_block(block, last_start_third, last_start_
fourth)  #如果当前已有块存储在block中，则调用process_block()函数处理当前快，并写出输出。
                    for b_line in updated_block:
                        fout.write(b_line+"\n")
                    #print(f"Processed block: {updated_block}")
                #fout.write(line)  # Write the 'a' line directly to the output
                #block = []
                block = [line]
                continue

            if line.startswith('s'):
                block.append(line)
                if len(block) == 3:
                    block.append("") #三行的块加一个空行作为第四行     
                if len(block) == 4:
                    # Determine the key to check if it's a new big block
                    key_third = block[1].split()[2].zfill(3)[-3:]
                    key_fourth = block[2].split()[2].zfill(3)[-3:]
                    current_chr_fourth = block[2].split()[1]  # 当前block的第三行染色体
                    #key_third = block[1].split()[2][-3:] #取第二行的第三列的后三个字符为key_third
                    #key_fourth = block[2].split()[2][-3:] #取第三行的第三列的后三个字符为key_fourth

                    if (last_end_key is None or last_end_key != (key_third, key_fourth) or
                        last_chr_fourth != current_chr_fourth):
                        last_start_third = int(block[1].split()[2])
                        last_start_fourth = int(block[2].split()[2])
                        last_chr_fourth = current_chr_fourth
                    last_end_key = (key_third, key_fourth)

        # Process the last block 如果文件读取结束仍然有未处理的块，则将其写入输出文件。
        if len(block) == 4:  
            updated_block, last_start_third, last_start_fourth = process_block(block, last_start_third, last_start_fourth)
            for b_line in updated_block:
                fout.write(b_line+"\n")
            #print(f"Processed block: {updated_block}")
# Example usage
#input_file = "DM.S_corneliomulleri.sing.maf_chunk"
#output_file = "maf_python_test.maf"
#process_maf(input_file, output_file)

# Check if the correct number of arguments is provided
if len(sys.argv) != 3:
    print("Usage: python script_name.py input_file output_file")
    sys.exit(1)
# Get the input and output file names from the command line arguments
input_file = sys.argv[1]
output_file = sys.argv[2]
# Call the process_maf function
process_maf(input_file, output_file) 

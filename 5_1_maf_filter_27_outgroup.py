# -*- coding: utf-8 -*-
#筛选至少有27个物种，外群有无都行
import sys

def filter_maf(input_path, output_path, outgroup='Sacule'):
    with open(input_path, 'r') as infile, open(output_path, 'w') as outfile:
        outfile.write('##maf version=1 scoring=multiz\n')  # 写入头信息,注意格式开头必须有两个#
        block = []
        for line in infile:
            if line.startswith('a '):
                if block and len({l.split()[1].split('.')[0] for l in block if l.startswith('s ') and outgroup not in l}) >= 27:
                    outfile.write(''.join(block))
                block = [line]
            else:
                block.append(line)
        if block and len({l.split()[1].split('.')[0] for l in block if l.startswith('s ') and outgroup not in l}) >= 27:
            outfile.write(''.join(block))

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python filter_maf.py <input_file> <output_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]

    filter_maf(input_file, output_file)

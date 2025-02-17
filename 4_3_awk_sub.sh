#!/bin/bash

input_file=$1
tpm_file=${input_file}_tpm

awk -F'\t' 'BEGIN {OFS="\t"} 
{
    if (NR > 1 && NF >= 2) {
        split($2, parts, "_")
        if (length(parts) > 1) {
            $2 = ""
            for (i = 1; i < length(parts); i++) {
                $2 = $2 parts[i] "_"
            }
            $2 = substr($2, 1, length($2) - 1) "." parts[length(parts)]
        }
    }
    print $0
}' "$input_file" > "$tpm_file"

mv $tpm_file $input_file

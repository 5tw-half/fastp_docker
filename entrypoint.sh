#!/usr/bin/env bash

# lyx 8/20/2024
# xing ZHAO 2025-05-28

source /root/set.thread.num.sh

INPUT_DIR="/mnt/in"
OUTPUT_DIR="/mnt/out"
mkdir -p "$OUTPUT_DIR"

# Find and process all FASTQ files
processed_files=()
shopt -s nullglob

# Process paired-end files (_R1/_R2)
for r1 in "$INPUT_DIR"/*_R1*.fastq.gz; do
    r2="${r1/_R1/_R2}"
    if [[ -f "$r2" ]]; then
        base_name=$(basename "$r1")
        base_name=${base_name%%_R1*}
        echo -e "\e[0;34mInfo: Processing paired-end sample: $base_name\e[0m"
        
        fastp --thread $THREAD_NUM \
            -i "$r1" -I "$r2" \
            -o "$OUTPUT_DIR/$(basename "$r1")" \
            -O "$OUTPUT_DIR/$(basename "$r2")" \
            -j "$OUTPUT_DIR/${base_name}_fastp.json" \
            -h "$OUTPUT_DIR/${base_name}_fastp.html"
            
        if [[ $? -ne 0 ]]; then
            echo -e "\e[0;31mError: fastp failed on $base_name\e[0m" >&2
            exit 1
        fi
        processed_files+=("$r1" "$r2")
    fi
done

# Process single-end files
for file in "$INPUT_DIR"/*.fastq.gz; do
    if [[ ! " ${processed_files[@]} " =~ " $file " ]]; then
        base_name=$(basename "$file" .fastq.gz)
        base_name=${base_name%%_*}
        echo -e "\e[0;34mInfo: Processing single-end sample: $base_name\e[0m"
        
        fastp --thread $THREAD_NUM \
            -i "$file" \
            -o "$OUTPUT_DIR/$(basename "$file")" \
            -j "$OUTPUT_DIR/${base_name}_fastp.json" \
            -h "$OUTPUT_DIR/${base_name}_fastp.html"
            
        if [[ $? -ne 0 ]]; then
            echo -e "\e[0;31mError: fastp failed on $file\e[0m" >&2
            exit 1
        fi
    fi
done

echo -e "\e[0;34mInfo: Run completed. Results saved to ${OUTPUT_DIR}\e[0m"
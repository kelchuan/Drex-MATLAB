#!/bin/bash

# Output file
output_file="all_data.txt"
> $output_file  # Clear or create the file

# Add header row to the output file
echo "Timestep | id | vol_frac | phi | theta | z" > $output_file

# Determine the approximate size of a header-only file (adjust based on your files)
header_size=$(du "$(ls weighted* | head -n 1)" | awk '{print $1}')

echo "Identifying files with numerical data based on size..."

# Filter files by size (larger than header size)
#valid_files=()
#for file in weighted*; do
#    file_size=$(du  "$file" | awk '{print $1}')
#    if (( file_size > header_size )); then
#        valid_files+=("$file")
#    fi
#done
# Define the minimum valid file size (in bytes)
min_size=$header_size

# Use ls, du, and awk to filter files with a size greater than the defined minimum size
valid_files=($(ls weighted_CPO-000* | xargs du -a | awk -v min_size=$min_size '$1 > min_size {print $2}'))
echo "Found ${#valid_files[@]} files likely to have data. Processing..."

# Loop through valid files and process them
for file in "${valid_files[@]}"; do
    echo "Processing file: $file"
    
    # Extract the time step (number between "CPO-" and ".")
    time_step=$(echo "$file" | sed -n 's/.*CPO-\([0-9]*\)\..*/\1/p')

    # Extract relevant data
    awk -v ts="$time_step" '{
        if (NR > 1 && $0 ~ /^[0-9]/) {  # Skip header and non-numerical rows
            printf "%s | %s | %s | %s | %s | %s\n", ts, $1, $6, $7, $8, $9
        }
    }' "$file" >> $output_file

    echo "  Successfully processed $file."
done

echo "Data extraction completed. All data saved to $output_file."

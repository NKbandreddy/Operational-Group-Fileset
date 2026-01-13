#!/bin/bash
# Decrypt .subdiv files, calculate size and MD5 of decrypted files, and update .fileset files

KEY="576162746563205261696C7761792045"
IV="2B7E151628AED2A6ABF7158809CF4F3C"

# Get all GEO folders
for folder in GEO*/; do
    if [ ! -d "$folder" ]; then
        continue
    fi
    
    echo ""
    echo "Processing: $folder"
    
    # Find the .subdiv file
    subdiv_file=$(find "$folder" -name "*.subdiv" -type f | head -n 1)
    
    if [ -z "$subdiv_file" ]; then
        echo "  No .subdiv file found, skipping..."
        continue
    fi
    
    echo "  Found file: $(basename "$subdiv_file")"
    
    # Create temporary decrypted file name
    decrypted_file="${folder}temp_decrypted.tmp"
    
    # Decrypt the file
    echo "  Decrypting..."
    if ! openssl enc -d -aes-128-cbc -in "$subdiv_file" -out "$decrypted_file" -K "$KEY" -iv "$IV" 2>/dev/null; then
        echo "  ERROR: Decryption failed for $(basename "$subdiv_file")"
        continue
    fi
    
    if [ ! -f "$decrypted_file" ]; then
        echo "  ERROR: Decrypted file was not created"
        continue
    fi
    
    # Calculate size and MD5 of decrypted file
    size=$(stat -f%z "$decrypted_file" 2>/dev/null || stat -c%s "$decrypted_file" 2>/dev/null)
    md5=$(md5sum "$decrypted_file" | cut -d' ' -f1)
    
    echo "  Decrypted size: $size bytes"
    echo "  Decrypted MD5: $md5"
    
    # Update .fileset file
    fileset_file=$(find "$folder" -name "*.fileset" -type f | head -n 1)
    
    if [ -z "$fileset_file" ]; then
        echo "  ERROR: No .fileset file found"
        rm -f "$decrypted_file"
        continue
    fi
    
    # Update size and MD5 in the file line
    # Use perl or sed to replace the size and md5 values
    if command -v perl &> /dev/null; then
        perl -i -pe "s/(file \"[^\"]+\" size=)\d+( md5=)[a-f0-9]+/\${1}${size}\${2}${md5}/" "$fileset_file"
    else
        # Fallback to sed (works on most systems)
        sed -i.bak "s/file \"[^\"]*\" size=[0-9]* md5=[a-f0-9]*/file \"$(grep -o 'file "[^"]*"' "$fileset_file" | sed 's/file "\([^"]*\)"/\1/')\" size=$size md5=$md5/" "$fileset_file"
        rm -f "${fileset_file}.bak"
    fi
    
    # Calculate new MD5 of updated .fileset
    new_fileset_md5=$(md5sum "$fileset_file" | cut -d' ' -f1)
    echo "  Updated .fileset MD5: $new_fileset_md5"
    
    # Clean up temporary decrypted file
    rm -f "$decrypted_file"
done

echo ""
echo "Decryption and update complete!"
echo ""
echo "Renaming folders with new MD5 hashes..."

# Rename folders after updates
for folder in GEO*/; do
    if [ ! -d "$folder" ]; then
        continue
    fi
    
    # Find the .fileset file
    fileset_file=$(find "$folder" -name "*.fileset" -type f | head -n 1)
    
    if [ -z "$fileset_file" ]; then
        continue
    fi
    
    # Calculate MD5 of .fileset file
    new_md5=$(md5sum "$fileset_file" | cut -d' ' -f1)
    
    # Extract GEO number from folder name
    geo_num=$(echo "$folder" | grep -o 'GEO[0-9]*' | grep -o '[0-9]*')
    
    # Create new folder name
    new_folder_name="GEO${geo_num}_${new_md5}"
    
    # Check if folder name needs to change
    current_folder_name=$(basename "$folder")
    if [ "$current_folder_name" != "$new_folder_name" ]; then
        echo "Renaming: $current_folder_name -> $new_folder_name"
        mv "$folder" "$new_folder_name"
        
        # Rename the .fileset file to match new MD5
        old_fileset_name=$(basename "$fileset_file")
        new_fileset_name="${new_md5}.fileset"
        if [ "$old_fileset_name" != "$new_fileset_name" ]; then
            mv "${new_folder_name}/${old_fileset_name}" "${new_folder_name}/${new_fileset_name}"
        fi
    fi
done

echo ""
echo "All done! Folders renamed with new MD5 hashes."


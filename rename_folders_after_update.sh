#!/bin/bash
# Rename folders after .fileset files have been updated with new MD5 hashes

for folder in GEO*/; do
    if [ ! -d "$folder" ]; then
        continue
    fi
    
    # Find the .fileset file
    fileset_file=$(find "$folder" -name "*.fileset" -type f | head -n 1)
    
    if [ -z "$fileset_file" ]; then
        echo "No .fileset file found in $folder, skipping..."
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
    else
        echo "No rename needed for: $current_folder_name"
    fi
done

echo ""
echo "Folder renaming complete!"


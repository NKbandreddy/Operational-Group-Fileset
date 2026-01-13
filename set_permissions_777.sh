#!/bin/bash
# Set all directories and files to 777 (drwxrwxrwx) recursively

echo "Setting permissions to 777 for all directories and files..."

# Set directories to 777
find . -type d -exec chmod 777 {} \;

# Set files to 777
find . -type f -exec chmod 777 {} \;

echo ""
echo "Permissions set to 777 recursively!"
echo ""
echo "Verifying permissions..."
ls -la | grep "^d" | head -5


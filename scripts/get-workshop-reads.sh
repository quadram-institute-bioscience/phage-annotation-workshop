#!/bin/bash

# Check existing files

if [[ -d "ont" ]]; then
    echo "Directory 'ont' already exists. Please remove it first."
    exit 1
fi
if [[ -d "illumina" ]]; then
    echo "Directory 'illumina' already exists. Please remove it first."
    exit 1
fi

if [[ -e "reads.zip" ]]; then
    echo "reads.zip found: skipping download"
else
    echo "Downloading reads..."
    wget --quiet -O reads.zip "https://zenodo.org/record/5704419/files/reads.zip?download=1" || { echo "ERROR: Failed to download reads.zip" ; exit 1; }
fi

echo "Unzipping..."
unzip -q reads.zip || { echo "ERROR: Failed to unzip reads.zip" ; exit 1; }

echo
echo "Reads downloaded in:"
echo "ont/"
echo "illumina/"
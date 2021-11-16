#!/bin/bash
# A script to download public data from the NCBI FTP site

# Script self directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OUTDIR="$DIR/../t4-demo/"

mkdir -p $OUTDIR

# Check if fastq-dump is available
if ! command -v fastq-dump >/dev/null 2>&1; then
    echo "fastq-dump is not available. Install it first (e.g. conda install -c bioconda sra-tools)"
    exit 1
else
    fastq-dump --version | grep .
fi

ACC="SRR1714822"

if [[ ! -e "$OUTDIR"/${ACC}_1.fastq.gz ]]; then
    echo "Downloading dataset $ACC..."
    fastq-dump --split-3 --gzip $ACC -O $OUTDIR
fi

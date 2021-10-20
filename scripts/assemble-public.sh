#!/bin/bash

# Script self directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


# Get options: -t THREADS -o OUTDIR -a ACCESSION
THREADS=1
ACC="SRR1714822"
OUTDIR="$DIR/../t4-demo/"

while getopts "t:o:a:" opt; do
  case $opt in
    t)
      THREADS=$OPTARG
      ;;
    o)
      OUTDIR=$OPTARG
      ;;
    a)
      ACC=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [[ ! -e "$OUTDIR"/${ACC}_1.fastq.gz ]]; then
    echo "Download the dataset first ($ACC)"
    exit 1
fi

set -euxo pipefail
unicycler -t $THREADS -1 $R1 -2 $R2 -o $OUTDIR/$ACC/ 
prokka --cpus $THREADS -o $OUTDIR/$ACC/prokka --prefix prokka $OUTDIR/$ACC/assembly.fasta 


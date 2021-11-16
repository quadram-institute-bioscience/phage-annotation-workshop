#!/bin/bash
# Assemble t4 reads from SRA with Unicycler

# Script self directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


# Get options: -t THREADS -o OUTDIR -a ACCESSION
THREADS=4
ACC="SRR1714822"
OUTDIR="$DIR/../t4-demo/"
CLEAN=0
while getopts "ct:o:a:" opt; do
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
    c)
      CLEAN=1
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

if [[ ! -e ""$OUTDIR""/${ACC}_1.fastq.gz ]]; then
    echo "Download the dataset first ($ACC)"
    exit 1
fi
R1="$OUTDIR"/${ACC}_1.fastq.gz
R2="$OUTDIR"/${ACC}_2.fastq.gz
if [[ ! -e "$OUTDIR"/"${ACC}"_1.fastq.gz ]]; then
    echo "Download the dataset first ($ACC)"
    exit 1
fi

if [[ ! -e "$OUTDIR"/"${ACC}"_2.fastq.gz ]]; then
    echo "ERROR: Corrupted download of $ACC, R2 not found"
    echo "Download the dataset first ($ACC)"
    exit 1
fi
alias fu-cov='/tmp/fucov'

set -euxo 

# Assemble
if [[ ! -e "$OUTDIR"/"$ACC"/assembly.fasta ]]; then
  gunzip "$OUTDIR"/"$ACC"/assembly.fasta.gz
fi

if [[ ! -e "$OUTDIR"/"$ACC"/assembly.fasta ]]; then
 unicycler -t $THREADS -1 $R1 -2 $R2 -o "$OUTDIR"/"$ACC"/ 
fi

# Statistics
seqfu stats -b -n "$OUTDIR"/"$ACC"/assembly.fasta > "$OUTDIR"/"$ACC"/assembly.stats.txt
seqfu stats -b    "$OUTDIR"/"$ACC"/assembly.fasta > "$OUTDIR"/"$ACC"/assembly.stats.tsv
fu-cov "$OUTDIR"/"$ACC"/assembly.fasta --min-cov 0.8 --min-len 100 > "$OUTDIR"/"$ACC"/assembly.coverage.fasta


# Annotation
if [[ ! -e "$OUTDIR"/"$ACC"/prokka/prokka.faa ]]; then
   prokka --cpus $THREADS -o "$OUTDIR"/"$ACC"/prokka --prefix prokka "$OUTDIR"/"$ACC"/assembly.fasta --force 
fi

if [[ ! -e "$OUTDIR"/"$ACC"/eggnog.emapper.hits ]]; then
    emapper.py --cpu $THREADS -i "$OUTDIR"/"$ACC"/prokka.faa -o "$OUTDIR"/"$ACC"/eggnog
fi

if [[ $CLEAN -eq 1 ]]; then
    rm -rf "$OUTDIR"/"$ACC"/*.gfa || true
    gzip -f "$OUTDIR"/"$ACC"/*.fasta  || true
fi

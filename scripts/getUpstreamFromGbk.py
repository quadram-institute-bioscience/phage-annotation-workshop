#!/usr/bin/env python3
# Andrea Telatin 2021 - Phage Annotation Workshop

"""
Read a GenBank file (gbk) and return the upstream sequences of each feature
"""

import sys, os
import argparse
from Bio import SeqIO

if __name__ == "__main__":
    args = argparse.ArgumentParser(description="Read a GenBank file (gbk) and return the upstream sequences of each feature")
    args.add_argument("-i", "--input", help="Input file", required=True)
    args.add_argument("-o", "--output", help="Output file")
    args.add_argument("-l", "--length", help="Length of upstream sequence [default: %(default)s]", default=100)
    args.add_argument("-t", "--type", help="Record type [default: %(default)s]", default="CDS")
    args = args.parse_args()

    if not os.path.isfile(args.input):
        print("ERROR: Input file not found")
        sys.exit(1)

    if args.output:
        output = open(args.output, "w")
    else:
        output = sys.stdout

    # get all sequence records for the specified genbank file
    recs = [rec for rec in SeqIO.parse(args.input, "genbank")]
 

    for rec in recs:

        feats = [feat for feat in rec.features if feat.type == args.type]
        for feat in feats:
            # get the upstream sequence: calculate start and end postitions of the slice
            if feat.location.start < int(args.length):
                start = 0
            else:
                start = feat.location.start - int(args.length)

            if feat.location.end + int(args.length) > len(rec.seq):
                end = len(rec.seq)
            else:
                end = feat.location.end + int(args.length)

            # Slice depending on the strand
            if feat.location.strand == 1:
                strand = "+"
                seq = rec.seq[start:feat.location.start]
            else:
                strand = "-"
                seq = rec.seq[feat.location.end:end].reverse_complement()

            # Sequence name
            name=feat.qualifiers["locus_tag"][0]
            name += " coords="   + str(feat.location.start) + "-" + str(feat.location.end) + " strand=" + strand
            name += " product='" + feat.qualifiers["product"][0] + "'"
            name += " upstream=" + str(args.length) + " slice=" + str(start) + "-" + str(end)
            
            print(">" , name, "\n", seq, sep="", file=output)


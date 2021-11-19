#!/usr/bin/env python3
# Andrea Telatin 2021 - Phage Annotation Workshop

"""
Extract protein sequences from GBK files
"""

import sys, os
import argparse
from Bio import SeqIO

if __name__ == "__main__":
    args = argparse.ArgumentParser(description="Read a GenBank file (gbk) and return the upstream sequences of each feature")
    args.add_argument("-i", "--input", help="Input file", required=True)
    args.add_argument("-o", "--output", help="Output file")
    args.add_argument("-k", "--key", help="Use this field as sequence name [default: %(default)s]", default="locus_tag")
    args.add_argument("-p", "--prefix", help="If --key is not found, use a prefix [default: %(default)s]", default="gp")
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
 
    c = 0
    for rec in recs:

        feats = [feat for feat in rec.features if feat.type == args.type]
        for feat in feats:
            c += 1
            seq = feat.extract(rec.seq).translate()[:-1]

            name = args.prefix + str(c)
            if args.key in feat.qualifiers:
                name = feat.qualifiers[args.key][0]
            print(">",name, "\n", seq, sep="", file=output)
            


"""Collect each sample's final bins as <sample>_<bin>.fa and write dRep's genomeInfo.

Inputs per sample (same order as --samples): a folder of <bin>.fasta and its stats table
(select_reassembled_bins.py layout: bin, completeness, contamination, GC, lineage, N50, size,
version). Outputs: the renamed bins, genomeInfo.csv (genome,completeness,contamination) and one
table of all bins across samples.
"""

import argparse
import csv
import os
import shutil


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--samples", nargs="+", required=True)
    ap.add_argument("--bins", nargs="+", required=True)
    ap.add_argument("--stats", nargs="+", required=True)
    ap.add_argument("--out-bins", required=True)
    ap.add_argument("--out-info", required=True)
    ap.add_argument("--out-table", required=True)
    args = ap.parse_args()
    if not len(args.samples) == len(args.bins) == len(args.stats):
        ap.error("--samples, --bins and --stats must have the same length")

    os.makedirs(args.out_bins, exist_ok=True)
    info_rows = []
    table_rows = []
    header = None
    for sample, bins_dir, stats in zip(args.samples, args.bins, args.stats):
        with open(stats) as fh:
            reader = csv.reader(fh, delimiter="\t")
            header = next(reader)
            rows = list(reader)
        for row in rows:
            genome = "%s_%s.fa" % (sample, row[0])
            shutil.copy(os.path.join(bins_dir, row[0] + ".fasta"), os.path.join(args.out_bins, genome))
            info_rows.append([genome, row[1], row[2]])
            table_rows.append([sample, genome] + row)
        print("%s: %d bins" % (sample, len(rows)))

    with open(args.out_info, "w", newline="") as fh:
        writer = csv.writer(fh)
        writer.writerow(["genome", "completeness", "contamination"])
        writer.writerows(info_rows)
    with open(args.out_table, "w", newline="") as fh:
        writer = csv.writer(fh, delimiter="\t")
        writer.writerow(["sample", "genome"] + header)
        writer.writerows(table_rows)
    print("total: %d bins" % len(info_rows))


if __name__ == "__main__":
    main()

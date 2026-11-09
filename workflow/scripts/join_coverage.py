"""Join per-sample CoverM genome tables onto dRep's Widb.csv.

Each CoverM table: `Genome` (fasta name without extension) plus one column per method, labelled
`<read file> <Method>`. Output: Widb.csv columns, then `<sample>_<method>` per sample (TSV).
Genomes absent from a CoverM table get NA. Runs in the metawrap2 container.
"""

import argparse
import csv
from pathlib import Path


def read_coverm(path):
    with open(path) as f:
        rows = list(csv.reader(f, delimiter="\t"))
    header, body = rows[0], rows[1:]
    # "<read file> Relative Abundance (%)" -> relative_abundance_pct
    methods = ["_".join(h.split(" ")[1:]).lower().replace("_(%)", "_pct") for h in header[1:]]
    return methods, {r[0]: r[1:] for r in body}


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--widb", required=True)
    p.add_argument("--samples", nargs="+", required=True)
    p.add_argument("--coverm-dir", required=True)
    p.add_argument("--out", required=True)
    args = p.parse_args()

    with open(args.widb) as f:
        widb = list(csv.DictReader(f))
    header = list(widb[0].keys()) if widb else ["genome"]

    tables = {}
    for s in args.samples:
        path = Path(args.coverm_dir) / f"{s}.tsv"
        if path.is_file():
            tables[s] = read_coverm(path)
    for s, (methods, _) in tables.items():
        header += [f"{s}_{m}" for m in methods]

    with open(args.out, "w", newline="") as f:
        w = csv.writer(f, delimiter="\t", lineterminator="\n")
        w.writerow(header)
        for row in widb:
            name = row["genome"].removesuffix(".fa")
            out = list(row.values())
            for methods, cov in tables.values():
                out += cov.get(name, ["NA"] * len(methods))
            w.writerow(out)


if __name__ == "__main__":
    main()

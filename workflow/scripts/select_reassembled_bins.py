"""Choose the best version (orig/strict/permissive) of each reassembled bin with CheckM2.

  stage   copy reassembled_bins/<bin>.{strict,permissive}.fasta and original_bins/<bin>.fasta
          (as <bin>.orig.fasta) into one candidates folder
  select  convert CheckM2's quality_report.tsv to MetaWrap2's .stats layout, pick with
          metawrap2.scripts.choose_best_bin, copy each winner to <out-bins>/<bin>.fasta

Runs in the metawrap2 container.
"""

import argparse
import os
import shutil
import subprocess
import sys

from metawrap2.checkm import STATS_HEADER, summarize_checkm2, write_stats

FASTA = ".fasta"
ORIG = "orig"
FINAL_HEADER = list(STATS_HEADER) + ["version"]


def stage(args):
    reassembled = os.path.join(args.reassembly, "reassembled_bins")
    original = os.path.join(args.reassembly, "original_bins")
    os.makedirs(args.candidates)
    n_reassembled = n_orig = 0
    for name in sorted(os.listdir(reassembled)):
        if name.endswith(FASTA):
            shutil.copy(os.path.join(reassembled, name), args.candidates)
            n_reassembled += 1
    for name in sorted(os.listdir(original)):
        if name.endswith(FASTA):
            stem = name[: -len(FASTA)]
            shutil.copy(
                os.path.join(original, name),
                os.path.join(args.candidates, "%s.%s%s" % (stem, ORIG, FASTA)),
            )
            n_orig += 1
    print("staged %d reassemblies and %d original bins" % (n_reassembled, n_orig))


def write_final(rows, path):
    rows = sorted(rows, key=lambda r: float(r[1]), reverse=True)
    with open(path, "w") as fh:
        fh.write("\t".join(FINAL_HEADER) + "\n")
        fh.writelines("\t".join(row) + "\n" for row in rows)


def select(args):
    os.makedirs(args.out_bins, exist_ok=True)
    if not os.path.isfile(args.report):
        write_final([], args.out_stats)
        print("no candidates; 0 bins selected")
        return

    rows = summarize_checkm2(args.report)
    candidates_stats = os.path.join(os.path.dirname(args.out_stats), "candidates.stats.tsv")
    write_stats(rows, candidates_stats)

    chosen = subprocess.run(
        [
            sys.executable,
            "-m",
            "metawrap2.scripts.choose_best_bin",
            candidates_stats,
            str(args.completeness),
            str(args.contamination),
        ],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    ).stdout.split()

    by_name = {row[0]: row for row in rows}
    final_rows = []
    counts = {}
    for name in chosen:
        bin_name, _, style = name.rpartition(".")
        shutil.copy(
            os.path.join(args.candidates, name + FASTA),
            os.path.join(args.out_bins, bin_name + FASTA),
        )
        final_rows.append([bin_name] + by_name[name][1:] + [style])
        counts[style] = counts.get(style, 0) + 1
    write_final(final_rows, args.out_stats)
    n_bins = len({row[0].rpartition(".")[0] for row in rows})
    print(
        "%d of %d bins selected (%s)"
        % (
            len(chosen),
            n_bins,
            ", ".join("%s %d" % (s, counts.get(s, 0)) for s in (ORIG, "strict", "permissive")),
        )
    )


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="command", required=True)

    p = sub.add_parser("stage")
    p.add_argument("--reassembly", required=True, help="reassemble_bins output directory")
    p.add_argument("--candidates", required=True, help="folder to stage all versions into")
    p.set_defaults(func=stage)

    p = sub.add_parser("select")
    p.add_argument("--candidates", required=True)
    p.add_argument("--report", required=True, help="CheckM2 quality_report.tsv")
    p.add_argument("--completeness", type=float, required=True)
    p.add_argument("--contamination", type=float, required=True)
    p.add_argument("--out-bins", required=True)
    p.add_argument("--out-stats", required=True)
    p.set_defaults(func=select)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()

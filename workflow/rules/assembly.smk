# Assembly: metaSPAdes with cleaned Illumina PE, plus cleaned ONT for the hybrid type.

SPADES_KEEP = [
    "contigs.fasta",
    "scaffolds.fasta",
    "contigs.paths",
    "scaffolds.paths",
    "assembly_graph_with_scaffolds.gfa",
    "spades.log",
    "params.txt",
]


rule spades:
    input:
        r1=rules.read_qc.output.r1,
        r2=rules.read_qc.output.r2,
        ont=ont_reads,
    output:
        contigs=TMP / "spades" / "{sample}" / "contigs.fasta",
    params:
        outdir=lambda wildcards, output: Path(output.contigs).parent,
        mem_gb=mem_gb,
        nanopore=nanopore_flag,
        keep=" ".join(f"! -name {n}" for n in SPADES_KEEP),
    container:
        sif("spades")
    threads: res("spades", "threads")
    resources:
        mem_mb=res("spades", "mem_mb"),
        runtime=res("spades", "runtime"),
    log:
        "logs/{assembly_type}/spades/{sample}.log",
    benchmark:
        "benchmarks/{assembly_type}/spades/{sample}.tsv"
    shell:
        """
        rm -rf {params.outdir}
        spades.py --meta -1 {input.r1} -2 {input.r2} {params.nanopore} \
            -t {threads} -m {params.mem_gb} -o {params.outdir} > {log} 2>&1
        # Drop per-k intermediates, corrected reads and tmp.
        find {params.outdir} -mindepth 1 -maxdepth 1 {params.keep} -exec rm -rf {{}} +
        """

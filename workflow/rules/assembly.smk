# Hybrid assembly: metaSPAdes with cleaned Illumina PE + cleaned ONT.

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
        ont=rules.nano_dehost.output.fq,
    output:
        contigs=TMP / "spades" / "{sample}" / "contigs.fasta",
    params:
        outdir=lambda wildcards, output: Path(output.contigs).parent,
        mem_gb=mem_gb,
        keep=" ".join(f"! -name {n}" for n in SPADES_KEEP),
    container:
        sif("spades")
    threads: res("spades", "threads")
    resources:
        mem_mb=res("spades", "mem_mb"),
        runtime=res("spades", "runtime"),
    log:
        "logs/spades/{sample}.log",
    benchmark:
        "benchmarks/spades/{sample}.tsv"
    shell:
        """
        rm -rf {params.outdir}
        spades.py --meta -1 {input.r1} -2 {input.r2} --nanopore {input.ont} \
            -t {threads} -m {params.mem_gb} -o {params.outdir} > {log} 2>&1
        # Drop per-k intermediates, corrected reads and tmp.
        find {params.outdir} -mindepth 1 -maxdepth 1 {params.keep} -exec rm -rf {{}} +
        """

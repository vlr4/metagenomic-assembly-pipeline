# Initial binning: MetaWrap2 binning with metaBAT2, MaxBin2, CONCOCT, SemiBin2 (short-read coverage).

BINNERS = ["metabat2", "maxbin2", "concoct", "semibin2"]


rule binning:
    input:
        contigs=rules.spades.output.contigs,
        r1=rules.read_qc.output.r1,
        r2=rules.read_qc.output.r2,
        toml=rules.metawrap2_config.output.toml,
    output:
        **{b: directory(TMP / "binning" / "{sample}" / f"{b}_bins") for b in BINNERS},
    params:
        outdir=str(TMP / "binning" / "{sample}"),
        mem_gb=mem_gb,
        binners=" ".join(f"--{b}" for b in BINNERS),
    container:
        sif("metawrap2")
    threads: res("binning", "threads")
    resources:
        mem_mb=res("binning", "mem_mb"),
        runtime=res("binning", "runtime"),
    log:
        "logs/{assembly_type}/binning/{sample}.log",
    benchmark:
        "benchmarks/{assembly_type}/binning/{sample}.tsv"
    shell:
        """
        metawrap2 --force binning --config {input.toml} \
            -a {input.contigs} -o {params.outdir} -t {threads} -m {params.mem_gb} \
            {params.binners} {input.r1} {input.r2} > {log} 2>&1
        """

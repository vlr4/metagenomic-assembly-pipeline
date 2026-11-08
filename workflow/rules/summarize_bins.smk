# Summary (all samples): final bins as {sample}_{bin}.fa + dRep genomeInfo.

rule summarize_bins:
    input:
        bins=expand(TMP / "reassembly_select" / "{sample}" / "bins", sample=SAMPLES),
        stats=expand(TMP / "reassembly_select" / "{sample}" / "bins.stats.tsv", sample=SAMPLES),
    output:
        bins=directory(RES / "metawrap_bins" / "hybrid" / "bins"),
        info=RES / "metawrap_bins" / "hybrid" / "hybrid_genomeInfo.csv",
        table=RES / "metawrap_bins" / "hybrid" / "hybrid_bins.tsv",
    params:
        script=SCRIPTS / "summarize_bins.py",
        samples=" ".join(SAMPLES),
    container:
        sif("metawrap2")
    threads: res("summarize_bins", "threads")
    resources:
        mem_mb=res("summarize_bins", "mem_mb"),
        runtime=res("summarize_bins", "runtime"),
    log:
        "logs/summarize_bins.log",
    benchmark:
        "benchmarks/summarize_bins.tsv"
    shell:
        """
        python {params.script} --samples {params.samples} --bins {input.bins} \
            --stats {input.stats} --out-bins {output.bins} --out-info {output.info} \
            --out-table {output.table} > {log} 2>&1
        """

# Dereplication (all samples): dRep with Chen's parameters, CheckM2 stats as genomeInfo.

rule drep:
    input:
        bins=rules.summarize_bins.output.bins,
        info=rules.summarize_bins.output.info,
    output:
        work=directory(TMP / "drep" / "hybrid"),
        final=directory(RES / "drep_bins" / "hybrid" / "dereplicated_genomes"),
    params:
        drep=config["drep"]["params"],
    container:
        sif("drep")
    threads: res("drep", "threads")
    resources:
        mem_mb=res("drep", "mem_mb"),
        runtime=res("drep", "runtime"),
    log:
        "logs/drep.log",
    benchmark:
        "benchmarks/drep.tsv"
    shell:
        """
        dRep dereplicate {output.work} -g {input.bins}/*.fa \
            {params.drep} -comp {COMP} -con {CONT} -p {threads} \
            --genomeInfo {input.info} > {log} 2>&1
        cp -r {output.work}/dereplicated_genomes {output.final}
        """

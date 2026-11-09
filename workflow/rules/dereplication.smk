# Dereplication (all samples of one assembly type; types are not pooled): dRep with Chen's parameters, CheckM2 stats as genomeInfo.

rule drep:
    input:
        bins=rules.summarize_bins.output.bins,
        info=rules.summarize_bins.output.info,
    output:
        work=directory(TMP / "drep" / "{assembly_type}"),
        final=directory(RES / "drep_bins" / "{assembly_type}" / "dereplicated_genomes"),
    params:
        drep=config["drep"]["params"],
    container:
        sif("drep")
    threads: res("drep", "threads")
    resources:
        mem_mb=res("drep", "mem_mb"),
        runtime=res("drep", "runtime"),
    log:
        "logs/{assembly_type}/drep.log",
    benchmark:
        "benchmarks/{assembly_type}/drep.tsv"
    shell:
        """
        dRep dereplicate {output.work} -g {input.bins}/*.fa \
            {params.drep} -comp {COMP} -con {CONT} -p {threads} \
            --genomeInfo {input.info} > {log} 2>&1
        cp -r {output.work}/dereplicated_genomes {output.final}
        """

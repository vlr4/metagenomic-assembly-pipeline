# Refinement: MetaWrap2 bin_refinement with CheckM2 (GUNC in production only).

rule bin_refinement:
    input:
        **{b: rules.binning.output[b] for b in BINNERS},
        toml=rules.metawrap2_config.output.toml,
    output:
        bins=directory(TMP / "bin_refinement" / "{sample}" / REFINED),
        stats=TMP / "bin_refinement" / "{sample}" / f"{REFINED}.stats.tsv",
        # contig -> bin map; needed downstream for ARG attribution (reassembly renames contigs).
        contigs=TMP / "bin_refinement" / "{sample}" / f"{REFINED}.contigs.tsv",
    params:
        outdir=str(TMP / "bin_refinement" / "{sample}"),
        mem_gb=mem_gb,
        gunc="" if config["gunc"]["enabled"] else "--skip-gunc",
    container:
        sif("metawrap2")
    threads: res("bin_refinement", "threads")
    resources:
        mem_mb=res("bin_refinement", "mem_mb"),
        runtime=res("bin_refinement", "runtime"),
    log:
        "logs/{assembly_type}/bin_refinement/{sample}.log",
    benchmark:
        "benchmarks/{assembly_type}/bin_refinement/{sample}.tsv"
    shell:
        """
        # MetaWrap2 2.1.3 reads CHECKM2DB from $METAWRAP2_CONFIG, not from --config.
        METAWRAP2_CONFIG={input.toml} \
        metawrap2 --force bin_refinement --config {input.toml} \
            -o {params.outdir} -t {threads} -m {params.mem_gb} -c {COMP} -x {CONT} \
            --checkm2 {params.gunc} \
            -A {input.metabat2} -B {input.maxbin2} -C {input.concoct} -D {input.semibin2} \
            > {log} 2>&1
        # With no passing bins MetaWrap2 writes no membership table.
        [ -f {output.contigs} ] || : > {output.contigs}
        """

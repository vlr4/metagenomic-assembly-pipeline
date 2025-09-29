rule dereplication:
    input:
        genomes = expand(str(base / "result/metawrap_bins/hybrid/{sample}_*.fa"), sample=SAMPLES),
        info    = str(base / "result/metawrap_bins/hybrid/hybrid_genomeInfo.csv")
    output:
        comparisons = str(base / "hybrid_temp/drep/hybrid/Cdb.csv")
    params:
        outdir = str(base / "hybrid_temp/drep/hybrid"),
        final  = str(base / "result/drep_bins/hybrid")
    threads: 80
    resources:
        mem_mb = 64000
    shell:
        """
        source activate drep
        dRep dereplicate {params.outdir} \
            -g {base}/result/metawrap_bins/hybrid/*fa \
            -pa 0.9 -sa 0.95 -nc 0.30 -cm larger \
            -comp 70 -con 10 \
            -p {threads} \
            --genomeInfo {input.info}

        mkdir -p {params.final}
        cp -r {params.outdir}/dereplicated_genomes {params.final}/
        """
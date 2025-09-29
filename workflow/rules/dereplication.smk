rule dereplication:
    input:
        bins = str(base / "result/metawrap_bins/hybrid"),
        info    = str(base / "result/metawrap_bins/hybrid/hybrid_genomeInfo.csv")
    output:
        comparisons = str(base / "hybrid_temp/drep/hybrid/Widb.csv")
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
            -g {input.bins}/*fa \
            -pa 0.9 -sa 0.95 -nc 0.30 -cm larger \
            -comp 70 -con 10 \
            -p {threads} \
            --genomeInfo {input.info}

        mkdir -p {params.final}
        cp -r {params.outdir}/dereplicated_genomes {params.final}/
        """
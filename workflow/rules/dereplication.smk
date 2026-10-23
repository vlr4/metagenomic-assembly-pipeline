rule dereplication:
    input:
        bins = BASE / "result/metawrap_bins/hybrid",
        info = BASE / "result/metawrap_bins/hybrid/hybrid_genomeInfo.csv"
    output:
        comparisons = str(BASE / "hybrid_temp/drep/hybrid/data_tables/Cdb.csv"),
        final_dir = directory(BASE / "result/drep_bins/hybrid")
    params:
        outdir = subpath(output.comparisons, ancestor=2),
        
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
        mkdir -p {output.final_dir}
        rm -rf {output.final_dir}/dereplicated_genomes
        cp -r {params.outdir}/dereplicated_genomes {output.final_dir}/
        """
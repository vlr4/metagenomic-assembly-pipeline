rule denovo_classify:
    input:
        bins = str(base / "result/metawrap_bins/hybrid")
    output:
        log = str(base / "result/classify/de_novo_classify/gtdbtk.log")
    params:
        outdir = str(base / "result/classify/de_novo_classify"),
        outgroup = "p__Patescibacteria"
    threads: 20
    shell:
        """
        source activate gtdbtk
        gtdbtk de_novo_wf \
          --genome_dir {input.bins} \
          --out_dir {params.outdir} \
          --bacteria \
          --outgroup_taxon  {params.outgroup}\
          --cpus {threads} \
          -x fa \
          --prefix de_novo
        """
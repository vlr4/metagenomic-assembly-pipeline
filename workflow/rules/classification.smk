rule classification:
    input:
        bins = str(base / "result/metawrap_bins/hybrid"),
        mashdb = config["gtdbtk"]["mash_db"]
    output:
        classify_summary = str(base / "result/classify/hybrid.summary.tsv"),
        bac_tree = str(base / "result/classify/bac120_infer_out/gtdbtk.bac120.classify.tree"),
        ar_tree = str(base / "result/classify/ar122_infer_out/gtdbtk.ar122.classify.tree"),
        denovo_tree = str(base / "result/de_novo_classify/de_novo.bac120.classify.tree")
    params:
        classify_out = str(base / "result/classify"),
        bac_out = str(base / "result/classify/bac120_infer_out"),
        ar_out = str(base / "result/classify/ar122_infer_out"),
        denovo_out = str(base / "result/de_novo_classify")
    threads: 20
    resources:
        mem_mb = 100000
    shell:
        """
        source activate gtdbtk

        gtdbtk classify_wf \
          --genome_dir {input.bins} \
          --out_dir {params.classify_out} \
          --mash_db {input.mashdb} \
          --cpus {threads} \
          -x fa \
          --prefix hybrid
        
        gunzip {params.classify_out}/align/hybrid.bac120.user_msa.fasta.gz
        
        gtdbtk infer \
          --msa_file {params.classify_out}/align/hybrid.bac120.user_msa.fasta \
          --out_dir {params.bac_out} \
          --cpu {threads}

        gtdbtk infer \
          --msa_file {params.classify_out}/align/hybrid.ar122.user_msa.fasta \
          --out_dir {params.ar_out} \
          --cpu {threads}

        gtdbtk de_novo_wf \
          --genome_dir {input.bins} \
          --out_dir {params.denovo_out} \
          --extension fa \
          --bacteria \
          --outgroup_taxon p__Patescibacteria \
          --prefix de_novo \
          --cpus {threads}
        """

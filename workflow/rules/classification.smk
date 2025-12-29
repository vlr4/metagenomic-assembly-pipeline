checkpoint gtdbtk_classify:
    input:
        bins = str(base / "result/metawrap_bins/hybrid")
    output:
        summary = str(base / "result/classify/hybrid.bac120.summary.tsv")
    params:
        outdir = str(base / "result/classify"),
        mashdb = config["gtdbtk"]["mash_db"],
        msa_dir = str(base / "result/classify/align/")
    threads: 20
    shell:
        """
        export GTDBTK_DATA_PATH={params.mashdb}
        source activate gtdbtk
        gtdbtk classify_wf \
          --genome_dir {input.bins} \
          --out_dir {params.outdir} \
          --mash_db {params.mashdb} \
          --cpus {threads} \
          -x fa \
          --prefix hybrid
        gzip -d {params.msa_dir}*.gz
        """

rule infer_bacteria:
    input:
        msa = str(base / "result/classify/align/hybrid.bac120.user_msa.fasta")
    output:
        tree = str(base / "result/classify/bac120_infer_out/gtdbtk.unrooted.tree")
    params:
        outdir_bac = str(base / "result/classify/bac120_infer_out")
    threads: 20
    shell:
        """
        source activate gtdbtk
        gtdbtk infer \
          --msa_file {input.msa} \
          --out_dir {params.outdir_bac} \
          --cpu {threads}
        """

rule infer_archaea:
    input:
        msa = str(base / "result/classify/align/hybrid.ar122.user_msa.fasta")
    output:
        tree = str(base / "result/classify/ar122_infer_out/gtdbtk.unrooted.tree")
    params:
        outdir_ar = str(base / "result/classify/ar122_infer_out")
    threads: 20
    shell:
        """
        source activate gtdbtk
        gtdbtk infer \
          --msa_file {input.msa} \
          --out_dir {params.outdir_ar} \
          --cpu {threads}
        """


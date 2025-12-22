checkpoint gtdbtk_classify:
    input:
        bins = str(base / "result/metawrap_bins/hybrid"),
        mashdb = config["gtdbtk"]["mash_db"]
    output:
        summary = str(base / "result/classify/hybrid.summary.tsv")
    params:
        outdir = str(base / "result/classify")
    threads: 20
    shell:
        """
        source activate gtdbtk
        gtdbtk classify_wf \
          --genome_dir {input.bins} \
          --out_dir {params.outdir} \
          --mash_db {input.mashdb} \
          --cpus {threads} \
          -x fa \
          --prefix hybrid
        """

rule infer_bacteria:
    input:
        msa = str(base / "result/classify/align/hybrid.bac120.user_msa.fasta")
    output:
        tree = str(base / "result/classify/bac120_infer_out/gtdbtk.bac120.classify.tree")
    threads: 20
    shell:
        """
        source activate gtdbtk
        gtdbtk infer \
          --msa_file {input.msa} \
          --out_dir {dirname(output.tree)} \
          --cpu {threads}
        """

rule infer_archaea:
    input:
        msa = str(base / "result/classify/align/hybrid.ar122.user_msa.fasta")
    output:
        tree = str(base / "result/classify/ar122_infer_out/gtdbtk.ar122.classify.tree")
    threads: 20
    shell:
        """
        source activate gtdbtk
        gtdbtk infer \
          --msa_file {input.msa} \
          --out_dir {dirname(output.tree)} \
          --cpu {threads}
        """


rule binning:
    input:
        assembly = BASE / config['output']['assembly']['spades'] / "{sample}_assembly" / "contigs.fasta",
        r1 = BASE / config["output"]["qc"]["read_qc"] / "{sample}" / "final_pure_reads_1.fastq",
        r2 = BASE / config["output"]["qc"]["read_qc"] / "{sample}" / "final_pure_reads_2.fastq"
    output:
        concoct_dir = directory(SYMLINK / "{sample}_binning" / "concoct_bins"),
        metabat2_dir = directory(SYMLINK / "{sample}_binning" / "metabat2_bins"),
        maxbin2_dir  = directory(SYMLINK / "{sample}_binning" / "maxbin2_bins"),
        concoct_bin = SYMLINK / "{sample}_binning" / "concoct_bins" / "bin.1.fa",
        metabat2_bin = SYMLINK / "{sample}_binning" / "metabat2_bins/bin.1.fa",
        maxbin2_bin = SYMLINK / "{sample}_binning" / "maxbin2_bins/bin.1.fa"
    params: 
        sample_dir = subpath(output.concoct_dir, parent=True)
    threads: config["threads"]["binning"]
#    conda: "../envs/metawrap.yaml"
    shell:
        """
        source activate metawrap-env
        export OPENBLAS_NUM_THREADS=1
        metawrap binning \
          -o {params.sample_dir} \
          -t {threads} \
          -a {input.assembly} \
          --concoct --metabat2 --maxbin2 \
          {input.r1} {input.r2}
        """

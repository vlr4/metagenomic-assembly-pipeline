rule binning:
    input:
        assembly = lambda wc: str(BASE / f"{config['output']['assembly']['spades']}/{wc.sample}_assembly/contigs.fasta"),
        r1 = lambda wc: str(BASE / f"{config['output']['qc']['read_qc']}/{wc.sample}/final_pure_reads_1.fastq"),
        r2 = lambda wc: str(BASE / f"{config['output']['qc']['read_qc']}/{wc.sample}/final_pure_reads_2.fastq")
    output:
        concoct_bin = BASE / config['output']['assembly']['binning'] / "{sample}_binning" / "concoct_bins" / "bin.1.fa",
        metabat2 = BASE / config['output']['assembly']['binning'] / "{sample}_binning" / "metabat2_bins/bin.1.fa",
        maxbin2 = BASE / config['output']['assembly']['binning'] / "{sample}_binning" / "maxbin2_bins/bin.1.fa"
    params: 
        sample_dir = lambda wc: str(BASE / config['output']['assembly']['binning'] / f"{wc.sample}_binning")
    threads: config["threads"]["binning"]
#    conda: "../envs/metawrap.yaml"
    shell:
        """
        source activate metawrap-env
        export OPENBLAS_NUM_THREADS=1
        mkdir -p {params.sample_dir}
        metawrap binning \
          -o {params.sample_dir} \
          -t {threads} \
          -a {input.assembly} \
          --concoct --metabat2 --maxbin2 \
          {input.r1} {input.r2}
        """

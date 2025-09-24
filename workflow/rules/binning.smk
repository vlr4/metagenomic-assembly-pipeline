rule binning:
    input:
        assembly = lambda wc: str(base / f"{config['output']['assembly']['spades']}/{wc.sample}_assembly/contigs.fasta"),
        r1 = lambda wc: str(base / f"{config['output']['qc']['read_qc']}/{wc.sample}/final_pure_reads_1.fastq"),
        r2 = lambda wc: str(base / f"{config['output']['qc']['read_qc']}/{wc.sample}/final_pure_reads_2.fastq")
    output:
#        concoct_dir = directory(base / f"{config['output']['assembly']['binning']}/{{sample}}_binning/concoct_bins")
        metabat2_dir = directory(base / f"{config['output']['assembly']['binning']}/{{sample}}_binning/metabat2_bins")
        maxbin2_dir = directory(base / f"{config['output']['assembly']['binning']}/{{sample}}_binning/maxbin2_bins")
    params: 
        bin_dir = str(base / {config['output']['assembly']['binning']})
        sample_dir = str(base / f"{config['output']['assembly']['binning']}/{{sample}}_binning")
    threads: config["threads"]["binning"]
#    conda: "../envs/metawrap.yaml"
    shell:
        """
        source activate metawrap-env
        mkdir -p {params.bin_dir}
        metawrap binning \
          -o {params.sample_dir} \
          -t {threads} \
          -a {input.assembly} \
          --metabat2 --maxbin2 \
          {input.r1} {input.r2}
        """

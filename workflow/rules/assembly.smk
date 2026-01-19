rule assembly:
    input:
        r1 = lambda wc: str(base / f"{config['output']['qc']['read_qc']}/{wc.sample}/final_pure_reads_1.fastq"),
        r2 = lambda wc: str(base / f"{config['output']['qc']['read_qc']}/{wc.sample}/final_pure_reads_2.fastq"),
        nano = lambda wc: str(base / f"{config['output']['dehost']['sam']}/nano.{wc.sample}.dehost.fq.gz")
    output:
        spades_contigs = str(base / f"{config['output']['assembly']['spades']}/{{sample}}_assembly/contigs.fasta") 
    params:
        spades_dir = str(base /  f"{config['output']['assembly']['spades']}/{{sample}}_assembly"),
        spades_opts = config["spades"]["options"],
        spades_mem = config["spades"]["memory"]
    threads: config["threads"]["spades"]
#    conda: "../envs/spades.yaml"
    shell:
        """
        source activate metawrap-env
        mkdir -p {params.spades_dir}
        spades.py {params.spades_opts} \
          -1 {input.r1} -2 {input.r2} \
          --nanopore {input.nano} \
          --threads {threads} --memory {params.spades_mem} \
          -o {params.spades_dir}
        """

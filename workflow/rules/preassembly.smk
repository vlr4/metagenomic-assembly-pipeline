rule preassembly:
    input:
        r1 = lambda wc: str(base / f"{config["output"]["qc"]["read_qc"]}/{wc.sample}/final_pure_reads_1.fastq"),
        r2 = lambda wc: str(base / f"{config["output"]["qc"]["read_qc"]}/{wc.sample}/final_pure_reads_2.fastq"),
        nano = lambda wc: str(base / f"{config["output"]["dehost"]["sam"]}/nano.{wc.sample}.dehost.fq.gz")
    output:
        spades_contigs = str(base / f"{config["output"]["assembly"]["spades"]}/{{sample}}_assembly/contigs.fasta") 
    params:
        spades_dir = str(base /  f"{config["output"]["assembly"]["spades"]}/{{sample}}_assembly"),
        sample_dir = str(base / {config["output"]["assembly"]["spades"]})
    threads: config["spades"]["threads"]
#    conda: "../envs/spades.yaml"
    shell:
        """
        source activate metawrap-env
        mkdir -p {params.spades_dir}
        spades.py {config[spades][options]} \
          -1 {input.r1} -2 {input.r2} \
          --nanopore {input.nano} \
          --threads {threads} --memory {config[spades][memory]} \
          -o {params.sample_dir}
        """

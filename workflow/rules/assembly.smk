rule assembly:
    input:
        r1 = BASE / config["output"]["qc"]["read_qc"] / "{sample}/final_pure_reads_1.fastq",
        r2 = BASE / config["output"]["qc"]["read_qc"] / "{sample}/final_pure_reads_2.fastq",
        nano = BASE / config["output"]["dehost"]["sam"] / "nano.{sample}.dehost.fq.gz"
    output:
        spades_contigs = BASE / config["output"]["assembly"]["spades"] / "{sample}_assembly/contigs.fasta"
    params:
        spades_dir = subpath(output.spades_contigs, parent=True),
        spades_opts = config["spades"]["options"],
        spades_mem = config["spades"]["memory"]
    threads:
        config["threads"]["spades"]
    shell:
        """
        source activate metawrap-env
        spades.py {params.spades_opts} \
          -1 {input.r1} -2 {input.r2} \
          --nanopore {input.nano} \
          --threads {threads} --memory {params.spades_mem} \
          -o {params.spades_dir}
        """

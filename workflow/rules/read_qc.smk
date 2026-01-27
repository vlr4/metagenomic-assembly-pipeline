rule read_qc:
    input:
        r1 = INPUT["short_reads"] / "{sample}_1.fastq",
        r2 = INPUT["short_reads"] / "{sample}_2.fastq",
        bitmask = HUMAN_DIR / f"{HG}.bitmask"
    output:
        pure_r1 = BASE / config["output"]["qc"]["read_qc"] / "{sample}/final_pure_reads_1.fastq",
        pure_r2 = BASE / config["output"]["qc"]["read_qc"] / "{sample}/final_pure_reads_2.fastq",
        host_r1 = BASE / config["output"]["qc"]["read_qc"] / "{sample}/host_reads_1.fastq",
        host_r2 = BASE / config["output"]["qc"]["read_qc"] / "{sample}/host_reads_2.fastq"
    params:
        sample_dir = lambda wc: BASE / config["output"]["qc"]["read_qc"] / wc.sample
    threads:
        config["threads"]["qc"]
    shell:
        """
        source activate metawrap-env
        mkdir -p {params.sample_dir}
        metawrap read_qc -t {threads} {config[metawrap][read_qc_options]} \
            -1 {input.r1} -2 {input.r2} -o {params.sample_dir}
        """

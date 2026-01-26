rule binning:
    input:
        assembly = BASE / config["output"]["assembly"]["spades"] / "{sample}_assembly/contigs.fasta",
        r1 = BASE / config["output"]["qc"]["read_qc"] / "{sample}/final_pure_reads_1.fastq",
        r2 = BASE / config["output"]["qc"]["read_qc"] / "{sample}/final_pure_reads_2.fastq"
    output:
        concoct = BASE / config["output"]["assembly"]["binning"] / "{sample}_binning/concoct_bins/bin.1.fa",
        metabat2 = BASE / config["output"]["assembly"]["binning"] / "{sample}_binning/metabat2_bins/bin.1.fa",
        maxbin2 = BASE / config["output"]["assembly"]["binning"] / "{sample}_binning/maxbin2_bins/bin.1.fa"
    params:
        sample_dir = BASE / config["output"]["assembly"]["binning"] / "{sample}_binning"
    threads:
        config["threads"]["binning"]
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

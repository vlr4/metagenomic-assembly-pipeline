rule reassembly:
    input:
        r1 = BASE / config["output"]["qc"]["read_qc"] / "{sample}/final_pure_reads_1.fastq",
        r2 = BASE / config["output"]["qc"]["read_qc"] / "{sample}/final_pure_reads_2.fastq",
        refined = "m/{sample}_binning/bin_refinement/metawrap_70_10_bins"
    output:
        stats = "m/{sample}_binning/bin_reassembly/reassembled_bins.stats",
        plot = "m/{sample}_binning/bin_reassembly/reassembly_results.png"
    params:
        out_dir = "m/{sample}_binning/bin_reassembly"
    threads:
        12
    resources:
        mem_mb = 200000
    shell:
        """
        source activate metawrap-env
        export PATH=/mnt/apps/users/vtelizhe/conda/envs/metawrap-env/bin:$PATH
        mkdir -p {params.out_dir}
        metawrap reassemble_bins \
          -o {params.out_dir} \
          -1 {input.r1} \
          -2 {input.r2} \
          -b {input.refined} \
          -t {threads} -m 128 -c 70 -x 10
        """

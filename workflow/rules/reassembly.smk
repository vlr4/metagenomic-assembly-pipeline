rule reassembly:
    input:
        r1 = lambda wc: str(base / f"{config["output"]["qc"]["read_qc"]}/{wc.sample}/final_pure_reads_1.fastq"),
        r2 = lambda wc: str(base / f"{config["output"]["qc"]["read_qc"]}/{wc.sample}/final_pure_reads_2.fastq"),
        refined = lambda wc: f"m/{wc.sample}_binning/bin_refinement/metawrap_70_10_bins"   
    output:
        stats = f"m/{{sample}}_binning/bin_reassembly/reassembled_bins.stats",
        plot = f"m/{{sample}}_binning/bin_reassembly/reassembly_results.png"
    params:
        out_dir = f"m/{{sample}}_binning/bin_reassembly"
    
#    conda: "../envs/metawrap.yaml"
    
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
          -t 12 -m 128 -c 70 -x 10 \
          
        """

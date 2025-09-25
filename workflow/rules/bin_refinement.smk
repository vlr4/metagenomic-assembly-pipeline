rule bin_refinement:
    input:
        metabat2 = lambda wc: f"m/{wc.sample}_binning/metabat2_bins",
        maxbin2 = lambda wc: f"m/{wc.sample}_binning/maxbin2_bins",
        concoct = lambda wc: f"m/{wc.sample}_binning/concoct_bins"
    output:
        stats = f"m/{{sample}}_binning/bin_refinement/metawrap_70_10_bins.stats"
    params:
        out_dir = f"m/{{sample}}_binning/bin_refinement"
    threads: config["threads"]["refinement"]
#    conda: "../envs/metawrap.yaml"
    
    shell:
        """
        source activate metawrap-env
        export PATH=/mnt/apps/users/vtelizhe/conda/envs/metawrap-env/bin:$PATH
        mkdir -p {params.out_dir}
        metawrap bin_refinement \
          -o {params.out_dir} \
          -A {input.metabat2} \
          -B {input.maxbin2} \
          -C {input.concoct} \
          -c 70 -x 10 \
          -t {threads}
        """

rule bin_refinement:
    input:
        metabat2 = SYMLINK / "{sample}_binning" / "metabat2_bins",
        maxbin2 = SYMLINK / "{sample}_binning" / "maxbin2_bins",
        concoct = SYMLINK / "{sample}_binning" / "concoct_bins"
    output:
        stats = SYMLINK / "{sample}_binning" / "bin_refinement" / "metawrap_70_10_bins.stats",
        bins  = directory(SYMLINK / "{sample}_binning" / "bin_refinement" / "metawrap_70_10_bins")
    params:
        out_dir = subpath(output.bins, parent=True)
    threads: config["threads"]["refinement"]
#    conda: "../envs/metawrap.yaml"
    
    shell:
        """
        source activate metawrap-env
        export PATH=/mnt/apps/users/vtelizhe/conda/envs/metawrap-env/bin:$PATH
        metawrap bin_refinement \
          -o {params.out_dir} \
          -A {input.metabat2} \
          -B {input.maxbin2} \
          -C {input.concoct} \
          -c 70 -x 10 \
          -t {threads}
        """

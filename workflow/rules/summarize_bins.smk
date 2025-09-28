rule summarize_bins:
    input:
        stats = lambda wc: f"m/{wc.sample}_binning/bin_reassembly/reassembled_bins.stats"
    output:
        csv = str(base / "result/metawrap_bins/hybrid/hybrid_genomeInfo.csv"),
        outdir = directory(str(base / "result/metawrap_bins/hybrid"))
    params:
        outdir = str(base / "result/metawrap_bins/hybrid")
    threads: 2
    resources:
        mem_mb = 16000
    shell:
        """
        mkdir -p {params.outdir}

        csv_out={output.csv}

        # Write header only once
        if [ ! -s "$csv_out" ]; then
            echo "genome,completeness,contamination,GC,lineage,N50,size" > "$csv_out"
        fi

        tail -n +2 {input.stats} | while IFS=$'\t' read -r fa completeness contamination GC lineage N50 size; do
            echo "{wildcards.sample}_${{completeness}}_${{contamination}}_${{fa}}.fa,${{completeness}},${{contamination}},${{GC}},${{lineage}},${{N50}},${{size}}" >> "$csv_out"
            cp m/{wildcards.sample}_binning/bin_reassembly/reassembled_bins/${{fa}}.fa \
               {params.outdir}/{wildcards.sample}_${{completeness}}_${{contamination}}_${{fa}}.fa
        done
        """
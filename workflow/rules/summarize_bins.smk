rule summarize_bins:
    input:
        expand("m/{sample}_binning/bin_reassembly/reassembled_bins.stats", sample=SAMPLES)
    output:
        csv = str(base / "result/metawrap_bins/hybrid/hybrid_genomeInfo.csv")
    params:
        outdir = str(base / "result/metawrap_bins/hybrid")
    threads: 2
    resources:
        mem_mb = 16000
    shell:
        """
        mkdir -p {params.outdir}

        csv_out={params.outdir}/hybrid_genomeInfo.csv
        echo "genome,completeness,contamination,GC,lineage,N50,size" > "$csv_out"

        for stats in {input}; do
            sample=$(basename $(dirname $(dirname "$stats")) | sed 's/_binning//')
            tail -n +2 "$stats" | while IFS=$'\t' read -r fa completeness contamination GC lineage N50 size; do
                echo "${sample}_${completeness}_${contamination}_${fa}.fa,${completeness},${contamination},${GC},${lineage},${N50},${size}" >> "$csv_out"

                cp m/${sample}_binning/bin_reassembly/reassembled_bins/${fa}.fa \
                   {params.outdir}/${sample}_${completeness}_${contamination}_${fa}.fa
            done
        done
        """

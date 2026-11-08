# Container versions

Built 2026-10-23 with Apptainer 1.5.4. Images are not tracked; put them in the directory set as
`sif_dir` in `config/paths.yaml`. Tool versions are from `--version` inside each image.

## Build

Run from the repository root, with `SIF` set to that directory. The two `.def` builds work
unprivileged when fakeroot is available; otherwise add `--fakeroot` or build elsewhere and copy the
images.

```bash
apptainer build $SIF/dehost.sif containers/dehost.def
apptainer build $SIF/metawrap2_2.1.3.sif containers/metawrap2.def
apptainer pull $SIF/spades_4.3.0.sif docker://quay.io/biocontainers/spades:4.3.0--hde4eca7_2
apptainer pull $SIF/drep_3.7.1.sif docker://quay.io/biocontainers/drep:3.7.1--pyhdfd78af_0
sha256sum $SIF/*.sif   # compare with the table below
```

## Images

| Image | Source | Size | sha256 |
|---|---|---|---|
| `dehost.sif` | `containers/dehost.def` (base `mambaorg/micromamba:2.8.0-debian12-slim`) | 155 MB | `e94f3fdc01cf9dc8ea1dd5cdc4a1656a8b45d4a19fcbd4236ab760c7fdee6208` |
| `spades_4.3.0.sif` | `docker://quay.io/biocontainers/spades:4.3.0--hde4eca7_2` | 141 MB | `a284dda57683ca80808e9ce84b41504b7d82b301f2d3a241d0636b48b4ee8a2c` |
| `metawrap2_2.1.3.sif` | `containers/metawrap2.def` (base `condaforge/miniforge3:26.7.2-0`) | 6.2 GB | `b0288c36b399e6ac5329a825644c9d8992edaca8eee03a38c20e250b393c5d0f` |
| `drep_3.7.1.sif` | `docker://quay.io/biocontainers/drep:3.7.1--pyhdfd78af_0` | 593 MB | `1443cc7c8e2457cd66f8d8e557f200ac045ed882193d11f8e5e77947936c82a6` |

## dehost

| Tool | Version |
|---|---|
| minimap2 | 2.31-r1302 |
| samtools / htslib | 1.24 / 1.24 |
| pigz | 2.8 |

## spades

| Tool | Version |
|---|---|
| SPAdes | 4.3.0 |

## metawrap2

MetaWrap2 2.1.3, commit `9e56004124a87f976949eb9c2b886bf5cd6cb5a9` (`/opt/metawrap2/COMMIT` in the image).
mamba 2.9.0. Envs built from upstream `src/metawrap2/envs/locks/<env>.linux-64.lock`.

| Env | Used by | Tool | Version |
|---|---|---|---|
| metawrap2-reads | read_qc, reassemble_bins | fastp | 1.3.7 |
| | | Trim Galore | 2.3.0 |
| | | FastQC | 0.12.1 |
| | | BMTagger / bmtool / srprism | 3.101 / – / 2.4.24-alpha |
| | | SPAdes | 4.3.0 |
| | | bwa | 0.7.19-r1273 |
| | | bowtie2 | 2.5.5 |
| | | minimap2 | 2.31-r1302 |
| | | samtools | 1.24 |
| metawrap2-bins | binning | MetaBAT2 | 2.18 |
| | | MaxBin2 | 2.2.7 |
| | | CONCOCT | 1.1.0 |
| | | minimap2 / samtools | 2.31-r1302 / 1.24 |
| | | bwa-mem2 / CoverM / skani | 2.3 / 0.8.0 / 0.3.2 |
| metawrap2-binqc | bin_refinement (GUNC) | GUNC | 1.1.1 |
| | | CheckM1 | 1.2.5 (unused) |
| | | DAS Tool | 1.1.7 (unused) |
| metawrap2-checkm2 | bin_refinement `--checkm2` | CheckM2 | 1.1.0 |
| | | DIAMOND | 2.1.11 |
| metawrap2-learned | binning `--semibin2` | SemiBin2 | 2.5.0 |
| | | pytorch | 2.13.0 (CUDA 13.0) |
| | | VAMB / COMEBin | 5.0.4 / present (unused) |

## drep

| Tool | Version |
|---|---|
| dRep | 3.7.1 |
| skani | 0.3.2 |
| fastANI | 1.34 |
| Mash | 2.3 |
| MUMmer (nucmer) | 4.0.1 |
| Prodigal | 2.6.3 |
| CheckM1 | present (unused) |

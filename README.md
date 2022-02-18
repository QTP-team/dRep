# dRep
 
## 1. Introduction

Clustering MAGs into SGBs mainly includes three parts:

1) All MAGs were clustered into strain-level genomes (ANI >= 99%);
 
2) Representative genomes which have the maximum genome quality score: completeness - 5x contamination + 0.5log(N50) in each strain cluster were selected;

3) The representative strain genomes were further clustered into the SGBs (ANI >= 95%).

## 2. Install

Install by conda：
```shell
conda env create -n dRep -f environment.yaml
conda active dRep
```

## 3. Usage

### 3.1 Demo data

Prepare MAGs files and MAGs completeness, contamination, length and N50 information.

```shell
$ cat MAGs_checkm.csv
genome  completeness    contamination   length  N50
TP20200814-DZC110_DT2009055438-1_bin.95.fa  91.53   0.65    37042   8993
TP20200814-DZC121_DT2009055449-1_bin.339.fa 97.18   0   108644  43098
TP20200814-DZC132_DT2009055460-1_bin.4.fa   76.01   0.89    9261    3684
TP20200815-DZC19_DT2009055489-1_bin.214.fa  91.02   1.61    31475   10931
TP20200815-DZC24_DT2009055494-1_bin.261.fa  78.32   0.81    26658   5824
```

### 3.2 Parameters

Parameters and file's names can be set in ```config.yaml```.

```yaml
params:
  dRep:
    ### MAGs filter
    min_len: 50000
    completeness: 50
    contamination: 10
    threads: 16
    ### MAGs choose (default: 1xCOM - 5xCNT + 0.5xlog(N50))
    choose_comW: 1
    choose_conW: 5
    choose_strW: 0
    choose_n50: 0.5
assay:
  strain: "1.assay/01.dRep_strain"
  species: "1.assay/02.dRep_species"

logs: "1.assay/logs"
```

### 3.3a. Locally run

First, do dry-run to test.

```shell
snakemake \
--snakefile dereplication.smk \
--configfile config.yaml \
--core 1 \
--dry-run
```

Then use --core to specify the CPU resource to run locally.

```shell
snakemake \
--snakefile dereplication.smk \
--configfile config.yaml \
--core 32 2> smk.log
```

### 3.3b. Cluster execution (qsub)

The CPU and memory required for each step can be set in ```cluster.yaml```，don't forget to update your project_ID and queue in this file.

```yaml
localrules: all

__default__:
  queue: "st.q"
  project: "your_project_ID"
  workdir: "./"
  mem: "1G"
  cores: 1

dRep_strain:
  mem: "100G"
  cores: 8
  output: "1.assay/cluster_logs/{rule}.{wildcards}.o"
  error: "1.assay/cluster_logs/{rule}.{wildcards}.e"

dRep_species:
  mem: "33G"
  cores: 8
  output: "1.assay/cluster_logs/{rule}.{wildcards}.o"
  error: "1.assay/cluster_logs/{rule}.{wildcards}.e"
```

Then, use the following command to post all tasks.

```shell
snakemake \
--snakefile dereplication.smk \
--configfile config.yaml \
--cluster-config cluster.yaml \
--jobs 1 \
--keep-going \
--rerun-incomplete \
--latency-wait 360 \
--cluster "qsub -S /bin/bash -cwd -q {cluster.queue} -P {cluster.project} -l vf={cluster.mem},p={cluster.cores} -binding linear:{cluster.cores} -o {cluster.output} -e {cluster.error}"
```

## 4. Statistical results

1.assay/01.dRep_strain
1.assay/02.dRep_species
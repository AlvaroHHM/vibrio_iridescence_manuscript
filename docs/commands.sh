#!/usr/bin/env bash
# Comandos exactos usados para análisis no-R
# SPAdes v3.15.5
spades.py -1 R1.fastq.gz -2 R2.fastq.gz -o spades_out

# Bakta v1.9.4
bakta --db db --output bakta_out genome.fna

# GTDB-Tk v2.3.2
gtdbtk classify_wf --genome_dir genomes --out_dir gtdb_out

# autoMLST2 (web)
# https://automlst.ziemertlab.com/

# PathogenFinder v1.4 (web)
# https://cge.food.dtu.dk/services/PathogenFinder/

# ResFinder 4.0 (web)
# https://cge.food.dtu.dk/services/ResFinder/

# KmerResistance v2.2 (web)
# https://cge.food.dtu.dk/services/KmerResistance/

# AMRFinderPlus v4.1
amrfinder -n genome.fna -o amrfinder_out.tsv

# antiSMASH v6.0
antismash --genefinding-tool prodigal genome.gbk

# eggNOG-mapper v2.1.12
emapper.py -i proteins.faa -o eggnog_out

# BLAST+ v2.15
blastp -query query.faa -subject subject.faa -outfmt 6

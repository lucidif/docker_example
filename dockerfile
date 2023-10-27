# Utilizza un'immagine base con R 4.3.1
FROM rocker/r-ver:4.3.1

# Installa i pacchetti di sistema necessari per alcuni pacchetti R
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libncurses5-dev

# Installa rtracklayer da Bioconductor
RUN R -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager'); BiocManager::install('edgeR')"

# Configura il container per eseguire R per default
CMD ["R"]




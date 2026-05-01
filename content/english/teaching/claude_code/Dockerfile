# ~/claude-sandbox/Dockerfile

# Use Node.js 20 (slim variant = smaller image, fewer unnecessary packages)
# Always pin to a specific version — never use :latest in sandboxes
FROM node:20-slim

RUN echo "APT::Acquire::Retries \"5\";" > /etc/apt/apt.conf.d/80-retries

# Install essential system tools Claude Code may need
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    ripgrep \
    nano \
    python3 \
    python3-pip \
    gnupg \
    && rm -rf /var/lib/apt/lists/*
    # ↑ Deleting the apt cache keeps the image size small

# Install R from the official CRAN Debian repository
# The key must be fetched from a keyserver by fingerprint — no .asc URL exists for Debian
RUN gpg --keyserver keyserver.ubuntu.com \
        --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' \
    && gpg --armor --export '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' \
        > /etc/apt/trusted.gpg.d/cran_debian_key.asc \
    && echo "deb http://cloud.r-project.org/bin/linux/debian bookworm-cran40/" \
        > /etc/apt/sources.list.d/r-project.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends r-base \
    && rm -rf /var/lib/apt/lists/*

# Install R development dependencies and compilers
# These are required for building R packages from source
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gfortran \
    pkg-config \
    cmake \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libopenblas-dev \
    liblapack-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libgit2-dev \
    libuv1-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages from CRAN
# This installs all user-required packages identified in the current container
RUN Rscript -e 'install.packages(c(
  "AER", "DBI", "Deriv", "Formula", "MatrixModels", "R6", "RColorBrewer",
  "RPostgreSQL", "RPostgres", "RSQLite", "Rcpp", "RcppArmadillo", "RcppEigen",
  "Rdpack", "S7", "SparseM", "TTR", "XML", "abind", "arrow", "askpass",
  "assertthat", "backports", "base64enc", "bit", "bit64", "blob", "brew",
  "brio", "broom", "bslib", "cachem", "callr", "car", "carData", "cellranger",
  "chron", "classInt", "cli", "clipr", "coda", "colorspace", "cols4all",
  "conflicted", "covr", "cowplot", "cpp11", "crayon", "crosstalk", "curl",
  "data.table", "dbplyr", "deldir", "desc", "dichromat", "diffobj", "digest",
  "doBy", "dplyr", "dtplyr", "e1071", "egg", "evaluate", "farver", "fastmap",
  "feather", "fontawesome", "forcats", "forecast", "fracdiff", "fs", "gargle",
  "generics", "geometries", "ggplot2", "glue", "goftest", "googledrive",
  "googlesheets4", "gridExtra", "gtable", "haven", "hexbin", "highr", "hms",
  "htmltools", "htmlwidgets", "httr", "ids", "isoband", "jquerylib", "jsonify",
  "jsonlite", "knitr", "labeling", "later", "lazyeval", "leaflet.providers",
  "lifecycle", "lme4", "lmtest", "logger", "lubridate", "magrittr", "mapproj",
  "maps", "memoise", "microbenchmark", "mime", "minqa", "mockr", "modelr",
  "mondate", "nanoarrow", "nloptr", "numDeriv", "openssl", "otel", "pbapply",
  "pbkrtest", "pillar", "pkgbuild", "pkgconfig", "pkgload", "plyr", "png",
  "polyclip", "praise", "prettyunits", "processx", "progress", "promises",
  "proxy", "ps", "purrr", "quadprog", "quantmod", "quantreg", "ragg",
  "rapidjsonr", "rappdirs", "rbibutils", "readr", "readxl", "reformulas",
  "rematch", "rematch2", "reprex", "rex", "rlang", "rmarkdown", "rprojroot",
  "rstudioapi", "rvest", "sandwich", "sass", "scales", "selectr", "sfheaders",
  "sp", "spacesXYZ", "spatstat.data", "spatstat.sparse", "spatstat.univar",
  "spatstat.utils", "stinepack", "stringdist", "stringi", "stringr",
  "strucchange", "svglite", "sys", "systemfonts", "tensor", "testthat",
  "textshaping", "tibble", "tidyr", "tidyselect", "tidyverse", "timeDate",
  "timeSeries", "timechange", "tinyplot", "tinytex", "tis", "tseries", "tzdb",
  "urca", "utf8", "uuid", "vctrs", "viridisLite", "vroom", "waldo", "withr",
  "wk", "xfun", "xml2", "xts", "yaml", "yyjsonr", "zoo"
), repos="https://cloud.r-project.org/")' && rm -rf /tmp/Rtmp*

# Create a non-root user called "claudeuser"
# Running as root inside a container is a security risk:
# if something goes wrong, a root process has more ability to cause damage
RUN useradd -ms /bin/bash claudeuser

# Install Claude Code globally inside the container
RUN npm install -g @anthropic-ai/claude-code

# Set the working directory — this is where the terminal starts inside the container
WORKDIR /workspace

# Switch from root to our safer non-root user for all operations
USER claudeuser

# When the container starts, open a bash terminal
CMD ["/bin/bash"]
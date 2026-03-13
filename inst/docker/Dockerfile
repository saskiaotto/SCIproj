# Dockerfile for reproducible research environment
# Based on the Rocker Project: https://rocker-project.org/
#
# Build:  docker build -t your_project_name .
# Run:    docker run --rm -it your_project_name

FROM rocker/r-ver:4.4.0

# Install system dependencies commonly needed by R packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Install renv for dependency management
RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org')"

# Copy renv files first (for caching)
COPY renv.lock renv.lock
COPY renv/ renv/
COPY .Rprofile .Rprofile

# Restore packages from renv.lock
RUN R -e "renv::restore()"

# Copy the rest of the project
COPY . /home/project
WORKDIR /home/project

CMD ["R"]

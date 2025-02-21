# Use the official micromamba image as the base
FROM mambaorg/micromamba:2.0.5

# copy in the environment yaml file
COPY --chown=$MAMBA_USER:$MAMBA_USER planetcantile_env.yaml /tmp/env.yaml
# copy the planetcantile data into the container
COPY --chown=$MAMBA_USER:$MAMBA_USER planetcantile/src/planetcantile/data/v4/ /planetcantile_data

# Create a the base environment
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes

# activate the conda environment for further useage
ARG MAMBA_DOCKERFILE_ACTIVATE=1 

# set environment variables
ENV TILEMATRIXSET_DIRECTORY=/planetcantile_data \
    TITILER_API_NAME="Planetcantile TiTiler" \
    TITILER_API_ROOT_PATH="/titiler/" \
    GDAL_HTTP_MERGE_CONSECUTIVE_RANGES=YES \
    GDAL_DISABLE_READDIR_ON_OPEN=EMPTY_DIR \ 
    GDAL_INGESTED_BYTES_AT_OPEN=32768 \
    GDAL_CACHEMAX=200 \
    CPL_VSIL_CURL_CACHE_SIZE=200000000 \
    GDAL_BAND_BLOCK_CACHE=HASHSET \
    CPL_VSIL_CURL_ALLOWED_EXTENSIONS=".tif,.TIF,.tiff" \
    VSI_CACHE=True \
    PYTHONWARNINGS=ignore \
    VSI_CACHE_SIZE=50000000 \
    GDAL_HTTP_MULTIPLEX=YES \
    GDAL_HTTP_VERSION=2  \  
    HOST=0.0.0.0 \
    PORT=80

ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "uvicorn", "titiler.application.main:app", "--host", "0.0.0.0", "--port",  "80"]

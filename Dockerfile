FROM nfcore/base:1.9

LABEL authors="ahmad zyoud" \
      description="Docker image containing all software requirements for the ENA/localdatahub pipeline"

# Install the conda environment
COPY environment.yml /
RUN conda env create --quiet -f /environment.yml && conda clean -a

# Add conda installation dir to PATH (instead of doing 'conda activate'), please change the name of the environment (here as "ENA-localdatahub-1.0") to match the name in environment.yml
ENV PATH /opt/conda/envs/ENA-localdatahub-1.0/bin:$PATH

# Dump the details of the installed packages to a file for posterity
RUN conda env export --name ENA-localdatahub-1.0 > ENA-localdatahub-1.0dev.yml

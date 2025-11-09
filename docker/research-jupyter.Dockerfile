FROM jupyter/tensorflow-notebook:latest

# Install additional research packages
RUN pip install --no-cache-dir \
    biopython \
    rdkit-pypi \
    openbabel \
    pymatgen \
    ase \
    MDAnalysis \
    nglview \
    plotly \
    dash \
    streamlit \
    scikit-learn \
    xgboost \
    lightgbm \
    catboost \
    optuna \
    mlflow \
    wandb \
    tensorboard \
    jupyterlab-git \
    jupyterlab-lsp \
    python-lsp-server \
    black \
    isort \
    flake8 \
    mypy

# Install system packages for research
USER root
RUN apt-get update && apt-get install -y \
    openbabel \
    gromacs \
    autodock-vina \
    && rm -rf /var/lib/apt/lists/*

USER jovyan

# Create research directories
RUN mkdir -p /home/jovyan/work/research \
    /home/jovyan/work/models \
    /home/jovyan/work/data \
    /home/jovyan/work/notebooks

# Copy research notebooks and scripts
COPY research-notebooks/ /home/jovyan/work/notebooks/
COPY research-scripts/ /home/jovyan/work/scripts/

# Set working directory
WORKDIR /home/jovyan/work

# Expose Jupyter port
EXPOSE 8888

# Start Jupyter Lab
CMD ["start-notebook.sh", "--NotebookApp.token='research2024'", "--NotebookApp.password=''", "--notebook-dir=/home/jovyan/work"]
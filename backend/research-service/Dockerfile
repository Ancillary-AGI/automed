FROM nvidia/cuda:11.8-devel-ubuntu20.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    python3.9 \
    python3-pip \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Python dependencies for AI/ML
RUN pip3 install --no-cache-dir \
    tensorflow==2.13.0 \
    torch==2.0.1 \
    torchvision==0.15.2 \
    scikit-learn==1.3.0 \
    pandas==2.0.3 \
    numpy==1.24.3 \
    matplotlib==3.7.2 \
    seaborn==0.12.2 \
    jupyter==1.0.0 \
    plotly==5.15.0 \
    biopython==1.81 \
    rdkit==2023.3.2 \
    openbabel==3.1.1 \
    pymatgen==2023.6.23 \
    ase==3.22.1

# Create application directory
WORKDIR /app

# Copy application files
COPY build.gradle.kts ./
COPY settings.gradle.kts ./
COPY gradlew ./
COPY gradle/ gradle/
COPY src/ src/

# Build the application
RUN ./gradlew build -x test

# Expose ports
EXPOSE 8085

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8085/actuator/health || exit 1

# Run the application
CMD ["./gradlew", "bootRun"]
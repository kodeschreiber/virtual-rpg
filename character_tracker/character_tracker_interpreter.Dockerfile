FROM nvidia/cuda:10.0-base-ubuntu18.04
# See http://bugs.python.org/issue19846
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
LABEL com.nvidia.volumes.needed="nvidia_driver"

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential cmake git curl vim ca-certificates python-qt4 libjpeg-dev \
        zip nano unzip libpng-dev strace python-opengl xvfb && \
        rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV PYTHON_VERSION=3.7

ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py37_4.8.2-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV CONTAINER_USER user
ENV CONTAINER_UID 1000

RUN adduser --shell /bin/bash --uid $CONTAINER_UID --disabled-password $CONTAINER_USER && \
    mkdir -p /opt/conda && \
    chown $CONTAINER_USER /opt/conda

# Create Enviroment
COPY environment.yaml /environment.yaml
RUN conda env create -f environment.yaml

# Cleanup
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get -y autoremove

EXPOSE 8888
ENV CONDA_DEFAULT_ENV character_tracker

WORKDIR /opt/project
RUN chown $CONTAINER_USER /opt/project

CMD ["/bin/bash"]

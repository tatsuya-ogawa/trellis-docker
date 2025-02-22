FROM nvidia/cuda:11.8.0-devel-ubuntu22.04
SHELL ["bash", "-c"]
ENV HOME /root
RUN apt-get update \
    && apt-get -y upgrade
RUN apt-get --fix-missing -y install build-essential libssl-dev libffi-dev libncurses5-dev zlib1g zlib1g-dev libreadline-dev libbz2-dev libsqlite3-dev liblzma-dev \
    curl git unzip libglib2.0-0 libgl1-mesa-dev
RUN curl https://pyenv.run | bash
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PATH:$PYENV_ROOT/bin
ENV PATH $PATH:/root/.pyenv/shims
RUN echo 'eval "$(pyenv init -)"' >> $HOME/.bashrc
RUN . ~/.bashrc

WORKDIR /opt/work
ARG python_version="miniforge3-24.11.2-1"
RUN pyenv install ${python_version} \
    && pyenv global ${python_version} 

RUN git clone --recurse-submodules https://github.com/microsoft/TRELLIS.git
WORKDIR /opt/work/TRELLIS
RUN conda init bash
RUN conda install -y python=3.11
RUN conda install -y numpy==1.26.4
RUN pip install torch==2.4.0 torchvision==0.19.0 --index-url https://download.pytorch.org/whl/cu118
RUN ./setup.sh --basic --xformers --flash-attn --diffoctreerast --spconv --mipgaussian --kaolin --nvdiffrast --demo
RUN pip install kaolin -f https://nvidia-kaolin.s3.us-east-2.amazonaws.com/torch-2.4.0_cu118.html
RUN git clone https://github.com/NVlabs/nvdiffrast.git /tmp/extensions/nvdiffrast && pip install /tmp/extensions/nvdiffrast
RUN pip install spconv-cu118
RUN pip install flash-attn==2.7.3 --no-build-isolation
ENV GRADIO_SERVER_NAME="0.0.0.0"
ENTRYPOINT /bin/bash -c "git clone https://github.com/autonomousvision/mip-splatting.git /tmp/extensions/mip-splatting && pip install /tmp/extensions/mip-splatting/submodules/diff-gaussian-rasterization/ && python app.py"

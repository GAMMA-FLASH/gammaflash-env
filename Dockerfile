FROM oraclelinux:8 AS oracle8

# ---------------------------------- Installing dependencies as root ---------------------------------- 
RUN dnf install -y epel-release git cmake3 gcc-c++ gcc binutils \
compat-openssl10 libX11-devel libXpm-devel libXft-devel libXext-devel \ 
gsl-devel openssl-devel wget bzip2-devel libffi-devel xz-devel sqlite-devel \
ncurses ncurses-devel make xz libzstd libzstd-devel which rsync \
nmap-ncat chrony

RUN dnf install -y oracle-epel-release-el8
RUN dnf config-manager --enable ol8_codeready_builder
RUN dnf install -y hdf5 hdf5-devel


# ---------------------------------- Create Agilepy user ---------------------------------- 
RUN useradd usergamma
USER usergamma
WORKDIR /home/usergamma
RUN mkdir -p /home/usergamma/dependencies
SHELL ["/bin/bash", "--login", "-c"]

user root 

#AMD64
#COPY ./Anaconda3-2023.07-2-Linux-x86_64.sh .
#RUN wget https://repo.anaconda.com/archive/Anaconda3-2023.07-2-Linux-x86_64.sh 
#RUN chmod +x Anaconda3-2023.07-2-Linux-x86_64.sh 
#RUN ./Anaconda3-2023.07-2-Linux-x86_64.sh -b -p /opt/conda 
#RUN rm Anaconda3-2023.07-2-Linux-x86_64.sh

#ARM
#RUN wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-aarch64.sh && \
COPY ./Anaconda3-2023.09-0-Linux-aarch64.sh .
RUN chmod +x Anaconda3-2023.09-0-Linux-aarch64.sh 
RUN ./Anaconda3-2023.09-0-Linux-aarch64.sh -b -p /opt/conda 
RUN rm Anaconda3-2023.09-0-Linux-aarch64.sh


WORKDIR /gammaflash
RUN chown -R usergamma:usergamma /gammaflash/


RUN git clone https://github.com/GAMMA-FLASH/gammaflash-env

USER usergamma

RUN export PATH=$PATH:/opt/conda/bin && conda config --append channels conda-forge && conda config --set channel_priority strict &&  conda env create -n gammaflash -f /gammaflash/gammaflash-env/conda/environment.yml

RUN export PATH=$PATH:/opt/conda/bin && source activate gammaflash && cd /gammaflash/gammaflash-env/venv && pip3 install -r requirements.txt


USER root
RUN  mkdir /shared_dir
RUN chown -R usergamma:usergamma /shared_dir
RUN  mkdir /data01
RUN chown -R usergamma:usergamma /data01
RUN  mkdir /data02
RUN chown -R usergamma:usergamma /data02
COPY ./entrypoint.sh /home/usergamma/entrypoint.sh
RUN chmod +x /home/usergamma/entrypoint.sh

USER usergamma
RUN mkdir /home/usergamma/workspace
ENV PATH="/opt/conda/bin:$PATH"
#ENTRYPOINT ["bash", "/home/usergamma/entrypoint.sh"]

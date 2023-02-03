FROM omnetpp/omnetpp:u22.04-6.0
# Environment variables
ENV OMNETPP_RELEASE=omnetpp-6.0
ENV HOME=/root
ENV __omnetpp_root_dir=${HOME}/omnetpp/
ENV PYTHONPATH=${__omnetpp_root_dir}/python
ENV PATH=${__omnetpp_root_dir}/bin:${HOME}/bin:${PATH}
# prepare directories
RUN mkdir -p ${__omnetpp_root_dir}/samples
# download sources
WORKDIR ${__omnetpp_root_dir}/samples
RUN git clone https://github.com/rlancellotti/fogchains.git
# compile
WORKDIR ${__omnetpp_root_dir}/samples/fogchains
RUN pwd && ls -l .
RUN make makefiles && make
# install tools
WORKDIR /root
RUN apt update && apt install -y libsqlite3-dev vim less
RUN git clone https://github.com/rlancellotti/omnet_analyzer.git
WORKDIR /root/omnet_analyzer
RUN pip3 install -r requirements.txt
RUN python3 install_tools.py
COPY simulations/run ${HOME}/bin/
# shell setup
WORKDIR /root
COPY container/bash_aliases ${HOME}/.bash_aliases
CMD /bin/bash --init-file ${HOME}/.bashrc

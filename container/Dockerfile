FROM omnetpp/omnetpp:u22.04-6.0
# Environment variables
ENV OMNETPP_RELEASE=omnetpp-6.0
ENV HOME=/root
ENV __omnetpp_root_dir=${HOME}/omnetpp/
ENV __fogchains_root_dir=${HOME}/fogchains
ENV PYTHONPATH=${__omnetpp_root_dir}/python
ENV PATH=${__omnetpp_root_dir}/bin:${HOME}/bin:${PATH}
# download sources
RUN git clone https://github.com/rlancellotti/fogchains.git
# compile
WORKDIR ${__fogchains_root_dir}
RUN make makefiles && make -j$(nproc)
# install tools
WORKDIR ${HOME}
RUN apt update && apt install -y libsqlite3-dev vim less
RUN git clone https://github.com/rlancellotti/omnet_analyzer.git
WORKDIR ${HOME}/omnet_analyzer
RUN pip3 install -r requirements.txt
RUN python3 install_tools.py
COPY simulations/run ${HOME}/bin/
# shell setup
WORKDIR /root
RUN echo "source ${__fogchains_root_dir}/setenv" >> ${HOME}/.bashrc
COPY container/bash_aliases ${HOME}/.bash_aliases
CMD /bin/bash --init-file ${HOME}/.bashrc

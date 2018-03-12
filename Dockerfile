FROM ubuntu:16.04 as builder

WORKDIR /work

RUN apt-get update && \
    apt-get install -y \
            build-essential \
            git \
            libdb-dev \
            libsodium-dev \
            libtinfo-dev \
            libleveldb-dev \
            sysvbanner \
            wget \
            wrk \
            psmisc \
            zlib1g-dev

RUN wget -q https://github.com/jpmorganchase/constellation/releases/download/v0.3.2/constellation-0.3.2-ubuntu1604.tar.xz && \
    tar xf constellation-0.3.2-ubuntu1604.tar.xz && \
    cp constellation-0.3.2-ubuntu1604/constellation-node /usr/local/bin && \
    chmod 0755 /usr/local/bin/constellation-node && \
    rm -rf constellation-0.3.2-ubuntu1604.tar.xz constellation-0.3.2-ubuntu1604

ENV GOREL go1.10.linux-amd64.tar.gz
ENV PATH $PATH:/usr/local/go/bin

RUN wget -q https://storage.googleapis.com/golang/$GOREL && \
    tar -xvzf $GOREL && \
    mv go /usr/local/go && \
    rm -f $GOREL

RUN git clone https://github.com/jpmorganchase/quorum.git && \
    cd quorum && \
    make all && \
    cp build/bin/geth /usr/local/bin && \
    cp build/bin/bootnode /usr/local/bin && \
    cd .. && \
    rm -rf quorum

### Create the runtime image, leaving most of the cruft behind (hopefully...)

FROM ubuntu:16.04

# Install add-apt-repository
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:ethereum/ethereum && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        netbase \
        libdb-dev \
        libleveldb-dev \
        libleveldb-dev \
        libsodium-dev \
        libtinfo-dev && \
    rm -rf /var/lib/apt/lists/*

# Temporary useful tools
#RUN apt-get update && \
#        apt-get install -y iputils-ping net-tools vim

COPY --from=builder \
        /usr/local/bin/constellation-node \
        /usr/local/bin/geth \
        /usr/local/bin/bootnode \
    /usr/local/bin/

CMD ["/qdata/start-node.sh"]

FROM ubuntu:16.04

ENV TL_TMP_DIR="/tmp/templight" \
    TL_LLVM_REV=290370 \
    TL_CLANG_REV=290373 \
    TL_REV=0738fa15ef7e24c5864c95e02d53c6f2e98f160b \
    TL_TOOLS_REV=cd3828bbc85faa3de5a05a9ccfc9ea27518af7d5 \
    CMAKE_CMD="cmake -DCMAKE_BUILD_TYPE=Release -GNinja"

RUN apt-get update -qq 1> /dev/null && \
    apt-get install -q=100 -y --no-install-recommends subversion libboost-program-options-dev \
        libboost-filesystem-dev libboost-system-dev libboost-test-dev python3-dev \
        git ca-certificates cmake ninja-build build-essential 1> /dev/null && \
    mkdir -p ${TL_TMP_DIR} && cd ${TL_TMP_DIR} && \
    svn co -r ${TL_LLVM_REV} http://llvm.org/svn/llvm-project/llvm/trunk llvm && \
    cd ${TL_TMP_DIR}/llvm/tools && \
    svn co -r ${TL_CLANG_REV} http://llvm.org/svn/llvm-project/cfe/trunk clang && \
    cd ${TL_TMP_DIR}/llvm/tools/clang/tools && \
    mkdir templight && \
    git clone https://github.com/mikael-s-persson/templight && \
    cd templight && \
    git reset --hard ${TL_REV} && \
    cd ${TL_TMP_DIR}/llvm/tools/clang && svn patch tools/templight/templight_clang_patch.diff && \
    echo "add_subdirectory(templight)" >> ${TL_TMP_DIR}/llvm/tools/clang/tools/CMakeLists.txt && \
    cd ${TL_TMP_DIR} && \
    mkdir build && \
    cd build && \
    ${CMAKE_CMD} -DLLVM_BUILD_TESTS=0 ../llvm/ && \
    ninja install 1> /dev/null && \
    rm -fr ${TL_TMP_DIR}/* && \
    cd ${TL_TMP_DIR} && git clone https://github.com/mikael-s-persson/templight-tools && cd templight-tools && git reset --hard ${TL_TOOLS_REV} && \
    cd ${TL_TMP_DIR}/templight-tools && \
    mkdir build && \
    cd build && \
    ${CMAKE_CMD} ../ && \
    ninja install 1> /dev/null && \
    rm -fr ${TL_TMP_DIR}/* && \
    apt-get install -q=100 -y --no-install-recommends kcachegrind libgraphviz-dev libyaml-cpp-dev libqt5gui5 qt5-qmake  qtbase5-dev 1> /dev/null &&\
    cd ${TL_TMP_DIR} && \
    git clone https://github.com/schulmar/Templar templar && \
    cd templar && \
    git checkout feature/templight2 && \
    git submodule update --init && \
    ${CMAKE_CMD} . && \
    ninja 1> /dev/null && \
    install -m 755 Templar /usr/local/bin && \
    rm -fr ${TL_TMP_DIR} && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

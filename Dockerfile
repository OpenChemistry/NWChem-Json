FROM        ubuntu:14.04

MAINTAINER  Chris Harris <chris.harris@kitware.com> 

ENV         NWCHEM_TOP="/opt/nwchem"

RUN         apt-get update \
            && apt-get -y upgrade \
            && apt-get install -y gfortran libopenblas-dev libopenmpi-dev \
                                  openmpi-bin tcsh make ssh patch curl git
RUN         apt-get install -y software-properties-common \
            && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
            && apt-get update \
            && apt-get install -y gfortran-4.9 \
            && update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-4.9 60

WORKDIR     /opt
RUN         mkdir nwchem
COPY        ./ nwchem

ENV         LARGE_FILES=TRUE
ENV         TCGRSH="/usr/bin/ssh"
ENV         NWCHEM_TARGET=LINUX64
ENV         NWCHEM_MODULES="all"
ENV         BLASOPT="-L/usr/lib/openblas-base -lopenblas"
ENV         LIBRARY_PATH="$LIBRARY_PATH:/usr/lib/openblas-base"
ENV         USE_MPI=y
ENV         USE_MPIF=y
ENV         USE_MPIF4=y
ENV         MPI_LOC="/usr/lib/openmpi/lib"
ENV         MPI_INCLUDE="/usr/lib/openmpi/include"
ENV         LIBMPI="-lmpi -lopen-rte -lopen-pal -ldl -lmpi_f77 -lpthread"
ENV         LIBRARY_PATH="$LIBRARY_PATH:/usr/lib/openmpi/lib"
ENV         MRCC_METHODS=y
#ENV         CCSDTQ=y
#ENV         CCSDTLR=y
ENV         FC=gfortran

WORKDIR     ${NWCHEM_TOP}/src
RUN         rm -f */dependencies \
            && rm -f */*/dependencies \
            && make clean \
            && make nwchem_config

# Horrible hack to ensure the json_nwchem.mod is built, 
# I am so sorry! The depends seem to be broken.
WORKDIR     ${NWCHEM_TOP}/src
# This will fail, but ignore the error, we will try again!
RUN         make -j `nproc --all` ; exit 0

WORKDIR     ${NWCHEM_TOP}/src/util
# Ignore first failure!
RUN         make ; make && cp *.mod ../include

WORKDIR     ${NWCHEM_TOP}/src
RUN         make -j `nproc --all`

WORKDIR     ${NWCHEM_TOP}/contrib
RUN         ./getmem.nwchem

ENV         NWCHEM_EXECUTABLE=${NWCHEM_TOP}/bin/LINUX64/nwchem
ENV         NWCHEM_BASIS_LIBRARY=${NWCHEM_TOP}/src/basis/libraries/
ENV         NWCHEM_NWPW_LIBRARY=${NWCHEM_TOP}/src/nwpw/libraryps/
ENV         FFIELD=amber
ENV         AMBER_1=${NWCHEM_TOP}/src/data/amber_s/
ENV         AMBER_2=${NWCHEM_TOP}/src/data/amber_q/
ENV         AMBER_3=${NWCHEM_TOP}/src/data/amber_x/
ENV         AMBER_4=${NWCHEM_TOP}/src/data/amber_u/
ENV         SPCE=${NWCHEM_TOP}/src/data/solvents/spce.rst
ENV         CHARMM_S=${NWCHEM_TOP}/src/data/charmm_s/
ENV         CHARMM_X=${NWCHEM_TOP}/src/data/charmm_x/
ENV         PATH=$PATH:${NWCHEM_TOP}/bin/LINUX64

WORKDIR     /data
ENTRYPOINT  ["/opt/nwchem/bin/LINUX64/nwchem"]

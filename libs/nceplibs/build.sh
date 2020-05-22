#!/bin/bash

## Yet another simple script that downloads and builds
## nceplibs libraries required for the UFS Weather application.
##      -Dusan Jovic Oct. 2019

set -eu
set -o pipefail

usage() {
  echo "Usage: $0 gnu | intel"
  exit 1
}

[[ $# -ne 1 ]] && usage

COMPILERS=$1

if [[ $COMPILERS == gnu ]]; then
  export CC=${CC:-gcc}
  export CXX=${CXX:-g++}
  export FC=${FC:-gfortran}
elif [[ $COMPILERS == intel ]]; then
  if [[ $(type ftn &> /dev/null) ]]; then
    # Special case on Cray systems
    export CC=${CC:-cc}
    export CXX=${CXX:-CC}
    export FC=${FC:-ftn}
  else
    export CC=${CC:-icc}
    export CXX=${CXX:-icpc}
    export FC=${FC:-ifort}
  fi
else
  usage
fi

date

echo
echo "Building nceplibs libraries using ${COMPILERS} compilers"
echo
#
# print compiler version
#
echo
${CC} --version | head -1
${CXX} --version | head -1
${FC} --version | head -1
mpiexec --version
cmake --version | head -1
echo

MYDIR=$(cd "$(dirname "$(readlink -n "${BASH_SOURCE[0]}" )" )" && pwd -P)

ALL_LIBS="
NCEPLIBS-bacio
NCEPLIBS-g2
NCEPLIBS-g2tmpl
NCEPLIBS-gfsio
NCEPLIBS-ip
NCEPLIBS-sp
NCEPLIBS-landsfcutil
NCEPLIBS-w3nco
NCEPLIBS-nemsio
NCEPLIBS-nemsiogfs
NCEPLIBS-sfcio
NCEPLIBS-sigio
NCEPLIBS-w3emc
EMC_crtm
"

for libname in ${ALL_LIBS}; do
  printf '%-.30s ' "Building ${libname} ..........................."
  (
    set -x
    cd ${MYDIR}/${libname}

    lib_name=${libname//NCEPLIBS-/}
    lib_name=${lib_name//EMC_/}


    if [[ -f VERSION ]]; then
      version=$(cat VERSION)
      install_name="${lib_name}_${version}"
    fi

    install_prefix=${MYDIR}/local/${install_name}

    mkdir -p ${MYDIR}/local/modulefiles/${lib_name}
    modulefile=${MYDIR}/local/modulefiles/${lib_name}/${version}
    echo "#%Module"                                                       >  ${modulefile}
    echo "setenv ${lib_name}_VERSION ${version}"                          >> ${modulefile}
    echo "setenv ${lib_name}_DIR ${install_prefix}/lib/cmake/${lib_name}" >> ${modulefile}

    # for backward compatibility with WW3
    if [[ ${lib_name} == bacio || ${lib_name} == g2 || ${lib_name} == w3nco ]]; then
    echo "setenv ${lib_name^^}_LIB4 ${install_prefix}/lib/lib${lib_name}_v${version}_4.a" >> ${modulefile}
    fi

    rm -rf build
    mkdir build
    cd build
    rm -rf ${MYDIR}/local/${install_name}

    cmake .. \
          -DCMAKE_INSTALL_PREFIX=${install_prefix} \
          -DCMAKE_C_COMPILER=${CC} \
          -DCMAKE_Fortran_COMPILER=${FC} \
          -DCMAKE_BUILD_TYPE=RELEASE \
          -DCMAKE_PREFIX_PATH="${MYDIR}/../3rdparty/local;${MYDIR}/local"
    make VERBOSE=1
    make install

  ) > log_${libname} 2>&1
  echo 'done'
done

echo
date

echo
echo "Finished"

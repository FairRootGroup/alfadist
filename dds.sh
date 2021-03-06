package: DDS
version: "%(tag_basename)s"
tag: "2.0"
source: https://github.com/FairRootGroup/DDS
requires:
  - boost
build_requires:
  - CMake
---
#!/bin/bash -ex

case $ARCHITECTURE in
  osx*)
    [[ ! $BOOST_ROOT ]] && BOOST_ROOT=`brew --prefix boost` ;;
esac


cmake                                                                \
  ${C_COMPILER:+-DCMAKE_C_COMPILER=$C_COMPILER}                      \
  ${CXX_COMPILER:+-DCMAKE_CXX_COMPILER=$CXX_COMPILER}                \
  ${CXX_COMPILER:+-DCMAKE_LINKER=$CXX_COMPILER}                      \
  -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE                               \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                                \
  ${BOOST_ROOT:+-DBOOST_ROOT=$BOOST_ROOT -DBoost_NO_SYSTEM_PATHS=ON} \
  $SOURCEDIR

cmake --build . --target wn_bin ${JOBS:+-- -j$JOBS}
cmake --build . --target install ${JOBS:+-- -j$JOBS}

MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 ${BOOST_VERSION:+boost/$BOOST_VERSION-$BOOST_REVISION} ${GCC_TOOLCHAIN_VERSION:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}
# Our environment
setenv DDS_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(DDS_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(DDS_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(DDS_ROOT)/lib")
EoF

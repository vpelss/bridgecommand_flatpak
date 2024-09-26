# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/run/build/bc/src/libs/Irrlicht/irrlicht-svn/source/Irrlicht"
  "/run/build/bc/src/libs/Irrlicht/irrlicht-svn/source/Irrlicht"
  "/run/build/bc/bin/libs/Irrlicht/bc-irrlicht-internal-prefix"
  "/run/build/bc/bin/libs/Irrlicht/bc-irrlicht-internal-prefix/tmp"
  "/run/build/bc/bin/libs/Irrlicht/bc-irrlicht-internal-prefix/src/bc-irrlicht-internal-stamp"
  "/run/build/bc/bin/libs/Irrlicht/bc-irrlicht-internal-prefix/src"
  "/run/build/bc/bin/libs/Irrlicht/bc-irrlicht-internal-prefix/src/bc-irrlicht-internal-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/run/build/bc/bin/libs/Irrlicht/bc-irrlicht-internal-prefix/src/bc-irrlicht-internal-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/run/build/bc/bin/libs/Irrlicht/bc-irrlicht-internal-prefix/src/bc-irrlicht-internal-stamp${cfgdir}") # cfgdir has leading slash
endif()

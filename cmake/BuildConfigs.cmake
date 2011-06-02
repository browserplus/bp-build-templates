#####
#  ***** BEGIN LICENSE BLOCK *****
#  The contents of this file are subject to the Mozilla Public License
#  Version 1.1 (the "License"); you may not use this file except in
#  compliance with the License. You may obtain a copy of the License at
#  http://www.mozilla.org/MPL/
#
#  Software distributed under the License is distributed on an "AS IS"
#  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
#  License for the specific language governing rights and limitations
#  under the License.
#
#  The Original Code is BrowserPlus (tm).
#
#  The Initial Developer of the Original Code is Yahoo!.
#  Portions created by Yahoo! are Copyright (C) 2006-2009 Yahoo!.
#  All Rights Reserved.
#
#  Contributor(s):
#  ***** END LICENSE BLOCK *****
#####
#####
# BuildConfigs.cmake
#
# A CMake build file to setup some default compiler and linker settings for
# VC and gcc.
#
# This file is intended to be included by client CMakeLists.txt files.
#
# Original Author: Lloyd Hilaiel
#####

# Require cmake 2.8.1 or higher.
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.1 FATAL_ERROR)

IF (POLICY CMP0011)
  CMAKE_POLICY(SET CMP0011 OLD)
ENDIF (POLICY CMP0011)
CMAKE_POLICY(SET CMP0003 NEW)
CMAKE_POLICY(SET CMP0009 NEW)

SET (CMAKE_CONFIGURATION_TYPES Debug Release CodeCoverage
     CACHE STRING "bp-service-framework build configs" FORCE)

# Reduce redundancy in the cmake language.
SET(CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS 1)

IF (NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE "Debug")
ENDIF ()

IF (OSX10.4_BUILD)
  MESSAGE("\n**** DOING AN OSX10.4 BUILD ****\n")
ELSE ()
  MESSAGE("\n**** To do an osx10.4 build, do cmake -DOSX10.4_BUILD=true ... ****\n")
ENDIF()

# Now set up the build configurations.
IF (WIN32)
  SET(win32Defs "/DWINDOWS /D_WINDOWS /DWIN32 /D_WIN32 /DXP_WIN32 /DUNICODE /D_UNICODE /DWIN32_LEAN_AND_MEAN /DNOSOUND /DNOCOMM /DNOMCX /DNOSERVICE /DNOIME /DNORPC")
  SET(disabledWarnings "/wd4100 /wd4127 /wd4201 /wd4250 /wd4251 /wd4275 /wd4800")
  SET(CMAKE_CXX_FLAGS
      "${win32Defs} /EHsc /Gy /MT /W4 ${disabledWarnings} /Zi"
      CACHE STRING "BrowserPlus CXX flags" FORCE)
  SET(CMAKE_CXX_FLAGS_DEBUG "/MTd /DDEBUG /D_DEBUG /Od /RTC1 /RTCc"
      CACHE STRING "BrowserPlus debug CXX flags" FORCE)
  SET(CMAKE_CXX_FLAGS_CODECOVERAGE "${CMAKE_CXX_FLAGS_CODECOVERAGE}"
      CACHE STRING "BrowserPlus code coverage CXX flags" FORCE)
  SET(CMAKE_CXX_FLAGS_RELEASE "/MT /DNDEBUG /O2"
      CACHE STRING "BrowserPlus release CXX flags" FORCE)

  # libs to ignore, from http://msdn.microsoft.com/en-us/library/aa267384.aspx
  #
  SET(noDefaultLibFlagsDebug "/NODEFAULTLIB:libc.lib /NODEFAULTLIB:libcmt.lib /NODEFAULTLIB:msvcrt.lib /NODEFAULTLIB:libcd.lib /NODEFAULTLIB:msvcrtd.lib")
  SET(noDefaultLibFlagsCodeCoverage ${noDefaultLibFlagsDebug})
  SET(noDefaultLibFlagsRelease "/NODEFAULTLIB:libc.lib /NODEFAULTLIB:msvcrt.lib /NODEFAULTLIB:libcd.lib /NODEFAULTLIB:libcmtd.lib /NODEFAULTLIB:msvcrtd.lib")

  SET(linkFlags "/DEBUG /MANIFEST:NO")
  SET(linkFlagsDebug " ${noDefaultLibFlagsDebug}")
  SET(linkFlagsCodeCoverage " ${linkFlagsDebug}")
  SET(linkFlagsRelease " /INCREMENTAL:NO /OPT:REF /OPT:ICF ${noDefaultLibFlagsRelease}")

  SET(CMAKE_EXE_LINKER_FLAGS "${linkFlags}"
      CACHE STRING "BrowserPlus linker flags" FORCE)
  SET(CMAKE_EXE_LINKER_FLAGS_DEBUG "${linkFlagsDebug}"
      CACHE STRING "BrowserPlus debug linker flags" FORCE)
  SET(CMAKE_EXE_LINKER_FLAGS_CODECOVERAGE "${CMAKE_EXE_LINKER_FLAGS_DEBUG}"
      CACHE STRING "BrowserPlus codecoverage linker flags" FORCE)
  SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "${linkFlagsRelease}"
      CACHE STRING "BrowserPlus release linker flags" FORCE)
  SET(CMAKE_SHARED_LINKER_FLAGS "${linkFlags}"
      CACHE STRING "BrowserPlus shared linker flags" FORCE)
  SET(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${linkFlagsDebug}"
      CACHE STRING "BrowserPlus shared debug linker flags" FORCE)
  SET(CMAKE_SHARED_LINKER_FLAGS_CODECOVERAGE "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}"
      CACHE STRING "BrowserPlus shared codecoverage linker flags" FORCE)
  SET(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${linkFlagsRelease}"
      CACHE STRING "BrowserPlus shared release linker flags" FORCE)

  SET(CMAKE_MODULE_LINKER_FLAGS "${linkFlags}"
      CACHE STRING "BrowserPlus module linker flags" FORCE)
  SET(CMAKE_MODULE_LINKER_FLAGS_DEBUG "${linkFlagsDebug}"
      CACHE STRING "BrowserPlus module debug linker flags" FORCE)
  SET(CMAKE_MODULE_LINKER_FLAGS_CODECOVERAGE "${CMAKE_MODULE_LINKER_FLAGS_DEBUG}"
      CACHE STRING "BrowserPlus module codecoverage linker flags" FORCE)
  SET(CMAKE_MODULE_LINKER_FLAGS_RELEASE "${linkFlagsRelease}"
      CACHE STRING "BrowserPlus module release linker flags" FORCE)
ELSE ()
  # Must tell cmake that we really, really, really want certain
  # compiler/sdk
  SET(isysrootFlag)
  SET(minVersionFlag)
  INCLUDE(CMakeForceCompiler)
  IF (APPLE)
    SET(CMAKE_OSX_ARCHITECTURES i386)
    # XXX when 10.4 dropped, remove 10.4 clause
    IF (OSX10.4_BUILD) 
      SET(CMAKE_C_COMPILER gcc-4.0)
      SET(CMAKE_CXX_COMPILER g++-4.0)
      IF ("${CMAKE_BUILD_TYPE}" STREQUAL "CodeCoverage") 
        MESSAGE(FATAL_ERROR "OSX CodeCoverage build not supported on 10.4 due to XCode shipping incorrect libgcov.a binary")
      ELSE ()
        SET (CMAKE_OSX_DEPLOYMENT_TARGET "10.4"
             CACHE STRING "Compile for tiger deployment" FORCE)
        SET(minVersionFlag "-mmacosx-version-min=10.4")
      ENDIF ()
      SET(CMAKE_OSX_SYSROOT "/Developer/SDKs/MacOSX10.4u.sdk"
          CACHE STRING "Compile for tiger deployment" FORCE)
      SET(isysrootFlag "-isysroot ${CMAKE_OSX_SYSROOT}")
      SET(CMAKE_FRAMEWORK_PATH "${CMAKE_OSX_SYSROOT}/System/Library/Frameworks"
          CACHE STRING "use 10.4 frameworks" FORCE)
      SET(CMAKE_XCODE_ATTRIBUTE_GCC_VERSION "4.0"
          CACHE STRING "BrowserPlus debug CXX flags" FORCE)
    ELSE ()
      # Use full paths since 10.5 doesn't have llvm in /usr/bin.
      # Even with all of this, 10.5 xcode generator doesn't honor this.
      # llvm does not support code coverage at the moment.
      # once they deliver that support, we should flip from gnu -> llvm
      SET(CMAKE_C_COMPILER gcc-4.2)
      SET(CMAKE_CXX_COMPILER g++-4.2)
      #SET(CMAKE_C_COMPILER /Developer/usr/bin/llvm-gcc-4.2)
      #SET(CMAKE_CXX_COMPILER /Developer/usr/bin/llvm-g++-4.2)
      IF ("${CMAKE_BUILD_TYPE}" STREQUAL "CodeCoverage") 
        SET (CMAKE_OSX_DEPLOYMENT_TARGET "10.6"
             CACHE STRING "Compile for snow leopard deployment" FORCE)
        SET(minVersionFlag "-mmacosx-version-min=10.6")
      ELSE ()
        SET (CMAKE_OSX_DEPLOYMENT_TARGET "10.5"
             CACHE STRING "Compile for leopard deployment" FORCE)
        SET(minVersionFlag "-mmacosx-version-min=10.5")
      ENDIF ()
      SET(CMAKE_XCODE_ATTRIBUTE_GCC_VERSION "4.2"
          CACHE STRING "BrowserPlus debug CXX flags" FORCE)
    ENDIF ()

    # now tell cmake to tell xcode that we really, really, really want i386
    SET(CMAKE_XCODE_ATTRIBUTE_ARCHS i386)

    SET(ENV{CC} ${CMAKE_C_COMPILER})
    SET(ENV{CXX} ${CMAKE_CXX_COMPILER})
    CMAKE_FORCE_C_COMPILER(${CMAKE_C_COMPILER} GNU)
    CMAKE_FORCE_CXX_COMPILER(${CMAKE_CXX_COMPILER} GNU)

    SET(CMAKE_MODULE_LINKER_FLAGS "${minVersionFlag} ${isysrootFlag}")
    SET(CMAKE_EXE_LINKER_FLAGS "-dead_strip -dead_strip_dylibs ${minVersionFlag} ${isysrootFlag}")
    SET(CMAKE_SHARED_LINKER_FLAGS "${minVersionFlag} ${isysrootFlag} -Wl,-single_module")
    ADD_DEFINITIONS(-DMACOSX -D_MACOSX -DMAC -D_MAC -DXP_MACOSX)
  ELSE()
    ADD_DEFINITIONS(-DLINUX -D_LINUX -DXP_LINUX)
  ENDIF()

  SET(CMAKE_CXX_FLAGS "-Wall ${isysrootFlag} ${minVersionFlag}")
  SET(CMAKE_CXX_FLAGS_DEBUG "-DDEBUG -g")
  SET(CMAKE_CXX_FLAGS_CODECOVERAGE "${CMAKE_CXX_FLAGS_DEBUG} -O0 -fprofile-arcs -ftest-coverage")
  SET(CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG -Os")
  SET(CMAKE_MODULE_LINKER_FLAGS_CODECOVERAGE "")
  SET(CMAKE_MODULE_LINKER_FLAGS_RELEASE "-Wl,-x")
  SET(CMAKE_EXE_LINKER_FLAGS_CODECOVERAGE "")
  SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "-Wl,-x")
  SET(CMAKE_SHARED_LINKER_FLAGS_CODECOVERAGE "")
  SET(CMAKE_SHARED_LINKER_FLAGS_RELEASE "-Wl,-x")
ENDIF ()

MACRO (BPAddCPPService)
  IF (NOT DEFINED SERVICE_NAME)
    MESSAGE(FATAL_ERROR, "$SERVICE_NAME is not defined, please add service name")
  ENDIF ()
  IF (NOT DEFINED SRCS)
    MESSAGE(FATAL_ERROR, "$SRCS is not defined, please add some source files")
  ENDIF ()
  IF (NOT DEFINED HDRS)
    MESSAGE(FATAL_ERROR, "$HDRS is not defined, please add some headers")
  ENDIF ()
  IF (NOT DEFINED LIBS)
    MESSAGE(FATAL_ERROR, "$LIBS is not defined, please add some libs")
  ENDIF ()
  #
  # Add output directory.
  SET(OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${SERVICE_NAME}")
  FILE(MAKE_DIRECTORY ${OUTPUT_DIR})
  #
  # Add actual target.
  ADD_LIBRARY(${SERVICE_NAME} MODULE ${HDRS} ${SRCS})
  TARGET_LINK_LIBRARIES(${SERVICE_NAME} ${LIBS})
  FOREACH(LIB ${LIBS_DEBUG})
    TARGET_LINK_LIBRARIES(${SERVICE_NAME} debug ${LIB})
  ENDFOREACH()
  FOREACH(LIB ${LIBS_RELEASE})
    TARGET_LINK_LIBRARIES(${SERVICE_NAME} optimized ${LIB})
  ENDFOREACH()
  # XXX when 10.4 dropped, "else" clause becomes the only one
  # XXX (provided that 'osx10.4' logic removed from build.rb)
  IF (OSX10.4_BUILD)
    ADD_CUSTOM_TARGET(${SERVICE_NAME}Externals ALL
                      COMMAND ruby build.rb osx10.4
                      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../external"
                      COMMENT Building externals...)
    ADD_DEPENDENCIES(${SERVICE_NAME} ${SERVICE_NAME}Externals)
  ELSE ()
    ADD_CUSTOM_TARGET(${SERVICE_NAME}Externals ALL
                      COMMAND ruby build.rb
                      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../external"
                      COMMENT Building externals...)
    ADD_DEPENDENCIES(${SERVICE_NAME} ${SERVICE_NAME}Externals)
  ENDIF ()
  #
  # Copy in manifest.
  GET_TARGET_PROPERTY(loc ${SERVICE_NAME} LOCATION)
  GET_FILENAME_COMPONENT(SERVICE_LIBRARY "${loc}" NAME)
  CONFIGURE_FILE("${CMAKE_CURRENT_SOURCE_DIR}/manifest.json"
                 "${OUTPUT_DIR}/manifest.json")  
  ADD_CUSTOM_COMMAND(TARGET ${SERVICE_NAME} POST_BUILD
                     COMMAND ${CMAKE_COMMAND} -E copy_if_different
                             \"${loc}\" \"${OUTPUT_DIR}\")
  # Strip non-debug unix/osx builds.
  IF (NOT WIN32)
    IF ("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
      ADD_CUSTOM_COMMAND(TARGET ${SERVICE_NAME} POST_BUILD
                         COMMAND cmake -E echo "stripping \"${OUTPUT_DIR}/${SERVICE_LIBRARY}\""
                         COMMAND strip -x \"${OUTPUT_DIR}/${SERVICE_LIBRARY}\")
    ENDIF ()
  ENDIF ()
ENDMACRO ()

MACRO (BPAddPythonService)
  IF (NOT DEFINED SERVICE_NAME)
    MESSAGE(FATAL_ERROR, "$SERVICE_NAME is not defined, please add service name")
  ENDIF ()
  IF (NOT DEFINED SRCS)
    MESSAGE(FATAL_ERROR, "$SRCS is not defined, please add some source files")
  ENDIF ()
  #
  # Add output directory.
  SET(OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${SERVICE_NAME}")
  FILE(MAKE_DIRECTORY ${OUTPUT_DIR})
  #
  # Add actual target.
  SET(ALL_DEPS)
  FOREACH(SRC ${SRCS})
    SET(MY_SRC "${CMAKE_CURRENT_SOURCE_DIR}/${SRC}")
    SET(MY_DST "${OUTPUT_DIR}/${SRC}")
    ADD_CUSTOM_COMMAND(
      OUTPUT ${MY_DST}
      DEPENDS ${MY_SRC}
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MY_SRC} ${MY_DST}
    )
    SET(ALL_DEPS ${ALL_DEPS} ${MY_DST})
  ENDFOREACH()
  ADD_CUSTOM_TARGET(${SERVICE_NAME} ALL DEPENDS ${ALL_DEPS})
  # XXX when 10.4 dropped, "else" clause becomes the only one
  # XXX (provided that 'osx10.4' logic removed from build.rb)
  IF (OSX10.4_BUILD)
    ADD_CUSTOM_TARGET(${SERVICE_NAME}Externals ALL
                      COMMAND ruby build.rb osx10.4
                      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../external"
                      COMMENT Building externals...)
    ADD_DEPENDENCIES(${SERVICE_NAME} ${SERVICE_NAME}Externals)
  ELSE ()
    ADD_CUSTOM_TARGET(${SERVICE_NAME}Externals ALL
                      COMMAND ruby build.rb
                      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../external"
                      COMMENT Building externals...)
    ADD_DEPENDENCIES(${SERVICE_NAME} ${SERVICE_NAME}Externals)
  ENDIF ()
  #
  # Copy in manifest.
  GET_TARGET_PROPERTY(loc ${SERVICE_NAME} LOCATION)
  GET_FILENAME_COMPONENT(SERVICE_LIBRARY "${loc}" NAME)
  CONFIGURE_FILE("${CMAKE_CURRENT_SOURCE_DIR}/manifest.json"
                 "${OUTPUT_DIR}/manifest.json")  
ENDMACRO ()

MACRO (BPAddRubyService)
  IF (NOT DEFINED SERVICE_NAME)
    MESSAGE(FATAL_ERROR, "$SERVICE_NAME is not defined, please add service name")
  ENDIF ()
  IF (NOT DEFINED SRCS)
    MESSAGE(FATAL_ERROR, "$SRCS is not defined, please add some source files")
  ENDIF ()
  #
  # Add output directory.
  SET(OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${SERVICE_NAME}")
  FILE(MAKE_DIRECTORY ${OUTPUT_DIR})
  #
  # Add actual target.
  SET(ALL_DEPS)
  FOREACH(SRC ${SRCS})
    SET(MY_SRC "${CMAKE_CURRENT_SOURCE_DIR}/${SRC}")
    SET(MY_DST "${OUTPUT_DIR}/${SRC}")
    ADD_CUSTOM_COMMAND(
      OUTPUT ${MY_DST}
      DEPENDS ${MY_SRC}
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MY_SRC} ${MY_DST}
    )
    SET(ALL_DEPS ${ALL_DEPS} ${MY_DST})
  ENDFOREACH()
  ADD_CUSTOM_TARGET(${SERVICE_NAME} ALL DEPENDS ${ALL_DEPS})
  # XXX when 10.4 dropped, "else" clause becomes the only one
  # XXX (provided that 'osx10.4' logic removed from build.rb)
  IF (OSX10.4_BUILD)
    ADD_CUSTOM_TARGET(${SERVICE_NAME}Externals ALL
                      COMMAND ruby build.rb osx10.4
                      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../external"
                      COMMENT Building externals...)
    ADD_DEPENDENCIES(${SERVICE_NAME} ${SERVICE_NAME}Externals)
  ELSE ()
    ADD_CUSTOM_TARGET(${SERVICE_NAME}Externals ALL
                      COMMAND ruby build.rb
                      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../external"
                      COMMENT Building externals...)
    ADD_DEPENDENCIES(${SERVICE_NAME} ${SERVICE_NAME}Externals)
  ENDIF ()
  #
  # Copy in manifest.
  GET_TARGET_PROPERTY(loc ${SERVICE_NAME} LOCATION)
  GET_FILENAME_COMPONENT(SERVICE_LIBRARY "${loc}" NAME)
  CONFIGURE_FILE("${CMAKE_CURRENT_SOURCE_DIR}/manifest.json"
                 "${OUTPUT_DIR}/manifest.json")  
ENDMACRO ()

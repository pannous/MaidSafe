#==================================================================================================#
#                                                                                                  #
#  Copyright 2012 MaidSafe.net limited                                                             #
#                                                                                                  #
#  This MaidSafe Software is licensed to you under (1) the MaidSafe.net Commercial License,        #
#  version 1.0 or later, or (2) The General Public License (GPL), version 3, depending on which    #
#  licence you accepted on initial access to the Software (the "Licences").                        #
#                                                                                                  #
#  By contributing code to the MaidSafe Software, or to this project generally, you agree to be    #
#  bound by the terms of the MaidSafe Contributor Agreement, version 1.0, found in the root        #
#  directory of this project at LICENSE, COPYING and CONTRIBUTOR respectively and also available   #
#  at: http://www.maidsafe.net/licenses                                                            #
#                                                                                                  #
#  Unless required by applicable law or agreed to in writing, the MaidSafe Software distributed    #
#  under the GPL Licence is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF   #
#  ANY KIND, either express or implied.                                                            #
#                                                                                                  #
#  See the Licences for the specific language governing permissions and limitations relating to    #
#  use of the MaidSafe Software.                                                                   #
#                                                                                                  #
#==================================================================================================#
#                                                                                                  #
#  Module used to locate Callback File System (CBFS) lib and header.                               #
#                                                                                                  #
#  Required variable for using CBFS is:                                                            #
#    CBFS_KEY                                                                                      #
#                                                                                                  #
#  This should be set to the value of the EldoS licence key, which must be provided to use CBFS.   #
#  This is automatically set via cloning a private MaidSafe repo for MaidSafe's use only.  To use  #
#  a different key, set CBFS_KEY when invoking cmake.  You can either provide the value of the     #
#  key or else the path to a file containing only the key's value:                                 #
#    cmake . -DCBFS_KEY=<Value of key>                                                             #
#  or                                                                                              #
#    cmake . -DCBFS_KEY=<Path to key file>                                                         #
#                                                                                                  #
#  Settable variables to aid with the CBFS module are:                                             #
#    CBFS_ROOT_DIR and DONT_USE_CBFS                                                               #
#                                                                                                  #
#  Variables set and cached by this module are:                                                    #
#    CbfsIncludeDir, CbfsLibraries, CbfsCab, CbfsInstaller and CbfsFound.                          #
#                                                                                                  #
#  Variables set and NOT cached by this module are:                                                #
#    CbfsKey.                                                                                      #
#                                                                                                  #
#==================================================================================================#


# Always retry to find CBFS in case user has provided a new location
unset(CbfsIncludeDir CACHE)
unset(CbfsLibrary CACHE)
unset(CbfsLibraryDebug CACHE)
unset(CbfsLibraries CACHE)
unset(CbfsCab CACHE)
unset(CbfsInstaller CACHE)
set(CbfsFound FALSE CACHE INTERNAL "")

if(DONT_USE_CBFS)
  return()
endif()

# If DONT_USE_CBFS=FALSE, assume CBFS is a requirement
if(DEFINED DONT_USE_CBFS)
  # DONT_USE_CBFS has been explicitly defined to FALSE, not just undefined
  set(CbfsRequired ON)
else()
  set(CbfsRequired OFF)
endif()

# If user defined CBFS_ROOT_DIR, assume CBFS is a requirement
if(CBFS_ROOT_DIR)
  set(CbfsRequired ON)
  set(CBFS_ROOT_DIR ${CBFS_ROOT_DIR} CACHE PATH "Path to Callback File System library directory" FORCE)
else()
  set(CbfsRequired ${CbfsRequired})
  set(CBFS_ROOT_DIR
        "C:/Program Files/EldoS/Callback File System"
        "D:/Program Files/EldoS/Callback File System"
        "E:/Program Files/EldoS/Callback File System"
        "C:/Program Files (x86)/EldoS/Callback File System"
        "D:/Program Files (x86)/EldoS/Callback File System"
        "E:/Program Files (x86)/EldoS/Callback File System")
endif()

# Prepare to find CBFS libs and headers
if(CMAKE_CL_64)
  set(CbfsLibPathSuffix "SourceCode/CallbackFS/CPP/x64/Release" "SourceCode/CBFS/CPP/x64/Release")
  set(CbfsLibPathSuffixDebug "SourceCode/CallbackFS/CPP/x64/Debug" "SourceCode/CBFS/CPP/x64/Debug")
  set(CbfsIncludePathSuffix "SourceCode/CallbackFS/CPP" "SourceCode/CBFS/CPP")
  set(CbfsInstallerPathSuffix "HelperDLLs/Installer/64bit/x64")
else()
  set(CbfsLibPathSuffix "SourceCode/CallbackFS/CPP/Release" "SourceCode/CBFS/CPP/Release")
  set(CbfsLibPathSuffixDebug "SourceCode/CallbackFS/CPP/Debug" "SourceCode/CBFS/CPP/Debug")
  set(CbfsIncludePathSuffix "SourceCode/CallbackFS/CPP" "SourceCode/CBFS/CPP")
  set(CbfsInstallerPathSuffix "HelperDLLs/Installer/32bit")
endif()
set(CbfsCabPathSuffix "Drivers")

macro(show_error_message_and_exit MissingComponent)
  set(ErrorMessage "\nCould not find Callback File System.  NO ${MissingComponent} - ")
  set(ErrorMessage "${ErrorMessage}If Cbfs is already installed, run:\n")
  set(ErrorMessage "${ErrorMessage}cmake . -DCBFS_ROOT_DIR=<Path to Cbfs root directory>\n")
  set(ErrorMessage "${ErrorMessage}e.g.\ncmake . -DCBFS_ROOT_DIR=\"C:\\Program Files\\EldoS\\Callback File System\"\n\n")
  if(CbfsRequired)
    message(FATAL_ERROR "${ErrorMessage}")
  else()
    message(WARNING "${ErrorMessage}")
    return()
  endif()
endmacro()

# Find CBFS Release lib
find_library(CbfsLibrary NAMES cbfs PATHS ${CBFS_ROOT_DIR} PATH_SUFFIXES ${CbfsLibPathSuffix} NO_DEFAULT_PATH)
if(NOT CbfsLibrary)
  show_error_message_and_exit("CBFS LIBRARY")
endif()

# Find CBFS Debug lib
find_library(CbfsLibraryDebug NAMES cbfs PATHS ${CBFS_ROOT_DIR} PATH_SUFFIXES ${CbfsLibPathSuffixDebug} NO_DEFAULT_PATH)
if(NOT CbfsLibraryDebug)
  show_error_message_and_exit("CBFS DEBUG LIBRARY")
endif()

set(CbfsLibraries optimized ${CbfsLibrary} debug ${CbfsLibraryDebug} CACHE STRING "Path to CBFS Debug and Release libraries.")

# Find CBFS header
find_path(CbfsIncludeDir CbFS.h PATHS ${CBFS_ROOT_DIR} PATH_SUFFIXES ${CbfsIncludePathSuffix} NO_DEFAULT_PATH)
if(NOT CbfsIncludeDir)
  show_error_message_and_exit("CbFS.h")
endif()

# Find CBFS cab file
find_file(CbfsCab NAMES cbfs.cab PATHS ${CBFS_ROOT_DIR} PATH_SUFFIXES ${CbfsCabPathSuffix} NO_DEFAULT_PATH)
if(NOT CbfsCab)
  show_error_message_and_exit("CBFS CABINET FILE")
endif()

# Find CBFS installer
find_file(CbfsInstaller NAMES cbfsinst.dll PATHS ${CBFS_ROOT_DIR} PATH_SUFFIXES ${CbfsInstallerPathSuffix} NO_DEFAULT_PATH)
if(NOT CbfsInstaller)
  show_error_message_and_exit("CBFS INSTALLER DLL")
endif()

# Get version of CBFS
file(STRINGS "${CbfsIncludeDir}/../dotNet/AssemblyInfo.cpp" CbfsVersionLine REGEX "AssemblyVersionAttribute")
string(REGEX MATCH "\"4." VersionFour "${CbfsVersionLine}")
string(REGEX MATCH "\"5." VersionFive "${CbfsVersionLine}")
if(VersionFour)
  set(CbfsVersion 4)
elseif(VersionFive)
  set(CbfsVersion 5)
endif()

message(STATUS "Found Callback Filesystem version ${CbfsVersion}")
message(STATUS "Found library ${CbfsLibrary}")
message(STATUS "Found library ${CbfsLibraryDebug}")
message(STATUS "Found cabinet file ${CbfsCab}")
message(STATUS "Found installer library ${CbfsInstaller}")

# Find licence key
if(CBFS_KEY)
  if(EXISTS ${CBFS_KEY})  # User set CBFS_KEY to path to key file
    file(READ ${CBFS_KEY} CbfsKey)
  else()  # User set CBFS_KEY to value of key
    set(CbfsKey ${CBFS_KEY})
  endif()
else()
  # Use MaidSafe's key
  set(LicenseFile ${CMAKE_BINARY_DIR}/MaidSafe-Drive-Private/eldos_licence_key_v${CbfsVersion}.txt)
  if(${CbfsVersion} EQUAL 4)
    set(ExpectedSHA512 e2de4a324268710fe780cd9c80841ce6c6d916411345001f9d06dfe3d0dc049e4df613acdaccb9b89232aa3654714985ed7245f93cf2c97c6060889291db0906)
  elseif(${CbfsVersion} EQUAL 5)
    set(ExpectedSHA512 82b34a9ad0112a7c498fb266ee97191aef460fbe6502766180382edb0ef90063977489a5659009212fa67ea2d5edf7ef6f00caa19a6fdca9fb3ca059a22e7b54)
  endif()
  if(NOT EXISTS ${LicenseFile})
    # Clone MaidSafe-Drive-Private
    execute_process(COMMAND ${Git_EXECUTABLE} clone git@github.com:maidsafe/MaidSafe-Drive-Private.git
                    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                    TIMEOUT 20
                    RESULT_VARIABLE ResultVar
                    OUTPUT_VARIABLE OutputVar
                    ERROR_VARIABLE ErrorVar)
    # Don't rely on RESULT_VARIABLE to indicate success here, since some versions of git may return 1 for success
    if(NOT EXISTS ${LicenseFile})
      set(ErrorMessage "\nFailed to clone MaidSafe-Drive-Private.\n\n${OutputVar}\n\n${ErrorVar}\n\n")
      set(ErrorMessage "${ErrorMessage}If you don't have permission to clone ")
      set(ErrorMessage "${ErrorMessage}git@github.com:maidsafe/MaidSafe-Drive-Private.git, you need ")
      set(ErrorMessage "${ErrorMessage}to set CBFS_KEY when invoking cmake.  You can either provide ")
      set(ErrorMessage "${ErrorMessage}the value of the key or else the path to a file containing ")
      set(ErrorMessage "${ErrorMessage}only the key's value:\n")
      set(ErrorMessage "${ErrorMessage}cmake . -DCBFS_KEY=<Value of key>\n")
      set(ErrorMessage "${ErrorMessage}or\ncmake . -DCBFS_KEY=<Path to key file>\n")
      message(FATAL_ERROR "${ErrorMessage}")
    endif()
    # Hash check file
    file(SHA512 ${LicenseFile} CbfsSHA512)
    if(NOT ${CbfsSHA512} STREQUAL ${ExpectedSHA512})
      file(RENAME ${CMAKE_BINARY_DIR}/MaidSafe-Drive-Private ${CMAKE_BINARY_DIR}/MaidSafe-Drive-Private-Failed)
      message(FATAL_ERROR "Failed hash check in MaidSafe-Drive-Private.")
    endif()
  else()
    # Hash check file
    file(SHA512 ${LicenseFile} CbfsSHA512)
    if(NOT ${CbfsSHA512} STREQUAL ${ExpectedSHA512})
      # Try pulling to get updated key file
      execute_process(COMMAND ${Git_EXECUTABLE} pull
                      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/MaidSafe-Drive-Private
                      TIMEOUT 20
                      RESULT_VARIABLE ResultVar
                      OUTPUT_VARIABLE OutputVar
                      ERROR_VARIABLE ErrorVar)
      if(NOT ${ResultVar} EQUAL 0)
        message(FATAL_ERROR "Failed to pull in MaidSafe-Drive-Private.\n\n${OutputVar}\n\n${ErrorVar}\n\n")
      endif()
      # Hash check updated file
      file(SHA512 ${LicenseFile} CbfsSHA512)
      if(NOT ${CbfsSHA512} STREQUAL ${ExpectedSHA512})
        file(RENAME ${CMAKE_BINARY_DIR}/MaidSafe-Drive-Private ${CMAKE_BINARY_DIR}/MaidSafe-Drive-Private-Failed)
        message(FATAL_ERROR "Failed hash check in MaidSafe-Drive-Private.")
      endif()
    endif()
  endif()
  # Read in the file contents
  file(READ ${LicenseFile} CbfsKey)
endif()

set(CbfsFound TRUE CACHE INTERNAL "")

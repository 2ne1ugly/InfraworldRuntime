@echo off

::#####################################VARS#############################################################################
set SCRIPT_FOLDER=%cd%

set GRPC_ROOT=%SCRIPT_FOLDER%\grpc
set GRPC_INCLUDE_DIR=%SCRIPT_FOLDER%\GrpcIncludes
set GRPC_LIBRARIES_DIR=%SCRIPT_FOLDER%\GrpcLibraries\Linux
set GRPC_PROGRAMS_DIR= %SCRIPT_FOLDER%\GrpcPrograms\Linux

set CMAKE_BUILD_DIR=%GRPC_ROOT%\.build\Linux

set REMOTE_ORIGIN=https://github.com/grpc/grpc.git
set BRANCH=v1.27.x
::#####################################VARS#############################################################################

:GET_UE_ROOT
IF "%UE_ROOT%" == "" (echo "UE_ROOT directory does not exist, please set correct UE_ROOT via SET UE_ROOT=<PATH_TO_UNREAL_ENGINE_FOLDER>" && GOTO ABORT)

:CLEAN
REM IF EXIST %GRPC_ROOT% (cd %GRPC_ROOT% && git clean -fdx && git submodule foreach git clean -fdx && cd %SCRIPT_FOLDER%) 
REM IF EXIST %GRPC_INCLUDE_DIR% (rmdir %GRPC_INCLUDE_DIR%)
REM IF EXIST %GRPC_LIBRARIES_DIR% (rmdir %GRPC_LIBRARIES_DIR%)
REM IF EXIST %GRPC_PROGRAMS_DIR% (rmdir %GRPC_PROGRAMS_DIR%)

:CLONE_OR_PULL
if EXIST %GRPC_ROOT% (cd %GRPC_ROOT% && echo Pulling repo && git pull) else (call git clone %REMOTE_ORIGIN% && cd %GRPC_ROOT%)

git fetch
git checkout -f
git checkout -t origin/%BRANCH%
git submodule update --init

SET SYSROOT_RAW="%LINUX_MULTIARCH_ROOT%\x86_64-unknown-linux-gnu"

:BUILD_ALL
rmdir %CMAKE_BUILD_DIR% /s /q
mkdir %CMAKE_BUILD_DIR%
cd %CMAKE_BUILD_DIR%
call cmake ../.. -G "NMake Makefiles" ^
	-DCMAKE_TOOLCHAIN_FILE="%SCRIPT_FOLDER%\LinuxToolChain.cmake" ^
	-DCMAKE_BUILD_TYPE=Release -Dprotobuf_BUILD_TESTS="False" -DgRPC_BUILD_TESTS="False" -DgRPC_ZLIB_PROVIDER=package -DgRPC_SSL_PROVIDER=package ^
	-DOPENSSL_INCLUDE_DIR="%UE_ROOT%\Engine\Source\ThirdParty\OpenSSL\1.1.1c\include\Linux\x86_64-unknown-linux-gnu" ^
	-DOPENSSL_CRYPTO_LIBRARY="%UE_ROOT%\Engine\Source\ThirdParty\OpenSSL\1.1.1c\lib\Linux\x86_64-unknown-linux-gnu\libcrypto.a" ^
	-DOPENSSL_SSL_LIBRARY="%UE_ROOT%\Engine\Source\ThirdParty\OpenSSL\1.1.1c\lib\Linux\x86_64-unknown-linux-gnu\libssl.a" ^
	-DZLIB_INCLUDE_DIR="%UE_ROOT%\Engine\Source\ThirdParty\zlib\v1.2.8\include\Linux\x86_64-unknown-linux-gnu" ^
	-DZLIB_LIBRARY="%UE_ROOT%\Engine\Source\ThirdParty\zlib\v1.2.8\lib\Linux\x86_64-unknown-linux-gnu\libz.a"

set CL=/MP
call cmake --build . --target absl_throw_delegate absl_strings address_sorting c-ares gpr grpc grpc++ upb

:COPY_HEADERS
robocopy %GRPC_ROOT%\include %GRPC_INCLUDE_DIR% /E *.h > nul
robocopy %GRPC_ROOT%\third_party\protobuf\src %GRPC_INCLUDE_DIR% /E *.h *.inc > nul

:COPY_LIBRARIES
robocopy "%CMAKE_BUILD_DIR%\third_party\abseil-cpp\absl\base" "%GRPC_LIBRARIES_DIR%" "libabsl_throw_delegate.a" > nul
robocopy "%CMAKE_BUILD_DIR%\third_party\abseil-cpp\absl\strings" "%GRPC_LIBRARIES_DIR%" "libabsl_strings.a" > nul
robocopy "%CMAKE_BUILD_DIR%" "%GRPC_LIBRARIES_DIR%" *.a > nul
robocopy "%CMAKE_BUILD_DIR%\third_party\cares\cares\lib" "%GRPC_LIBRARIES_DIR%" "libcares.a" > nul
robocopy "%CMAKE_BUILD_DIR%\third_party\protobuf" "%GRPC_LIBRARIES_DIR%" "libprotobuf.a" > nul

:Finish
cd %SCRIPT_FOLDER%
GOTO GRACEFULEXIT

:ABORT
pause
echo Aborted...

:GRACEFULEXIT
echo Build done!

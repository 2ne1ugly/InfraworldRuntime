@echo off

::#####################################VARS#############################################################################
set SCRIPT_FOLDER=%cd%

set GRPC_ROOT=%SCRIPT_FOLDER%\grpc
set GRPC_INCLUDE_DIR=%SCRIPT_FOLDER%\GrpcIncludes
set GRPC_LIBRARIES_DIR=%SCRIPT_FOLDER%\GrpcLibraries\Win64
set GRPC_PROGRAMS_DIR= %SCRIPT_FOLDER%\GrpcPrograms\Win64

set CMAKE_BUILD_DIR=%GRPC_ROOT%\.build\Win64

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

REM -DSSL_EAY_LIBRARY_RELEASE="%UE_ROOT%\Engine\Source\ThirdParty\OpenSSL\1.1.1\Lib\Win64\VS2015\Release\libssl.lib" ^
REM -DSSL_EAY_LIBRARY_DEBUG="%UE_ROOT%\Engine\Source\ThirdParty\OpenSSL\1.1.1\Lib\Win64\VS2015\Debug\libssl.lib" ^

:BUILD_ALL
mkdir %CMAKE_BUILD_DIR%
cd %CMAKE_BUILD_DIR%
cmake ../.. -G "Visual Studio 16 2019" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CONFIGURATION_TYPES=Release -Dprotobuf_BUILD_TESTS=OFF -DgRPC_BUILD_TESTS=OFF -DgRPC_ZLIB_PROVIDER=package -DgRPC_SSL_PROVIDER=package ^
	-DZLIB_LIBRARY_RELEASE="%UE_ROOT%\Engine\Source\ThirdParty\zlib\v1.2.8\lib\Win64\VS2015\Release\zlibstatic.lib" ^
	-DZLIB_LIBRARY_DEBUG="%UE_ROOT%\Engine\Source\ThirdParty\zlib\v1.2.8\lib\Win64\VS2015\Debug\zlibstatic.lib" ^
	-DLIB_EAY_RELEASE="%UE_ROOT%\Engine\Source\ThirdParty\OpenSSL\1.1.1\Lib\Win64\VS2015\Release\libcrypto.lib" ^
	-DLIB_EAY_DEBUG="%UE_ROOT%\Engine\Source\ThirdParty\OpenSSL\1.1.1\Lib\Win64\VS2015\Debug\libcrypto.lib" ^
	-DSSL_EAY_RELEASE="%UE_ROOT%\Engine\Source\ThirdParty\OpenSSL\1.1.1\Lib\Win64\VS2015\Release\libssl.lib" ^
	-DSSL_EAY_DEBUG="%UE_ROOT%\Engine\Source\ThirdParty\OpenSSL\1.1.1\Lib\Win64\VS2015\Debug\libssl.lib"

cmake --build . --config Release -j4 --target absl_throw_delegate absl_strings address_sorting c-ares gpr grpc grpc++ upb protoc grpc_cpp_plugin

:COPY_HEADERS
robocopy %GRPC_ROOT%\include %GRPC_INCLUDE_DIR% /E *.h > nul
robocopy %GRPC_ROOT%\third_party\protobuf\src %GRPC_INCLUDE_DIR% /E *.h *.inc > nul

:COPY_LIBRARIES
robocopy "%CMAKE_BUILD_DIR%\third_party\abseil-cpp\absl\base\Release" "%GRPC_LIBRARIES_DIR%" "absl_throw_delegate.lib" > nul
robocopy "%CMAKE_BUILD_DIR%\third_party\abseil-cpp\absl\strings\Release" "%GRPC_LIBRARIES_DIR%" "absl_strings.lib" > nul
robocopy "%CMAKE_BUILD_DIR%\Release" "%GRPC_LIBRARIES_DIR%" *.lib > nul
robocopy "%CMAKE_BUILD_DIR%\third_party\cares\cares\lib\Release" "%GRPC_LIBRARIES_DIR%" "cares.lib" > nul
robocopy "%CMAKE_BUILD_DIR%\third_party\protobuf\Release" "%GRPC_LIBRARIES_DIR%" "libprotobuf.lib" > nul

:COPY_PROGRAMS
robocopy "%CMAKE_BUILD_DIR%\Release" %GRPC_PROGRAMS_DIR% *.exe /R:0 /S > nul
copy "%CMAKE_BUILD_DIR%\third_party\protobuf\Release\protoc.exe" %GRPC_PROGRAMS_DIR%\protoc.exe

:Finish
cd %SCRIPT_FOLDER%
GOTO GRACEFULEXIT

:ABORT
pause
echo Aborted...

:GRACEFULEXIT
echo Build done!

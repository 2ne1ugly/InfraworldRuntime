# the name of the target operating system
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(TRIPPLE x86_64-unknown-linux-gnu)

# include (CMakeForceCompiler)
file(TO_CMAKE_PATH $ENV{LINUX_MULTIARCH_ROOT}\\x86_64-unknown-linux-gnu LINUX_ROOT)
file(TO_CMAKE_PATH $ENV{UE_ROOT}\\Engine\\Source\\ThirdParty\\Linux\\LibCxx STANDARD_ROOT)
set(C_LINKER_LIB "-lc")
set(CXX_LINKER_LIB "-lc")
set(UE4_CXX_COMPILER_FLAG "-nostdinc++ -I ${STANDARD_ROOT}/include -I ${STANDARD_ROOT}/include/c++/v1 -fno-math-errno -fno-rtti -fvisibility=hidden -fdiagnostics-format=msvc -fdiagnostics-absolute-paths")
set(C_DEF "-D GOOGLE_PROTOBUF_NO_RTTI -D GPR_FORBID_UNREACHABLE_CODE -D GRPC_ALLOW_EXCEPTIONS=0")
# which compilers to use for C and C++
# include(CMakeForceCompiler)
#Use 8.1 names if path has spaces since it will break on paths with spaces
set(CMAKE_AR ${LINUX_ROOT}/bin/llvm-ar.exe)
set(CMAKE_RANLIB ${LINUX_ROOT}/bin/x86_64-unknown-linux-gnu-ranlib.exe)
set(CMAKE_LINKER lld)

set(CMAKE_C_COMPILER ${LINUX_ROOT}/bin/clang.exe)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --sysroot=${LINUX_ROOT} -nodefaultlibs --target=${TRIPPLE} -D GRPC_LINUX_TCP_H ${C_DEF}")
set(CMAKE_C_LINK_FLAGS  "${CMAKE_C_LINK_FLAGS} --sysroot=${LINUX_ROOT} -nodefaultlibs ${C_LINKER_LIB} --target=${TRIPPLE} -fuse-ld=lld -D GRPC_LINUX_TCP_H ${C_DEF}")
set(CMAKE_CXX_COMPILER ${LINUX_ROOT}/bin/clang++.exe)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --sysroot=${LINUX_ROOT} -nodefaultlibs --target=${TRIPPLE} ${UE4_CXX_COMPILER_FLAG} -D GRPC_LINUX_TCP_H ${C_DEF}")
set(CMAKE_CXX_LINK_FLAGS "${CMAKE_CXX_LINK_FLAGS} --sysroot=${LINUX_ROOT} -nodefaultlibs ${CXX_LINKER_LIB} --target=${TRIPPLE} ${STANDARD_ROOT}/lib/Linux/x86_64-unknown-linux-gnu/libc++.a ${STANDARD_ROOT}/lib/Linux/x86_64-unknown-linux-gnu/libc++abi.a -fuse-ld=lld -D GRPC_LINUX_TCP_H ${C_DEF}")

set(CMAKE_FIND_ROOT_PATH ${LINUX_ROOT})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)

# REM -DCMAKE_SYSTEM_NAME="Linux" ^
# REM -DCMAKE_SYSTEM_PROCESSOR="x86_64" ^
# REM -DUNIX="True" ^
# REM -DCMAKE_SYSROOT="%SYSROOT_RAW:\=/%" ^
# REM -DCMAKE_C_COMPILER="%LINUX_MULTIARCH_ROOT%\x86_64-unknown-linux-gnu\bin\clang.exe" ^
# REM -DCMAKE_CXX_COMPILER="%LINUX_MULTIARCH_ROOT%\x86_64-unknown-linux-gnu\bin\clang++.exe" ^
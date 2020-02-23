/*
 * Copyright 2018 Vizor Games LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */

// Disable some warnings in GRPC
#if PLATFORM_WINDOWS
	#pragma warning(push)
	#pragma warning (disable : 4125)// decimal digit terminates...
	#pragma warning (disable : 4647)// behavior change __is_pod...
	#pragma warning (disable : 4668)// 'symbol' is not defined as a preprocessor macro...
	#pragma warning (disable : 4456)// declaration of 'size' hides previous local declaration
	#pragma warning (disable : 4577)// 'noexcept' used with no exception handling mode specified
	#pragma warning (disable : 4946)// reinterpret_cast used between related classes
	#pragma warning (disable : 4005)// 'TEXT': macro redefinition
	#pragma warning (disable : 4582)// constructor is not implicitly called
	#pragma warning (disable : 4583)// destructor is not implicitly called
	#pragma warning (disable : 4800)// Implicit conversion from 'type' to bool. Possible information loss

	#ifdef WINDOWS_PLATFORM_TYPES_GUARD
		#pragma warning(push)
		#include "Windows/HideWindowsPlatformTypes.h"
	#endif
#elif PLATFORM_COMPILER_CLANG
    #include "CoreMinimal.h"

	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Wundef"
	#pragma clang diagnostic ignored "-Wshadow"

    #ifndef bswap_16
    static inline uint16 bswap_16(uint16 x) {
        return static_cast<uint16>(((x & 0xFF) << 8) | ((x & 0xFF00) >> 8));
    }
    #define bswap_16(x) bswap_16(x)
    #endif

    #ifndef bswap_32
    static inline uint32 bswap_32(uint32 x) {
        return (((x & 0xFF) << 24) |
            ((x & 0xFF00) << 8) |
            ((x & 0xFF0000) >> 8) |
            ((x & 0xFF000000) >> 24));
    }
    #define bswap_32(x) bswap_32(x)
    #endif

    #ifndef bswap_64
    static inline uint64 bswap_64(uint64 x) {
        return (((x & 0xFFULL) << 56) |
            ((x & 0xFF00ULL) << 40) |
            ((x & 0xFF0000ULL) << 24) |
            ((x & 0xFF000000ULL) << 8) |
            ((x & 0xFF00000000ULL) >> 8) |
            ((x & 0xFF0000000000ULL) >> 24) |
            ((x & 0xFF000000000000ULL) >> 40) |
            ((x & 0xFF00000000000000ULL) >> 56));
    }
    #define bswap_64(x) bswap_64(x)
    #endif
#endif

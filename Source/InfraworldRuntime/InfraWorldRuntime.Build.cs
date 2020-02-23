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

// #define TRACE

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net.NetworkInformation;
using System.Text;
using System.Text.RegularExpressions;
using UnrealBuildTool;

public class InfraworldRuntime : ModuleRules
{
    string LibRoot;

    public InfraworldRuntime(ReadOnlyTargetRules Target) : base(Target)
    {
        PublicDefinitions.Add("GOOGLE_PROTOBUF_NO_RTTI");
        PublicDefinitions.Add("GPR_FORBID_UNREACHABLE_CODE");
        PublicDefinitions.Add("GRPC_ALLOW_EXCEPTIONS=0");

        PublicIncludePaths.Add(Path.Combine(ModuleDirectory, "..", "..", "GrpcIncludes"));
		PublicIncludePaths.Add(Path.Combine(ModuleDirectory, "Layton"));
        LibRoot = Path.Combine(ModuleDirectory, "..", "..", "GrpcLibraries");

        string[] libs = {
            "absl_throw_delegate",
            "absl_strings",
            "address_sorting",
            "cares",
            "gpr",
            "grpc",
            "grpc++",
            "upb"
        };
        foreach (string lib in libs)
        {
            PublicAdditionalLibraries.Add(ToPlatformPath(Target.Platform, lib));
        }
        if (Target.Platform == UnrealTargetPlatform.Linux)
        {
            PublicAdditionalLibraries.Add(Path.Combine(LibRoot, "Linux", "libprotobuf.a"));
        }
        else if (Target.Platform == UnrealTargetPlatform.Win64)
        {
            PublicAdditionalLibraries.Add(Path.Combine(LibRoot, "Win64", "libprotobuf.lib"));
        }




        PublicDependencyModuleNames.AddRange(new string[] {
            "Core"
        });

        AddEngineThirdPartyPrivateStaticDependencies(Target, "OpenSSL");
        AddEngineThirdPartyPrivateStaticDependencies(Target, "zlib");

        PrivateDependencyModuleNames.AddRange(new string[] { "CoreUObject", "Engine" });
    }

    private string ToPlatformPath(UnrealTargetPlatform Platform, string LibName)
    {
        if (Platform == UnrealTargetPlatform.Linux)
        {
            return Path.Combine(LibRoot, "Linux", "lib" + LibName + ".a");
        }
        else if (Platform == UnrealTargetPlatform.Win64)
        {
            return Path.Combine(LibRoot, "Win64", LibName + ".lib");
        }
        return "";
    }
}

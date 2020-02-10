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
#include "RpcClient.h"

#include "InfraworldRuntime.h"
#include "GrpcUriValidator.h"
#include "AsyncConduitBase.h"

#include "Containers/Ticker.h"
#include "Misc/CoreDelegates.h"
#include "CastUtils.h"

#include "GrpcIncludesBegin.h"
#include "grpcpp/impl/grpc_library.h"
#include "GrpcIncludesEnd.h"

#include "Misc/DefaultValueHelper.h"
#include "HAL/RunnableThread.h"
#include "Kismet/KismetStringLibrary.h"

// ============ RpcClient implementation ===========

bool URpcClient::Init(const FString& URI, UChannelCredentials* ChannelCredentials)
{
    grpc::internal::GrpcLibraryInitializer();
    FString ErrorMessage;
    if (!FGrpcUriValidator::Validate(URI, ErrorMessage))
    {
        UE_LOG(LogInfraworldRuntime, Error, TEXT("%s Unable to validate URI: %s"), *(GetClass()->GetName()), *ErrorMessage);
    }

    //Channel
    Channel = grpc::CreateChannel(casts::Proto_Cast<std::string>(URI), grpc::InsecureChannelCredentials());

    // Launch 'chaining' hierarchical init, which will init a superclass (a concrete implementation).
    PostInit();

    UE_LOG(LogInfraworldRuntime, Log, TEXT("RpcClient at [%p], finished HierarchicalInit"), this);

    return true;
}

URpcClient::URpcClient()
{
}

URpcClient::~URpcClient()
{
}

URpcClient* URpcClient::CreateRpcClient(TSubclassOf<URpcClient> Class, FRpcClientInstantiationParameters InstantiationParameters, UObject* Outer)
{
    const FString& URI = FString::Printf(TEXT("%s:%d"), *(InstantiationParameters.Ip), InstantiationParameters.Port);
    return CreateRpcClientUri(Class, URI, InstantiationParameters.ChannelCredentials, Outer);
}

URpcClient* URpcClient::CreateRpcClientUri(TSubclassOf<URpcClient> Class, const FString& URI, UChannelCredentials* ChannelCredentials, UObject* Outer)
{
    UObject* const RealOuter = Outer ? Outer : (UObject*)GetTransientPackage();
    
    if (URpcClient* const CreatedClient = NewObject<URpcClient>(RealOuter, *Class))
    {
		UE_LOG(LogInfraworldRuntime, Log, TEXT("Created RpcClient at [%p] with outer [%p]"), CreatedClient, RealOuter);
    	
        bool IsClientInitialized = CreatedClient->Init(URI, ChannelCredentials);
        if (!IsClientInitialized)
        {
            UE_LOG(LogInfraworldRuntime, Error, TEXT("Unable to initialize an RPC client (%s::Init() failed"), *(Class->GetName()));
            return nullptr;
        }
        else
        {
            UE_LOG(LogInfraworldRuntime, Verbose, TEXT("An instance of %s has been created and initialized"), *(Class->GetName()));
            return CreatedClient;
        }
    }
    else
    {
        UE_LOG(LogInfraworldRuntime, Fatal, TEXT("Unable to create an instance of RPC client (NewObject<%s>() failed)"), *(Class->GetName()));
        return nullptr;
    }
}

void URpcClient::Tick(float DeltaTime)
{
    void* Tag;
    bool Ok;
    UAsyncConduitBase* Conduit;

    gpr_timespec TimeSpec;
    TimeSpec.clock_type = GPR_TIMESPAN;
    TimeSpec.tv_sec = 0;
    TimeSpec.tv_nsec = 0;

    while (CompletionQueue.AsyncNext(&Tag, &Ok, TimeSpec) == CompletionQueue.GOT_EVENT)
    {
        Conduit = static_cast<UAsyncConduitBase*>(Tag);
        Conduit->Process();
    }
}

TStatId URpcClient::GetStatId() const
{
    return TStatId();
}

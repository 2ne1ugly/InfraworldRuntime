// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintAsyncActionBase.h"

#include "GrpcIncludesBegin.h"
#include "grpcpp/client_context.h"
#include "GrpcIncludesEnd.h"

#include "AsyncConduitBase.generated.h"

/**
 * 
 */
UCLASS(Abstract)
class INFRAWORLDRUNTIME_API UAsyncConduitBase : public UBlueprintAsyncActionBase
{
	GENERATED_BODY()

public:
    virtual void Process() PURE_VIRTUAL(URpcClient::PostInit, );

    grpc::Status Status;
    grpc::ClientContext ClientContext;
};

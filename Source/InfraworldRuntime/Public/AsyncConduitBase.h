// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintAsyncActionBase.h"

#include "GrpcIncludesBegin.h"
#include "grpcpp/client_context.h"
#include "GrpcIncludesEnd.h"

#include "Rpc.h"
#include "AsyncConduitBase.generated.h"

DECLARE_MULTICAST_DELEGATE_OneParam(FOnTagReceivedDelegate, bool);
DECLARE_DYNAMIC_MULTICAST_DELEGATE(FEmptyDelegate);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FMessageDelegate, FString, Message);

UCLASS()
class INFRAWORLDRUNTIME_API UTagDelegateWrapper : public UObject
{
    GENERATED_BODY()

public:
    FOnTagReceivedDelegate Delegate;
};

/**
 *      Single Request, Single Response
 */
UCLASS(Abstract)
class INFRAWORLDRUNTIME_API UUnaryConduitBase : public UBlueprintAsyncActionBase
{
	GENERATED_BODY()

public:
    grpc::Status Status;

    grpc::ClientContext ClientContext;

    UPROPERTY()
    UTagDelegateWrapper* Tag;

    virtual void OnResponseReceived(bool Ok) PURE_VIRTUAL(UUnaryConduitBase::OnResponseReceived, );
};

/**
 *      Bidrectional Stream
 */
UCLASS(Abstract)
class INFRAWORLDRUNTIME_API UBidirectionalStreamConduitBase : public UObject
{
    GENERATED_BODY()

public:

    grpc::Status Status;

    grpc::ClientContext ClientContext;

    bool bActive;

    bool bSendingMessage;

    UPROPERTY()
    TArray<UTagDelegateWrapper*> KnownTags;


    //virtual void SendMessage();

    //virtual void ReceiveMessage();

    //virtual void OnMessageSent();

    //virtual void OnMessageReceived();

    virtual void StartStream(UTagDelegateWrapper* DelegateWrapper);

    virtual void EndStream(UTagDelegateWrapper* DelegateWrapper);

    virtual void OnStreamStarted(bool Ok);

    virtual void OnStreamFinished(bool Ok);
};

// Fill out your copyright notice in the Description page of Project Settings.


#include "AsyncConduitBase.h"

UBidirectionalStreamConduitBase::UBidirectionalStreamConduitBase()
{
}

void UBidirectionalStreamConduitBase::StartSendTaskHandler()
{
}

void UBidirectionalStreamConduitBase::StartReceiveTaskHandler()
{
}

void UBidirectionalStreamConduitBase::StartStream(UTagDelegateWrapper* DelegateWrapper)
{
}

void UBidirectionalStreamConduitBase::EndStream(UTagDelegateWrapper* DelegateWrapper)
{
}

void UBidirectionalStreamConduitBase::OnStreamStarted(bool Ok)
{
	bActive = true;
	TaskReceiveDelegate = NewObject<UTagDelegateWrapper>(this);
	TaskReceiveDelegate->bBindDefault = false;
}

void UBidirectionalStreamConduitBase::OnStreamFinished(bool Ok)
{
	bActive = false;
}

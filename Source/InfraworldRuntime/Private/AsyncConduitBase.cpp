// Fill out your copyright notice in the Description page of Project Settings.


#include "AsyncConduitBase.h"


void UBidirectionalStreamConduitBase::StartStream(UTagDelegateWrapper* DelegateWrapper)
{
}

void UBidirectionalStreamConduitBase::EndStream(UTagDelegateWrapper* DelegateWrapper)
{
}

void UBidirectionalStreamConduitBase::OnStreamStarted(bool Ok)
{
	bActive = true;
}

void UBidirectionalStreamConduitBase::OnStreamFinished(bool Ok)
{
	bActive = false;
}

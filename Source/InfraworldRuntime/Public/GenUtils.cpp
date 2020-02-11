
#include "GenUtils.h"
#include "CastUtils.h"

void UGrpcClientContext::AddMetadata(const FString& Key, const FString& Value)
{
	Context.AddMetadata(casts::Proto_Cast<std::string>(Key), casts::Proto_Cast<std::string>(Value));
}

EGrpcStatusCode UGrpcStatus::GetErrorCode() const
{
	return casts::Proto_Cast<EGrpcStatusCode>(Status.error_code());
}

FString UGrpcStatus::GetErrorMsg() const
{
	return casts::Proto_Cast<FString>(Status.error_message());
}

FString UGrpcStatus::GetErrorDetail() const
{
	return casts::Proto_Cast<FString>(Status.error_details());
}

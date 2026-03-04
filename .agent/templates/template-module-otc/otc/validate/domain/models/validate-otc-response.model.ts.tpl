export interface ValidateOtcResponseModel {
  responseType: {
    value: string;
  };
  responseDetail: {
    errorCode: string;
    errorDesc: string;
    errorType: string;
  };
}

export interface GenerateOtcResponseModel {
  responseType: {
    value: string;
  };
  responseDetail: {
    errorCode: string;
    errorDesc: string;
    errorType: string;
  };
}

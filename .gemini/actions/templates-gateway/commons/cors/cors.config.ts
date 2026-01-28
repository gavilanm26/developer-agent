export function corsValue() {
  if (process.env.APPAPIGATEWAYCORSORIGIN == 'dev') {
    return ['https://dev.bancocajasocialsa.org', 'http://localhost:3000'];
  }

  if (process.env.APPAPIGATEWAYCORSORIGIN == 'qa') {
    return ['https://qa.bancocajasocialsa.org'];
  }

  if (process.env.APPAPIGATEWAYCORSORIGIN == 'prd') {
    return ['https://digital.bancocajasocial.com'];
  }
}

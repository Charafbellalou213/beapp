class ImpactConfig {
  const ImpactConfig._();

  static const String baseUrl = 'https://impact.dei.unipd.it/bwthw/';

  static const String pingEndpoint = 'gate/v1/ping/';
  static const String tokenEndpoint = 'gate/v1/token/';
  static const String refreshEndpoint = 'gate/v1/refresh/';

  static const String caloriesEndpoint = 'data/v1/calories/patients/';
  static const String stepsEndpoint = 'data/v1/steps/patients/';
  static const String distanceEndpoint = 'data/v1/distance/patients/';

  static const String username = 'K9t3MFnoo0';
  static const String password = '12345678!';

  static const String patientUsername = 'Jpefaq6m58';

  // se il dataset è di un anno fa e "ieri" non ha dati, usa la stessa data dell'anno prima
  static const bool usePreviousYearDemoData = false;

  static const Duration requestTimeout = Duration(seconds: 8);
}

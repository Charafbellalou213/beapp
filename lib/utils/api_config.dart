/// Configurazione dell'API dati attività (calorie/passi/distanza/esercizio).
///
/// Valori segnaposto: sostituisci `baseUrl` (e `apiToken`, se l'API lo
/// richiede) SOLO in locale, con le credenziali fornite dal corso.
/// Non committare mai credenziali reali su un repository GitHub pubblico.
class ApiConfig {
  static const String baseUrl = 'https://example.invalid/data/v1';
  static const String? apiToken = null;

  static const Duration requestTimeout = Duration(seconds: 8);
}

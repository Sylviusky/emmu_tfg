/// Sustituye este valor con tu clave de Places.
/// Mantenerlo en un único archivo evita configuraciones adicionales.
const String googleMapsApiKey = 'AIzaSyCUAa4T7lGEsFHtQnIBUL3moi10FSf6VOI';

bool get isGoogleMapsApiKeyConfigured =>
    googleMapsApiKey.trim().isNotEmpty &&
    googleMapsApiKey.trim() != 'TU_API_KEY_DE_PLACES';


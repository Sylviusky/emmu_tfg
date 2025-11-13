// v3 - Forcing redeploy with HARCODED API key for testing

import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as functions from "firebase-functions";
import { logger } from "firebase-functions";
import fetch from "node-fetch";

// La configuración se lee una vez cuando la función se inicializa
//const mapsApiKey = functions.config().maps?.key;

const mapsApiKey = "AIzaSyCud0_25Wse5k9qetnURnc8utLYq_bG86o";

export const reverseGeocode = onCall(async (request) => {
  // 1. Validar que la clave de API existe en la configuración del servidor
  if (!mapsApiKey) {
    logger.error("GEOCODING API KEY (maps.key) is not set in Firebase config.");
    throw new HttpsError("failed-precondition", "The server is not configured correctly.");
  }

  // 2. Obtener y validar los datos de entrada (lat, lng)
  const { lat, lng } = request.data || {};
  if (typeof lat !== "number" || typeof lng !== "number") {
    throw new HttpsError("invalid-argument", "The function must be called with 'lat' and 'lng' of type number.");
  }

  // 3. Construir la URL y llamar a la API de Google Maps
  const url = `https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lng}&key=${mapsApiKey}`;
  
  // Debug: Log API key prefix (first 10 chars) for verification
  logger.info("Using API key", { keyPrefix: mapsApiKey.substring(0, 10) + "..." });

  try {
    const res = await fetch(url);
    const json = await res.json();
    
    // Debug: Log the full response for troubleshooting
    logger.info("Geocoding API response", { 
      status: json.status, 
      error_message: json.error_message,
      has_results: !!json.results 
    });

    // 4. Manejar la respuesta de la API de Google Maps
    if (json.status !== "OK") {
      const errorDetails = {
        status: json.status,
        error_message: json.error_message,
        results: json.results
      };
      logger.error("Geocode API failed", errorDetails);
      
      // Provide more helpful error messages based on status
      let errorMessage = `Geocoding API failed with status: ${json.status}`;
      if (json.error_message) {
        errorMessage += ` - ${json.error_message}`;
      }
      
      if (json.status === "REQUEST_DENIED") {
        errorMessage += ". This usually means: 1) Geocoding API is not enabled for your API key, 2) Billing is not enabled on your Google Cloud project, 3) API key restrictions are blocking the request, or 4) The API key is invalid.";
      }
      
      throw new HttpsError("internal", errorMessage);
    }

    // 5. Devolver el resultado si todo fue exitoso
    return { results: json.results };

  } catch (error) {
    if (error instanceof HttpsError) {
      throw error; // Re-throw HttpsError as-is
    }
    logger.error("An unexpected error occurred while calling the Geocoding API", error);
    throw new HttpsError("internal", "An unexpected error occurred.");
  }
});




/*import { onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import fetch from "node-fetch";

const apiKey = functions.config().maps.key;

export const reverseGeocode = onCall(async (request) => {
  const { lat, lng } = request.data || {};
  if (typeof lat !== "number" || typeof lng !== "number") {
    throw new Error("invalid-argument: lat/lng required");
  }

  const key = process.env.GEOCODING_API_KEY;
  if (!key) {
    logger.error("GEOCODING_API_KEY is not set");
    throw new Error("failed-precondition: server not configured");
  }

  const url = `https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lng}&key=${key}`;
  const res = await fetch(url);
  const json = await res.json();
  if (json.status !== "OK") {
    logger.error("Geocode failed", json);
    throw new Error(`geocode-failed: ${json.status}`);
  }
  return { results: json.results };
});*/
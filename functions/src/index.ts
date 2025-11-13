/**
 * This file is for your Cloud Functions.
 */

// Import the 'onCall' function trigger
import { onCall, HttpsError } from "firebase-functions/v2/https";
// Import 'node-fetch' to make HTTP requests
import fetch from "node-fetch";
// Import logger for better error logging
import { logger } from "firebase-functions";

// IMPORTANT: Make sure this API key matches the "Cloud Functions Geocoding Key" in Google Cloud Console
// To verify: Go to APIs & Services > Credentials > Click on "Cloud Functions Geocoding Key" > Click "Mostrar clave"
const mapsApiKey = "AIzaSyCud0_25Wse5k9qetnURnc8utLYq_bG86o";

// The Cloud Function to perform reverse geocoding
export const reverseGeocode = onCall(async (request) => {
  // Check if the user is authenticated (optional but good practice)
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "The function must be called while authenticated.");
  }

  // Get lat and lng from the data sent from the app
  const { lat, lng } = request.data || {};

  // Validate that lat and lng exist and are numbers
  if (typeof lat !== "number" || typeof lng !== "number") {
    throw new HttpsError("invalid-argument", "The function must be called with 'lat' and 'lng' of type number.");
  }

  // Validate that API key exists
  if (!mapsApiKey) {
    logger.error("GEOCODING API KEY is not set correctly.");
    throw new HttpsError("failed-precondition", "The server is not configured correctly.");
  }

  // Construct the URL and call the Google Maps API
  const url = `https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lng}&key=${mapsApiKey}`;
  
  // Debug: Log API key prefix (first 10 chars) for verification
  logger.info("Using API key", { keyPrefix: mapsApiKey.substring(0, 10) + "..." });

  try {
    const response = await fetch(url);
    const data = await response.json() as { 
      results: any[], 
      status: string, 
      error_message?: string 
    };
    
    // Debug: Log the full response for troubleshooting
    logger.info("Geocoding API response", { 
      status: data.status, 
      error_message: data.error_message,
      has_results: !!data.results 
    });

    if (data.status !== "OK") {
      // Log detailed error information
      const errorDetails = {
        status: data.status,
        error_message: data.error_message,
        has_results: !!data.results
      };
      logger.error("Geocode API failed", errorDetails);
      
      // Provide more helpful error messages based on status
      let errorMessage = `Geocoding API failed with status: ${data.status}`;
      if (data.error_message) {
        errorMessage += ` - ${data.error_message}`;
      }
      
      if (data.status === "REQUEST_DENIED") {
        errorMessage += ". This usually means: 1) Geocoding API is not enabled for your API key, 2) Billing is not enabled on your Google Cloud project, 3) API key restrictions are blocking the request, or 4) The API key is invalid.";
      }
      
      throw new HttpsError("internal", errorMessage);
    }

    // Return the successful results to the app
    return {
      results: data.results,
    };
  } catch (error) {
    if (error instanceof HttpsError) {
      throw error; // Re-throw HttpsError as-is
    }
    logger.error("An unexpected error occurred while calling the Geocoding API", error);
    throw new HttpsError("internal", "An unexpected error occurred.");
  }
});



/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 *//*


import {setGlobalOptions} from "firebase-functions";
import {onRequest} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
 */

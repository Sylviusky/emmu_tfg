import { onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import fetch from "node-fetch";

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
});



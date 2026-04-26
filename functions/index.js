const admin = require("firebase-admin");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");

admin.initializeApp();

const googleRoutesApiKey = defineSecret("GOOGLE_ROUTES_API_KEY");

const allowedTravelModes = new Set(["DRIVE", "WALK", "BICYCLE", "TWO_WHEELER"]);

exports.getRoute = onCall(
  {
    region: "us-central1",
    secrets: [googleRoutesApiKey],
    invoker: "public",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in before requesting routes.");
    }

    const origin = readLatLng(request.data?.origin, "origin");
    const destination = readLatLng(request.data?.destination, "destination");
    const requestedMode = String(request.data?.travelMode || "DRIVE").toUpperCase();
    const travelMode = allowedTravelModes.has(requestedMode) ? requestedMode : "DRIVE";

    const response = await fetch(
      "https://routes.googleapis.com/directions/v2:computeRoutes",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": googleRoutesApiKey.value(),
          "X-Goog-FieldMask":
            "routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline",
        },
        body: JSON.stringify({
          origin: {location: {latLng: origin}},
          destination: {location: {latLng: destination}},
          travelMode,
          routingPreference: travelMode === "DRIVE" ? "TRAFFIC_AWARE" : undefined,
          polylineQuality: "HIGH_QUALITY",
        }),
      },
    );

    if (!response.ok) {
      const body = await response.text();
      console.error("Google Routes API failed", response.status, body);
      throw new HttpsError("unavailable", "Route data is unavailable right now.");
    }

    const payload = await response.json();
    const route = payload.routes?.[0];
    if (!route) {
      throw new HttpsError("not-found", "No route was found for this destination.");
    }

    return {
      distanceMeters: route.distanceMeters ?? 0,
      durationSeconds: parseDurationSeconds(route.duration),
      encodedPolyline: route.polyline?.encodedPolyline ?? "",
      travelMode,
    };
  },
);

function readLatLng(value, label) {
  const latitude = Number(value?.latitude);
  const longitude = Number(value?.longitude);

  if (!Number.isFinite(latitude) || latitude < -90 || latitude > 90) {
    throw new HttpsError("invalid-argument", `${label}.latitude is invalid.`);
  }
  if (!Number.isFinite(longitude) || longitude < -180 || longitude > 180) {
    throw new HttpsError("invalid-argument", `${label}.longitude is invalid.`);
  }

  return {latitude, longitude};
}

function parseDurationSeconds(duration) {
  if (typeof duration !== "string") return 0;
  const match = duration.match(/^([0-9]+(?:\\.[0-9]+)?)s$/);
  return match ? Math.round(Number(match[1])) : 0;
}

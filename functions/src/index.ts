import {onCall, HttpsError} from "firebase-functions/v2/https";
import {setGlobalOptions} from "firebase-functions/v2/options";
import * as admin from "firebase-admin";

setGlobalOptions({region: "europe-west4", maxInstances: 10});

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Bootstrap the first admin (only works if no admins exist yet)
 */
export const bootstrapFirstAdmin = onCall(async (request) => {
  const {uid, email} = request.data as { uid?: string; email?: string };

  if (!uid || !email) {
    throw new HttpsError("invalid-argument", "UID and email are required");
  }

  const adminsSnap = await admin.firestore().collection("admins").get();
  if (!adminsSnap.empty) {
    throw new HttpsError(
      "failed-precondition",
      "Admins already exist. Use addAdminUser instead."
    );
  }

  await admin.auth().setCustomUserClaims(uid, {admin: true});
  await admin.firestore().collection("admins").doc(uid).set({
    email,
    addedAt: admin.firestore.FieldValue.serverTimestamp(),
    firstAdmin: true,
  });

  return {success: true, message: `Bootstrapped first admin: ${uid}`};
});

/**
 * Add a new admin
 */
export const addAdminUser = onCall(async (request) => {
  const {uid, email} = request.data as { uid?: string; email?: string };
  const auth = request.auth;

  if (!auth) throw new HttpsError("unauthenticated", "You must be logged in.");
  if (!auth.token.admin) {
    throw new HttpsError("permission-denied", "Only admins can add admins.");
  }
  if (!uid || !email) {
    throw new HttpsError("invalid-argument", "UID and email are required.");
  }

  try {
    await admin.auth().setCustomUserClaims(uid, {admin: true});
    await admin.firestore().collection("admins").doc(uid).set({
      email,
      addedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return {success: true, message: `Added admin user: ${uid}`};
  } catch (err) {
    console.error(err);
    throw new HttpsError("internal", "Failed to add admin user.");
  }
});

/**
 * Remove an admin
 */
export const removeAdminUser = onCall(async (request) => {
  const {uid} = request.data as { uid?: string };
  const auth = request.auth;

  if (!auth) throw new HttpsError("unauthenticated", "You must be logged in.");
  if (!auth.token.admin) {
    throw new HttpsError("permission-denied", "Only admins can remove admins.");
  }
  if (!uid) throw new HttpsError("invalid-argument", "UID is required.");

  try {
    await admin.auth().setCustomUserClaims(uid, {admin: false});
    await admin.firestore().collection("admins").doc(uid).delete();
    return {success: true, message: `Removed admin privileges: ${uid}`};
  } catch (err) {
    console.error(err);
    throw new HttpsError("internal", "Failed to remove admin.");
  }
});

/**
 * Delete a user (and their Firestore record)
 */
export const deleteUser = onCall(async (request) => {
  const {uid} = request.data as { uid?: string };
  const auth = request.auth;

  if (!auth) throw new HttpsError("unauthenticated", "You must be logged in.");
  if (!auth.token.admin) {
    throw new HttpsError("permission-denied", "Only admins can delete users.");
  }
  if (!uid) throw new HttpsError("invalid-argument", "UID is required.");

  try {
    await admin.auth().deleteUser(uid);
    await admin.firestore().collection("users").doc(uid).delete();
    return {success: true, message: `Deleted user ${uid}`};
  } catch (err) {
    console.error(err);
    throw new HttpsError("internal", "Failed to delete user.");
  }
});

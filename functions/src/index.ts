import { onCall } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2/options";
import * as admin from "firebase-admin";
// import * as functions from "firebase-functions";

setGlobalOptions({ maxInstances: 10 });

/**
 * Bootstrap the first admin (only works if no admins exist yet)
 */
export const bootstrapFirstAdmin = onCall(async (request) => {
  const { data } = request;

  const { uid, email } = data as { uid: string; email: string };

  if (!uid || !email) {
    throw new Error("UID and email are required");
  }

  // Check if any admin exists
  const adminsSnap = await admin.firestore().collection("admins").get();
  if (!adminsSnap.empty) {
    throw new Error("Admins already exist. Use normal addAdminUser function.");
  }

  // Set custom claim
  await admin.auth().setCustomUserClaims(uid, { admin: true });

  // Add to Firestore for tracking
  await admin.firestore().collection("admins").doc(uid).set({
    email,
    addedAt: admin.firestore.FieldValue.serverTimestamp(),
    firstAdmin: true,
  });

  return { success: true, uid, email };
});

/**
 * Add a new admin (callable only by existing admins)
 */
export const addAdminUser = onCall(async (request) => {
  const { data, auth } = request;

  if (!auth) {
    throw new Error("You must be logged in to call this function");
  }

  if (!auth?.token.admin) {
    throw new Error("Only admins can add other admins");
  }

  const { uid, email } = data as { uid: string; email: string };

  if (!uid || !email) {
    throw new Error("UID and email are required");
  }

  try {
    // Set custom claim
    await admin.auth().setCustomUserClaims(uid, { admin: true });

    // Add to Firestore for tracking
    await admin.firestore().collection("admins").doc(uid).set({
      email,
      addedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, uid, email };
  } catch (error) {
    console.error("Error adding admin user:", error);
    throw new Error("Failed to add admin user.");
  }
});

// export const addAdminUser = onCall(async (request) => {
//   const { data, auth } = request;

//   if (!auth) {
//     throw new functions.https.HttpsError(
//       "unauthenticated",
//       "You must be logged in to call this function."
//     );
//   }

//   if (!(auth.token.admin === true)) {
//     throw new functions.https.HttpsError(
//       "permission-denied",
//       "Only admins can add other admins."
//     );
//   }

//   const uid = data.uid as string;
//   const email = data.email as string;

//   if (!uid || !email) {
//     throw new functions.https.HttpsError(
//       "invalid-argument",
//       "UID and email are required."
//     );
//   }

//   try {
//     await admin.auth().setCustomUserClaims(uid, { admin: true });
//     await admin.firestore().collection("admins").doc(uid).set({
//       email,
//       addedAt: admin.firestore.FieldValue.serverTimestamp(),
//     });

//     return { success: true };
//   } catch (err) {
//     console.error(err);
//     throw new functions.https.HttpsError(
//       "internal",
//       "Failed to add admin user."
//     );
//   }
// });

export const deleteUser = onCall(async (request) => {
  const { data, auth } = request;

  if (!auth) {
    throw new Error("You must be logged in to call this function");
    // throw new functions.https.HttpsError(
    //   "unauthenticated",
    //   "You must be logged in to call this function."
    // );
  }

  if (!(auth.token.admin === true)) {
    throw new Error("Only admins can delete users.");

    // throw new functions.https.HttpsError(
    //   "permission-denied",
    //   "Only admins can delete users."
    // );
  }

  const uid = data.uid as string | undefined;
  if (!uid) {
    throw new Error("UID is required.");
    // throw new functions.https.HttpsError(
    //   "invalid-argument",
    //   "UID is required."
    // );
  }

  try {
    await admin.auth().deleteUser(uid);
    await admin.firestore().collection("users").doc(uid).delete();

    return { success: true };
  } catch (error) {
    console.error("Error deleting user:", error);
    throw new Error("Failed to delete user.");

    // throw new functions.https.HttpsError("internal", "Failed to delete user.");
  }
});

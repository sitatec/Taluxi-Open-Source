import { FirebaseAuthAdapter } from "../src/services";
import * as admin from "firebase-admin";

const fakeUid = "__fk_uid__";
let idTokenValidationThrowException = false;

jest.mock("firebase-admin", () => {
  return {
    auth: jest.fn(() => ({
      verifyIdToken: async (idToken: string) => {
        if (idTokenValidationThrowException) throw false;
        return Promise.resolve({ uid: fakeUid });
      },
    })),
  };
});
const firebaseAuth = admin.auth();
const firebaseAuthAdapter = new FirebaseAuthAdapter(firebaseAuth);

describe("AuthenticationValidator.validateToken() ", () => {
  test("should return the uid", async () => {
    await expect(firebaseAuthAdapter.validateToken("idToken")).resolves.toEqual(
      fakeUid
    );
  });

  test("should throw a Error", async () => {
    idTokenValidationThrowException = true;
    await expect(firebaseAuthAdapter.validateToken("idToken")).rejects.toThrow(
      Error("validation-failed")
    );
  });
});

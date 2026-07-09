// Passkeys WebAuthn stub — satisfies the passkeys_web Dart interop bindings
// without pulling in the full Corbado SDK.
//
// The Dart plugin (passkeys_web 2.9.0) expects a global PasskeyAuthenticator
// object with the following methods: init, register, login,
// cancelCurrentAuthenticatorOperation, isUserVerifyingPlatformAuthenticatorAvailable,
// isConditionalMediationAvailable, hasPasskeySupport.
//
// Since this app uses email/password auth (not WebAuthn passkeys), we provide
// safe no-op implementations.
var PasskeyAuthenticator = {
  init: function () {},
  register: function () {
    return Promise.reject(JSON.stringify({
      code: "not-configured",
      message: "Passkeys are not configured for this app",
      details: "This app uses email/password authentication"
    }));
  },
  login: function () {
    return Promise.reject(JSON.stringify({
      code: "not-configured",
      message: "Passkeys are not configured for this app",
      details: "This app uses email/password authentication"
    }));
  },
  cancelCurrentAuthenticatorOperation: function () {},
  isUserVerifyingPlatformAuthenticatorAvailable: function () {
    return Promise.resolve(false);
  },
  isConditionalMediationAvailable: function () {
    return Promise.resolve(false);
  },
  hasPasskeySupport: function () {
    return false;
  }
};
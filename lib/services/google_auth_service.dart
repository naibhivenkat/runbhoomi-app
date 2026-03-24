import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: '830296224047-c6mftjed5a6ld7c6oa9k72rpeurgvfo5.apps.googleusercontent.com',
  );

  static Future<String?> signIn() async {
    try {
      final GoogleSignInAccount? account =
          await _googleSignIn.signIn();

      if (account == null) return null;

      final auth = await account.authentication;

      print("ID TOKEN: ${auth.idToken}"); // debug

      return auth.idToken;

    } catch (e) {
      print("Google Sign In Error: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: '830296224047-c6mftjed5a6ld7c6oa9k72rpeurgvfo5.apps.googleusercontent.com',
  );

  static Future<String?> signIn() async {
    try {
      // 🔥 VERY IMPORTANT: clear old session (fixes expired token issue)
      await _googleSignIn.signOut();

      // 🔥 Start fresh login
      final GoogleSignInAccount? account =
          await _googleSignIn.signIn();

      if (account == null) {
        print("User cancelled Google login");
        return null;
      }

      // 🔥 Get fresh authentication tokens
      final GoogleSignInAuthentication auth =
          await account.authentication;

      final idToken = auth.idToken;

      if (idToken == null) {
        print("❌ ID Token is null");
        return null;
      }

      print("✅ NEW ID TOKEN: $idToken");

      return idToken;

    } catch (e) {
      print("❌ Google Sign In Error: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
// lib/services/auth_service.dart
//
// PLACEHOLDER — Hubungkan ke Firebase sesuai konfigurasi project.
// Semua method sudah siap, tinggal uncomment bagian Firebase.

import 'package:flutter/foundation.dart';

enum AuthRole { kader, kepala }

class AuthResult {
  final bool success;
  final String? message;
  final String? userId;

  AuthResult({required this.success, this.message, this.userId});
}

class AuthService {
  // ---------------------------------------------------------------------------
  // REGISTER
  // Alur: developer sudah input username ke Firestore collection 'username_pool'
  // (atau 'kader_usernames' / 'kepala_usernames').
  // User datang, tulis username yang diberikan developer,
  // lalu isi nama, password, NIK, HP → akun terbentuk.
  // ---------------------------------------------------------------------------

  Future<AuthResult> register({
    required String username,
    required String namaLengkap,
    required String password,
    required String nik,
    required String nomorHp,
    required AuthRole role,
  }) async {
    try {
      // TODO: Uncomment dan sesuaikan dengan Firebase Anda
      //
      // final firestore = FirebaseFirestore.instance;
      // final collection = role == AuthRole.kader
      //     ? AppConstants.colKader
      //     : AppConstants.colKepala;
      //
      // // 1. Cek apakah username sudah ada di pool developer
      // final poolDoc = await firestore
      //     .collection(AppConstants.colUsernamePool)
      //     .doc(username)
      //     .get();
      //
      // if (!poolDoc.exists) {
      //   return AuthResult(
      //     success: false,
      //     message: 'Username tidak dikenali. Hubungi operator.',
      //   );
      // }
      //
      // // 2. Cek apakah username ini sudah dipakai (sudah daftar)
      // final existing = await firestore
      //     .collection(collection)
      //     .where('username', isEqualTo: username)
      //     .get();
      //
      // if (existing.docs.isNotEmpty) {
      //   return AuthResult(
      //     success: false,
      //     message: 'Username ini sudah terdaftar.',
      //   );
      // }
      //
      // // 3. Buat akun Firebase Auth (email = username@podita.app, password)
      // final credential = await FirebaseAuth.instance
      //     .createUserWithEmailAndPassword(
      //   email: '$username@podita.app',
      //   password: password,
      // );
      //
      // // 4. Simpan data ke Firestore
      // await firestore.collection(collection).doc(credential.user!.uid).set({
      //   'username': username,
      //   'namaLengkap': namaLengkap,
      //   'nik': nik,
      //   'nomorHp': nomorHp,
      //   'role': role == AuthRole.kader ? 'kader' : 'kepala',
      //   'createdAt': FieldValue.serverTimestamp(),
      // });
      //
      // return AuthResult(success: true, userId: credential.user!.uid);

      // PLACEHOLDER — simulasi sukses
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('[AuthService] Register placeholder: $username / $role');
      return AuthResult(success: true, userId: 'placeholder_uid_$username');
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------

  Future<AuthResult> login({
    required String username,
    required String password,
    required AuthRole role,
  }) async {
    try {
      // TODO: Uncomment dan sesuaikan dengan Firebase Anda
      //
      // final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      //   email: '$username@podita.app',
      //   password: password,
      // );
      //
      // // Verifikasi role
      // final collection = role == AuthRole.kader
      //     ? AppConstants.colKader
      //     : AppConstants.colKepala;
      //
      // final doc = await FirebaseFirestore.instance
      //     .collection(collection)
      //     .doc(credential.user!.uid)
      //     .get();
      //
      // if (!doc.exists) {
      //   await FirebaseAuth.instance.signOut();
      //   return AuthResult(
      //     success: false,
      //     message: 'Akun tidak ditemukan di role ini.',
      //   );
      // }
      //
      // return AuthResult(success: true, userId: credential.user!.uid);

      // PLACEHOLDER — simulasi sukses
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('[AuthService] Login placeholder: $username / $role');
      return AuthResult(success: true, userId: 'placeholder_uid_$username');
    } catch (e) {
      return AuthResult(success: false, message: 'Username atau password salah.');
    }
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    // await FirebaseAuth.instance.signOut();
    debugPrint('[AuthService] Logout placeholder');
  }
}

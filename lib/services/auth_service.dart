import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_constants.dart';
import 'bayi_service.dart';

enum AuthRole { kader, kepala }

class AuthResult {
  final bool success;
  final String? message;
  final String? userId;

  AuthResult({required this.success, this.message, this.userId});
}

class AuthService {
  static String? activeUsername;

  static String get currentUsername {
    if (activeUsername != null) return activeUsername!;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        return user.email!.split('@').first;
      }
    } catch (_) {}
    return '';
  }

  bool get _isFirebaseInitialized {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // REGISTER
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
      final cleanUsername = username.trim().split('@').first;
      bool useLocalFallback = false;

      if (_isFirebaseInitialized) {
        final firestore = FirebaseFirestore.instance;
        final collection = role == AuthRole.kader
            ? AppConstants.colKader
            : AppConstants.colKepala;

        try {
          // 1. Cek apakah username sudah ada di pool developer
          // (Dihapus sementara karena pool di Firebase hilang/tidak digunakan)
          /*
          final poolDoc = await firestore
              .collection(AppConstants.colUsernamePool)
              .doc(cleanUsername)
              .get()
              .timeout(const Duration(seconds: 10), onTimeout: () {
            throw 'Koneksi ke Firestore timeout. Periksa internet Anda.';
          });

          if (!poolDoc.exists) {
            return AuthResult(
              success: false,
              message: 'Username tidak dikenali. Hubungi operator.',
            );
          }
          */

          // 2. Cek apakah username ini sudah dipakai (sudah daftar)
          final existing = await firestore
              .collection(collection)
              .where('username', isEqualTo: cleanUsername)
              .get()
              .timeout(const Duration(seconds: 10), onTimeout: () {
            throw 'Koneksi ke Firestore timeout. Periksa internet Anda.';
          });

          if (existing.docs.isNotEmpty) {
            return AuthResult(
              success: false,
              message: 'Username ini sudah terdaftar.',
            );
          }

          // 3. Buat akun Firebase Auth (email = username@podita.app, password)
          final credential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
            email: '$cleanUsername@podita.app',
            password: password,
          )
              .timeout(const Duration(seconds: 10), onTimeout: () {
            throw 'Koneksi ke Firebase Auth timeout. Periksa internet Anda.';
          });

          // 4. Simpan data ke Firestore
          await firestore.collection(collection).doc(credential.user!.uid).set({
            'username': cleanUsername,
            'namaLengkap': namaLengkap,
            'nik': nik,
            'nomorHp': nomorHp,
            'role': role == AuthRole.kader ? 'kader' : 'kepala',
            'createdAt': FieldValue.serverTimestamp(),
          }).timeout(const Duration(seconds: 10), onTimeout: () {
            throw 'Gagal melengkapi data profil. Periksa koneksi internet Anda.';
          });

          // 5. Tambah ke cache local jika role kader
          if (role == AuthRole.kader) {
            BayiService().tambahKader({
              'nama': namaLengkap,
              'username': cleanUsername,
              'nik': nik,
              'hp': nomorHp,
              'password': password,
            }, syncToFirestore: false);
          }

          activeUsername = cleanUsername;
          return AuthResult(success: true, userId: credential.user!.uid);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'network-request-failed') {
            useLocalFallback = true;
          } else {
            rethrow;
          }
        } catch (e) {
          String errStr = e.toString().toLowerCase();
          if (errStr.contains('timeout') ||
              errStr.contains('unavailable') ||
              errStr.contains('network') ||
              errStr.contains('failed host lookup')) {
            useLocalFallback = true;
          } else {
            rethrow;
          }
        }
      } else {
        useLocalFallback = true;
      }

      if (useLocalFallback) {
        // FALLBACK LOCAL
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('[AuthService] Register offline fallback: $cleanUsername');
        if (role == AuthRole.kader) {
          // Check if already registered in local cache
          final exists = BayiService()
              .dataKader
              .any((k) => k['username'] == cleanUsername);
          if (exists) {
            return AuthResult(
              success: false,
              message: 'Username ini sudah terdaftar secara lokal.',
            );
          }
          BayiService().tambahKader({
            'nama': namaLengkap,
            'username': cleanUsername,
            'nik': nik,
            'hp': nomorHp,
            'password': password,
          });
        }
        activeUsername = cleanUsername;
        return AuthResult(success: true, userId: 'local_uid_$cleanUsername');
      }

      throw Exception('Unexpected register state');
    } on FirebaseAuthException catch (e) {
      debugPrint(
          '[AuthService] register FirebaseAuthException: ${e.code} - ${e.message}');
      String msg = e.message ?? 'Registrasi gagal.';
      if (e.code == 'email-already-in-use') {
        msg = 'Username ini sudah terdaftar.';
      } else if (e.code == 'network-request-failed') {
        msg = 'Koneksi internet bermasalah. Periksa koneksi Anda.';
      } else if (e.code == 'weak-password') {
        msg = 'Password terlalu lemah.';
      }
      return AuthResult(success: false, message: msg);
    } catch (e) {
      debugPrint('[AuthService] register Exception: $e');
      return AuthResult(
        success: false,
        message: e.toString().contains('timeout')
            ? 'Koneksi lambat atau terputus. Silakan coba lagi.'
            : 'Registrasi gagal: $e',
      );
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
      final cleanUsername = username.trim().split('@').first;
      bool useLocalFallback = false;

      if (_isFirebaseInitialized) {
        debugPrint('[AuthService] Online login initiated for: $cleanUsername');
        try {
          final credential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
            email: '$cleanUsername@podita.app',
            password: password,
          )
              .timeout(const Duration(seconds: 10), onTimeout: () {
            throw 'Koneksi ke Firebase Auth timeout. Periksa internet Anda.';
          });

          debugPrint(
              '[AuthService] Firebase Auth sign-in successful. Fetching Firestore doc...');
          final collection = role == AuthRole.kader
              ? AppConstants.colKader
              : AppConstants.colKepala;

          final doc = await FirebaseFirestore.instance
              .collection(collection)
              .doc(credential.user!.uid)
              .get()
              .timeout(const Duration(seconds: 10), onTimeout: () {
            throw 'Koneksi ke Firestore timeout. Periksa internet Anda.';
          });

          debugPrint(
              '[AuthService] Firestore doc fetched. exists: ${doc.exists}');
          if (!doc.exists) {
            await FirebaseAuth.instance.signOut();
            return AuthResult(
              success: false,
              message: 'Akun tidak ditemukan di role ini.',
            );
          }

          activeUsername = cleanUsername;
          return AuthResult(success: true, userId: credential.user!.uid);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'network-request-failed') {
            useLocalFallback = true;
          } else {
            rethrow;
          }
        } catch (e) {
          String errStr = e.toString().toLowerCase();
          if (errStr.contains('timeout') ||
              errStr.contains('unavailable') ||
              errStr.contains('network') ||
              errStr.contains('failed host lookup')) {
            useLocalFallback = true;
          } else {
            rethrow;
          }
        }
      } else {
        useLocalFallback = true;
      }

      if (useLocalFallback) {
        // FALLBACK LOCAL
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('[AuthService] Login offline fallback: $cleanUsername');

        if (role == AuthRole.kader) {
          final kader = BayiService().dataKader.firstWhere(
                (k) => k['username'] == cleanUsername,
                orElse: () => {},
              );
          if (kader.isEmpty) {
            return AuthResult(
              success: false,
              message:
                  'Gagal login: Mode offline aktif namun username belum terdaftar lokal.',
            );
          }
          final expectedPassword = kader['password'] ?? '123456';
          if (expectedPassword != password) {
            return AuthResult(
              success: false,
              message: 'Username atau password salah.',
            );
          }
        } else {
          // Kepala Puskesmas mock login
          if (cleanUsername != 'kepala_puskesmas' &&
              !cleanUsername.startsWith('kepala')) {
            return AuthResult(
              success: false,
              message:
                  'Gagal login: Username kepala tidak ditemukan di mode offline.',
            );
          }
          if (password != '123456') {
            return AuthResult(
              success: false,
              message: 'Username atau password salah.',
            );
          }
        }

        activeUsername = cleanUsername;
        return AuthResult(success: true, userId: 'local_uid_$cleanUsername');
      }

      throw Exception('Unexpected login state');
    } on FirebaseAuthException catch (e) {
      debugPrint(
          '[AuthService] login FirebaseAuthException: ${e.code} - ${e.message}');
      String msg = 'Username atau password salah.';
      if (e.code == 'network-request-failed') {
        msg = 'Koneksi internet bermasalah. Periksa koneksi Anda.';
      } else if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        msg = 'Username atau password salah.';
      } else if (e.code == 'too-many-requests') {
        msg = 'Terlalu banyak percobaan masuk. Coba lagi nanti.';
      }
      return AuthResult(success: false, message: msg);
    } catch (e) {
      debugPrint('[AuthService] login Exception: $e');
      return AuthResult(
        success: false,
        message: e.toString().contains('timeout')
            ? 'Koneksi lambat atau terputus. Silakan coba lagi.'
            : 'Gagal masuk: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // GET USER PROFILE
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> getCurrentUserProfile(AuthRole role) async {
    try {
      final cleanUsername = currentUsername;
      if (_isFirebaseInitialized) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final collection = role == AuthRole.kader
              ? AppConstants.colKader
              : AppConstants.colKepala;
          final doc = await FirebaseFirestore.instance
              .collection(collection)
              .doc(user.uid)
              .get()
              .timeout(const Duration(seconds: 5));
          if (doc.exists && doc.data() != null) {
            return doc.data();
          }
        }
      }

      // Fallback local / mock
      if (role == AuthRole.kader) {
        final kader = BayiService().dataKader.firstWhere(
              (k) => k['username'] == cleanUsername,
              orElse: () => {},
            );
        if (kader.isNotEmpty) {
          return {
            'namaLengkap': kader['nama'] ?? 'Kader Posyandu',
            'username': kader['username'] ?? cleanUsername,
            'nomorHp': kader['hp'] ?? '',
            'nik': kader['nik'] ?? '',
            'role': 'kader',
          };
        }
      } else {
        return {
          'namaLengkap': 'Kepala Puskesmas',
          'username':
              cleanUsername.isEmpty ? 'kepala_puskesmas' : cleanUsername,
          'nomorHp': '08123456789',
          'nik': '3201234567890000',
          'role': 'kepala',
        };
      }
    } catch (e) {
      debugPrint('[AuthService] Error fetching user profile: $e');
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    if (_isFirebaseInitialized) {
      await FirebaseAuth.instance.signOut();
    }
    debugPrint('[AuthService] Logout');
  }
}

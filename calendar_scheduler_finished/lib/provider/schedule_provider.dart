import 'package:calendar_scheduler/model/event_model.dart';
import 'package:calendar_scheduler/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ScheduleProvider extends ChangeNotifier {

  final AuthRepository authRepository;

  String? accessToken;
  String? refreshToken;

  ScheduleProvider({
    required this.authRepository,
  }) : super() {}

  updateTokens({
    String? refreshToken,
    String? accessToken,
  }) {
    // refreshToken이 입력됐을 경우 refreshToken 업데이트
    if (refreshToken != null) {
      this.refreshToken = refreshToken;
    }
    // accessToken이 입력됐을 경우 accessToken 업데이트
    if (accessToken != null) {
      this.accessToken = accessToken;
    }

    notifyListeners();
  }

  // 로그인 기능
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final resp = await authRepository.login(
      email: email,
      password: password,
    );

    updateTokens(
      refreshToken: resp.refreshToken,
      accessToken: resp.accessToken,
    );
  }

  // 회원가입 기능
  Future<void> register({
    required String email,
    required String password,
  }) async {
    // AuthRepository에 미리 구현해둔 register() 함수를 실행합니다.
    final resp = await authRepository.register(
      email: email,
      password: password,
    );
    // 반환받은 토큰을 기반으로 토큰 프로퍼티를 업데이트합니다.
    updateTokens(
      refreshToken: resp.refreshToken,
      accessToken: resp.accessToken,
    );
  }

  rotateToken({
    required String refreshToken,
    required bool isRefreshToken,
  }) async {
    // isRefreshToken이 true일 경우 refreshToken 재발급
    // false일 경우 accessToken 재발급
    if (isRefreshToken) {
      final token = await authRepository.rotateRefreshToken(
          refreshToken: refreshToken);

      this.refreshToken = token;
    } else {
      final token = await authRepository.rotateAccessToken(
          refreshToken: refreshToken);

      accessToken = token;
    }

    notifyListeners();
  }
}




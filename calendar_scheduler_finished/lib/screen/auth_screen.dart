import 'package:calendar_scheduler/component/login_text_field.dart';
import 'package:calendar_scheduler/const/colors.dart';
import 'package:calendar_scheduler/provider/schedule_provider.dart';
import 'package:calendar_scheduler/screen/calendar_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/img/original.png',
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
              ),
              const SizedBox(height: 16.0),
              // Form과 연동할 텍스트 필드를 추가합니다.
              LoginTextField(
                onSaved: (val) {
                  email = val!;
                },
                // Form의 validate() 함수를 실행하면 입력값을 확인합니다.
                validator: (val) {
                  // 이메일이 입력되지 않았으면 에러 메시지를 반환합니다.
                  if (val?.isEmpty ?? true) {
                    return '이메일을 입력해주세요.';
                  }
                  // 정규표현식(regex)을 이용해 이메일 형식이 맞는지 검사합니다.
                  RegExp reg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  // 이메일 형식이 올바르지 않게 입력됐다면 에러 메시지를 반환합니다.
                  if (!reg.hasMatch(val!)) {
                    return '이메일 형식이 올바르지 않습니다.';
                  }
                  // 입력값에 문제가 있다면 null을 반환합니다.
                  return null;
                },
                hintText: '이메일',
              ),
              const SizedBox(height: 8.0),
              LoginTextField(
                onSaved: (val) {
                  password = val!;
                },
                obscureText: true,
                validator: (val) {
                  // 비밀번호가 입력되지 않았다면 에리 메시지를 반환합니다.
                  if (val?.isEmpty ?? true) {
                    return '비밀번호를 입력해주세요.';
                  }
                  // 입력된 비밀번호가 4자리에서 8자리 사이인지 확인합니다.
                  if (val!.length < 4 || val.length > 8) {
                    return '비밀번호는 4~8자 사이로 입력 해주세요!';
                  }
                  // 입력값에 문제가 없다면 null을 반환합니다.
                  return null;
                },
                hintText: '비밀번호',
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SECONDARY_COLOR,
                ),
                onPressed: () async {
                  onRegisterPress(provider);
                },
                child: Text('회원가입'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SECONDARY_COLOR,
                ),
                onPressed: () async {
                  onLoginPress(provider);
                },
                child: Text('로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onRegisterPress(ScheduleProvider provider) async {
    if (!saveAndValidateForm()) {
      return;
    }

    String? message;

    try {
      await provider.register(
        email: email,
        password: password,
      );
    } on DioError catch (e) {
      message = e.response?.data['message'] ?? '알 수 없는 오류가 발생했습니다.';
    } catch (e) {
      message = '알 수 없는 오류가 발생했습니다.';
    } finally {
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CalendarScreen(),
          ),
        );
      }
    }
  }

  onLoginPress(ScheduleProvider provider) async {
    if (!saveAndValidateForm()) {
      return;
    }

    String? message;

    try {
      await provider.login(
        email: email,
        password: password,
      );
    } on DioError catch (e) {
      message = e.response?.data['message'] ?? '알 수 없는 오류가 발생했습니다.';
    } catch (e) {
      message = '알 수 없는 오류가 발생했습니다.';
    } finally {
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CalendarScreen(),
          ),
        );
      }
    }
  }

  bool saveAndValidateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    formKey.currentState!.save();

    return true;
  }
}

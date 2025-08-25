import 'dart:async';
import 'dart:io';

import 'package:chat_app/core/socket_service.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/screens/login_page.dart';
import 'package:chat_app/features/contact/presentation/bloc/contacts_bloc.dart';
import 'package:chat_app/features/contact/presentation/screens/contacts_page.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_bloc.dart';
import 'package:chat_app/features/conversation/presentation/screens/conversations_page.dart';
import 'package:chat_app/features/auth/presentation/screens/register_page.dart';
import 'package:chat_app/features/user/presentation/screens/user_profile_page.dart';
import 'package:chat_app/theme_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'api/firebase_api.dart';
import 'api/notification_service.dart';
import 'deeplink_handle.dart';
import 'di_container.dart';
import 'features/user/presentation/bloc/user_bloc.dart';
import 'firebase_options.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final socketService = SocketService();
  await socketService.initSocket();

  setupDependencies();

  runApp(
    BlocProvider(
      create: (_) => ThemeCubit(),
      child: const MyApp(),
    ),
  );
  Future.microtask(() => FirebaseApi().initNotifications());
  // Khởi tạo deep link sau app dựng xong
  Future.delayed(const Duration(milliseconds: 300), () {
    DeepLinkHandler().init();
  });
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            loginUseCase: sl(),
            registerUseCase: sl(),
            forgotPasswordUseCase: sl(),
            resetPasswordUseCase: sl(),
            logoutUseCase: sl(),
          ),
        ),
        BlocProvider(create: (_) => ConversationsBloc(fetchConversationsUseCase: sl())),
        BlocProvider(
          create: (_) => ChatBloc(
            fetchMessagesUseCase: sl(),
            fetchDailyQuestionUseCase: sl(),
          ),
        ),
        BlocProvider(
          create: (_) => ContactsBloc(
            fetchContactsUseCase: sl(),
            addContactUseCase: sl(),
            deleteContactUseCase: sl(),
            checkOrCreateConversationUseCase: sl(),
            fetchRecentContactsUseCase: sl(),
          ),
        ),
        BlocProvider(
          create: (_) => UserBloc(
            changePasswordUseCase: sl(),
            getUserUseCase: sl(),
            updateUserUseCase: sl(),
            uploadProfileImageUseCase: sl(),
          ),
        ),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, theme) {
          return ScreenUtilInit(
            designSize: const Size(411, 866),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'Chat App',
                theme: theme,
                debugShowCheckedModeBanner: false,
                navigatorObservers: [routeObserver],
                navigatorKey: navigatorKey,
                home: const LoginPage(),
                routes: {
                  "/login": (_) => const LoginPage(),
                  "/register": (_) => const RegisterPage(),
                  "/conversations-page": (_) => const ConversationsPage(),
                  "/user-profile-page": (_) => const UserProfilePage(),
                  "/contact-page": (_) => const ContactsPage(),
                },
              );
            },
          );
        },
      ),
    );
  }
}

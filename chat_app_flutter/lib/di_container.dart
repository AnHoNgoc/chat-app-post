import 'package:chat_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chat_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:chat_app/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/register_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/reset_password_use_case.dart';
import 'package:chat_app/features/chat/data/datasources/message_remote_data_source.dart';
import 'package:chat_app/features/chat/data/repositories/message_repository_impl.dart';
import 'package:chat_app/features/chat/domain/repositories/message_repository.dart';
import 'package:chat_app/features/contact/data/datasources/contacts_remote_data_source.dart';
import 'package:chat_app/features/contact/data/repositories/contacts_repository_impl.dart';
import 'package:chat_app/features/contact/domain/repositories/contact_repository.dart';
import 'package:chat_app/features/conversation/data/datasources/conversations_remote_data_source.dart';
import 'package:chat_app/features/conversation/data/repositories/conversations_repository_impl.dart';
import 'package:chat_app/features/conversation/domain/repositories/conversations_repository.dart';
import 'package:chat_app/features/conversation/domain/usecases/fetch_conversations_use_case.dart';
import 'package:chat_app/features/user/domain/usecases/get_user_use_case.dart';
import 'package:chat_app/features/user/domain/usecases/update_user_use_case.dart';
import 'package:chat_app/features/user/domain/usecases/upload_profile_image_use_case.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/domain/usecases/logout_use_case.dart';
import 'features/chat/domain/usecaes/fetch_daily_question_use_case.dart';
import 'features/chat/domain/usecaes/fetch_messages_use_case.dart';
import 'features/contact/domain/usecases/add_contact_use_case.dart';
import 'features/contact/domain/usecases/delete_contact_use_case.dart';
import 'features/contact/domain/usecases/fetch_contacts_use_case.dart';
import 'features/contact/domain/usecases/fetch_recent_contacts_use_case.dart';
import 'features/conversation/domain/usecases/check_or_create_conversation_use_case.dart';
import 'features/user/data/datasources/user_remote_data_source.dart';
import 'features/user/data/repositories/user_repository_impl.dart';
import 'features/user/domain/repositories/user_repository.dart';
import 'features/user/domain/usecases/change_password_use_case.dart';

GetIt sl = GetIt.instance;

void setupDependencies(){

  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource());
  sl.registerLazySingleton<MessageRemoteDataSource>(() => MessageRemoteDataSource());
  sl.registerLazySingleton<ContactsRemoteDataSource>(() => ContactsRemoteDataSource());
  sl.registerLazySingleton<ConversationsRemoteDataSource>(() => ConversationsRemoteDataSource());
  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSource());

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(authRemoteDataSource: sl()));
  sl.registerLazySingleton<MessageRepository>(() => MessageRepositoryImpl(messageRemoteDataSource: sl()));
  sl.registerLazySingleton<ContactsRepository>(() => ContactsRepositoryImpl(contactsRemoteDataSource: sl() ));
  sl.registerLazySingleton<ConversationsRepository>(() => ConversationsRepositoryImpl(conversationsRemoteDataSource: sl()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(userRemoteDataSource: sl()));

  sl.registerLazySingleton(() => LoginUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => FetchConversationsUseCase( sl()));
  sl.registerLazySingleton(() => FetchMessagesUseCase(messageRepository: sl()));
  sl.registerLazySingleton(() => FetchDailyQuestionUseCase(messageRepository: sl()));
  sl.registerLazySingleton(() => FetchContactsUseCase(contactsRepository: sl()));
  sl.registerLazySingleton(() => AddContactUseCase(contactsRepository: sl()));
  sl.registerLazySingleton(() => DeleteContactUseCase(contactsRepository: sl()));
  sl.registerLazySingleton(() => CheckOrCreateConversationUseCase(conversationsRepository: sl()));
  sl.registerLazySingleton(() => FetchRecentContactsUseCase(contactsRepository: sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(userRepository: sl()));
  sl.registerLazySingleton(() => GetUserUseCase(userRepository: sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(userRepository: sl()));
  sl.registerLazySingleton(() => UploadProfileImageUseCase(userRepository: sl()));

}
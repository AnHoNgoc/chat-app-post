import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/user_detail_entity.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/logout_confirmation_dialog.dart';


class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  String? _newProfileImage;
  bool _isUsernameSet = false;

  @override
  void initState() {
    super.initState();
    final userState = context.read<UserBloc>().state;
    if (userState is! UserLoadedState) {
      context.read<UserBloc>().add(FetchUserEvent());
    }
  }
  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final userBloc = context.read<UserBloc>();

    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      userBloc.add(UploadProfileImageEvent(imageFile: imageFile));
    }
  }
  void _onUpdateUser(UserDetailEntity user) {
    final updatedUsername = _usernameController.text;
    final updatedImage = _newProfileImage ?? user.profileImage;

    context.read<UserBloc>().add(UpdateUserEvent(
      username: updatedUsername,
      profileImage: updatedImage,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontSize: 18.sp)),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 22.sp),
            onPressed: () async {
              final authBloc = context.read<AuthBloc>(); // lấy trước khi showDialog

              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => const LogoutConfirmationDialog(),
              );

              if (shouldLogout == true) {
                authBloc.add(AuthLogoutEvent()); // dùng sau
              }
            },
          ),
        ],
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UploadImageSuccessState) {
            setState(() {
              _newProfileImage = state.imageUrl;
            });
            context.read<UserBloc>().add(FetchUserEvent());
          } else if (state is UploadImageFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload failed: ${state.error}')),
            );
          }
          if (state is UserUpdateSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Updated user successfully')),
            );
            Navigator.of(context).pushReplacementNamed('/conversations-page');
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoadingState || state is UploadImageInProgressState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserLoadedState) {
              final user = state.user;
              if (!_isUsernameSet) {
                _usernameController.text = user.username;
                _isUsernameSet = true;
              }
              final displayImage = _newProfileImage ?? user.profileImage;

              return SingleChildScrollView(
                padding: EdgeInsets.only(top: 32.h),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400.w),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 100.r,
                            backgroundImage: CachedNetworkImageProvider(displayImage),
                          ),
                          SizedBox(height: 12.h),
                          TextButton(
                            onPressed: _pickImage,
                            child: Text('Upload Photo', style: TextStyle(fontSize: 14.sp)),
                          ),
                          SizedBox(height: 20.h),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Email: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                              Flexible(
                                child: Text(user.email, style: TextStyle(fontSize: 14.sp)),
                              ),
                            ],
                          ),
                          SizedBox(height: 40.h),
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () => _onUpdateUser(user),
                              child: Text('Update', style: TextStyle(fontSize: 14.sp)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (state is UserFailureState) {
              return Center(child: Text(state.error));
            }
            return const Center(child: Text("No data"));
          },
        ),
      ),
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/theme.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_page.dart';
import 'package:chat_app/features/contact/presentation/bloc/contacts_bloc.dart';
import 'package:chat_app/features/contact/presentation/bloc/contacts_event.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_bloc.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_event.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_state.dart';
import 'package:chat_app/features/user/presentation/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../contact/presentation/bloc/contacts_state.dart';
import 'package:intl/intl.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../../../user/presentation/bloc/user_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../user/presentation/widgets/change_password_dialog.dart';
import '../../../user/presentation/widgets/logout_confirmation_dialog.dart';

class ConversationsPage extends StatefulWidget {

  final String? search;

  const ConversationsPage({super.key, this.search});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contactsBloc = BlocProvider.of<ContactsBloc>(context);
      final conversationsBloc = BlocProvider.of<ConversationsBloc>(context);
      final user = BlocProvider.of<UserBloc>(context);

      conversationsBloc.add(FetchConversationsEvent(search: widget.search));
      user.add(FetchUserEvent());

      if (contactsBloc.state is! RecentContactsLoadedState) {
        contactsBloc.add(LoadRecentContactsEvent());
      }
    });
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy – HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthInitialState) {
              context.read<ContactsBloc>().add(ClearRecentContactsEvent());
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        ),
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is ChangePasswordSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Changed password successfully')),
              );
              context.read<UserBloc>().add(FetchUserEvent());
            } else if (state is UserFailureState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Message",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 70.h,  // dùng screenutil
          iconTheme: IconThemeData(
            color: Theme.of(context).iconTheme.color,
          ),
          actions: [
            IconButton(
              onPressed: showSearchDialog,
              icon: Icon(Icons.search),
              tooltip: 'Search',
            ),
            IconButton(
              tooltip: 'Setting',
              onPressed: () {
                final currentContext = context; // Lưu lại context tại thời điểm onPressed

                showMenu(
                  context: currentContext,
                  position: RelativeRect.fromLTRB(1000.w, 80.h, 10.w, 100.h),  // dùng screenutil
                  items: const [
                    PopupMenuItem(
                      value: 'profile',
                      child: Text('Profile'),
                    ),
                    PopupMenuItem(
                      value: 'change_password',
                      child: Text('Change password'),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                ).then((value) async {
                  if (!currentContext.mounted) return; // Kiểm tra context còn mounted không

                  if (value == 'profile') {
                    Navigator.pushNamed(currentContext, '/user-profile-page');
                  } else if (value == 'logout') {
                    final shouldLogout = await showDialog<bool>(
                      context: currentContext,
                      builder: (context) => const LogoutConfirmationDialog(),
                    );

                    if (!currentContext.mounted) return;

                    if (shouldLogout == true) {
                      currentContext.read<AuthBloc>().add(AuthLogoutEvent());
                    }
                  } else if (value == 'change_password') {
                    final result = await showDialog<Map<String, String>>(
                      context: currentContext,
                      builder: (context) => const ChangePasswordDialog(),
                    );

                    if (!currentContext.mounted) return;

                    if (result != null) {
                      final oldPassword = result['oldPassword'];
                      final newPassword = result['newPassword'];
                      currentContext.read<UserBloc>().add(ChangePasswordEvent(
                        oldPassword: oldPassword!,
                        newPassword: newPassword!,
                      ));
                    }
                  }
                });
              },
              icon: const Icon(Icons.settings),
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),  // dùng screenutil
              child: Text(
                "Recent",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            BlocBuilder<ContactsBloc, ContactsState>(
              builder: (context, state) {
                if (state is ContactsLoadingState) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is RecentContactsLoadedState) {
                  return Container(
                    height: 90.h,
                    padding: EdgeInsets.all(5.w),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: state.recentContacts.length,
                      itemBuilder: (context, index) {
                        final contact = state.recentContacts[index];
                        return _buildRecentContact(contact.username, contact.profileImage, context);
                      },
                    ),
                  );
                } else if (state is ContactsFailureState) {
                  return Center(child: Text("Failed "));
                }

                return Center(child: Text("No recent contacts found"));
              },
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: DefaultColors.messageListPage(context),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.r),  // dùng screenutil
                    topRight: Radius.circular(50.r),
                  ),
                ),
                child: BlocBuilder<ConversationsBloc, ConversationsState>(
                  builder: (context, state) {
                    if (state is ConversationsLoadingState) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is ConversationsLoadedState) {
                      return ListView.builder(
                        itemCount: state.conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = state.conversations[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    conversationId: conversation.id,
                                    mate: conversation.participantName,
                                    profileImage: conversation.participantImage,
                                  ),
                                ),
                              );
                            },
                            child: _buildMessageTile(
                              conversation.participantName,
                              conversation.participantImage,
                              conversation.lastMessage,
                              formatDateTime(conversation.lastMessageTime),
                            ),
                          );
                        },
                      );
                    } else if (state is ConversationsFailureState) {
                      return Center(child: Text(state.message));
                    }
                    return Center(
                      child: Text("No conversation found"),
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final currentContext = context;

            await Navigator.pushNamed(currentContext, "/contact-page");

            if (!currentContext.mounted) return;

            BlocProvider.of<ContactsBloc>(currentContext)
                .add(LoadRecentContactsEvent());
          },
          backgroundColor: DefaultColors.buttonColor,
          child: Icon(Icons.contacts),
        ),
      ),
    );
  }

  Widget _buildRecentContact(String name, String image, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),  // dùng screenutil
      child: Column(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: Colors.grey[200],
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                width: 60.w,
                height: 60.h,
                errorWidget: (context, url, error) => Icon(Icons.error, size: 24.r),
                placeholder: (context, url) => CircularProgressIndicator(strokeWidth: 2.w),
              ),
            ),
          ),
          SizedBox(height: 5.h),  // dùng screenutil
          // Text(
          //   name,
          //   style: Theme.of(context).textTheme.bodyMedium,
          // ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(String name, String image, String message, String time) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),  // dùng screenutil
      leading: CircleAvatar(
        radius: 30.r,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: image,
            fit: BoxFit.cover,
            width: 60.w,
            height: 60.h,
            errorWidget: (context, url, error) => Icon(Icons.error, size: 24.r),
            placeholder: (context, url) => CircularProgressIndicator(strokeWidth: 2.w),
          ),
        ),
      ),
      title: Text(
        name,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).hintColor,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        time,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }

  Future<void> showSearchDialog() async {
    String keyword = "";

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Search Conversations"),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: "Enter a name..."),
            onChanged: (value) {
              keyword = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                if (keyword.trim().isEmpty) {
                  // If empty → show all conversations
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConversationsPage(),
                    ),
                  );
                } else {
                  // If keyword is entered → search
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConversationsPage(search: keyword),
                    ),
                  );
                }
              },
              child: Text("Search"),
            ),
          ],
        );
      },
    );
  }
}
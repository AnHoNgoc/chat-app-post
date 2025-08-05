import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/theme.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../bloc/chat_bloc.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String mate;
  final String profileImage;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.mate,
    required this.profileImage,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _storage = FlutterSecureStorage();
  String userId = "";
  String botId = "00000000-0000-0000-0000-000000000000";

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatBloc>(context)
      ..add(LoadMessageEvent(widget.conversationId))
      ..add(LoadDailyQuestionEvent(widget.conversationId));
    fetchUserId();
  }

  void fetchUserId() async {
    userId = await _storage.read(key: "userId") ?? "";
    setState(() {});
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (_pickedImageUrl != null) {
      BlocProvider.of<ChatBloc>(context).add(
        SendMessageEvent(widget.conversationId, _pickedImageUrl!),
      );
      _pickedImageUrl = null;
      _messageController.clear();
      setState(() {});
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      return;
    }
    if (content.isNotEmpty) {
      BlocProvider.of<ChatBloc>(context).add(
        SendMessageEvent(widget.conversationId, content),
      );
      _messageController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      setState(() {});
    }
  }

  bool _isUploadingImage = false;
  String? _pickedImageUrl;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _isUploadingImage = true;
      });
      context.read<UserBloc>().add(UploadProfileImageEvent(imageFile: imageFile));
    }
  }


  bool _isImage(String content) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return imageExtensions.any((ext) => content.toLowerCase().endsWith(ext));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.profileImage,
                  width: 40.w,
                  height: 40.h,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(Icons.error, size: 20.r),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(widget.mate, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, size: 22.sp),
          ),
        ],
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UploadImageSuccessState) {
            setState(() {
              _pickedImageUrl = state.imageUrl;
              _isUploadingImage = false;
            });
          } else if (state is UploadImageFailureState) {
            setState(() {
              _isUploadingImage = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Upload image failed")),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChatLoadedState) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(20.w),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isSentMessage = message.senderId == userId;
                        final isDailyQuestion = message.senderId == botId;
                        final isImage = _isImage(message.content);
                        if (isDailyQuestion) {
                          return _buildDailyQuestionMessage(context, message.content);
                        }
                        if (isImage) {
                          return _buildImageMessage(context, message.content, isSentMessage);
                        }
                        return isSentMessage
                            ? _buildSentMessage(context, message.content)
                            : _buildReceivedMessage(context, message.content);
                      },
                    );
                  } else if (state is ChatErrorState) {
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: Text("No messages found"));
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(BuildContext context, String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(right: 30.w, top: 5.h, bottom: 5.h),
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: DefaultColors.receiverMessage,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  Widget _buildSentMessage(BuildContext context, String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(right: 30.w, top: 5.h, bottom: 5.h),
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: DefaultColors.senderMessage,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context, String imageUrl, bool isSent) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: Colors.black.withOpacity(0.9),
              insetPadding: EdgeInsets.all(10.w),
              child: Stack(
                children: [
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      errorWidget: (context, url, error) =>
                          Icon(Icons.broken_image, color: Colors.white, size: 100.r),
                    ),
                  ),
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 30.r),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: isSent ? DefaultColors.senderMessage : DefaultColors.receiverMessage,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 200.w,
              height: 200.h,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 50.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyQuestionMessage(BuildContext context, String question) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.sentMessageInput,
        borderRadius: BorderRadius.circular(25.r),
      ),
      margin: EdgeInsets.all(25.w),
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Icon(Icons.camera_alt, color: Colors.grey, size: 22.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _pickedImageUrl != null
                ? Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: CachedNetworkImage(
                    imageUrl: _pickedImageUrl!,
                    width: 200.w,
                    height: 200.w,
                    fit: BoxFit.cover,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey, size: 20.sp),
                  onPressed: () {
                    setState(() {
                      _pickedImageUrl = null;
                    });
                  },
                ),
              ],
            )
                : _isUploadingImage
                ? SizedBox(
              width: 5.w,
              height: 10.w,
              child: CircularProgressIndicator(strokeWidth: 2.w),
            )
                : TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Message",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: _sendMessage,
            child: Icon(Icons.send, color: Colors.grey, size: 22.sp),
          ),
        ],
      ),
    );
  }
}
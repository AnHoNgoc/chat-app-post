import 'package:chat_app/features/chat/presentation/screens/chat_page.dart';
import 'package:chat_app/features/contact/presentation/bloc/contacts_bloc.dart';
import 'package:chat_app/features/contact/presentation/bloc/contacts_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../main.dart';
import '../bloc/contacts_state.dart';
import '../widgets/add_contact_dialog.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> with RouteAware {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ContactsBloc>(context).add(FetchContactsEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    BlocProvider.of<ContactsBloc>(context).add(FetchContactsEvent());
  }

  void _showAddContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddContactDialog(
        onAdd: (email) {
          BlocProvider.of<ContactsBloc>(context).add(AddContactsEvent(email));
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String contactId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Contact"),
        content: const Text("Are you sure you want to delete this contact?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // ✅ Sử dụng context gốc, không phải dialogContext
              BlocProvider.of<ContactsBloc>(context)
                  .add(DeleteContactEvent(contactId));
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: true,
        title: Text(
          "Contacts",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<ContactsBloc, ContactsState>(
        listener: (context, state) {
          if (state is ConversationReady) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  conversationId: state.conversationId,
                  mate: state.contact.username,
                  profileImage: state.contact.profileImage,
                ),
              ),
            );
          }
        },
        child: BlocBuilder<ContactsBloc, ContactsState>(
          builder: (context, state) {
            if (state is ContactsInitialState ||
                state is ContactsLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ContactsLoadedState) {
              if (state.contacts.isEmpty) {
                return const Center(child: Text("No contacts found"));
              }
              return ListView.builder(
                itemCount: state.contacts.length,
                itemBuilder: (context, index) {
                  final contact = state.contacts[index];
                  return ListTile(
                    title: Text(contact.username),
                    subtitle: Text(contact.email),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: "Delete",
                      onPressed: () => _confirmDelete(context, contact.id),
                    ),
                    onTap: () {
                      BlocProvider.of<ContactsBloc>(context).add(
                        CheckOrCreateConversationEvent(contact.id, contact),
                      );
                    },
                  );
                },
              );
            } else if (state is ContactsFailureState) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

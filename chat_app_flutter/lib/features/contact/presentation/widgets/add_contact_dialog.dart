import 'package:flutter/material.dart';

class AddContactDialog extends StatefulWidget {
  final Function(String) onAdd;

  const AddContactDialog({required this.onAdd, Key? key}) : super(key: key);

  @override
  _AddContactDialogState createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text("Add contact", style: Theme.of(context).textTheme.bodyMedium),
      content: TextField(
        controller: emailController,
        decoration: InputDecoration(
          hintText: "Enter contact email",
          hintStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final email = emailController.text.trim();
            if (email.isNotEmpty) {
              widget.onAdd(email);
              Navigator.pop(context);
            }
          },
          child: Text("Add", style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
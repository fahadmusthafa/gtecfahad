import 'package:flutter/material.dart';
import 'package:lms/provider/authprovider.dart';
import 'package:provider/provider.dart';

class CreateLiveLinkDialog extends StatefulWidget {
  final int courseId;

  final int batchId;



  const CreateLiveLinkDialog(this.courseId, this.batchId, {Key? key}) : super(key: key);
  _CreateLiveLinkDialogState createState() => _CreateLiveLinkDialogState();
}


class _CreateLiveLinkDialogState extends State<CreateLiveLinkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _liveLinkController = TextEditingController();
  DateTime? _liveStartTime;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Live Link'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _liveLinkController,
              decoration: InputDecoration(labelText: 'Live Link'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a live link';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      _liveStartTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: Text(_liveStartTime == null
                  ? 'Pick Live Start Time'
                  : 'Live Start Time: $_liveStartTime'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() &&
                _liveStartTime != null) {
              try {
                // Call provider to create live link
                await context.read<AdminAuthProvider>().AdmincreateLivelinkprovider(
                      widget.courseId,
                      widget.batchId, // Replace with the actual courseId
                      _liveLinkController.text,
                      _liveStartTime!,
                    );

                Navigator.of(context).pop(); // Close the dialog
                // Navigate to the next page
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => NextPage(), // Replace with your target page
                //   ),
                // );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          child: Text('Create',),
        ),
      ],
    );
  }
}

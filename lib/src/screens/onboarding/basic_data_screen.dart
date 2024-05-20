import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:netten/src/screens/home/home_screen.dart';
import 'package:netten/src/widgets/gradient_text.dart';
import 'package:netten/theme.dart';

class BasicDataScreen extends StatefulWidget {
  const BasicDataScreen({Key? key, required this.userId}) : super(key: key);

  @override
  BasicDataScreenState createState() => BasicDataScreenState();
  final String userId;
}

class BasicDataScreenState extends State<BasicDataScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _firstNameError;
  String? _lastNameError;

  void _validateInputs() {
    setState(() {
      _firstNameError = _firstNameController.text.isEmpty ? 'Please enter your first name' : null;
      _lastNameError = _lastNameController.text.isEmpty ? 'Please enter your last name' : null;
    });

    if (_firstNameError == null && _lastNameError == null) {
      _updateName(context).then((value) =>
          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                var curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
                (route) => false, // Prevents user from going back to the previous screen
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: GradientText(
                "NeteN",
                style: Theme.of(context).textTheme.displayMedium,
                gradient: LinearGradient(colors: [NetenColor.primaryColor, NetenColor.secondaryColor]),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(labelText: 'First Name', errorText: _firstNameError),
                    textCapitalization: TextCapitalization.words,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(labelText: 'Last Name', errorText: _lastNameError),
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validateInputs,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Continue', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateName(BuildContext context) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);

    try {
      await userDoc.update({
        'firstName': _firstNameController.text.toLowerCase(),
        'lastName': _lastNameController.text.toLowerCase(),
        'fullName': _firstNameController.text.toLowerCase() + ' ' + _lastNameController.text.toLowerCase(),
        'displayName': _firstNameController.text + ' ' + _lastNameController.text,
      });
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user')),
      );
    }
  }
}

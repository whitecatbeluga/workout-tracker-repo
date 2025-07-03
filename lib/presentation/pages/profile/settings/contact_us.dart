import 'package:flutter/material.dart';

import '../../../../routes/profile/profile.dart';
import '../../../widgets/buttons/button.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  @override
  Widget build(BuildContext context) {
    //text field borders
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blueGrey), // Faded border
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Contact Us'),
        leading: IconButton(
          onPressed: Navigator.canPop(context)
              ? () => Navigator.pop(context)
              : () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    ProfileRoutes.settings,
                    (route) => false,
                  );
                },
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE0E0E0), // Light gray border
            height: 1.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Text(
                textAlign: TextAlign.center,
                "Need a Spot? We're Here to Help",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
              ),
            ),
            Image.asset(
              'assets/images/contact_us.png',
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),

            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Subject"),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Subject',
                    prefixIcon: Icon(Icons.email),
                    enabledBorder: border,
                    focusedBorder: border.copyWith(
                      borderSide: BorderSide(
                        color:  Colors.blueGrey,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            //message
            SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Message"),
                SizedBox(height: 10),
                TextField(
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Message',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14, bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.insert_drive_file),
                        ],
                      ),
                    ),
                    enabledBorder: border,
                    focusedBorder: border.copyWith(
                      borderSide: BorderSide(color: Colors.blueGrey, width: 1.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text("Message from: John Doe(volt@gmail.com"),
            SizedBox(height:20),
            Button(
              label: 'Send',
              onPressed: () {},
              variant: ButtonVariant.secondary,
              size: ButtonSize.medium,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}

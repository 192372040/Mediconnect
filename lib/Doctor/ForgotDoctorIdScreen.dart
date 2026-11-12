import 'package:flutter/material.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';

class ForgotDoctorIdScreen
    extends StatefulWidget {

  const ForgotDoctorIdScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ForgotDoctorIdScreen>
      createState() =>
          _ForgotDoctorIdScreenState();
}

class _ForgotDoctorIdScreenState
    extends State<ForgotDoctorIdScreen> {

  final TextEditingController
      emailController =
          TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text(
              "Forgot Doctor ID",
            ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller:
                  emailController,

              decoration:
                  const InputDecoration(
                labelText:
                    "Enter Email",
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(

              onPressed: () async {

                var res =
                    await ApiService
                        .forgotDoctorId(

                  email:
                      emailController.text,
                );

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(

                  SnackBar(
                    content: Text(

                      res["message"] ??
                          res["error"],

                    ),
                  ),
                );
              },

              child: const Text(
                "Send Doctor ID",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
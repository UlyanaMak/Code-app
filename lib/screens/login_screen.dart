import 'package:course_project_code_app/screens/code_screen.dart';
import 'package:flutter/material.dart';
import '../screens/lab_list_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 80.0, 20.0, 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              //Текст входа
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Вход',
                  style:  TextStyle(
                    fontSize: 36,
                    color: Color(0xFF6E97EC),
                    fontWeight: FontWeight.bold,                
                  ),
                ),
              ),

              SizedBox(height: 80,),

              //Поле для ввода пароля
              TextField(
                 controller: emailController,
                 style: TextStyle(fontSize: 20.0),
                 decoration: InputDecoration(
                   labelText: 'Email',
                   labelStyle: TextStyle(
                     fontSize: 20.0,
                   ),

                  hintText: 'Введите корпоративный email',

                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(20.0)
                   ),
                 ),
               ),

               SizedBox(height: 80,),

              //Поле для ввода пароля
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  
                  labelStyle: TextStyle(
                    fontSize: 20.0,

                  ),

                  hintText: 'Введите пароль',

                  hintStyle: TextStyle(
                      fontSize: 20.0,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),

                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword 
                          ? Icons.visibility_off 
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              
              Spacer(),

              //Кнопка "Войти"
              ElevatedButton(
                onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => LabsListScreen()),  //заменём 1 экран
                    );
                  },

                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 60),
                  backgroundColor: Color(0xFF6E97EC), // основной цвет кнопки (ваш голубой)
                  foregroundColor: Colors.white,
                  overlayColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  )
                ),

                child: Text(
                  'Войти',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,

                  ),
                ),
              ),

            ],
          ),
          
        )
      )
    );
  }
}

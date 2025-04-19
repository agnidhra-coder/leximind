import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leximind/config.dart';
import 'package:leximind/providers/gemma_provider.dart';
import 'package:leximind/services/lg_service.dart';
import 'package:leximind/widgets/custom_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartssh2/dartssh2.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  final Function(bool) onConnectionChanged;

  const ConnectionScreen({required this.onConnectionChanged, Key? key})
      : super(key: key);

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get isConnected => ref.watch(connectionStatusProvider);
  

  
  bool isLoading = false;
  

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sshPortController = TextEditingController();
  final TextEditingController _rigsController = TextEditingController();
  final TextEditingController _apiController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _sshPortController.dispose();
    _rigsController.dispose();
    _apiController.dispose();
    super.dispose();
  }

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _loadSettings() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('ipAddress') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _sshPortController.text = prefs.getString('sshPort') ?? '';
      _rigsController.text = prefs.getString('numberOfRigs') ?? '';
      _apiController.text = prefs.getString('apiKey') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (_ipController.text.isNotEmpty) {
      await prefs.setString('ipAddress', _ipController.text);
    }
    if (_usernameController.text.isNotEmpty) {
      await prefs.setString('username', _usernameController.text);
    }
    if (_passwordController.text.isNotEmpty) {
      await prefs.setString('password', _passwordController.text);
    }
    if (_sshPortController.text.isNotEmpty) {
      await prefs.setString('sshPort', _sshPortController.text);
    }
    if (_rigsController.text.isNotEmpty) {
      await prefs.setString('numberOfRigs', _rigsController.text);
    }
    if (_apiController.text.isNotEmpty) {
      await prefs.setString('apiKey', _apiController.text);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  trySubmit(int buttonId) {
    final isValid = _formKey.currentState!.validate();
    if(isValid) {
      _formKey.currentState!.save();
      if(buttonId == 1){
        connectToLG();
      } else{
        removeLogo();
      }
      
    } else{
      print('Error');
    }

  }

  void connectToLG() async{
    await _saveSettings();
    SSH ssh = SSH();
    setState(() {
          isLoading = true;
        });
    bool? result = await ssh.connectToLG();

    try {
      
      if (result == true) {
        ref.read(connectionStatusProvider.notifier).state = true;
        widget.onConnectionChanged(true);
        final snackbar = SnackBar(
          backgroundColor: Colors.white70,
          content: Text(
            "Connected!",
            style: TextStyle(color: Colors.black),
          )
          
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        // setState(() {
        //   isConnected = true;
        //   widget.onConnectionChanged(isConnected);
        // });
        print('Connected to LG successfully');
      } else{
        ref.read(connectionStatusProvider.notifier).state = false;
        widget.onConnectionChanged(false);
        final snackbar = SnackBar(
          backgroundColor: Colors.red[400],
          content: Text("Can't connect")
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } finally {
        setState(() {
          isLoading = false;
        });
      }
  }

  void removeLogo() async {
    SSH ssh = SSH();
    LGService lgService = LGService();
    setState(() {
      isLoading = true;
    });
    await ssh.connectToLG();
    try {
      await lgService.cleanKML(3);
      setState(() {
        isLoading = false;
      });
      final snackbar = SnackBar(
        backgroundColor: Colors.white70,
        content: Text(
          "Successfully removed!",
          style: TextStyle(
            color: Colors.black
          ),
        ),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
      final snackbar = SnackBar(
        backgroundColor: Colors.red[400],
        content: Text("An error occured"),
        duration: Duration(seconds: 2)
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection'),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10,),
                Text(
                  isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.red,
                    fontSize: 20,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextFormField(labelText: 'IP Address', hintText: '192.168.0.1', controller: _ipController, valueKey: 'ipController', inputType: TextInputType.number),
                        SizedBox(height: 20),
                        CustomTextFormField(labelText: 'Port', hintText: '22', controller: _sshPortController, valueKey: 'sshPort', inputType: TextInputType.number),
                        SizedBox(height: 20),
                        CustomTextFormField(labelText: 'Rigs', hintText: '3', controller: _rigsController, valueKey: 'rigs', inputType: TextInputType.number),
                        SizedBox(height: 20),
                        CustomTextFormField(labelText: 'Username', hintText: 'Username', controller: _usernameController, valueKey: 'username', inputType: TextInputType.text),
                        SizedBox(height: 20),
                        TextFormField(
                          obscureText: _obscureText,
                          
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 211, 211, 211)
                            ),
                            hintText: 'Enter Password',
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 211, 211, 211)
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                              ),
                              // color: Colors.white70,
                              onPressed: _togglePasswordVisibility,
                            ),
                            
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          controller: _passwordController,
                          key: ValueKey('password'),
                          validator:(value) {
                            if (value.toString().isEmpty){
                              return "Field can't be empty";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => trySubmit(1),
                              
                              child: Text('Connect to LG',),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => trySubmit(2),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Remove Logo',),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        if(isLoading) ...[
                          SizedBox(width: 20,),
                          SpinKitThreeBounce(
                            color: Colors.white,
                            size: 15,
                          )
                        ]
                      ],
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
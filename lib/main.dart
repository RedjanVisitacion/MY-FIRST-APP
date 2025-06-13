import 'package:flutter/material.dart';

void main() {
  runApp(const AuthApp());
}

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login & Register',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const AuthPage(),
    );
  }
}

class User {
  final String username;
  final String email;
  final String password;
  final String role;
  User({required this.username, required this.email, required this.password, required this.role});
}

// In-memory user storage
final List<User> registeredUsers = [];

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6D5BFF), Color(0xFF00B4D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Practice Mode', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            bottom: const TabBar(
              indicatorColor: Colors.white,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [
                Tab(text: 'Login'),
                Tab(text: 'Register'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              LoginForm(),
              RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}

const List<String> roles = ['User', 'Admin', 'Guest'];

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String? role;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter your email' : null,
                    onSaved: (value) => email = value ?? '',
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscure,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter your password' : null,
                    onSaved: (value) => password = value ?? '',
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    value: role,
                    items: roles
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        role = value;
                      });
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Select your role' : null,
                    onSaved: (value) => role = value,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFF6D5BFF),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          // Check if user exists and matches
                          final user = registeredUsers.firstWhere(
                            (u) => u.email == email && u.password == password && u.role == role,
                            orElse: () => User(username: '', email: '', password: '', role: ''),
                          );
                          if (user.email.isNotEmpty) {
                            // Navigate to dashboard based on role
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) {
                                if (user.role == 'Admin') {
                                  return AdminDashboard(user: user);
                                } else if (user.role == 'User') {
                                  return UserDashboard(user: user);
                                } else {
                                  return GuestDashboard(user: user);
                                }
                              }),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Login failed: No matching user found.')),
                            );
                          }
                        }
                      },
                      child: const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String password = '';
  String? role;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Register',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter your username' : null,
                    onSaved: (value) => username = value ?? '',
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter your email' : null,
                    onSaved: (value) => email = value ?? '',
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscure,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter your password' : null,
                    onSaved: (value) => password = value ?? '',
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    value: role,
                    items: roles
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        role = value;
                      });
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Select your role' : null,
                    onSaved: (value) => role = value,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFF00B4D8),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          // Check if email already exists
                          final exists = registeredUsers.any((u) => u.email == email && u.role == role);
                          if (exists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User with this email and role already exists.')),
                            );
                          } else {
                            registeredUsers.add(User(
                              username: username,
                              email: email,
                              password: password,
                              role: role!,
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Registered as $username ($role)')),
                            );
                          }
                        }
                      },
                      child: const Text('Register'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Dashboard Pages ---

class UserDashboard extends StatelessWidget {
  final User user;
  const UserDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.username}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('You are logged in as a ${user.role}.', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthApp()), // Go back to login
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  final User user;
  const AdminDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, Admin ${user.username}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('You have administrative privileges.', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthApp()), // Go back to login
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class GuestDashboard extends StatelessWidget {
  final User user;
  const GuestDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Dashboard'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, Guest ${user.username}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('You have limited access.', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthApp()), // Go back to login
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

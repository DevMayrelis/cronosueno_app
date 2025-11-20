// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registro_screen.dart';
import '../eventos/eventos_screen.dart '; // Para navegar a EventsScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // CONTROLADORES PARA LOS CAMPOS DE TEXTO
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  // INSTANCIA DE FIREBASE AUTH
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // VARIABLES DE ESTADO
  bool _contrasenaVisible = false; // Para mostrar/ocultar contraseña
  bool _isLoading = false; // Estado de carga durante el login

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fondo gris muy claro
      appBar: AppBar(
        // APPBAR CON BOTÓN DE REGRESO
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5F63E1)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOGO DE LA APP
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Image.asset(
                    'assets/images/imagen_circular_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.nightlight_round,
                          size: 50,
                          color: Color(0xFF5F63E1),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // TÍTULO PRINCIPAL
              Text(
                'Iniciar Sesión',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 8),

              // SUBTÍTULO
              Text(
                'Bienvenido de vuelta a CronoSueño',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 40),

              // CAMPO DE EMAIL
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'Ingresa tu email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // CAMPO DE CONTRASEÑA
              _buildPasswordField(),

              const SizedBox(height: 16),

              // ENLACE "OLVIDÉ MI CONTRASEÑA"
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed:
                      _isLoading ? null : _mostrarDialogoRecuperarContrasena,
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF5F63E1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // BOTÓN PRINCIPAL DE INGRESAR
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _iniciarSesion,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5F63E1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Estilos cuando está deshabilitado
                    disabledBackgroundColor: const Color(0xFF94A3B8),
                    disabledForegroundColor: const Color(0xFFFFFFFF),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'INGRESAR',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // SEPARADOR "O"
              _buildSeparator(),

              const SizedBox(height: 24),

              // BOTÓN DE GOOGLE (SIMPLIFICADO - SOLO ICONO)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _iniciarSesionGoogle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E293B),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 234, 226, 239),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.g_mobiledata_rounded,
                        color: Color(0xFF5F63E1),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'INICIAR SESIÓN CON GOOGLE',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ENLACE "¿NO TIENES CUENTA?"
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _irARegistro,
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                      children: [
                        const TextSpan(text: '¿No tienes cuenta? '),
                        TextSpan(
                          text: 'Regístrate',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF5F63E1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== WIDGETS REUTILIZABLES ==========

  /// Widget para campos de texto normales (email, etc.)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: const Color(0xFF94A3B8)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5F63E1), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Widget especial para campo de contraseña
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contraseña',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contrasenaController,
          obscureText: !_contrasenaVisible,
          decoration: InputDecoration(
            hintText: 'Ingresa tu contraseña',
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF94A3B8),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _contrasenaVisible ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: () {
                setState(() {
                  _contrasenaVisible = !_contrasenaVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5F63E1), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Separador visual "O"
  Widget _buildSeparator() {
    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFFE2E8F0), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'O',
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: const Color(0xFFE2E8F0), thickness: 1)),
      ],
    );
  }

  // ========== FUNCIONES DE LA PANTALLA ==========

  /// Función para iniciar sesión con email y contraseña
  Future<void> _iniciarSesion() async {
    final email = _emailController.text.trim();
    final contrasena = _contrasenaController.text.trim();

    // Validar campos vacíos
    if (email.isEmpty || contrasena.isEmpty) {
      _mostrarSnackBar('Por favor, completa todos los campos');
      return;
    }

    // Validar formato de correo electrónico
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _mostrarSnackBar('Por favor, ingresa un correo válido');
      return;
    }

    // Mostrar indicador de carga
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: contrasena,
      );

      if (!mounted) return;
      _mostrarSnackBar('Sesión iniciada correctamente');

      // CAMBIO PRINCIPAL: Navegar a EventsScreen después del login exitoso
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const EventosScreen()));
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') {
        errorMessage = 'No existe una cuenta con este email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Credenciales inválidas';
      }

      if (mounted) {
        _mostrarSnackBar('Error: $errorMessage');
      }
    } catch (e) {
      if (mounted) {
        _mostrarSnackBar('Error inesperado: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Función para iniciar sesión con Google
  void _iniciarSesionGoogle() {
    _mostrarSnackBar('Funcionalidad de Google en desarrollo');
    // print('Iniciando sesión con Google...');
  }

  /// Función para navegar a la pantalla de registro
  void _irARegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroScreen()),
    );
  }

  /// Diálogo para recuperar contraseña
  void _mostrarDialogoRecuperarContrasena() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Recuperar Contraseña',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
              style: GoogleFonts.inter(),
            ),
            const SizedBox(height: 16),
            Text(
              'Correo electrónico',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'tu@email.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.inter()),
          ),
          FilledButton(
            onPressed: () async {
              final email = emailController.text.trim();

              // Validar email
              if (email.isEmpty ||
                  !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Por favor, ingresa un correo válido'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                return;
              }

              try {
                await _auth.sendPasswordResetEmail(email: email);

                // VERIFICACIÓN CORRECTA: usar context.mounted
                if (context.mounted) {
                  Navigator.pop(context);
                  _mostrarSnackBar('Enlace de recuperación enviado a $email');
                }
              } catch (e) {
                // VERIFICACIÓN CORRECTA: usar context.mounted
                if (context.mounted) {
                  Navigator.pop(context);
                  _mostrarSnackBar(
                      'Error al enviar el enlace: ${e.toString()}');
                }
              }
            },
            child: Text('Enviar', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  /// Función para mostrar mensajes temporales
  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar controladores al cerrar la pantalla
    _emailController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }
}

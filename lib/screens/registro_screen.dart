// lib/screens/registro_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  // CONTROLADORES PARA TODOS LOS CAMPOS DE TEXTO
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController =
      TextEditingController();

  //INSTANCIA DE FIREBASE
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // VARIABLES DE ESTADO
  bool _contrasenaVisible = false; // Para mostrar/ocultar contraseña
  bool _confirmarContrasenaVisible = false; // Para mostrar/ocultar confirmación
  bool _aceptoTerminos = false; // Estado del checkbox de términos
  bool _isLoading = false; // Estado de carga

  //Función para registrar usuario en Firebase
  Future<void> _registrarUsuario() async {
    if (!_aceptoTerminos) {
      _mostrarSnackBar('Debes aceptar los términos y condiciones');
      return;
    }

    // OBTENER VALORES DE LOS CAMPOS
    final nombre = _nombreController.text.trim();
    final apellidos = _apellidosController.text.trim();
    final email = _emailController.text.trim();
    final contrasena = _contrasenaController.text.trim();
    final confirmarContrasena = _confirmarContrasenaController.text.trim();

    // VALIDACIONES
    if (nombre.isEmpty ||
        apellidos.isEmpty ||
        email.isEmpty ||
        contrasena.isEmpty ||
        confirmarContrasena.isEmpty) {
      _mostrarSnackBar('Por favor, completa todos los campos');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _mostrarSnackBar('Por favor, ingresa un correo electrónico válido');
      return;
    }

    if (contrasena != confirmarContrasena) {
      _mostrarSnackBar('Las contraseñas no coinciden');
      return;
    }
    if (contrasena.length < 8) {
      _mostrarSnackBar('La contraseña debe tener al menos 8 caracteres');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1.Crear usuario en Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: contrasena,
      );

      // 2.Guardar información adicional en Firestore
      await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
        'nombre': nombre,
        'apellidos': apellidos,
        'email': email,
        'fechaRegistro': FieldValue.serverTimestamp(),
        'uid': userCredential.user!.uid,
      });

      //Verificar si el wiget sigue montado antes de mostrar el SnackBar
      if (!mounted) return;

      _mostrarSnackBar('Cuenta creada exitosamente');

      //Verificar si el wiget sigue montado antes de navegar
      if (!mounted) return;

      // Navegar al login después del registro
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al registrar usuario';
      if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es demasiado débil';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Ya existe una cuenta con este correo electrónico';
      }

      //Verificar mounted antes de mostrar el SnackBar
      if (mounted) {
        _mostrarSnackBar('Error: $errorMessage');
      }
    } catch (e) {
      //Verificar mounted antes de mostrar el SnackBar de error inesperado
      if (mounted) {
        _mostrarSnackBar('Error inesperado: ${e.toString()}');
      }
    } finally {
      // Asegurarse de que el widget sigue montado antes de llamar a setState
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFC,
      ), // Fondo gris claro igual al login
      appBar: AppBar(
        // APPBAR CON BOTÓN DE REGRESO AL LOGIN
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5F63E1)),
          onPressed: () => Navigator.pop(context), // Regresa al login
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOGO DE LA APP - CENTRADO
              Center(
                child: Container(
                  width: 100, // Tamaño un poco más pequeño que en login
                  height: 100,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Image.asset(
                    'assets/images/imagen_circular_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // FALLBACK SI LA IMAGEN NO CARGA
                      return Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.nightlight_round,
                          size: 40,
                          color: Color(0xFF5F63E1),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20), // Espacio después del logo

              // TÍTULO PRINCIPAL "REGISTRARSE"
              Text(
                'REGISTRARSE',
                style: GoogleFonts.inter(
                  fontSize: 28, // Tamaño un poco menor que el login
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B), // Gris oscuro
                ),
              ),

              const SizedBox(height: 8),

              // SUBTÍTULO BIENVENIDA
              Text(
                'Únete a CronoSueño y mejora tu descanso',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B), // Gris medio
                ),
              ),

              const SizedBox(height: 32), // Espacio antes de los campos

              // CAMPO DE NOMBRE
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre',
                hintText: 'Ingresa tu nombre',
                prefixIcon: Icons.person_outline_rounded, // Ícono de persona
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 16),

              // CAMPO DE APELLIDOS
              _buildTextField(
                controller: _apellidosController,
                label: 'Apellidos',
                hintText: 'Ingresa tus apellidos',
                prefixIcon: Icons.person_pin_rounded,
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 16),

              // CAMPO EMAIL
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'Ingresa tu email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // CAMPO DE CONTRASEÑA
              _buildPasswordField(
                controller: _contrasenaController,
                label: 'Contraseña',
                hintText: 'Crea tu contraseña',
                isVisible: _contrasenaVisible,
                onToggleVisibility: () {
                  setState(() {
                    _contrasenaVisible = !_contrasenaVisible;
                  });
                },
              ),

              const SizedBox(height: 16),

              // CAMPO DE CONFIRMAR CONTRASEÑA
              _buildPasswordField(
                controller: _confirmarContrasenaController,
                label: 'Confirmar contraseña',
                hintText: 'Repite tu contraseña',
                isVisible: _confirmarContrasenaVisible,
                onToggleVisibility: () {
                  setState(() {
                    _confirmarContrasenaVisible = !_confirmarContrasenaVisible;
                  });
                },
              ),

              const SizedBox(height: 16),

              // CHECKBOX TÉRMINOS Y CONDICIONES
              Row(
                children: [
                  // CHECKBOX PERSONALIZADO
                  Transform.scale(
                    scale: 0.9, // Tamaño ligeramente reducido
                    child: Checkbox(
                      value: _aceptoTerminos,
                      onChanged: (bool? value) {
                        setState(() {
                          _aceptoTerminos = value ?? false;
                        });
                      },
                      activeColor: const Color(
                        0xFF5F63E1,
                      ), // Color cuando está activo
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // TEXTO DE TÉRMINOS
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _mostrarTerminosYCondiciones();
                      },
                      child: Text(
                        'Acepto términos y condiciones',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // BOTÓN PRINCIPAL DE REGISTRO
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _registrarUsuario,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5F63E1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Efecto visual cuando está desactivado
                    disabledBackgroundColor: const Color(
                      0xFF94A3B8,
                    ), // 50% opacidad
                    disabledForegroundColor: const Color(
                      0xFFFFFFFF,
                    ), // 70% opacidad
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

                      // SI NO ESTÁ CARGANDO, MOSTRAR TEXTO
                      : Text(
                          'REGISTRAR',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              // SEPARADOR "O"
              const SizedBox(height: 24),
              // Separator
              _buildSeparator(),
              const SizedBox(height: 24),

              // BOTÓN REGISTRARSE CON GOOGLE
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _registrarseConGoogle,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E293B),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 234, 226, 239),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // Contenido del botón
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ÍCONO DE GOOGLE
                      Image.asset(
                        'assets/images/icons.google.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.g_mobiledata_rounded,
                            color: Color(0xFF5F63E1),
                          );
                        },
                      ),
                      const SizedBox(width: 12),

                      // TEXTO DEL BOTÓN
                      Text(
                        'REGISTRARSE CON GOOGLE',
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

              // ENLACE "¿YA TIENES CUENTA?"
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _irALogin, // Navegar al login
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                      children: [
                        const TextSpan(text: '¿Ya tienes cuenta? '),
                        TextSpan(
                          text: 'Iniciar Sesión',
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

  // WIDGET REUTILIZABLE PARA CAMPOS DE TEXTO NORMALES
  // COMO NOMBRE, APELLIDOS, EMAIL
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
        // ETIQUETA DEL CAMPO
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        // CAMPO DE TEXTO
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

  // WIDGET REUTILIZABLE PARA CAMPOS DE CONTRASEÑA

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
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
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF94A3B8),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: onToggleVisibility,
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

  // SEPARADOR "O" - IGUAL AL DEL LOGIN
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

// FUNCIÓN PARA REGISTRARSE CON GOOGLE
  void _registrarseConGoogle() {
    print('Registrándose con Google...');
    _mostrarSnackBar('Registrándose con Google...');
    // AQUÍ IRÍA LA INTEGRACIÓN CON FIREBASE AUTH O SIMILAR
  }

// FUNCIÓN PARA IR AL LOGIN
  void _irALogin() {
    // En lugar de pop, usamos pushReplacement para reemplazar la pantalla actual
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

// FUNCIÓN PARA MOSTRAR TÉRMINOS Y CONDICIONES
  void _mostrarTerminosYCondiciones() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Términos y Condiciones',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Términos y condiciones de CronoSueño. '
            'Por favor, lee detenidamente antes de aceptar.\n\n'
            '1. Tu información personal será protegida\n'
            '2. Los datos de sueño son confidenciales\n'
            '3. Puedes eliminar tu cuenta cuando quieras\n'
            '4. Nos comprometemos a mejorar tu descanso',
            style: GoogleFonts.inter(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

// FUNCIÓN PARA MOSTRAR MENSAJES TEMPORALES
  void _mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 3)),
    );
  }

  @override
  void dispose() {
    // LIMPIAR CONTROLADORES AL CERRAR LA PANTALLA
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }
}

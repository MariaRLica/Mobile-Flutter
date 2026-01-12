// lib/screens/profile_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // carregar provider (se necessário)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<UserProvider>(context, listen: false);
      prov.loadFromPrefs().then((_) {
        _nameController.text = prov.name;
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // OBS: no web o image_picker pode devolver um XFile cuja path não é acessível via dart:io.
  // Para web é recomendável salvar os bytes (base64) em SharedPreferences ou enviar para servidor.
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _loading = true);
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );

      if (picked == null) return;

      // Diferencia web / mobile:
      if (kIsWeb) {
        // No Web: lemos os bytes e salvamos como base64 na SharedPreferences via provider.
        final bytes = await picked.readAsBytes();
        final base64Data = base64Encode(bytes);
        // armazenar um prefixo para sabermos que é base64
        final storageValue =
            'data:image/${picked.mimeType?.split('/').last ?? 'png'};base64,$base64Data';
        await Provider.of<UserProvider>(context, listen: false)
            .setPhotoUrl(storageValue);
      } else {
        // Mobile/desktop: salvamos o path retornado pelo image_picker
        await Provider.of<UserProvider>(context, listen: false)
            .setPhotoUrl(picked.path);
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Erro ao escolher imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao escolher imagem')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar foto'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remover foto'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Provider.of<UserProvider>(context, listen: false)
                      .clearPhoto();
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancelar'),
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    await Provider.of<UserProvider>(context, listen: false).setName(newName);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil salvo com sucesso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final imageValue = userProv.photoUrl;
    final hasImage = imageValue.isNotEmpty;

    // determina ImageProvider de forma segura (sem usar File em web)
    ImageProvider? imageProvider;
    if (hasImage) {
      try {
        if (kIsWeb) {
          // Se o valor armazenado começar com "data:image/...;base64," então decodificamos
          if (imageValue.startsWith('data:image')) {
            final base64Part = imageValue.split(',').last;
            final bytes = base64Decode(base64Part);
            imageProvider = MemoryImage(bytes);
          } else if (imageValue.startsWith('http')) {
            // se armazenou uma URL remota
            imageProvider = NetworkImage(imageValue);
          } else {
            // caminho local não funciona no web; ignorar (fallback para ícone)
            imageProvider = null;
          }
        } else {
          // mobile / desktop: usar FileImage, mas protegendo existsSync() em try/catch
          final file = File(imageValue);
          if (file.existsSync()) {
            imageProvider = FileImage(file);
          } else {
            imageProvider = null;
          }
        }
      } catch (e) {
        debugPrint('Erro ao criar ImageProvider: $e');
        imageProvider = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white), // cor do texto
        ),
        backgroundColor: Colors.deepPurple, // cor de fundo
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _showPickOptions,
              child: _loading
                  ? const SizedBox(
                      height: 120,
                      width: 120,
                      child: Center(child: CircularProgressIndicator()))
                  : CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue[100],
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(Icons.camera_alt,
                              size: 40, color: Colors.black54)
                          : null,
                    ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController..text = (userProv.name),
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('Salvar Perfil'),
            ),
            const SizedBox(height: 30),
            if (userProv.name.isNotEmpty)
              Text('Olá, ${userProv.name}!',
                  style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

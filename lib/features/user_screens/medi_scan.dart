
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediscan_plus/main.dart';

import '../../Provider/Scan_Cubit/scan_medi_cubit.dart';
import '../../Provider/Scan_Cubit/scan_state.dart'; // for AppTheme


class ScanMedi_Screen extends StatelessWidget {
  const ScanMedi_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanMediCubit(),
      child: const _ScanMediView(),
    );
  }
}

class _ScanMediView extends StatelessWidget {
  const _ScanMediView({Key? key}) : super(key: key);

  void _showPickOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Select Image Source", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ScanMediCubit>().pickImage(ImageSource.gallery);
              },
              icon: const Icon(Icons.photo_library),
              label: const Text("Pick from Gallery", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ScanMediCubit>().pickImage(ImageSource.camera);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text("Use Camera", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanMediCubit, ScanState>(
      listener: (context, state) {
        if (state.status == ScanStatus.failure && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/images/surface_logo.png', fit: BoxFit.contain, height: 32),
            ),
            title: const Text("Scan Medicine", style: TextStyle(fontSize: 22)),
            centerTitle: true,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  state.imageFile == null
                      ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.textPrimary,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/scan_medi.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      : AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 250,
                    child: Image.file(state.imageFile!),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _showPickOptionsDialog(context),
                    child: const Text("FLASH-SCAN"),
                  ),
                  const SizedBox(height: 20),
                  if (state.status == ScanStatus.loading) const Center(child: CircularProgressIndicator())
                  else if (state.extractedText.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Extracted Text:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            state.extractedText,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => context.read<ScanMediCubit>().clear(),
                          icon: const Icon(Icons.clear),
                          label: const Text("Clear ×"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        ),
                      ],
                    )
                  else
                    const SizedBox(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

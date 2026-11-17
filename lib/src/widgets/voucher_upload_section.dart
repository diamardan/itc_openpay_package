import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class VoucherUploadSection extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onPickFromCamera;
  final VoidCallback onPickFromGallery;
  final VoidCallback? onRemoveImage;
  final bool showCheckbox;
  final bool checkboxValue;
  final ValueChanged<bool> onCheckboxChanged;
  final String checkboxLabel;
  final VoidCallback? onSubmit;
  final bool isSubmitEnabled;
  final bool showSubmitButton;
  final String title;
  final String subtitle;
  final bool useDottedBorderStyle;
  final Color? dottedButtonColor;

  const VoucherUploadSection({
    super.key,
    required this.imageFile,
    required this.onPickFromCamera,
    required this.onPickFromGallery,
    this.onRemoveImage,
    required this.showCheckbox,
    required this.checkboxValue,
    required this.onCheckboxChanged,
    required this.checkboxLabel,
    required this.isSubmitEnabled,
    this.onSubmit,
    this.showSubmitButton = true,
    this.title = 'Comprobante de pago',
    this.subtitle = 'Sube la foto del comprobante para validar el pago.',
    this.useDottedBorderStyle = false,
    this.dottedButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    if (useDottedBorderStyle) {
      return _buildDottedBorderStyle(context);
    }
    return _buildCurrentStyle(context);
  }

  Widget _buildCurrentStyle(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style:
              theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        _VoucherPreview(
          imageFile: imageFile,
          onRemoveImage: onRemoveImage,
        ),
        if (imageFile == null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickFromCamera,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Tomar Foto'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
              ),
            ],
          ),
        ],
        if (showCheckbox) ...[
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: checkboxValue,
            onChanged: (value) => onCheckboxChanged(value ?? false),
            title: Text(
              checkboxLabel,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
        if (showSubmitButton) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSubmitEnabled ? onSubmit : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Continuar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDottedBorderStyle(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = dottedButtonColor ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVoucherNotices(),
        const SizedBox(height: 12),
        if (imageFile == null)
          _buildDottedPlaceholder(buttonColor)
        else
          _buildDottedPreview(buttonColor),
        if (showCheckbox) ...[
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: checkboxValue,
            onChanged: (value) => onCheckboxChanged(value ?? false),
            title: Text(
              checkboxLabel,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ],
    );
  }

  Widget _buildVoucherNotices() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade300, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SIN SU COMPROBANTE DE PAGO NO SE IMPRIME SU CREDENCIAL.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.yellow.shade50,
            border: Border.all(color: Colors.yellow.shade400, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange.shade600, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NO SE PROCESARÁ SU SOLICITUD SI EL COMPROBANTE DE PAGO:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildBulletItem('TIENE MÁS DE 30 DÍAS DE ANTIGÜEDAD.'),
                    _buildBulletItem('MUESTRA DATOS DE CUENTA INCORRECTOS O A NOMBRE DE UN TERCERO.'),
                    _buildBulletItem('EL IMPORTE ESTÁ INCOMPLETO.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDottedPlaceholder(Color buttonColor) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(12),
        dashPattern: const [8, 4],
        color: Colors.grey.shade400,
        strokeWidth: 1.5,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 48,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 12),
            Text(
              'Toma una foto clara y completa\nde tu comprobante de pago.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Asegúrate de que se vean todos los datos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: onPickFromCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Tomar foto',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDottedPreview(Color buttonColor) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(12),
        dashPattern: const [8, 4],
        color: Colors.grey.shade400,
        strokeWidth: 1.5,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.file(imageFile!, fit: BoxFit.contain),
                    if (onRemoveImage != null)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: onRemoveImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onPickFromCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                label: const Text(
                  'Tomar otra foto',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherPreview extends StatelessWidget {
  final File? imageFile;
  final VoidCallback? onRemoveImage;

  const _VoucherPreview({required this.imageFile, this.onRemoveImage});

  @override
  Widget build(BuildContext context) {
    if (imageFile == null) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1E6F2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image_outlined, size: 48, color: Colors.black38),
            SizedBox(height: 8),
            Text('Aún no hay imagen cargada'),
          ],
        ),
      );
    }

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.file(
                  imageFile!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (onRemoveImage != null)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onRemoveImage,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

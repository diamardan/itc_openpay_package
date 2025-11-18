import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itc_openpay_package/itc_openpay_package.dart';

void main() {
  final config = OpenPayConfig.fromEnvironment();
  runApp(
    OpenPayScope(
      config: config,
      child: const OpenPayDemoApp(),
    ),
  );
}

class OpenPayDemoApp extends StatelessWidget {
  const OpenPayDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ITC OpenPay Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

class CourseOption {
  final String id;
  final String name;
  final double price;

  const CourseOption({required this.id, required this.name, required this.price});
}

const List<CourseOption> kCourseCatalog = [
  CourseOption(id: 'prog1', name: 'Programación 1', price: 180),
  CourseOption(id: 'mec1', name: 'Mecánica 1', price: 150),
  CourseOption(id: 'soldadura', name: 'Soldadura industrial', price: 170),
  CourseOption(id: 'refri', name: 'Refrigeración y A/A', price: 160),
  CourseOption(id: 'reposteria', name: 'Repostería', price: 140),
];

class StoreOption {
  final String id;
  final String name;
  final String instructions;

  const StoreOption({required this.id, required this.name, required this.instructions});
}

const List<StoreOption> kStoreOptions = [
  StoreOption(
    id: 'oxxo',
    name: 'OXXO',
    instructions:
        'Acude a tu tienda OXXO más cercana y menciona que realizarás un pago de OpenPay. Presenta la referencia que enviaremos por correo y paga en efectivo. Conserva tu ticket.',
  ),
  StoreOption(
    id: 'seven',
    name: '7-Eleven',
    instructions:
        'Dirígete a cualquier 7-Eleven, proporciona el folio de pago OpenPay y liquida en caja. Recibirás una confirmación al correo registrado.',
  ),
  StoreOption(
    id: 'farmacia',
    name: 'Farmacias del Ahorro',
    instructions:
        'Paga en mostrador indicando tu referencia OpenPay. El comprobante llegará en cuestión de minutos a tu mail.',
  ),
];

enum CheckoutMethod { card, store }

class CourseSelection {
  final String studentName;
  final List<CourseOption> courses;

  const CourseSelection({required this.studentName, required this.courses});

  double get total => courses.fold(0, (sum, course) => sum + course.price);
}

class PaymentSummaryArgs {
  final CourseSelection selection;
  final String tokenId;

  const PaymentSummaryArgs({required this.selection, required this.tokenId});
}

class StoreReferenceArgs {
  final CourseSelection selection;
  final StoreOption store;

  const StoreReferenceArgs({required this.selection, required this.store});
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'course-selection',
      builder: (context, state) => const CourseSelectionPage(),
    ),
    GoRoute(
      path: '/payment',
      name: 'payment',
      builder: (context, state) {
        final selection = state.extra as CourseSelection?;
        if (selection == null) {
          return const FlowErrorPage(message: 'Selecciona cursos antes de continuar.');
        }
        return PaymentMethodPage(selection: selection);
      },
    ),
    GoRoute(
      path: '/summary',
      name: 'summary',
      builder: (context, state) {
        final args = state.extra as PaymentSummaryArgs?;
        if (args == null) {
          return const FlowErrorPage(message: 'Falta la información de pago.');
        }
        return PaymentSummaryPage(args: args);
      },
    ),
    GoRoute(
      path: '/store-reference',
      name: 'store-reference',
      builder: (context, state) {
        final args = state.extra as StoreReferenceArgs?;
        if (args == null) {
          return const FlowErrorPage(message: 'Selecciona una tienda para generar la referencia.');
        }
        return StoreReferencePage(args: args);
      },
    ),
    GoRoute(
      path: '/success',
      name: 'success',
      builder: (context, state) {
        double? amount;
        String? method;
        ChargeModel? charge;

        final extra = state.extra;
        if (extra is Map<String, dynamic>) {
          amount = extra['amount'] as double?;
          method = extra['method'] as String?;
        } else if (extra is ChargeModel) {
          charge = extra;
          amount = extra.amount;
          final chargeMethod = extra.method;
          method = chargeMethod.isEmpty ? 'Cargo tarjeta' : 'Cargo $chargeMethod';
        }

        return PaymentSuccessPage(
          charge: charge,
          amount: amount,
          currency: 'MXN',
          description: 'Pago de cursos seleccionados',
          paymentMethodLabel: method,
          onShare: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compartir comprobante (ejemplo).')),
          ),
          onContinue: () => context.go('/'),
        );
      },
    ),
  ],
);

class CourseSelectionPage extends StatefulWidget {
  const CourseSelectionPage({super.key});

  @override
  State<CourseSelectionPage> createState() => _CourseSelectionPageState();
}

class _CourseSelectionPageState extends State<CourseSelectionPage> {
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedCourseIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _nameController.text.trim().isNotEmpty && _selectedCourseIds.isNotEmpty;

  void _toggleCourse(CourseOption course) {
    setState(() {
      if (_selectedCourseIds.contains(course.id)) {
        _selectedCourseIds.remove(course.id);
      } else {
        _selectedCourseIds.add(course.id);
      }
    });
  }

  void _goToPayment(BuildContext context) {
    if (!_canContinue) return;
    final selectedCourses = kCourseCatalog
        .where((course) => _selectedCourseIds.contains(course.id))
        .toList();
    final selection = CourseSelection(
      studentName: _nameController.text.trim(),
      courses: selectedCourses,
    );
    context.go('/payment', extra: selection);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Inscripción a cursos')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Datos del alumno', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Text('2. Selecciona tus cursos', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final course in kCourseCatalog)
                  FilterChip(
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(course.name),
                        Text('\$${course.price.toStringAsFixed(2)} MXN',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                    selected: _selectedCourseIds.contains(course.id),
                    onSelected: (_) => _toggleCourse(course),
                    selectedColor: theme.colorScheme.primaryContainer,
                    showCheckmark: true,
                  ),
              ],
            ),
            const Spacer(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedCourseIds
                  .map(
                    (id) => Chip(
                      label: Text(kCourseCatalog
                          .firstWhere((course) => course.id == id)
                          .name),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue ? () => _goToPayment(context) : null,
                child: const Text('Siguiente'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodPage extends StatefulWidget {
  final CourseSelection selection;
  const PaymentMethodPage({super.key, required this.selection});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  CheckoutMethod _method = CheckoutMethod.card;
  CardModel? _currentCard;
  bool _isFormValid = false;
  StoreOption? _selectedStore;

  void _handleTokenSuccess(String tokenId) {
    if (!mounted) return;
    final args = PaymentSummaryArgs(selection: widget.selection, tokenId: tokenId);
    context.go('/summary', extra: args);
  }

  void _goToStoreReference() {
    if (_selectedStore == null) return;
    final args = StoreReferenceArgs(selection: widget.selection, store: _selectedStore!);
    context.go('/store-reference', extra: args);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Método de pago')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SelectionSummaryCard(selection: widget.selection),
            const SizedBox(height: 24),
            SegmentedButton<CheckoutMethod>(
              segments: const [
                ButtonSegment(value: CheckoutMethod.card, label: Text('Tarjeta')),
                ButtonSegment(value: CheckoutMethod.store, label: Text('Pago en tienda')),
              ],
              selected: {_method},
              onSelectionChanged: (selection) {
                if (selection.isEmpty) return;
                setState(() => _method = selection.first);
              },
            ),
            const SizedBox(height: 24),
            if (_method == CheckoutMethod.card)
              _buildCardForm(theme)
            else
              _buildStoreOptions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingresa los datos de tu tarjeta', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        CreditCardForm(
          onCardChanged: (card) => setState(() => _currentCard = card),
          onValidityChanged: (isValid) => setState(() => _isFormValid = isValid),
          showAddress: false,
        ),
        const SizedBox(height: 24),
        _currentCard != null && _isFormValid
            ? TokenizeButton(
                card: _currentCard!,
                buttonText: 'Confirmar pago',
                onSuccess: _handleTokenSuccess,
                onError: (message) => ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(message))),
                onProcessing: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Generando token de tu tarjeta...'),
                    duration: Duration(milliseconds: 1200),
                  ),
                ),
              )
            : const SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null,
                  child: Text('Confirmar pago'),
                ),
              ),
      ],
    );
  }

  Widget _buildStoreOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selecciona la tienda donde pagarás', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        ...kStoreOptions.map(
          (store) => Card(
            child: ListTile(
              leading: Icon(
                _selectedStore?.id == store.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(store.name),
              subtitle: Text(
                store.instructions,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => setState(() => _selectedStore = store),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _selectedStore == null ? null : _goToStoreReference,
            icon: const Icon(Icons.storefront),
            label: const Text('Generar referencia'),
          ),
        ),
      ],
    );
  }
}

class PaymentSummaryPage extends StatefulWidget {
  final PaymentSummaryArgs args;
  const PaymentSummaryPage({super.key, required this.args});

  @override
  State<PaymentSummaryPage> createState() => _PaymentSummaryPageState();
}

class _PaymentSummaryPageState extends State<PaymentSummaryPage> {
  bool _isProcessing = false;

  Future<void> _simulateBackendProcessing() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    setState(() => _isProcessing = false);
    context.go('/success', extra: {
      'amount': widget.args.selection.total,
      'method': 'Token ${widget.args.tokenId.substring(0, 6)}...'
    });
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.args.selection;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Resumen antes de pagar')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alumno', style: theme.textTheme.titleMedium),
            Text(selection.studentName,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            Text('Cursos seleccionados', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: selection.courses.length + 1,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  if (index == selection.courses.length) {
                    return ListTile(
                      title: const Text('Total'),
                      trailing: Text('\$${selection.total.toStringAsFixed(2)} MXN',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    );
                  }
                  final course = selection.courses[index];
                  return ListTile(
                    title: Text(course.name),
                    trailing: Text('\$${course.price.toStringAsFixed(2)} MXN'),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text('Token generado', style: theme.textTheme.titleMedium),
            Text(widget.args.tokenId,
                style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'monospace')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isProcessing ? null : _simulateBackendProcessing,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isProcessing ? 'Procesando...' : 'Procesar pago'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlowErrorPage extends StatelessWidget {
  final String message;
  const FlowErrorPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionSummaryCard extends StatelessWidget {
  final CourseSelection selection;
  const _SelectionSummaryCard({required this.selection});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alumno', style: theme.textTheme.titleMedium),
            Text(selection.studentName,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Cursos (${selection.courses.length})', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selection.courses
                  .map((course) => Chip(label: Text(course.name)))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total estimado'),
                Text('\$${selection.total.toStringAsFixed(2)} MXN',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StoreReferencePage extends StatelessWidget {
  final StoreReferenceArgs args;
  const StoreReferencePage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Referencia de pago en tienda')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alumno', style: theme.textTheme.titleMedium),
            Text(
              args.selection.studentName,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Tienda seleccionada', style: theme.textTheme.titleMedium),
            Text(args.store.name, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            Text('Cursos incluidos', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  ...args.selection.courses.map(
                    (course) => ListTile(
                      title: Text(course.name),
                      trailing: Text('\$${course.price.toStringAsFixed(2)} MXN'),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Total a pagar'),
                    trailing: Text(
                      '\$${args.selection.total.toStringAsFixed(2)} MXN',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Instrucciones', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: SingleChildScrollView(
                child: Text(args.store.instructions),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Listo, volver al inicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

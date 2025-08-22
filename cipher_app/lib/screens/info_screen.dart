import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/info_provider.dart';
import '../widgets/carousel/info_carousel.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger data load when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InfoProvider>().loadInfoItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informações')),
      body: Consumer<InfoProvider>(
        builder: (context, infoProvider, child) {
          if (infoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: infoProvider.refresh,
            child: infoProvider.infoItems.isEmpty
                ? const Center(child: Text('Nenhuma informação disponível'))
                : CarouselInfo(items: infoProvider.infoItems),
          );
        },
      ),
    );
  }
}

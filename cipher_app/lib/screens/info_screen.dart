import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/info_provider.dart';
import '../widgets/carousel/carousel_info.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen>
    with AutomaticKeepAliveClientMixin {
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true;

  void _loadDataIfNeeded() {
    if (!_hasInitialized && mounted) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<InfoProvider>().loadInfo();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _loadDataIfNeeded(); // Only load when screen is visible

    return Consumer<InfoProvider>(
      builder: (context, infoProvider, child) {
        if (infoProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (infoProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Erro: ${infoProvider.error}'),
                ElevatedButton(
                  onPressed: () => infoProvider.refresh(),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CarouselInfo(
            items: infoProvider.infoItems,
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight -
                MediaQuery.of(context).padding.bottom,
          ),
        );
      },
    );
  }
}

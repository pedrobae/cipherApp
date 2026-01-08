import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:cordis/models/domain/info_item.dart';
import '../info/info_card.dart';

class CarouselInfo extends StatelessWidget {
  final List<InfoItem> items;
  final double height;

  const CarouselInfo({super.key, required this.items, this.height = 200.0});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Nenhuma informação disponível'),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: CarouselSlider.builder(
        itemCount: items.length,
        itemBuilder: (context, index, realIndex) {
          // Add bounds checking
          if (index >= items.length || index < 0) {
            return const SizedBox.shrink();
          }

          try {
            return InfoCard(item: items[index]);
          } catch (e) {
            debugPrint('Error building carousel item at index $index: $e');
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Center(child: Text('Erro ao carregar item')),
            );
          }
        },
        options: CarouselOptions(
          disableCenter: true,
          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
          height: height,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          enlargeCenterPage: true,
          enlargeFactor: 0.25,
          viewportFraction: 0.9,
          padEnds: true,
          enableInfiniteScroll: true,
        ),
      ),
    );
  }
}

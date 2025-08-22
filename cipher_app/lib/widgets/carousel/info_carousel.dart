import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:cipher_app/models/domain/info_item.dart';
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
        child: const Center(child: Text('No information available')),
      );
    }

    return CarouselSlider.builder(
      itemCount: items.length,
      itemBuilder: (context, index, realIndex) {
        return InfoCard(item: items[index]);
      },
      options: CarouselOptions(
        height: height,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        autoPlayInterval: const Duration(seconds: 5),
      ),
    );
  }
}

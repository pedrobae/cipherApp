import 'package:flutter/material.dart';
import '../widgets/carousel/info_carousel.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselInfo(items: items);
  }
}

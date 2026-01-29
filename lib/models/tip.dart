import 'package:dart_mappable/dart_mappable.dart';

part 'tip.mapper.dart';

@MappableClass()
class Tip with TipMappable {
  final String id;
  final String text;
  final String? author; // e.g., "Gabby Beckford" or null for general tips
  final bool isActive;

  Tip({
    required this.id,
    required this.text,
    this.author,
    this.isActive = true,
  });
}

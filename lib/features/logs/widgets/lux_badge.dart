import 'package:flutter/material.dart';
import 'package:adventure_logger/core/services/sensor_service.dart';

class LuxBadge extends StatelessWidget {
  final double lux;
  const LuxBadge({super.key, required this.lux});

  @override
  Widget build(BuildContext context) {
    final condition = SensorService.classify(lux);
    final (color, icon) = _style(condition);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            lux < 0
                ? 'N/A'
                : '${lux.toStringAsFixed(0)} lx',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _style(LightCondition c) => switch (c) {
        LightCondition.bright => (Colors.amber.shade700, Icons.wb_sunny),
        LightCondition.moderate =>
          (Colors.orange.shade600, Icons.wb_cloudy_outlined),
        LightCondition.dim =>
          (Colors.blueGrey.shade600, Icons.nights_stay_outlined),
        LightCondition.dark => (Colors.indigo.shade700, Icons.dark_mode),
      };
}

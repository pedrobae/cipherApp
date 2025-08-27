import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDangerous;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isLoading = false,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDangerous ? Colors.red : null;
    
    return Card(
      child: ListTile(
        leading: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            : Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: isDangerous ? FontWeight.w600 : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isLoading ? null : const Icon(Icons.chevron_right),
        onTap: isLoading ? null : onTap,
        enabled: !isLoading,
      ),
    );
  }
}

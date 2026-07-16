import 'package:flutter/material.dart';

class ConfiguracoesSectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const ConfiguracoesSectionTitle({
    super.key,
    required this.title,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF2E5B94),
        ),
      ),
    );
  }
}

class ConfiguracoesCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const ConfiguracoesCard({
    super.key,
    required this.children,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class ConfiguracoesOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDark;

  const ConfiguracoesOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white : const Color(0xFF2E5B94),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey.shade700,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
      onTap: onTap,
    );
  }
}

class ConfiguracoesSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const ConfiguracoesSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: isDark ? Colors.white : const Color(0xFF2E5B94),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey.shade700,
        ),
      ),
      value: value,
      activeColor: const Color(0xFF2E5B94),
      onChanged: onChanged,
    );
  }
}

class ConfiguracoesDropdownTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const ConfiguracoesDropdownTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2E5B94),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

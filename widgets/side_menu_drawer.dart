import 'package:flutter/material.dart';
import '../screens/sobre.dart';
import '../screens/ecra_ajuda.dart';
import '../screens/catalogo_badges.dart';
import '../screens/ecra_login.dart';

class SideMenuDrawer extends StatelessWidget {
  final String username;
  const SideMenuDrawer({super.key, this.username = 'Marco Paulo'});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFF3E5F5),
                    child:
                        Icon(Icons.person, color: Color(0xFF9C27B0), size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      username,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E5B94)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(context, Icons.home_outlined, 'Home', true),
            _buildMenuItem(
                context, Icons.badge_outlined, 'Catálogo de Badges', false,
                onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CatalogoBadgesScreen()));
            }),
            _buildMenuItem(context, Icons.bar_chart, 'Rankings', false),
            _buildMenuItem(
                context, Icons.folder_outlined, 'Candidaturas', false),
            _buildMenuItem(
                context, Icons.settings_outlined, 'Configurações', false),
            _buildMenuItem(context, Icons.logout, 'Terminar Sessão', false,
                onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            }),
            const Spacer(),
            const Divider(),
            _buildMenuItem(context, Icons.info_outline, 'Sobre', false,
                onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()));
            }),
            _buildMenuItem(context, Icons.help_outline, 'Ajuda', false,
                onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HelpScreen()));
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, bool isSelected,
      {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2E5B94) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black87,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (onTap != null) {
            onTap();
          }
        },
      ),
    );
  }
}

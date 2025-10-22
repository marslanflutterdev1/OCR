import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = [
      {
        "icon": Icons.language,
        "title": "Language",
        "onTap": () {},
      },
      {
        "icon": Icons.privacy_tip_outlined,
        "title": "Privacy",
        "onTap": () {},
      },
      {
        "icon": Icons.description_outlined,
        "title": "Terms & Conditions",
        "onTap": () {},
      },
      {
        "icon": Icons.star_rate_rounded,
        "title": "Rate Us",
        "onTap": () {},
      },
      {
        "icon": Icons.support_agent_outlined,
        "title": "Contact Support",
        "onTap": () {},
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xffF6F7FC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: settings.length,
            separatorBuilder: (context, index) =>  Divider(
              color: Colors.black.withOpacity(0.1),
              height: 4,
            ),
            itemBuilder: (context, index) {
              final item = settings[index];
              return _buildSettingTile(
                icon: item["icon"] as IconData,
                title: item["title"] as String,
                onTap: item["onTap"] as VoidCallback,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: Colors.black87, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../auth/login.dart';
import 'settings_provider.dart';
import '../profile_page.dart'; // 👈 trang thông tin tài khoản

// import file i18n đã generate trong lib/l10n
import 'package:chitieu/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _openProfileOrLogin(BuildContext context) async {
    final auth = context.read<AuthProvider>();

    if (!auth.isAuthenticated) {
      // mở trang đăng nhập trước
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );

      // nếu đăng nhập xong thì mở luôn trang hồ sơ
      if (!context.mounted) return;
      if (context.read<AuthProvider>().isAuthenticated) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
      }
    } else {
      // đã đăng nhập → mở trang hồ sơ
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;       // lấy text theo ngôn ngữ
    final auth = context.watch<AuthProvider>();    // theo dõi trạng thái đăng nhập
    final settings = context.watch<SettingsProvider>(); // theo dõi cài đặt theme, locale, text scale
    final name = auth.user?['name'] ?? '';         // tên người dùng

    // danh sách màu chủ đạo -> MaterialColor
    const seedPalette = <MaterialColor>[
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.amber,
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // chừa chỗ cho FAB + BottomAppBar
          children: [
            // ======================
            // Header (tên + avatar) -> bấm để mở hồ sơ / đăng nhập
            // ======================
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openProfileOrLogin(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 32, backgroundColor: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        name.isNotEmpty ? name : t.userNamePlaceholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // hiển thị mũi tên nếu đã đăng nhập, biểu tượng đăng nhập nếu chưa
                    Icon(
                      auth.isAuthenticated ? Icons.arrow_forward_ios : Icons.login,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ======================
            // Ngôn ngữ
            // ======================
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(t.language),
              trailing: DropdownButton<Locale>(
                value: settings.locale,
                items: const [
                  DropdownMenuItem(value: Locale('vi'), child: Text('Tiếng Việt')),
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                ],
                onChanged: (v) {
                  if (v != null) context.read<SettingsProvider>().setLocale(v);
                },
              ),
            ),
            const Divider(),

            // ======================
            // Sáng / Tối
            // ======================
            SwitchListTile(
              title: Text(t.brightness),
              value: settings.themeMode == ThemeMode.light,
              onChanged: (isLight) =>
                  context.read<SettingsProvider>().toggleTheme(isLight),
            ),
            const Divider(),

            // ======================
            // Màu chủ đạo
            // ======================
            ListTile(
              title: Text(t.color),
              subtitle: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final MaterialColor c in seedPalette)
                    InkWell(
                      onTap: () => context.read<SettingsProvider>().setSeed(c),
                      child: CircleAvatar(backgroundColor: c, radius: 14),
                    ),
                ],
              ),
            ),
            const Divider(),

            // ======================
            // Cỡ chữ
            // ======================
            ListTile(
              title: Text(t.fontSize),
              trailing: DropdownButton<String>(
                value: settings.textScale == 0.9
                    ? 'small'
                    : (settings.textScale == 1.15 ? 'large' : 'normal'),
                items: [
                  DropdownMenuItem(value: 'small', child: Text(t.fontSmall)),
                  DropdownMenuItem(value: 'normal', child: Text(t.fontNormal)),
                  DropdownMenuItem(value: 'large', child: Text(t.fontLarge)),
                ],
                onChanged: (v) {
                  if (v == 'small') {
                    context.read<SettingsProvider>().setTextScale(0.9);
                  } else if (v == 'large') {
                    context.read<SettingsProvider>().setTextScale(1.2);
                  } else {
                    context.read<SettingsProvider>().setTextScale(1.0);
                  }
                },
              ),
            ),
            const Divider(),

            // ======================
            // Đổi mật khẩu
            // ======================
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: OutlinedButton(
                onPressed: () {
                  // TODO: mở form đổi mật khẩu
                },
                child: Text(t.changePassword),
              ),
            ),

            // ======================
            // Thông tin ứng dụng
            // ======================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.apartment_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TrọPay',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            Text(
                              'Quản lý Chi tiêu Phòng trọ & Quỹ sinh viên',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Phiên bản đồ án',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('1.0.0 (BTL Lập trình di động)',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ======================
            // Điều lệ & Bảo mật
            // ======================
            ListTile(
              title: Text(t.policy),
              trailing: TextButton(
                onPressed: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'TrọPay',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.apartment_rounded,
                        color: Color(0xFF2563EB), size: 36),
                    children: const [
                      Text(
                          'Ứng dụng hỗ trợ sinh viên quản lý quỹ phòng trọ, chia tiền hóa đơn thông minh và trợ lý ảo giọng nói AI.'),
                    ],
                  );
                },
                child: Text(t.view),
              ),
            ),

            // Spacer cuối chống tràn
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

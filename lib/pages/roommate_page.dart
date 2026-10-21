import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../roommate/roommate_provider.dart';
import '../roommate/roommate_model.dart';

class RoommatePage extends StatefulWidget {
  const RoommatePage({super.key});

  @override
  State<RoommatePage> createState() => _RoommatePageState();
}

class _RoommatePageState extends State<RoommatePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _fmt = NumberFormat.decimalPattern('vi_VN');
  String _selectedCategoryFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatVn(num v) => '${_fmt.format(v.round())} ₫';

  void _openQuickPaySheet(
      BuildContext context, DebtRecord debt, RoommateProvider prov) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickPaySheet(debt: debt, prov: prov),
    );
  }

  Widget _buildFilterChip(String catKey, String label) {
    final isSelected = _selectedCategoryFilter == catKey;
    return InkWell(
      onTap: () => setState(() => _selectedCategoryFilter = catKey),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<RoommateProvider>();
    final fund = prov.fund;
    final totalIOwe = prov.totalIOwe;
    final totalOwedToMe = prov.totalOwedToMe;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.apartment_rounded,
                  color: Color(0xFF60A5FA), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fund?.name ?? 'Phòng trọ sinh viên',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Mã phòng: ${fund?.roomCode ?? "P304"} • ${prov.members.length} thành viên',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Chia hóa đơn mới',
            icon: const Icon(Icons.post_add_rounded, color: Color(0xFF38BDF8)),
            onPressed: () => _openCreateBillSheet(context),
          ),
          IconButton(
            tooltip: 'Thêm bạn cùng phòng',
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => _openAddMemberSheet(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF38BDF8),
          indicatorWeight: 3,
          labelColor: const Color(0xFF38BDF8),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long_rounded, size: 20), text: 'Chia tiền'),
            Tab(icon: Icon(Icons.savings_rounded, size: 20), text: 'Quỹ phòng'),
            Tab(icon: Icon(Icons.group_rounded, size: 20), text: 'Thành viên'),
          ],
        ),
      ),
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Thẻ tổng quan nợ nần sinh viên
                _buildDebtSummaryHeader(totalIOwe, totalOwedToMe),

                // Nội dung các Tab
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBillsTab(context, prov),
                      _buildFundTab(context, prov),
                      _buildMembersTab(context, prov),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ============================================================
  // HEADER TỔNG QUAN NỢ NẦN
  // ============================================================
  Widget _buildDebtSummaryHeader(double totalIOwe, double totalOwedToMe) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Bạn nợ
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: totalIOwe > 0
                      ? const Color(0xFFEF4444).withOpacity(0.5)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_upward_rounded,
                          size: 14,
                          color: totalIOwe > 0
                              ? const Color(0xFFF87171)
                              : Colors.white54),
                      const SizedBox(width: 4),
                      const Text(
                        'Bạn cần trả',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatVn(totalIOwe),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: totalIOwe > 0
                          ? const Color(0xFFF87171)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Mọi người nợ bạn
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: totalOwedToMe > 0
                      ? const Color(0xFF10B981).withOpacity(0.5)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_downward_rounded,
                          size: 14,
                          color: totalOwedToMe > 0
                              ? const Color(0xFF34D399)
                              : Colors.white54),
                      const SizedBox(width: 4),
                      const Text(
                        'Bạn sẽ nhận',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatVn(totalOwedToMe),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: totalOwedToMe > 0
                          ? const Color(0xFF34D399)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 1: DANH SÁCH HÓA ĐƠN CHIA TIỀN & AI NỢ AI
  // ============================================================
  Widget _buildBillsTab(BuildContext context, RoommateProvider prov) {
    final bills = prov.bills;
    final debtsIOwe = prov.debtsIOwe;
    final debtsOthersOweMe = prov.debtsOthersOweMe;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      children: [
        // Khoản nợ cần thanh toán gấp
        if (debtsIOwe.isNotEmpty || debtsOthersOweMe.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payments_rounded,
                        color: Colors.amber.shade900, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tóm tắt nợ nần phòng trọ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.amber.shade900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (debtsIOwe.isNotEmpty) ...[
                  const Text('Bạn cần chuyển khoản cho:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  ...debtsIOwe.map((d) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('• ${d.toName} (${d.billTitle}):',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                            Text(_formatVn(d.amount),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red)),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _openQuickPaySheet(context, d, prov),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.qr_code_rounded, size: 13, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text('Trả nợ QR',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                ],
                if (debtsOthersOweMe.isNotEmpty) ...[
                  const Text('Các bạn cần gửi lại bạn:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  ...debtsOthersOweMe.map((d) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('• ${d.fromName} (${d.billTitle}):',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                            Text(_formatVn(d.amount),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green)),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 2),
                                    content: Text('Đã sao chép tin nhắn nhắc nợ: "Alo ${d.fromName} ơi, gửi giúp mình ${_formatVn(d.amount)} tiền ${d.billTitle} phòng 304 nha!"'),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.chat_bubble_outline_rounded, size: 13, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text('Nhắc nợ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Lọc danh mục hóa đơn
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('all', 'Tất cả (${bills.length})'),
              const SizedBox(width: 8),
              _buildFilterChip('electric', '⚡ Tiền điện'),
              const SizedBox(width: 8),
              _buildFilterChip('water', '💧 Tiền nước'),
              const SizedBox(width: 8),
              _buildFilterChip('internet', '🌐 Wifi'),
              const SizedBox(width: 8),
              _buildFilterChip('room', '🏠 Tiền phòng'),
              const SizedBox(width: 8),
              _buildFilterChip('other', '🛒 Khác'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hóa đơn chung',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Text(
                  '${_selectedCategoryFilter == "all" ? bills.length : bills.where((b) => b.category == _selectedCategoryFilter).length} hóa đơn',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _openCreateBillSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 1,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add_card_rounded, size: 16),
              label: const Text(
                'Tạo hóa đơn',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (bills.isEmpty || (_selectedCategoryFilter != 'all' && bills.where((b) => b.category == _selectedCategoryFilter).isEmpty))
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.receipt_rounded,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                const Text('Không có hóa đơn nào phù hợp',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                const Text('Bấm nút bên dưới để tạo hóa đơn đầu tiên!',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          )
        else
          ...bills
              .where((b) =>
                  _selectedCategoryFilter == 'all' ||
                  b.category == _selectedCategoryFilter)
              .map((bill) => _buildBillCard(context, bill, prov)),
      ],
    );
  }

  Widget _buildBillCard(
      BuildContext context, BillSplitItem bill, RoommateProvider prov) {
    IconData getCatIcon(String? cat) {
      switch (cat) {
        case 'electric':
          return Icons.bolt_rounded;
        case 'water':
          return Icons.water_drop_rounded;
        case 'internet':
          return Icons.wifi_rounded;
        case 'room':
          return Icons.home_rounded;
        default:
          return Icons.shopping_bag_rounded;
      }
    }

    Color getCatColor(String? cat) {
      switch (cat) {
        case 'electric':
          return Colors.amber.shade700;
        case 'water':
          return Colors.blue.shade600;
        case 'internet':
          return Colors.purple.shade600;
        case 'room':
          return Colors.indigo.shade600;
        default:
          return Colors.teal.shade600;
      }
    }

    final catColor = getCatColor(bill.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: catColor.withOpacity(0.15),
          child: Icon(getCatIcon(bill.category), color: catColor, size: 22),
        ),
        title: Text(
          bill.title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: Text(
          'Đã trả bởi ${bill.payerName} • ${_formatVn(bill.totalAmount)}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatVn(bill.amountPerPerson),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.blue.shade700,
              ),
            ),
            Text(
              '/ người (${bill.participantIds.length})',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Chi tiết phần chia của từng bạn:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 18, color: Colors.red),
                      tooltip: 'Xóa hóa đơn',
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: Text('Xóa hóa đơn "${bill.title}"?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Hủy')),
                              FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Xóa')),
                            ],
                          ),
                        );
                        if (ok == true) prov.deleteBill(bill.id);
                      },
                    ),
                  ],
                ),
                ...bill.participantIds.map((pId) {
                  final isPayer = pId == bill.payerId;
                  final isSettled = bill.isSettledBy(pId);
                  final member = prov.members.firstWhere(
                    (m) => m.id == pId,
                    orElse: () => RoommateMember(
                      id: pId,
                      name: 'Thành viên',
                      avatarColor: 0xFF9E9E9E,
                      joinedAt: DateTime.now(),
                    ),
                  );
                  final share = bill.shares[pId] ?? bill.amountPerPerson;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSettled
                          ? Colors.green.shade50
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Color(member.avatarColor),
                          child: Text(
                            member.name[0],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isPayer ? '${member.name} (Đã thanh toán)' : member.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isPayer ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          _formatVn(share),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        if (isPayer)
                          const Chip(
                            labelPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            label: Text('Người trả',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white)),
                            backgroundColor: Colors.blue,
                          )
                        else
                          InkWell(
                            onTap: () => prov.toggleSettleShare(
                              billId: bill.id,
                              memberId: pId,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSettled
                                    ? Colors.green.shade600
                                    : Colors.orange.shade600,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSettled
                                        ? Icons.check_circle_rounded
                                        : Icons.schedule_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isSettled ? 'Đã trả' : 'Chưa trả',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 2: QUỸ CHUNG PHÒNG TRỌ (ROOM FUND)
  // ============================================================
  Widget _buildFundTab(BuildContext context, RoommateProvider prov) {
    final fund = prov.fund;
    final txs = prov.fundTxs;
    final balance = fund?.balance ?? 0;
    final target = fund?.monthlyTargetPerMember ?? 150000;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      children: [
        // Thẻ quỹ lớn
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fund?.name ?? 'Quỹ phòng trọ',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Mục tiêu: ${_formatVn(target)}/người/tháng',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _formatVn(balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Đóng quỹ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => _openContributeFundSheet(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white12,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      label: const Text('Chi từ quỹ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => _openSpendFundSheet(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // Thống kê nhanh thu chi quỹ
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng thu quỹ:',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF047857),
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '+${_formatVn(txs.where((t) => t.type == "deposit").fold<double>(0, (s, t) => s + t.amount))}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF065F46)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng đã chi:',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB91C1C),
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '-${_formatVn(txs.where((t) => t.type == "spend").fold<double>(0, (s, t) => s + t.amount))}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF991B1B)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        const Text(
          'Lịch sử thu chi quỹ phòng',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),

        if (txs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text('Chưa có lịch sử thu chi quỹ phòng',
                  style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...txs.map((tx) {
            final isDeposit = tx.type == 'deposit';
            final color = isDeposit
                ? const Color(0xFF059669)
                : const Color(0xFFDC2626);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 1)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withOpacity(0.12),
                    child: Icon(
                      isDeposit
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        Text(
                          '${tx.memberName} • ${DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt)}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isDeposit ? "+" : "-"}${_formatVn(tx.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ============================================================
  // TAB 3: DANH SÁCH BẠN CÙNG PHÒNG
  // ============================================================
  Widget _buildMembersTab(BuildContext context, RoommateProvider prov) {
    final members = prov.members;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thành viên (${members.length} người)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm bạn'),
              onPressed: () => _openAddMemberSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...members.map((m) {
          final idx = members.indexOf(m);
          final role = idx == 0
              ? 'Trưởng phòng 👑'
              : (idx == 1 ? 'Thủ quỹ 💰' : 'Thành viên 🏠');
          final roleColor = idx == 0
              ? const Color(0xFF2563EB)
              : (idx == 1 ? const Color(0xFF059669) : const Color(0xFF64748B));

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3,
                    offset: Offset(0, 1)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(m.avatarColor),
                  child: Text(
                    m.name[0],
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              m.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (m.isMe) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('Bạn',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              role,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: roleColor),
                            ),
                          ),
                          if (m.nickname?.isNotEmpty == true) ...[
                            const SizedBox(width: 6),
                            Text('• ${m.nickname}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black54)),
                          ],
                        ],
                      ),
                      if (m.phone?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text('SĐT: ${m.phone}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Gửi tin nhắn Zalo',
                  icon: const Icon(Icons.chat_rounded,
                      color: Color(0xFF0068FF), size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 2),
                        content: Text('Đã mở liên hệ Zalo cho bạn ${m.name} (${m.phone ?? "P304"})'),
                      ),
                    );
                  },
                ),
                if (!m.isMe)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                          color: Colors.grey, size: 20),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: Text(
                                'Xóa bạn "${m.name}" khỏi danh sách phòng?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Hủy')),
                              FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Xóa')),
                            ],
                          ),
                        );
                        if (ok == true) prov.removeMember(m.id);
                      },
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ============================================================
  // FORM BOTTOM SHEETS
  // ============================================================

  void _openCreateBillSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateBillSheet(),
    );
  }

  void _openAddMemberSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMemberSheet(),
    );
  }

  void _openContributeFundSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ContributeFundSheet(),
    );
  }

  void _openSpendFundSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SpendFundSheet(),
    );
  }
}

// ============================================================
// MODAL: TẠO HÓA ĐƠN CHIA TIỀN MỚI
// ============================================================
class _CreateBillSheet extends StatefulWidget {
  const _CreateBillSheet();

  @override
  State<_CreateBillSheet> createState() => _CreateBillSheetState();
}

class _CreateBillSheetState extends State<_CreateBillSheet> {
  final _titleCtl = TextEditingController();
  final _amountCtl = TextEditingController();
  final _noteCtl = TextEditingController();

  String? _selectedPayerId;
  String _category = 'room';
  final Set<String> _selectedParticipants = {};

  final categories = const [
    {'id': 'room', 'name': 'Tiền phòng trọ', 'icon': Icons.home_rounded},
    {'id': 'electric', 'name': 'Tiền điện', 'icon': Icons.bolt_rounded},
    {'id': 'water', 'name': 'Tiền nước', 'icon': Icons.water_drop_rounded},
    {'id': 'internet', 'name': 'Mạng Internet', 'icon': Icons.wifi_rounded},
    {'id': 'food', 'name': 'Ăn uống chung', 'icon': Icons.restaurant_rounded},
    {'id': 'other', 'name': 'Đồ dùng chung', 'icon': Icons.shopping_bag_rounded},
  ];

  @override
  void initState() {
    super.initState();
    final prov = context.read<RoommateProvider>();
    _selectedPayerId = prov.me?.id ?? (prov.members.isNotEmpty ? prov.members.first.id : null);
    _selectedParticipants.addAll(prov.members.map((m) => m.id));
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _amountCtl.dispose();
    _noteCtl.dispose();
    super.dispose();
  }

  double _parseAmount(String s) {
    final cleaned = s.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  void _submit() {
    final title = _titleCtl.text.trim();
    final amount = _parseAmount(_amountCtl.text);

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên hóa đơn.')),
      );
      return;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền > 0.')),
      );
      return;
    }

    if (_selectedPayerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn người đã thanh toán.')),
      );
      return;
    }

    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 bạn cùng chia tiền.')),
      );
      return;
    }

    context.read<RoommateProvider>().addBill(
          title: title,
          totalAmount: amount,
          payerId: _selectedPayerId!,
          participantIds: _selectedParticipants.toList(),
          category: _category,
          note: _noteCtl.text.trim(),
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã tạo hóa đơn chia tiền thành công!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<RoommateProvider>();
    final members = prov.members;

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tạo Hóa Đơn Chia Tiền Phòng Trọ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),

            // Danh mục
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories.map((c) {
                  final sel = _category == c['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: sel,
                      label: Text(c['name'] as String),
                      avatar: Icon(c['icon'] as IconData,
                          size: 16,
                          color: sel ? Colors.white : Colors.black87),
                      selectedColor: const Color(0xFF2563EB),
                      labelStyle: TextStyle(
                        color: sel ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() {
                        _category = c['id'] as String;
                        if (_titleCtl.text.isEmpty) {
                          _titleCtl.text = c['name'] as String;
                        }
                      }),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _titleCtl,
              decoration: const InputDecoration(
                labelText: 'Tên khoản chi / hóa đơn *',
                hintText: 'Ví dụ: Tiền điện tháng 10, Ăn lẩu...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _amountCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tổng số tiền (VNĐ) *',
                hintText: 'Ví dụ: 800000',
                border: OutlineInputBorder(),
                isDense: true,
                suffixText: '₫',
              ),
            ),
            const SizedBox(height: 14),

            // Người trả tiền
            DropdownButtonFormField<String>(
              value: _selectedPayerId,
              decoration: const InputDecoration(
                labelText: 'Ai là người đã trả tiền trước? *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: members.map((m) {
                return DropdownMenuItem(
                  value: m.id,
                  child: Text('${m.name} ${m.isMe ? "(Tôi)" : ""}'),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedPayerId = v),
            ),
            const SizedBox(height: 14),

            // Chọn người cùng chia
            const Text(
              'Những ai cùng chia tiền khoản này? (Mặc định cả phòng)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: members.map((m) {
                final checked = _selectedParticipants.contains(m.id);
                return FilterChip(
                  selected: checked,
                  label: Text(m.name),
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue.shade800,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedParticipants.add(m.id);
                      } else {
                        if (_selectedParticipants.length > 1) {
                          _selectedParticipants.remove(m.id);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _noteCtl,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
                hintText: 'Số điện/nước, địa chỉ...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 20),

            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _submit,
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Lưu & Chia tiền cho cả phòng',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MODAL: THÊM THÀNH VIÊN MỚI
// ============================================================
class _AddMemberSheet extends StatefulWidget {
  const _AddMemberSheet();

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _nameCtl = TextEditingController();
  final _nicknameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();

  @override
  void dispose() {
    _nameCtl.dispose();
    _nicknameCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên bạn cùng phòng.')),
      );
      return;
    }

    context.read<RoommateProvider>().addMember(
          name: name,
          nickname: _nicknameCtl.text.trim(),
          phone: _phoneCtl.text.trim(),
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Đã thêm "$name" vào phòng!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Thêm Bạn Cùng Phòng Trọ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nameCtl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Họ và tên *',
              hintText: 'Ví dụ: Nguyễn Văn A',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nicknameCtl,
            decoration: const InputDecoration(
              labelText: 'Biệt danh (tùy chọn)',
              hintText: 'Ví dụ: A Béo, A Bách Khoa...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại (tùy chọn)',
              hintText: '09xxxxxxxx',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _submit,
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Thêm vào phòng',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MODAL: ĐÓNG QUỸ PHÒNG
// ============================================================
class _ContributeFundSheet extends StatefulWidget {
  const _ContributeFundSheet();

  @override
  State<_ContributeFundSheet> createState() => _ContributeFundSheetState();
}

class _ContributeFundSheetState extends State<_ContributeFundSheet> {
  final _amountCtl = TextEditingController(text: '150000');
  final _noteCtl = TextEditingController(text: 'Đóng quỹ tháng');
  String? _selectedMemberId;

  @override
  void initState() {
    super.initState();
    final prov = context.read<RoommateProvider>();
    _selectedMemberId = prov.me?.id ?? (prov.members.isNotEmpty ? prov.members.first.id : null);
  }

  @override
  void dispose() {
    _amountCtl.dispose();
    _noteCtl.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _amountCtl.text.replaceAll(RegExp(r'[^\d]'), '');
    final amount = double.tryParse(raw) ?? 0;

    if (amount <= 0 || _selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ.')),
      );
      return;
    }

    context.read<RoommateProvider>().contributeToFund(
          memberId: _selectedMemberId!,
          amount: amount,
          note: _noteCtl.text.trim(),
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã ghi nhận đóng quỹ phòng!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<RoommateProvider>();

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Đóng Tiền Quỹ Phòng Trọ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),

          DropdownButtonFormField<String>(
            value: _selectedMemberId,
            decoration: const InputDecoration(
              labelText: 'Thành viên đóng quỹ',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: prov.members.map((m) {
              return DropdownMenuItem(
                value: m.id,
                child: Text('${m.name} ${m.isMe ? "(Tôi)" : ""}'),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedMemberId = v),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _amountCtl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Số tiền đóng (VNĐ)',
              border: OutlineInputBorder(),
              isDense: true,
              suffixText: '₫',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _noteCtl,
            decoration: const InputDecoration(
              labelText: 'Ghi chú',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 20),

          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _submit,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Xác nhận đóng quỹ',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MODAL: CHI TỪ QUỸ PHÒNG
// ============================================================
class _SpendFundSheet extends StatefulWidget {
  const _SpendFundSheet();

  @override
  State<_SpendFundSheet> createState() => _SpendFundSheetState();
}

class _SpendFundSheetState extends State<_SpendFundSheet> {
  final _amountCtl = TextEditingController();
  final _titleCtl = TextEditingController();

  @override
  void dispose() {
    _amountCtl.dispose();
    _titleCtl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtl.text.trim();
    final raw = _amountCtl.text.replaceAll(RegExp(r'[^\d]'), '');
    final amount = double.tryParse(raw) ?? 0;

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên khoản chi và số tiền.')),
      );
      return;
    }

    context.read<RoommateProvider>().spendFromFund(
          amount: amount,
          title: title,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã ghi nhận khoản chi từ quỹ phòng!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Chi Tiền Từ Quỹ Phòng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),

          TextField(
            controller: _titleCtl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Khoản chi dùng cho việc gì? *',
              hintText: 'Ví dụ: Mua nước lau sàn, Thay bóng đèn...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _amountCtl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Số tiền chi (VNĐ) *',
              border: OutlineInputBorder(),
              isDense: true,
              suffixText: '₫',
            ),
          ),
          const SizedBox(height: 20),

          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _submit,
            icon: const Icon(Icons.shopping_bag_rounded),
            label: const Text('Xác nhận chi từ quỹ',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MODAL: THANH TOÁN CHUYỂN KHOẢN VIETQR TRẢ NỢ PHÒNG TRỌ
// ============================================================
class _QuickPaySheet extends StatelessWidget {
  final DebtRecord debt;
  final RoommateProvider prov;

  const _QuickPaySheet({required this.debt, required this.prov});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('vi_VN');
    final amountStr = '${fmt.format(debt.amount.round())} ₫';

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.qr_code_2_rounded,
                      color: Color(0xFF2563EB), size: 24),
                  SizedBox(width: 8),
                  Text('Thanh toán Chuyển khoản QR',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Thẻ VietQR Mockup
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('VietQR • NAPAS 247',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                    ),
                    const Text('Phòng 304 Bách Khoa',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 12),
                // QR Mockup graphic
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildQrPattern(),
                      const SizedBox(height: 6),
                      Text(
                        'Quét bằng app Ngân hàng (MB, VCB, Vietin) / MoMo',
                        style:
                            TextStyle(fontSize: 9, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  amountStr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Bảng chi tiết người nhận
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('Người nhận:', debt.toName, isBold: true),
                const Divider(height: 12),
                _buildInfoRow('Ngân hàng:', 'MB Bank (Quân Đội)'),
                const Divider(height: 12),
                _buildInfoRow('Số tài khoản:', '0984 888 304',
                    copyable: true, context: context),
                const Divider(height: 12),
                _buildInfoRow(
                    'Nội dung CK:', 'TROPAY P304 ${debt.billTitle}',
                    copyable: true,
                    context: context),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Xác nhận đã chuyển tiền xong',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              onPressed: () {
                prov.toggleSettleShare(
                  billId: debt.billId,
                  memberId: debt.fromId,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF10B981),
                    content: Text(
                        '✅ Đã ghi nhận thanh toán $amountStr cho bạn ${debt.toName}!'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isBold = false, bool copyable = false, BuildContext? context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
        Row(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                    color: Colors.black87)),
            if (copyable && context != null) ...[
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text('Đã sao chép: $value'),
                    ),
                  );
                },
                child: const Icon(Icons.copy_rounded,
                    size: 14, color: Color(0xFF2563EB)),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildQrPattern() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 49,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
              itemBuilder: (context, index) {
                final row = index ~/ 7;
                final col = index % 7;
                final isCorner1 = (row < 2 && col < 2);
                final isCorner2 = (row < 2 && col > 4);
                final isCorner3 = (row > 4 && col < 2);
                final isFilled = isCorner1 ||
                    isCorner2 ||
                    isCorner3 ||
                    ((index * 7 + 3) % 3 == 0);

                return Container(
                  decoration: BoxDecoration(
                    color:
                        isFilled ? const Color(0xFF0F172A) : Colors.transparent,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2),
              ],
            ),
            child: const Icon(Icons.apartment_rounded,
                color: Color(0xFF2563EB), size: 16),
          ),
        ],
      ),
    );
  }
}

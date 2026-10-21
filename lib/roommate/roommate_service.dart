import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'roommate_model.dart';

class RoommateService {
  static const _kMembersKey = 'tropay_roommate_members_v1';
  static const _kBillsKey = 'tropay_roommate_bills_v1';
  static const _kFundKey = 'tropay_roommate_fund_v1';
  static const _kFundTxsKey = 'tropay_roommate_fund_txs_v1';

  /// Khởi tạo dữ liệu mẫu nếu chưa có dữ liệu trong máy
  Future<void> ensureInitialized() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_kMembersKey)) {
      final defaultMembers = [
        RoommateMember(
          id: 'mem_me',
          name: 'Tôi (Trưởng phòng)',
          nickname: 'Bạn',
          phone: '0981234567',
          avatarColor: 0xFF2563EB, // Xanh dương
          isMe: true,
          joinedAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        RoommateMember(
          id: 'mem_1',
          name: 'Minh Quân',
          nickname: 'Quân Béo',
          phone: '0978654321',
          avatarColor: 0xFF059669, // Xanh lá
          isMe: false,
          joinedAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        RoommateMember(
          id: 'mem_2',
          name: 'Thu Trang',
          nickname: 'Trang Tây',
          phone: '0912345678',
          avatarColor: 0xFFD97706, // Vàng cam
          isMe: false,
          joinedAt: DateTime.now().subtract(const Duration(days: 50)),
        ),
        RoommateMember(
          id: 'mem_3',
          name: 'Tuấn Anh',
          nickname: 'Anh Bách Khoa',
          phone: '0934567890',
          avatarColor: 0xFF7C3AED, // Tím
          isMe: false,
          joinedAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
      ];

      await saveMembers(defaultMembers);
    }

    if (!prefs.containsKey(_kFundKey)) {
      final defaultFund = RoomFund(
        id: 'fund_p304',
        name: 'Quỹ Phòng 304 (Bách Khoa)',
        balance: 650000,
        monthlyTargetPerMember: 150000,
        roomCode: 'P304-BK',
      );
      await saveFund(defaultFund);
    }

    if (!prefs.containsKey(_kFundTxsKey)) {
      final now = DateTime.now();
      final defaultTxs = [
        FundTransaction(
          id: 'ftx_1',
          fundId: 'fund_p304',
          memberId: 'mem_me',
          memberName: 'Tôi (Trưởng phòng)',
          type: 'deposit',
          amount: 150000,
          title: 'Đóng quỹ tháng 10',
          createdAt: now.subtract(const Duration(days: 5)),
        ),
        FundTransaction(
          id: 'ftx_2',
          fundId: 'fund_p304',
          memberId: 'mem_1',
          memberName: 'Minh Quân',
          type: 'deposit',
          amount: 150000,
          title: 'Đóng quỹ tháng 10',
          createdAt: now.subtract(const Duration(days: 4)),
        ),
        FundTransaction(
          id: 'ftx_3',
          fundId: 'fund_p304',
          memberId: 'mem_2',
          memberName: 'Thu Trang',
          type: 'deposit',
          amount: 150000,
          title: 'Đóng quỹ tháng 10',
          createdAt: now.subtract(const Duration(days: 3)),
        ),
        FundTransaction(
          id: 'ftx_4',
          fundId: 'fund_p304',
          memberId: 'mem_3',
          memberName: 'Tuấn Anh',
          type: 'deposit',
          amount: 150000,
          title: 'Đóng quỹ tháng 10',
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        FundTransaction(
          id: 'ftx_5',
          fundId: 'fund_p304',
          memberId: 'mem_me',
          memberName: 'Tôi (Trưởng phòng)',
          type: 'expense',
          amount: 80000,
          title: 'Mua túi rác & nước lau sàn',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
      ];
      await saveFundTransactions(defaultTxs);
    }

    if (!prefs.containsKey(_kBillsKey)) {
      final now = DateTime.now();
      final defaultBills = [
        BillSplitItem(
          id: 'bill_1',
          title: 'Tiền điện tháng này (310 kWh)',
          totalAmount: 930000,
          payerId: 'mem_1',
          payerName: 'Minh Quân',
          participantIds: ['mem_me', 'mem_1', 'mem_2', 'mem_3'],
          splitType: 'equal',
          shares: {
            'mem_me': 232500,
            'mem_1': 232500,
            'mem_2': 232500,
            'mem_3': 232500,
          },
          settledMemberIds: ['mem_1', 'mem_2'], // Trang đã trả Quân, Tôi & Tuấn Anh chưa trả
          createdAt: now.subtract(const Duration(days: 4)),
          category: 'electric',
          note: 'Chỉ số công tơ: 1205 -> 1515',
        ),
        BillSplitItem(
          id: 'bill_2',
          title: 'Tiền mạng Internet FPT (Tháng 10)',
          totalAmount: 220000,
          payerId: 'mem_me',
          payerName: 'Tôi (Trưởng phòng)',
          participantIds: ['mem_me', 'mem_1', 'mem_2', 'mem_3'],
          splitType: 'equal',
          shares: {
            'mem_me': 55000,
            'mem_1': 55000,
            'mem_2': 55000,
            'mem_3': 55000,
          },
          settledMemberIds: ['mem_me'], // Chưa ai hoàn tiền cho Tôi
          createdAt: now.subtract(const Duration(days: 2)),
          category: 'internet',
        ),
        BillSplitItem(
          id: 'bill_3',
          title: 'Gia vị chung phòng (mắm, muối, dầu ăn)',
          totalAmount: 160000,
          payerId: 'mem_2',
          payerName: 'Thu Trang',
          participantIds: ['mem_me', 'mem_1', 'mem_2', 'mem_3'],
          splitType: 'equal',
          shares: {
            'mem_me': 40000,
            'mem_1': 40000,
            'mem_2': 40000,
            'mem_3': 40000,
          },
          settledMemberIds: ['mem_2', 'mem_me', 'mem_1', 'mem_3'], // Đã thanh toán hết
          createdAt: now.subtract(const Duration(days: 7)),
          category: 'other',
        ),
      ];
      await saveBills(defaultBills);
    }
  }

  // ===== Members =====
  Future<List<RoommateMember>> loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMembersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List;
      return list.map((e) => RoommateMember.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMembers(List<RoommateMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(members.map((m) => m.toJson()).toList());
    await prefs.setString(_kMembersKey, raw);
  }

  // ===== Bills =====
  Future<List<BillSplitItem>> loadBills() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kBillsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List;
      return list.map((e) => BillSplitItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBills(List<BillSplitItem> bills) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(bills.map((b) => b.toJson()).toList());
    await prefs.setString(_kBillsKey, raw);
  }

  // ===== Fund =====
  Future<RoomFund> loadFund() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kFundKey);
    if (raw == null || raw.isEmpty) {
      return RoomFund(
        id: 'fund_p304',
        name: 'Quỹ Phòng 304',
        balance: 0,
        monthlyTargetPerMember: 150000,
        roomCode: 'P304-BK',
      );
    }
    try {
      return RoomFund.fromJson(json.decode(raw));
    } catch (_) {
      return RoomFund(
        id: 'fund_p304',
        name: 'Quỹ Phòng 304',
        balance: 0,
        monthlyTargetPerMember: 150000,
        roomCode: 'P304-BK',
      );
    }
  }

  Future<void> saveFund(RoomFund fund) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(fund.toJson());
    await prefs.setString(_kFundKey, raw);
  }

  // ===== Fund Transactions =====
  Future<List<FundTransaction>> loadFundTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kFundTxsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List;
      return list.map((e) => FundTransaction.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFundTransactions(List<FundTransaction> txs) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(txs.map((t) => t.toJson()).toList());
    await prefs.setString(_kFundTxsKey, raw);
  }
}

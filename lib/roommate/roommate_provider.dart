import 'dart:math';
import 'package:flutter/foundation.dart';
import 'roommate_model.dart';
import 'roommate_service.dart';

class RoommateProvider extends ChangeNotifier {
  final RoommateService _service;

  RoommateProvider({RoommateService? service})
      : _service = service ?? RoommateService();

  List<RoommateMember> _members = [];
  List<BillSplitItem> _bills = [];
  RoomFund? _fund;
  List<FundTransaction> _fundTxs = [];
  bool _loading = false;

  List<RoommateMember> get members => List.unmodifiable(_members);
  List<BillSplitItem> get bills => List.unmodifiable(_bills);
  RoomFund? get fund => _fund;
  List<FundTransaction> get fundTxs => List.unmodifiable(_fundTxs);
  bool get loading => _loading;

  RoommateMember? get me {
    try {
      return _members.firstWhere((m) => m.isMe);
    } catch (_) {
      return _members.isNotEmpty ? _members.first : null;
    }
  }

  /// Khởi tạo và tải dữ liệu từ local
  Future<void> init() async {
    _loading = true;
    notifyListeners();

    try {
      await _service.ensureInitialized();
      _members = await _service.loadMembers();
      _bills = await _service.loadBills();
      _fund = await _service.loadFund();
      _fundTxs = await _service.loadFundTransactions();
    } catch (e) {
      debugPrint('Error init RoommateProvider: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 👥 QUẢN LÝ THÀNH VIÊN
  // ==========================================
  Future<void> addMember({
    required String name,
    String? nickname,
    String? phone,
  }) async {
    final colors = [
      0xFF2563EB, // Blue
      0xFF059669, // Green
      0xFFD97706, // Amber
      0xFF7C3AED, // Purple
      0xFFDC2626, // Red
      0xFF0D9488, // Teal
      0xFFDB2777, // Pink
    ];
    final color = colors[Random().nextInt(colors.length)];

    final newMember = RoommateMember(
      id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      nickname: nickname?.trim(),
      phone: phone?.trim(),
      avatarColor: color,
      isMe: false,
      joinedAt: DateTime.now(),
    );

    _members.add(newMember);
    await _service.saveMembers(_members);
    notifyListeners();
  }

  Future<void> removeMember(String id) async {
    _members.removeWhere((m) => m.id == id && !m.isMe);
    await _service.saveMembers(_members);
    notifyListeners();
  }

  // ==========================================
  // 🧾 CHIA TIỀN HÓA ĐƠN (BILL SPLITTER)
  // ==========================================
  Future<void> addBill({
    required String title,
    required double totalAmount,
    required String payerId,
    required List<String> participantIds,
    String splitType = 'equal',
    Map<String, double>? customShares,
    String? category,
    String? note,
  }) async {
    if (participantIds.isEmpty) return;

    final payer = _members.firstWhere(
      (m) => m.id == payerId,
      orElse: () => _members.first,
    );

    Map<String, double> shares = {};
    if (splitType == 'equal') {
      final perPerson = (totalAmount / participantIds.length).roundToDouble();
      for (final id in participantIds) {
        shares[id] = perPerson;
      }
    } else {
      shares = customShares ?? {};
    }

    final newBill = BillSplitItem(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      totalAmount: totalAmount,
      payerId: payer.id,
      payerName: payer.name,
      participantIds: participantIds,
      splitType: splitType,
      shares: shares,
      settledMemberIds: [payer.id], // Người đã chi trả coi như tự hòa tiền cho chính mình
      createdAt: DateTime.now(),
      category: category ?? 'other',
      note: note,
    );

    _bills.insert(0, newBill);
    await _service.saveBills(_bills);
    notifyListeners();
  }

  /// Đánh dấu thành viên đã hoàn tiền hóa đơn
  Future<void> toggleSettleShare({
    required String billId,
    required String memberId,
  }) async {
    final idx = _bills.indexWhere((b) => b.id == billId);
    if (idx == -1) return;

    final old = _bills[idx];
    final settled = List<String>.from(old.settledMemberIds);

    if (settled.contains(memberId)) {
      settled.remove(memberId);
    } else {
      settled.add(memberId);
    }

    final updated = BillSplitItem(
      id: old.id,
      title: old.title,
      totalAmount: old.totalAmount,
      payerId: old.payerId,
      payerName: old.payerName,
      participantIds: old.participantIds,
      splitType: old.splitType,
      shares: old.shares,
      settledMemberIds: settled,
      createdAt: old.createdAt,
      category: old.category,
      note: old.note,
    );

    _bills[idx] = updated;
    await _service.saveBills(_bills);
    notifyListeners();
  }

  Future<void> deleteBill(String id) async {
    _bills.removeWhere((b) => b.id == id);
    await _service.saveBills(_bills);
    notifyListeners();
  }

  // ==========================================
  // 💰 TÍNH TOÁN "AI NỢ AI" (DEBT SUMMARY)
  // ==========================================

  /// Danh sách các khoản mà "Tôi" đang nợ người khác
  List<DebtRecord> get debtsIOwe {
    final myId = me?.id;
    if (myId == null) return [];

    final list = <DebtRecord>[];
    for (final bill in _bills) {
      if (bill.payerId != myId && bill.participantIds.contains(myId)) {
        if (!bill.isSettledBy(myId)) {
          final amt = bill.shares[myId] ?? bill.amountPerPerson;
          list.add(DebtRecord(
            fromId: myId,
            fromName: 'Tôi',
            toId: bill.payerId,
            toName: bill.payerName,
            amount: amt,
            billId: bill.id,
            billTitle: bill.title,
          ));
        }
      }
    }
    return list;
  }

  /// Danh sách các khoản người khác đang nợ "Tôi"
  List<DebtRecord> get debtsOthersOweMe {
    final myId = me?.id;
    if (myId == null) return [];

    final list = <DebtRecord>[];
    for (final bill in _bills) {
      if (bill.payerId == myId) {
        for (final pId in bill.participantIds) {
          if (pId != myId && !bill.isSettledBy(pId)) {
            final pName = _members.firstWhere(
              (m) => m.id == pId,
              orElse: () => RoommateMember(
                id: pId,
                name: 'Bạn cùng phòng',
                avatarColor: 0xFF9E9E9E,
                joinedAt: DateTime.now(),
              ),
            ).name;

            final amt = bill.shares[pId] ?? bill.amountPerPerson;
            list.add(DebtRecord(
              fromId: pId,
              fromName: pName,
              toId: myId,
              toName: 'Tôi',
              amount: amt,
              billId: bill.id,
              billTitle: bill.title,
            ));
          }
        }
      }
    }
    return list;
  }

  double get totalIOwe => debtsIOwe.fold<double>(0, (s, d) => s + d.amount);
  double get totalOwedToMe =>
      debtsOthersOweMe.fold<double>(0, (s, d) => s + d.amount);
  double get netBalance => totalOwedToMe - totalIOwe;

  // ==========================================
  // 🏦 QUỸ CHUNG PHÒNG TRỌ (ROOM FUND)
  // ==========================================
  Future<void> contributeToFund({
    required String memberId,
    required double amount,
    String? note,
  }) async {
    if (_fund == null) return;

    final member = _members.firstWhere(
      (m) => m.id == memberId,
      orElse: () => _members.first,
    );

    final newTx = FundTransaction(
      id: 'ftx_${DateTime.now().millisecondsSinceEpoch}',
      fundId: _fund!.id,
      memberId: member.id,
      memberName: member.name,
      type: 'deposit',
      amount: amount,
      title: note?.isNotEmpty == true ? note! : 'Đóng quỹ phòng trọ',
      createdAt: DateTime.now(),
    );

    _fundTxs.insert(0, newTx);
    _fund = _fund!.copyWith(balance: _fund!.balance + amount);

    await Future.wait([
      _service.saveFund(_fund!),
      _service.saveFundTransactions(_fundTxs),
    ]);

    notifyListeners();
  }

  Future<void> spendFromFund({
    required double amount,
    required String title,
  }) async {
    if (_fund == null) return;

    final myName = me?.name ?? 'Trưởng phòng';

    final newTx = FundTransaction(
      id: 'ftx_${DateTime.now().millisecondsSinceEpoch}',
      fundId: _fund!.id,
      memberId: me?.id ?? 'mem_me',
      memberName: myName,
      type: 'expense',
      amount: amount,
      title: title.trim(),
      createdAt: DateTime.now(),
    );

    _fundTxs.insert(0, newTx);
    _fund = _fund!.copyWith(balance: _fund!.balance - amount);

    await Future.wait([
      _service.saveFund(_fund!),
      _service.saveFundTransactions(_fundTxs),
    ]);

    notifyListeners();
  }

  Future<void> updateFundTarget(double target) async {
    if (_fund == null) return;
    _fund = _fund!.copyWith(monthlyTargetPerMember: target);
    await _service.saveFund(_fund!);
    notifyListeners();
  }
}

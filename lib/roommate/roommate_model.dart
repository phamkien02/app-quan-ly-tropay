import 'dart:convert';

/// Đại diện cho một bạn cùng phòng
class RoommateMember {
  final String id;
  final String name;
  final String? nickname;
  final String? phone;
  final int avatarColor;
  final bool isMe;
  final DateTime joinedAt;

  RoommateMember({
    required this.id,
    required this.name,
    this.nickname,
    this.phone,
    required this.avatarColor,
    this.isMe = false,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nickname': nickname,
        'phone': phone,
        'avatarColor': avatarColor,
        'isMe': isMe,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory RoommateMember.fromJson(Map<String, dynamic> json) => RoommateMember(
        id: json['id'],
        name: json['name'],
        nickname: json['nickname'],
        phone: json['phone'],
        avatarColor: json['avatarColor'] ?? 0xFF1E88E5,
        isMe: json['isMe'] ?? false,
        joinedAt: DateTime.parse(json['joinedAt']),
      );
}

/// Hóa đơn chia tiền phòng trọ / sinh hoạt chung
class BillSplitItem {
  final String id;
  final String title;
  final double totalAmount;
  final String payerId;
  final String payerName;
  final List<String> participantIds;
  final String splitType; // 'equal' | 'custom'
  final Map<String, double> shares; // memberId -> amount
  final List<String> settledMemberIds; // memberId đã trả nợ
  final DateTime createdAt;
  final String? note;
  final String? category; // 'room', 'electric', 'water', 'internet', 'food', 'other'

  BillSplitItem({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.payerId,
    required this.payerName,
    required this.participantIds,
    this.splitType = 'equal',
    required this.shares,
    this.settledMemberIds = const [],
    required this.createdAt,
    this.note,
    this.category = 'other',
  });

  double get amountPerPerson =>
      participantIds.isNotEmpty ? totalAmount / participantIds.length : 0;

  bool isSettledBy(String memberId) => settledMemberIds.contains(memberId);

  bool get isFullySettled =>
      participantIds.where((id) => id != payerId).every(isSettledBy);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'totalAmount': totalAmount,
        'payerId': payerId,
        'payerName': payerName,
        'participantIds': participantIds,
        'splitType': splitType,
        'shares': shares,
        'settledMemberIds': settledMemberIds,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
        'category': category,
      };

  factory BillSplitItem.fromJson(Map<String, dynamic> json) => BillSplitItem(
        id: json['id'],
        title: json['title'],
        totalAmount: (json['totalAmount'] as num).toDouble(),
        payerId: json['payerId'],
        payerName: json['payerName'],
        participantIds: List<String>.from(json['participantIds'] ?? []),
        splitType: json['splitType'] ?? 'equal',
        shares: Map<String, double>.from(
          (json['shares'] as Map? ?? {}).map(
            (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
          ),
        ),
        settledMemberIds: List<String>.from(json['settledMemberIds'] ?? []),
        createdAt: DateTime.parse(json['createdAt']),
        note: json['note'],
        category: json['category'] ?? 'other',
      );
}

/// Quỹ chung của phòng trọ / nhóm sinh viên
class RoomFund {
  final String id;
  final String name;
  final double balance;
  final double monthlyTargetPerMember;
  final String roomCode;

  RoomFund({
    required this.id,
    required this.name,
    required this.balance,
    required this.monthlyTargetPerMember,
    required this.roomCode,
  });

  RoomFund copyWith({
    String? id,
    String? name,
    double? balance,
    double? monthlyTargetPerMember,
    String? roomCode,
  }) =>
      RoomFund(
        id: id ?? this.id,
        name: name ?? this.name,
        balance: balance ?? this.balance,
        monthlyTargetPerMember:
            monthlyTargetPerMember ?? this.monthlyTargetPerMember,
        roomCode: roomCode ?? this.roomCode,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'balance': balance,
        'monthlyTargetPerMember': monthlyTargetPerMember,
        'roomCode': roomCode,
      };

  factory RoomFund.fromJson(Map<String, dynamic> json) => RoomFund(
        id: json['id'],
        name: json['name'],
        balance: (json['balance'] as num).toDouble(),
        monthlyTargetPerMember:
            (json['monthlyTargetPerMember'] as num).toDouble(),
        roomCode: json['roomCode'] ?? 'P304',
      );
}

/// Giao dịch nạp hoặc chi từ quỹ chung
class FundTransaction {
  final String id;
  final String fundId;
  final String memberId;
  final String memberName;
  final String type; // 'deposit' | 'expense'
  final double amount;
  final String title;
  final DateTime createdAt;

  FundTransaction({
    required this.id,
    required this.fundId,
    required this.memberId,
    required this.memberName,
    required this.type,
    required this.amount,
    required this.title,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fundId': fundId,
        'memberId': memberId,
        'memberName': memberName,
        'type': type,
        'amount': amount,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FundTransaction.fromJson(Map<String, dynamic> json) => FundTransaction(
        id: json['id'],
        fundId: json['fundId'],
        memberId: json['memberId'],
        memberName: json['memberName'],
        type: json['type'],
        amount: (json['amount'] as num).toDouble(),
        title: json['title'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

/// Thể hiện khoản nợ giữa 2 thành viên
class DebtRecord {
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final double amount;
  final String billId;
  final String billTitle;

  DebtRecord({
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.amount,
    required this.billId,
    required this.billTitle,
  });
}

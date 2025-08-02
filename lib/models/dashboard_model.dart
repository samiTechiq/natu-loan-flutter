class DashboardModel {
  final int totalCashOut;
  final int totalCashIn;
  final int netBalance;
  final int totalUsers;
  final List<Transaction> recentTransactions;

  DashboardModel({
    required this.totalCashOut,
    required this.totalCashIn,
    required this.netBalance,
    required this.totalUsers,
    required this.recentTransactions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalCashOut: json['total_cash_out'] ?? 0,
      totalCashIn: json['total_cash_in'] ?? 0,
      netBalance: json['net_balance'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      recentTransactions:
          (json['recent_transactions'] as List<dynamic>? ?? [])
              .map((e) => Transaction.fromJson(e))
              .toList(),
    );
  }
}

class Transaction {
  final int id;
  final String valueDate;
  final String description;
  final String amount;
  final String transactionType;
  final String userId;
  final String createdBy;
  final String createdAt;
  final String updatedAt;
  final User? user;
  final User? creator;

  Transaction({
    required this.id,
    required this.valueDate,
    required this.description,
    required this.amount,
    required this.transactionType,
    required this.userId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.creator,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      valueDate: json['value_date'] ?? '',
      description: json['description'] ?? '',
      amount: json['amount'] ?? '',
      transactionType: json['transaction_type'] ?? '',
      userId: json['user_id'].toString(),
      createdBy: json['created_by'].toString(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
    );
  }
}

class User {
  final String id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'].toString(), name: json['name'] ?? '');
  }
}

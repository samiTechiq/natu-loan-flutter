// Model for user dashboard data
class UserDashboardData {
  final double totalCashOut;
  final double totalCashIn;
  final double netBalance;
  final int recordCount;
  final List<UserTransaction> recentTransactions;

  UserDashboardData({
    required this.totalCashOut,
    required this.totalCashIn,
    required this.netBalance,
    required this.recordCount,
    required this.recentTransactions,
  });

  factory UserDashboardData.fromJson(Map<String, dynamic> json) {
    return UserDashboardData(
      totalCashOut: double.tryParse(json['total_cash_out'].toString()) ?? 0.0,
      totalCashIn: double.tryParse(json['total_cash_in'].toString()) ?? 0.0,
      netBalance: double.tryParse(json['net_balance'].toString()) ?? 0.0,
      recordCount: json['record_count'] ?? 0,
      recentTransactions:
          (json['recent_transactions'] as List<dynamic>?)
              ?.map((item) => UserTransaction.fromJson(item))
              .toList() ??
          [],
    );
  }
}

// Model for user transactions
class UserTransaction {
  final int id;
  final String valueDate;
  final String description;
  final double amount;
  final String transactionType;
  final int userId;
  final int createdBy;
  final String createdAt;
  final String updatedAt;
  final TransactionUser? user;
  final TransactionUser? creator;

  UserTransaction({
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

  bool get isCashIn => transactionType.toLowerCase() == 'cash_in';
  bool get isCashOut => transactionType.toLowerCase() == 'cash_out';

  factory UserTransaction.fromJson(Map<String, dynamic> json) {
    return UserTransaction(
      id: json['id'] ?? 0,
      valueDate: json['value_date'] ?? '',
      description: json['description'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      transactionType: json['transaction_type'] ?? '',
      userId: json['user_id'] ?? 0,
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user:
          json['user'] != null ? TransactionUser.fromJson(json['user']) : null,
      creator:
          json['creator'] != null
              ? TransactionUser.fromJson(json['creator'])
              : null,
    );
  }
}

// Model for transaction user info
class TransactionUser {
  final int id;
  final String name;

  TransactionUser({required this.id, required this.name});

  factory TransactionUser.fromJson(Map<String, dynamic> json) {
    return TransactionUser(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

// Model for user history/statement
class UserHistoryData {
  final List<UserHistoryEntry> entries;
  final UserHistorySummary summary;

  UserHistoryData({required this.entries, required this.summary});

  factory UserHistoryData.fromJson(Map<String, dynamic> json) {
    return UserHistoryData(
      entries:
          (json['data'] as List<dynamic>?)
              ?.map((item) => UserHistoryEntry.fromJson(item))
              .toList() ??
          [],
      summary: UserHistorySummary.fromJson(json['summary'] ?? {}),
    );
  }
}

// Model for individual history entry
class UserHistoryEntry {
  final String date;
  final String description;
  final double cashIn;
  final double cashOut;
  final double balance;

  UserHistoryEntry({
    required this.date,
    required this.description,
    required this.cashIn,
    required this.cashOut,
    required this.balance,
  });

  bool get isCashIn => cashIn > 0;
  bool get isCashOut => cashOut > 0;
  double get amount => isCashIn ? cashIn : cashOut;

  factory UserHistoryEntry.fromJson(Map<String, dynamic> json) {
    return UserHistoryEntry(
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      cashIn: double.tryParse(json['cash_in'].toString()) ?? 0.0,
      cashOut: double.tryParse(json['cash_out'].toString()) ?? 0.0,
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
    );
  }
}

// Model for history summary
class UserHistorySummary {
  final double totalCashIn;
  final double totalCashOut;
  final double totalOutstanding;

  UserHistorySummary({
    required this.totalCashIn,
    required this.totalCashOut,
    required this.totalOutstanding,
  });

  factory UserHistorySummary.fromJson(Map<String, dynamic> json) {
    return UserHistorySummary(
      totalCashIn: double.tryParse(json['total_cash_in'].toString()) ?? 0.0,
      totalCashOut: double.tryParse(json['total_cash_out'].toString()) ?? 0.0,
      totalOutstanding:
          double.tryParse(json['total_outstanding'].toString()) ?? 0.0,
    );
  }
}

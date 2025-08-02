class LoanStatementItem {
  final String date;
  final String description;
  final double cashIn;
  final double cashOut;
  final double balance;

  LoanStatementItem({
    required this.date,
    required this.description,
    required this.cashIn,
    required this.cashOut,
    required this.balance,
  });

  factory LoanStatementItem.fromJson(Map<String, dynamic> json) {
    return LoanStatementItem(
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      cashIn: (json['cash_in'] ?? 0).toDouble(),
      cashOut: (json['cash_out'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }
}

class LoanStatementSummary {
  final double totalCashIn;
  final double totalCashOut;
  final double totalOutstanding;

  LoanStatementSummary({
    required this.totalCashIn,
    required this.totalCashOut,
    required this.totalOutstanding,
  });

  factory LoanStatementSummary.fromJson(Map<String, dynamic> json) {
    return LoanStatementSummary(
      totalCashIn: (json['total_cash_in'] ?? 0).toDouble(),
      totalCashOut: (json['total_cash_out'] ?? 0).toDouble(),
      totalOutstanding: (json['total_outstanding'] ?? 0).toDouble(),
    );
  }
}

class LoanStatement {
  final bool success;
  final String message;
  final List<LoanStatementItem> data;
  final LoanStatementSummary? summary;

  LoanStatement({
    required this.success,
    required this.message,
    required this.data,
    this.summary,
  });

  factory LoanStatement.fromJson(Map<String, dynamic> json) {
    return LoanStatement(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => LoanStatementItem.fromJson(item))
              .toList() ??
          [],
      summary:
          json['summary'] != null
              ? LoanStatementSummary.fromJson(json['summary'])
              : null,
    );
  }
}

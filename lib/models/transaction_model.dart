class TransactionUser {
  final int id;
  final String name;

  TransactionUser({required this.id, required this.name});

  factory TransactionUser.fromJson(Map<String, dynamic> json) {
    return TransactionUser(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class Transaction {
  final int id;
  final String valueDate;
  final String description;
  final double amount;
  final String transactionType;
  final int userId;
  final int createdBy;
  final String createdAt;
  final String updatedAt;
  final TransactionUser user;
  final TransactionUser creator;

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
    required this.user,
    required this.creator,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      valueDate: json['value_date'] ?? '',
      description: json['description'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      transactionType: json['transaction_type'] ?? '',
      userId: json['user_id'] ?? 0,
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: TransactionUser.fromJson(json['user'] ?? {}),
      creator: TransactionUser.fromJson(json['creator'] ?? {}),
    );
  }

  bool get isCashIn => transactionType == 'cash_in';
  bool get isCashOut => transactionType == 'cash_out';
}

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({this.url, required this.label, required this.active});

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}

class TransactionData {
  final int currentPage;
  final List<Transaction> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  TransactionData({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      currentPage: json['current_page'] ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Transaction.fromJson(item))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links:
          (json['links'] as List<dynamic>?)
              ?.map((item) => PaginationLink.fromJson(item))
              .toList() ??
          [],
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class TransactionResponse {
  final bool success;
  final String message;
  final TransactionData data;

  TransactionResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: TransactionData.fromJson(json['data'] ?? {}),
    );
  }
}

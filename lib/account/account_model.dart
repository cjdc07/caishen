class AccountColor {
  final int alpha;
  final int red;
  final int green;
  final int blue;
  final String name;

  AccountColor({
    this.alpha,
    this.red,
    this.green,
    this.blue,
    this.name,
  });

  static AccountColor parse(Map<String, dynamic> data) {
    return AccountColor(
      alpha: data['alpha'],
      red: data['red'],
      green: data['green'],
      blue: data['blue'],
      name: data['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alpha': alpha,
      'red': red,
      'green': green,
      'blue': blue,
      'name': name,
    };
  }

  @override
  String toString() {
    return "{ alpha: $alpha, red: $red, green: $green, blue: $blue, name: $name }";
  }
}

class AccountType {
  final String key;
  final String value;

  AccountType({this.key, this.value});

  static AccountType parse(Map<String, dynamic> data) {
    return AccountType(
      key: data['key'],
      value: data['value'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
    };
  }

  @override
  String toString() {
    return "{ key: $value, value: $value }";
  }
}

class Account {
  String id;
  final String name;
  double balance;
  final AccountColor color;
  final AccountType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String user;

  Account({
    this.id,
    this.name,
    this.balance,
    this.color,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  void deduct(double amount) {
    balance -= amount;
  }

  void add(double amount) {
    balance += amount;
  }

  static Account parse(Map<String, dynamic> data) {
    return Account(
      id: data['id'],
      name: data['name'],
      balance: data['balance'] is int
          ? (data['balance'] as int).toDouble()
          : data['balance'],
      color: AccountColor.parse(data['color']),
      type: AccountType.parse(data['type']),
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
      user: data['user'],
    );
  }

  static List<Account> parseList(List accounts) {
    return accounts
        .map(
          (account) => Account.parse(account),
        )
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'balance': balance,
      'color': color.toMap(),
      'type': type.toMap(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'user': user,
    };
  }

  @override
  String toString() {
    return "{ id: $id, name: $name, balance: $balance, color: ${color.toString()}, type: ${type.toString()}, createdAt: $createdAt, updatedAt: $updatedAt, user: $user}";
  }
}

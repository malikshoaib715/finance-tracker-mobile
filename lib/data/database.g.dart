// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 3),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _balanceCentsMeta =
      const VerificationMeta('balanceCents');
  @override
  late final GeneratedColumn<int> balanceCents = GeneratedColumn<int>(
      'balance_cents', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _archivedMeta =
      const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
      'archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, kind, currency, position, balanceCents, archived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    if (data.containsKey('balance_cents')) {
      context.handle(
          _balanceCentsMeta,
          balanceCents.isAcceptableOrUnknown(
              data['balance_cents']!, _balanceCentsMeta));
    } else if (isInserting) {
      context.missing(_balanceCentsMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta,
          archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      balanceCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}balance_cents'])!,
      archived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String name;
  final String kind;
  final String currency;
  final int position;
  final int balanceCents;
  final bool archived;
  const Account(
      {required this.id,
      required this.name,
      required this.kind,
      required this.currency,
      required this.position,
      required this.balanceCents,
      required this.archived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['currency'] = Variable<String>(currency);
    map['position'] = Variable<int>(position);
    map['balance_cents'] = Variable<int>(balanceCents);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      currency: Value(currency),
      position: Value(position),
      balanceCents: Value(balanceCents),
      archived: Value(archived),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      currency: serializer.fromJson<String>(json['currency']),
      position: serializer.fromJson<int>(json['position']),
      balanceCents: serializer.fromJson<int>(json['balanceCents']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'currency': serializer.toJson<String>(currency),
      'position': serializer.toJson<int>(position),
      'balanceCents': serializer.toJson<int>(balanceCents),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Account copyWith(
          {int? id,
          String? name,
          String? kind,
          String? currency,
          int? position,
          int? balanceCents,
          bool? archived}) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        kind: kind ?? this.kind,
        currency: currency ?? this.currency,
        position: position ?? this.position,
        balanceCents: balanceCents ?? this.balanceCents,
        archived: archived ?? this.archived,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      currency: data.currency.present ? data.currency.value : this.currency,
      position: data.position.present ? data.position.value : this.position,
      balanceCents: data.balanceCents.present
          ? data.balanceCents.value
          : this.balanceCents,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currency: $currency, ')
          ..write('position: $position, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, kind, currency, position, balanceCents, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.currency == this.currency &&
          other.position == this.position &&
          other.balanceCents == this.balanceCents &&
          other.archived == this.archived);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> currency;
  final Value<int> position;
  final Value<int> balanceCents;
  final Value<bool> archived;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.currency = const Value.absent(),
    this.position = const Value.absent(),
    this.balanceCents = const Value.absent(),
    this.archived = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String kind,
    required String currency,
    this.position = const Value.absent(),
    required int balanceCents,
    this.archived = const Value.absent(),
  })  : name = Value(name),
        kind = Value(kind),
        currency = Value(currency),
        balanceCents = Value(balanceCents);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? currency,
    Expression<int>? position,
    Expression<int>? balanceCents,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (currency != null) 'currency': currency,
      if (position != null) 'position': position,
      if (balanceCents != null) 'balance_cents': balanceCents,
      if (archived != null) 'archived': archived,
    });
  }

  AccountsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? kind,
      Value<String>? currency,
      Value<int>? position,
      Value<int>? balanceCents,
      Value<bool>? archived}) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      currency: currency ?? this.currency,
      position: position ?? this.position,
      balanceCents: balanceCents ?? this.balanceCents,
      archived: archived ?? this.archived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (balanceCents.present) {
      map['balance_cents'] = Variable<int>(balanceCents.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currency: $currency, ')
          ..write('position: $position, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, kind, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String kind;
  final String color;
  const Category(
      {required this.id,
      required this.name,
      required this.kind,
      required this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['color'] = Variable<String>(color);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      color: Value(color),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      color: serializer.fromJson<String>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'color': serializer.toJson<String>(color),
    };
  }

  Category copyWith({int? id, String? name, String? kind, String? color}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        kind: kind ?? this.kind,
        color: color ?? this.color,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, kind, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.color == this.color);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> color;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.color = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String kind,
    required String color,
  })  : name = Value(name),
        kind = Value(kind),
        color = Value(color);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (color != null) 'color': color,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? kind,
      Value<String>? color}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
      'local_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountCentsMeta =
      const VerificationMeta('amountCents');
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
      'amount_cents', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _occurredOnMeta =
      const VerificationMeta('occurredOn');
  @override
  late final GeneratedColumn<DateTime> occurredOn = GeneratedColumn<DateTime>(
      'occurred_on', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        serverId,
        clientId,
        accountId,
        categoryId,
        kind,
        amountCents,
        occurredOn,
        description,
        notes,
        tags,
        serverUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
          _amountCentsMeta,
          amountCents.isAcceptableOrUnknown(
              data['amount_cents']!, _amountCentsMeta));
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('occurred_on')) {
      context.handle(
          _occurredOnMeta,
          occurredOn.isAcceptableOrUnknown(
              data['occurred_on']!, _occurredOnMeta));
    } else if (isInserting) {
      context.missing(_occurredOnMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id']),
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      amountCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_cents'])!,
      occurredOn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_on'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at']),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int localId;
  final int? serverId;
  final String clientId;
  final int accountId;
  final int? categoryId;
  final String kind;
  final int amountCents;
  final DateTime occurredOn;
  final String description;
  final String? notes;
  final String tags;

  /// Server `updated_at` of the last version we saw; sent back on PATCH so
  /// the server can detect conflicting edits.
  final DateTime? serverUpdatedAt;
  const Transaction(
      {required this.localId,
      this.serverId,
      required this.clientId,
      required this.accountId,
      this.categoryId,
      required this.kind,
      required this.amountCents,
      required this.occurredOn,
      required this.description,
      this.notes,
      required this.tags,
      this.serverUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['client_id'] = Variable<String>(clientId);
    map['account_id'] = Variable<int>(accountId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['kind'] = Variable<String>(kind);
    map['amount_cents'] = Variable<int>(amountCents);
    map['occurred_on'] = Variable<DateTime>(occurredOn);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['tags'] = Variable<String>(tags);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      clientId: Value(clientId),
      accountId: Value(accountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      kind: Value(kind),
      amountCents: Value(amountCents),
      occurredOn: Value(occurredOn),
      description: Value(description),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      tags: Value(tags),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      localId: serializer.fromJson<int>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      accountId: serializer.fromJson<int>(json['accountId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      kind: serializer.fromJson<String>(json['kind']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      occurredOn: serializer.fromJson<DateTime>(json['occurredOn']),
      description: serializer.fromJson<String>(json['description']),
      notes: serializer.fromJson<String?>(json['notes']),
      tags: serializer.fromJson<String>(json['tags']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'clientId': serializer.toJson<String>(clientId),
      'accountId': serializer.toJson<int>(accountId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'kind': serializer.toJson<String>(kind),
      'amountCents': serializer.toJson<int>(amountCents),
      'occurredOn': serializer.toJson<DateTime>(occurredOn),
      'description': serializer.toJson<String>(description),
      'notes': serializer.toJson<String?>(notes),
      'tags': serializer.toJson<String>(tags),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
    };
  }

  Transaction copyWith(
          {int? localId,
          Value<int?> serverId = const Value.absent(),
          String? clientId,
          int? accountId,
          Value<int?> categoryId = const Value.absent(),
          String? kind,
          int? amountCents,
          DateTime? occurredOn,
          String? description,
          Value<String?> notes = const Value.absent(),
          String? tags,
          Value<DateTime?> serverUpdatedAt = const Value.absent()}) =>
      Transaction(
        localId: localId ?? this.localId,
        serverId: serverId.present ? serverId.value : this.serverId,
        clientId: clientId ?? this.clientId,
        accountId: accountId ?? this.accountId,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        kind: kind ?? this.kind,
        amountCents: amountCents ?? this.amountCents,
        occurredOn: occurredOn ?? this.occurredOn,
        description: description ?? this.description,
        notes: notes.present ? notes.value : this.notes,
        tags: tags ?? this.tags,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      kind: data.kind.present ? data.kind.value : this.kind,
      amountCents:
          data.amountCents.present ? data.amountCents.value : this.amountCents,
      occurredOn:
          data.occurredOn.present ? data.occurredOn.value : this.occurredOn,
      description:
          data.description.present ? data.description.value : this.description,
      notes: data.notes.present ? data.notes.value : this.notes,
      tags: data.tags.present ? data.tags.value : this.tags,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('kind: $kind, ')
          ..write('amountCents: $amountCents, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      localId,
      serverId,
      clientId,
      accountId,
      categoryId,
      kind,
      amountCents,
      occurredOn,
      description,
      notes,
      tags,
      serverUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.clientId == this.clientId &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.kind == this.kind &&
          other.amountCents == this.amountCents &&
          other.occurredOn == this.occurredOn &&
          other.description == this.description &&
          other.notes == this.notes &&
          other.tags == this.tags &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> localId;
  final Value<int?> serverId;
  final Value<String> clientId;
  final Value<int> accountId;
  final Value<int?> categoryId;
  final Value<String> kind;
  final Value<int> amountCents;
  final Value<DateTime> occurredOn;
  final Value<String> description;
  final Value<String?> notes;
  final Value<String> tags;
  final Value<DateTime?> serverUpdatedAt;
  const TransactionsCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.occurredOn = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    required String clientId,
    required int accountId,
    this.categoryId = const Value.absent(),
    required String kind,
    required int amountCents,
    required DateTime occurredOn,
    required String description,
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
  })  : clientId = Value(clientId),
        accountId = Value(accountId),
        kind = Value(kind),
        amountCents = Value(amountCents),
        occurredOn = Value(occurredOn),
        description = Value(description);
  static Insertable<Transaction> custom({
    Expression<int>? localId,
    Expression<int>? serverId,
    Expression<String>? clientId,
    Expression<int>? accountId,
    Expression<int>? categoryId,
    Expression<String>? kind,
    Expression<int>? amountCents,
    Expression<DateTime>? occurredOn,
    Expression<String>? description,
    Expression<String>? notes,
    Expression<String>? tags,
    Expression<DateTime>? serverUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (clientId != null) 'client_id': clientId,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (kind != null) 'kind': kind,
      if (amountCents != null) 'amount_cents': amountCents,
      if (occurredOn != null) 'occurred_on': occurredOn,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? localId,
      Value<int?>? serverId,
      Value<String>? clientId,
      Value<int>? accountId,
      Value<int?>? categoryId,
      Value<String>? kind,
      Value<int>? amountCents,
      Value<DateTime>? occurredOn,
      Value<String>? description,
      Value<String?>? notes,
      Value<String>? tags,
      Value<DateTime?>? serverUpdatedAt}) {
    return TransactionsCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      clientId: clientId ?? this.clientId,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      kind: kind ?? this.kind,
      amountCents: amountCents ?? this.amountCents,
      occurredOn: occurredOn ?? this.occurredOn,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (occurredOn.present) {
      map['occurred_on'] = Variable<DateTime>(occurredOn.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('clientId: $clientId, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('kind: $kind, ')
          ..write('amountCents: $amountCents, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, operation, clientId, serverId, attempts, lastError, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id']),
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final int id;
  final String operation;
  final String clientId;

  /// For deletes: the row is gone locally, so remember which server record to delete.
  final int? serverId;
  final int attempts;
  final String? lastError;
  final DateTime createdAt;
  const OutboxData(
      {required this.id,
      required this.operation,
      required this.clientId,
      this.serverId,
      required this.attempts,
      this.lastError,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation'] = Variable<String>(operation);
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      operation: Value(operation),
      clientId: Value(clientId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      id: serializer.fromJson<int>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      clientId: serializer.fromJson<String>(json['clientId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operation': serializer.toJson<String>(operation),
      'clientId': serializer.toJson<String>(clientId),
      'serverId': serializer.toJson<int?>(serverId),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxData copyWith(
          {int? id,
          String? operation,
          String? clientId,
          Value<int?> serverId = const Value.absent(),
          int? attempts,
          Value<String?> lastError = const Value.absent(),
          DateTime? createdAt}) =>
      OutboxData(
        id: id ?? this.id,
        operation: operation ?? this.operation,
        clientId: clientId ?? this.clientId,
        serverId: serverId.present ? serverId.value : this.serverId,
        attempts: attempts ?? this.attempts,
        lastError: lastError.present ? lastError.value : this.lastError,
        createdAt: createdAt ?? this.createdAt,
      );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, operation, clientId, serverId, attempts, lastError, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.clientId == this.clientId &&
          other.serverId == this.serverId &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<int> id;
  final Value<String> operation;
  final Value<String> clientId;
  final Value<int?> serverId;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.clientId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.id = const Value.absent(),
    required String operation,
    required String clientId,
    this.serverId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : operation = Value(operation),
        clientId = Value(clientId);
  static Insertable<OutboxData> custom({
    Expression<int>? id,
    Expression<String>? operation,
    Expression<String>? clientId,
    Expression<int>? serverId,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (clientId != null) 'client_id': clientId,
      if (serverId != null) 'server_id': serverId,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxCompanion copyWith(
      {Value<int>? id,
      Value<String>? operation,
      Value<String>? clientId,
      Value<int?>? serverId,
      Value<int>? attempts,
      Value<String?>? lastError,
      Value<DateTime>? createdAt}) {
    return OutboxCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      clientId: clientId ?? this.clientId,
      serverId: serverId ?? this.serverId,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('clientId: $clientId, ')
          ..write('serverId: $serverId, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String key;
  final String value;
  const SyncStateData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory SyncStateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SyncStateData copyWith({String? key, String? value}) => SyncStateData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<SyncStateData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SyncStateCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final Index transactionsOccurredOn = Index('transactions_occurred_on',
      'CREATE INDEX transactions_occurred_on ON transactions (occurred_on)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        accounts,
        categories,
        transactions,
        outbox,
        syncState,
        transactionsOccurredOn
      ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  required String name,
  required String kind,
  required String currency,
  Value<int> position,
  required int balanceCents,
  Value<bool> archived,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> kind,
  Value<String> currency,
  Value<int> position,
  Value<int> balanceCents,
  Value<bool> archived,
});

class $$AccountsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get currency => $state.composableBuilder(
      column: $state.table.currency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get position => $state.composableBuilder(
      column: $state.table.position,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get balanceCents => $state.composableBuilder(
      column: $state.table.balanceCents,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get archived => $state.composableBuilder(
      column: $state.table.archived,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AccountsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get currency => $state.composableBuilder(
      column: $state.table.currency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get position => $state.composableBuilder(
      column: $state.table.position,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get balanceCents => $state.composableBuilder(
      column: $state.table.balanceCents,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get archived => $state.composableBuilder(
      column: $state.table.archived,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
    Account,
    PrefetchHooks Function()> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AccountsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AccountsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> balanceCents = const Value.absent(),
            Value<bool> archived = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            name: name,
            kind: kind,
            currency: currency,
            position: position,
            balanceCents: balanceCents,
            archived: archived,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String kind,
            required String currency,
            Value<int> position = const Value.absent(),
            required int balanceCents,
            Value<bool> archived = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            name: name,
            kind: kind,
            currency: currency,
            position: position,
            balanceCents: balanceCents,
            archived: archived,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
    Account,
    PrefetchHooks Function()>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
  required String kind,
  required String color,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> kind,
  Value<String> color,
});

class $$CategoriesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CategoriesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CategoriesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CategoriesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> color = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            kind: kind,
            color: color,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String kind,
            required String color,
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            kind: kind,
            color: color,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> localId,
  Value<int?> serverId,
  required String clientId,
  required int accountId,
  Value<int?> categoryId,
  required String kind,
  required int amountCents,
  required DateTime occurredOn,
  required String description,
  Value<String?> notes,
  Value<String> tags,
  Value<DateTime?> serverUpdatedAt,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> localId,
  Value<int?> serverId,
  Value<String> clientId,
  Value<int> accountId,
  Value<int?> categoryId,
  Value<String> kind,
  Value<int> amountCents,
  Value<DateTime> occurredOn,
  Value<String> description,
  Value<String?> notes,
  Value<String> tags,
  Value<DateTime?> serverUpdatedAt,
});

class $$TransactionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer(super.$state);
  ColumnFilters<int> get localId => $state.composableBuilder(
      column: $state.table.localId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get serverId => $state.composableBuilder(
      column: $state.table.serverId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get clientId => $state.composableBuilder(
      column: $state.table.clientId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get accountId => $state.composableBuilder(
      column: $state.table.accountId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get amountCents => $state.composableBuilder(
      column: $state.table.amountCents,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get occurredOn => $state.composableBuilder(
      column: $state.table.occurredOn,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tags => $state.composableBuilder(
      column: $state.table.tags,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get serverUpdatedAt => $state.composableBuilder(
      column: $state.table.serverUpdatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$TransactionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get localId => $state.composableBuilder(
      column: $state.table.localId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get serverId => $state.composableBuilder(
      column: $state.table.serverId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get clientId => $state.composableBuilder(
      column: $state.table.clientId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get accountId => $state.composableBuilder(
      column: $state.table.accountId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get amountCents => $state.composableBuilder(
      column: $state.table.amountCents,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get occurredOn => $state.composableBuilder(
      column: $state.table.occurredOn,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tags => $state.composableBuilder(
      column: $state.table.tags,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get serverUpdatedAt => $state.composableBuilder(
      column: $state.table.serverUpdatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TransactionsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TransactionsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<String> clientId = const Value.absent(),
            Value<int> accountId = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<int> amountCents = const Value.absent(),
            Value<DateTime> occurredOn = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
          }) =>
              TransactionsCompanion(
            localId: localId,
            serverId: serverId,
            clientId: clientId,
            accountId: accountId,
            categoryId: categoryId,
            kind: kind,
            amountCents: amountCents,
            occurredOn: occurredOn,
            description: description,
            notes: notes,
            tags: tags,
            serverUpdatedAt: serverUpdatedAt,
          ),
          createCompanionCallback: ({
            Value<int> localId = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            required String clientId,
            required int accountId,
            Value<int?> categoryId = const Value.absent(),
            required String kind,
            required int amountCents,
            required DateTime occurredOn,
            required String description,
            Value<String?> notes = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            localId: localId,
            serverId: serverId,
            clientId: clientId,
            accountId: accountId,
            categoryId: categoryId,
            kind: kind,
            amountCents: amountCents,
            occurredOn: occurredOn,
            description: description,
            notes: notes,
            tags: tags,
            serverUpdatedAt: serverUpdatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()>;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  required String operation,
  required String clientId,
  Value<int?> serverId,
  Value<int> attempts,
  Value<String?> lastError,
  Value<DateTime> createdAt,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  Value<String> operation,
  Value<String> clientId,
  Value<int?> serverId,
  Value<int> attempts,
  Value<String?> lastError,
  Value<DateTime> createdAt,
});

class $$OutboxTableFilterComposer
    extends FilterComposer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get operation => $state.composableBuilder(
      column: $state.table.operation,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get clientId => $state.composableBuilder(
      column: $state.table.clientId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get serverId => $state.composableBuilder(
      column: $state.table.serverId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get attempts => $state.composableBuilder(
      column: $state.table.attempts,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get lastError => $state.composableBuilder(
      column: $state.table.lastError,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$OutboxTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get operation => $state.composableBuilder(
      column: $state.table.operation,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get clientId => $state.composableBuilder(
      column: $state.table.clientId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get serverId => $state.composableBuilder(
      column: $state.table.serverId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get attempts => $state.composableBuilder(
      column: $state.table.attempts,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get lastError => $state.composableBuilder(
      column: $state.table.lastError,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$OutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()> {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$OutboxTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$OutboxTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> clientId = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OutboxCompanion(
            id: id,
            operation: operation,
            clientId: clientId,
            serverId: serverId,
            attempts: attempts,
            lastError: lastError,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String operation,
            required String clientId,
            Value<int?> serverId = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OutboxCompanion.insert(
            id: id,
            operation: operation,
            clientId: clientId,
            serverId: serverId,
            attempts: attempts,
            lastError: lastError,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()>;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SyncStateTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer(super.$state);
  ColumnFilters<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SyncStateTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer(super.$state);
  ColumnOrderings<String> get key => $state.composableBuilder(
      column: $state.table.key,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$SyncStateTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncStateTable,
    SyncStateData,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (
      SyncStateData,
      BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>
    ),
    SyncStateData,
    PrefetchHooks Function()> {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SyncStateTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SyncStateTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStateCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStateCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStateTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncStateTable,
    SyncStateData,
    $$SyncStateTableFilterComposer,
    $$SyncStateTableOrderingComposer,
    $$SyncStateTableCreateCompanionBuilder,
    $$SyncStateTableUpdateCompanionBuilder,
    (
      SyncStateData,
      BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>
    ),
    SyncStateData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
}

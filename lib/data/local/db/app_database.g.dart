// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionKindMeta = const VerificationMeta(
    'transactionKind',
  );
  @override
  late final GeneratedColumn<String> transactionKind = GeneratedColumn<String>(
    'transaction_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal_income'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spendingTypeMeta = const VerificationMeta(
    'spendingType',
  );
  @override
  late final GeneratedColumn<String> spendingType = GeneratedColumn<String>(
    'spending_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedDebtIdMeta = const VerificationMeta(
    'linkedDebtId',
  );
  @override
  late final GeneratedColumn<int> linkedDebtId = GeneratedColumn<int>(
    'linked_debt_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    description,
    amount,
    date,
    direction,
    source,
    transactionKind,
    category,
    spendingType,
    linkedDebtId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('transaction_kind')) {
      context.handle(
        _transactionKindMeta,
        transactionKind.isAcceptableOrUnknown(
          data['transaction_kind']!,
          _transactionKindMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('spending_type')) {
      context.handle(
        _spendingTypeMeta,
        spendingType.isAcceptableOrUnknown(
          data['spending_type']!,
          _spendingTypeMeta,
        ),
      );
    }
    if (data.containsKey('linked_debt_id')) {
      context.handle(
        _linkedDebtIdMeta,
        linkedDebtId.isAcceptableOrUnknown(
          data['linked_debt_id']!,
          _linkedDebtIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      transactionKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_kind'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      spendingType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spending_type'],
      ),
      linkedDebtId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_debt_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final String description;
  final double amount;
  final DateTime date;
  final String direction;
  final String source;
  final String transactionKind;
  final String? category;
  final String? spendingType;
  final int? linkedDebtId;
  final DateTime createdAt;
  const Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.direction,
    required this.source,
    required this.transactionKind,
    this.category,
    this.spendingType,
    this.linkedDebtId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['direction'] = Variable<String>(direction);
    map['source'] = Variable<String>(source);
    map['transaction_kind'] = Variable<String>(transactionKind);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || spendingType != null) {
      map['spending_type'] = Variable<String>(spendingType);
    }
    if (!nullToAbsent || linkedDebtId != null) {
      map['linked_debt_id'] = Variable<int>(linkedDebtId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      description: Value(description),
      amount: Value(amount),
      date: Value(date),
      direction: Value(direction),
      source: Value(source),
      transactionKind: Value(transactionKind),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      spendingType: spendingType == null && nullToAbsent
          ? const Value.absent()
          : Value(spendingType),
      linkedDebtId: linkedDebtId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedDebtId),
      createdAt: Value(createdAt),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      direction: serializer.fromJson<String>(json['direction']),
      source: serializer.fromJson<String>(json['source']),
      transactionKind: serializer.fromJson<String>(json['transactionKind']),
      category: serializer.fromJson<String?>(json['category']),
      spendingType: serializer.fromJson<String?>(json['spendingType']),
      linkedDebtId: serializer.fromJson<int?>(json['linkedDebtId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'direction': serializer.toJson<String>(direction),
      'source': serializer.toJson<String>(source),
      'transactionKind': serializer.toJson<String>(transactionKind),
      'category': serializer.toJson<String?>(category),
      'spendingType': serializer.toJson<String?>(spendingType),
      'linkedDebtId': serializer.toJson<int?>(linkedDebtId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Transaction copyWith({
    int? id,
    String? description,
    double? amount,
    DateTime? date,
    String? direction,
    String? source,
    String? transactionKind,
    Value<String?> category = const Value.absent(),
    Value<String?> spendingType = const Value.absent(),
    Value<int?> linkedDebtId = const Value.absent(),
    DateTime? createdAt,
  }) => Transaction(
    id: id ?? this.id,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    direction: direction ?? this.direction,
    source: source ?? this.source,
    transactionKind: transactionKind ?? this.transactionKind,
    category: category.present ? category.value : this.category,
    spendingType: spendingType.present ? spendingType.value : this.spendingType,
    linkedDebtId: linkedDebtId.present ? linkedDebtId.value : this.linkedDebtId,
    createdAt: createdAt ?? this.createdAt,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      description: data.description.present
          ? data.description.value
          : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      direction: data.direction.present ? data.direction.value : this.direction,
      source: data.source.present ? data.source.value : this.source,
      transactionKind: data.transactionKind.present
          ? data.transactionKind.value
          : this.transactionKind,
      category: data.category.present ? data.category.value : this.category,
      spendingType: data.spendingType.present
          ? data.spendingType.value
          : this.spendingType,
      linkedDebtId: data.linkedDebtId.present
          ? data.linkedDebtId.value
          : this.linkedDebtId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('direction: $direction, ')
          ..write('source: $source, ')
          ..write('transactionKind: $transactionKind, ')
          ..write('category: $category, ')
          ..write('spendingType: $spendingType, ')
          ..write('linkedDebtId: $linkedDebtId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    description,
    amount,
    date,
    direction,
    source,
    transactionKind,
    category,
    spendingType,
    linkedDebtId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.direction == this.direction &&
          other.source == this.source &&
          other.transactionKind == this.transactionKind &&
          other.category == this.category &&
          other.spendingType == this.spendingType &&
          other.linkedDebtId == this.linkedDebtId &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<String> description;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String> direction;
  final Value<String> source;
  final Value<String> transactionKind;
  final Value<String?> category;
  final Value<String?> spendingType;
  final Value<int?> linkedDebtId;
  final Value<DateTime> createdAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.direction = const Value.absent(),
    this.source = const Value.absent(),
    this.transactionKind = const Value.absent(),
    this.category = const Value.absent(),
    this.spendingType = const Value.absent(),
    this.linkedDebtId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required String description,
    required double amount,
    required DateTime date,
    required String direction,
    required String source,
    this.transactionKind = const Value.absent(),
    this.category = const Value.absent(),
    this.spendingType = const Value.absent(),
    this.linkedDebtId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : description = Value(description),
       amount = Value(amount),
       date = Value(date),
       direction = Value(direction),
       source = Value(source);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? direction,
    Expression<String>? source,
    Expression<String>? transactionKind,
    Expression<String>? category,
    Expression<String>? spendingType,
    Expression<int>? linkedDebtId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (direction != null) 'direction': direction,
      if (source != null) 'source': source,
      if (transactionKind != null) 'transaction_kind': transactionKind,
      if (category != null) 'category': category,
      if (spendingType != null) 'spending_type': spendingType,
      if (linkedDebtId != null) 'linked_debt_id': linkedDebtId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<String>? description,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String>? direction,
    Value<String>? source,
    Value<String>? transactionKind,
    Value<String?>? category,
    Value<String?>? spendingType,
    Value<int?>? linkedDebtId,
    Value<DateTime>? createdAt,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      direction: direction ?? this.direction,
      source: source ?? this.source,
      transactionKind: transactionKind ?? this.transactionKind,
      category: category ?? this.category,
      spendingType: spendingType ?? this.spendingType,
      linkedDebtId: linkedDebtId ?? this.linkedDebtId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (transactionKind.present) {
      map['transaction_kind'] = Variable<String>(transactionKind.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (spendingType.present) {
      map['spending_type'] = Variable<String>(spendingType.value);
    }
    if (linkedDebtId.present) {
      map['linked_debt_id'] = Variable<int>(linkedDebtId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('direction: $direction, ')
          ..write('source: $source, ')
          ..write('transactionKind: $transactionKind, ')
          ..write('category: $category, ')
          ..write('spendingType: $spendingType, ')
          ..write('linkedDebtId: $linkedDebtId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DebtsTable extends Debts with TableInfo<$DebtsTable, Debt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _personNameMeta = const VerificationMeta(
    'personName',
  );
  @override
  late final GeneratedColumn<String> personName = GeneratedColumn<String>(
    'person_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalAmountMeta = const VerificationMeta(
    'originalAmount',
  );
  @override
  late final GeneratedColumn<double> originalAmount = GeneratedColumn<double>(
    'original_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingBalanceMeta = const VerificationMeta(
    'remainingBalance',
  );
  @override
  late final GeneratedColumn<double> remainingBalance = GeneratedColumn<double>(
    'remaining_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCreatedMeta = const VerificationMeta(
    'dateCreated',
  );
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
    'date_created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personName,
    originalAmount,
    remainingBalance,
    description,
    dateCreated,
    type,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Debt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person_name')) {
      context.handle(
        _personNameMeta,
        personName.isAcceptableOrUnknown(data['person_name']!, _personNameMeta),
      );
    } else if (isInserting) {
      context.missing(_personNameMeta);
    }
    if (data.containsKey('original_amount')) {
      context.handle(
        _originalAmountMeta,
        originalAmount.isAcceptableOrUnknown(
          data['original_amount']!,
          _originalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalAmountMeta);
    }
    if (data.containsKey('remaining_balance')) {
      context.handle(
        _remainingBalanceMeta,
        remainingBalance.isAcceptableOrUnknown(
          data['remaining_balance']!,
          _remainingBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingBalanceMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
        _dateCreatedMeta,
        dateCreated.isAcceptableOrUnknown(
          data['date_created']!,
          _dateCreatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateCreatedMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Debt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Debt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      personName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_name'],
      )!,
      originalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}original_amount'],
      )!,
      remainingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}remaining_balance'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      dateCreated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_created'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DebtsTable createAlias(String alias) {
    return $DebtsTable(attachedDatabase, alias);
  }
}

class Debt extends DataClass implements Insertable<Debt> {
  final int id;
  final String personName;
  final double originalAmount;
  final double remainingBalance;
  final String description;
  final DateTime dateCreated;
  final String type;
  final String status;
  final DateTime createdAt;
  const Debt({
    required this.id,
    required this.personName,
    required this.originalAmount,
    required this.remainingBalance,
    required this.description,
    required this.dateCreated,
    required this.type,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person_name'] = Variable<String>(personName);
    map['original_amount'] = Variable<double>(originalAmount);
    map['remaining_balance'] = Variable<double>(remainingBalance);
    map['description'] = Variable<String>(description);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DebtsCompanion toCompanion(bool nullToAbsent) {
    return DebtsCompanion(
      id: Value(id),
      personName: Value(personName),
      originalAmount: Value(originalAmount),
      remainingBalance: Value(remainingBalance),
      description: Value(description),
      dateCreated: Value(dateCreated),
      type: Value(type),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Debt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Debt(
      id: serializer.fromJson<int>(json['id']),
      personName: serializer.fromJson<String>(json['personName']),
      originalAmount: serializer.fromJson<double>(json['originalAmount']),
      remainingBalance: serializer.fromJson<double>(json['remainingBalance']),
      description: serializer.fromJson<String>(json['description']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'personName': serializer.toJson<String>(personName),
      'originalAmount': serializer.toJson<double>(originalAmount),
      'remainingBalance': serializer.toJson<double>(remainingBalance),
      'description': serializer.toJson<String>(description),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Debt copyWith({
    int? id,
    String? personName,
    double? originalAmount,
    double? remainingBalance,
    String? description,
    DateTime? dateCreated,
    String? type,
    String? status,
    DateTime? createdAt,
  }) => Debt(
    id: id ?? this.id,
    personName: personName ?? this.personName,
    originalAmount: originalAmount ?? this.originalAmount,
    remainingBalance: remainingBalance ?? this.remainingBalance,
    description: description ?? this.description,
    dateCreated: dateCreated ?? this.dateCreated,
    type: type ?? this.type,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  Debt copyWithCompanion(DebtsCompanion data) {
    return Debt(
      id: data.id.present ? data.id.value : this.id,
      personName: data.personName.present
          ? data.personName.value
          : this.personName,
      originalAmount: data.originalAmount.present
          ? data.originalAmount.value
          : this.originalAmount,
      remainingBalance: data.remainingBalance.present
          ? data.remainingBalance.value
          : this.remainingBalance,
      description: data.description.present
          ? data.description.value
          : this.description,
      dateCreated: data.dateCreated.present
          ? data.dateCreated.value
          : this.dateCreated,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Debt(')
          ..write('id: $id, ')
          ..write('personName: $personName, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('remainingBalance: $remainingBalance, ')
          ..write('description: $description, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personName,
    originalAmount,
    remainingBalance,
    description,
    dateCreated,
    type,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Debt &&
          other.id == this.id &&
          other.personName == this.personName &&
          other.originalAmount == this.originalAmount &&
          other.remainingBalance == this.remainingBalance &&
          other.description == this.description &&
          other.dateCreated == this.dateCreated &&
          other.type == this.type &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class DebtsCompanion extends UpdateCompanion<Debt> {
  final Value<int> id;
  final Value<String> personName;
  final Value<double> originalAmount;
  final Value<double> remainingBalance;
  final Value<String> description;
  final Value<DateTime> dateCreated;
  final Value<String> type;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const DebtsCompanion({
    this.id = const Value.absent(),
    this.personName = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.remainingBalance = const Value.absent(),
    this.description = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DebtsCompanion.insert({
    this.id = const Value.absent(),
    required String personName,
    required double originalAmount,
    required double remainingBalance,
    required String description,
    required DateTime dateCreated,
    required String type,
    required String status,
    this.createdAt = const Value.absent(),
  }) : personName = Value(personName),
       originalAmount = Value(originalAmount),
       remainingBalance = Value(remainingBalance),
       description = Value(description),
       dateCreated = Value(dateCreated),
       type = Value(type),
       status = Value(status);
  static Insertable<Debt> custom({
    Expression<int>? id,
    Expression<String>? personName,
    Expression<double>? originalAmount,
    Expression<double>? remainingBalance,
    Expression<String>? description,
    Expression<DateTime>? dateCreated,
    Expression<String>? type,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personName != null) 'person_name': personName,
      if (originalAmount != null) 'original_amount': originalAmount,
      if (remainingBalance != null) 'remaining_balance': remainingBalance,
      if (description != null) 'description': description,
      if (dateCreated != null) 'date_created': dateCreated,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DebtsCompanion copyWith({
    Value<int>? id,
    Value<String>? personName,
    Value<double>? originalAmount,
    Value<double>? remainingBalance,
    Value<String>? description,
    Value<DateTime>? dateCreated,
    Value<String>? type,
    Value<String>? status,
    Value<DateTime>? createdAt,
  }) {
    return DebtsCompanion(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      originalAmount: originalAmount ?? this.originalAmount,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      description: description ?? this.description,
      dateCreated: dateCreated ?? this.dateCreated,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (personName.present) {
      map['person_name'] = Variable<String>(personName.value);
    }
    if (originalAmount.present) {
      map['original_amount'] = Variable<double>(originalAmount.value);
    }
    if (remainingBalance.present) {
      map['remaining_balance'] = Variable<double>(remainingBalance.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsCompanion(')
          ..write('id: $id, ')
          ..write('personName: $personName, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('remainingBalance: $remainingBalance, ')
          ..write('description: $description, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NotificationQueueTable extends NotificationQueue
    with TableInfo<$NotificationQueueTable, NotificationQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceOrDestinationMeta =
      const VerificationMeta('sourceOrDestination');
  @override
  late final GeneratedColumn<String> sourceOrDestination =
      GeneratedColumn<String>(
        'source_or_destination',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _detectedAmountMeta = const VerificationMeta(
    'detectedAmount',
  );
  @override
  late final GeneratedColumn<double> detectedAmount = GeneratedColumn<double>(
    'detected_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detectedDirectionMeta = const VerificationMeta(
    'detectedDirection',
  );
  @override
  late final GeneratedColumn<String> detectedDirection =
      GeneratedColumn<String>(
        'detected_direction',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _detectedTimeMeta = const VerificationMeta(
    'detectedTime',
  );
  @override
  late final GeneratedColumn<DateTime> detectedTime = GeneratedColumn<DateTime>(
    'detected_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detectionStatusMeta = const VerificationMeta(
    'detectionStatus',
  );
  @override
  late final GeneratedColumn<String> detectionStatus = GeneratedColumn<String>(
    'detection_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rawText,
    sourceOrDestination,
    detectedAmount,
    detectedDirection,
    detectedTime,
    detectionStatus,
    receivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('source_or_destination')) {
      context.handle(
        _sourceOrDestinationMeta,
        sourceOrDestination.isAcceptableOrUnknown(
          data['source_or_destination']!,
          _sourceOrDestinationMeta,
        ),
      );
    }
    if (data.containsKey('detected_amount')) {
      context.handle(
        _detectedAmountMeta,
        detectedAmount.isAcceptableOrUnknown(
          data['detected_amount']!,
          _detectedAmountMeta,
        ),
      );
    }
    if (data.containsKey('detected_direction')) {
      context.handle(
        _detectedDirectionMeta,
        detectedDirection.isAcceptableOrUnknown(
          data['detected_direction']!,
          _detectedDirectionMeta,
        ),
      );
    }
    if (data.containsKey('detected_time')) {
      context.handle(
        _detectedTimeMeta,
        detectedTime.isAcceptableOrUnknown(
          data['detected_time']!,
          _detectedTimeMeta,
        ),
      );
    }
    if (data.containsKey('detection_status')) {
      context.handle(
        _detectionStatusMeta,
        detectionStatus.isAcceptableOrUnknown(
          data['detection_status']!,
          _detectionStatusMeta,
        ),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      )!,
      sourceOrDestination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_or_destination'],
      ),
      detectedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}detected_amount'],
      ),
      detectedDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detected_direction'],
      ),
      detectedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_time'],
      ),
      detectionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detection_status'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
    );
  }

  @override
  $NotificationQueueTable createAlias(String alias) {
    return $NotificationQueueTable(attachedDatabase, alias);
  }
}

class NotificationQueueData extends DataClass
    implements Insertable<NotificationQueueData> {
  final int id;
  final String rawText;
  final String? sourceOrDestination;
  final double? detectedAmount;
  final String? detectedDirection;
  final DateTime? detectedTime;
  final String detectionStatus;
  final DateTime receivedAt;
  const NotificationQueueData({
    required this.id,
    required this.rawText,
    this.sourceOrDestination,
    this.detectedAmount,
    this.detectedDirection,
    this.detectedTime,
    required this.detectionStatus,
    required this.receivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['raw_text'] = Variable<String>(rawText);
    if (!nullToAbsent || sourceOrDestination != null) {
      map['source_or_destination'] = Variable<String>(sourceOrDestination);
    }
    if (!nullToAbsent || detectedAmount != null) {
      map['detected_amount'] = Variable<double>(detectedAmount);
    }
    if (!nullToAbsent || detectedDirection != null) {
      map['detected_direction'] = Variable<String>(detectedDirection);
    }
    if (!nullToAbsent || detectedTime != null) {
      map['detected_time'] = Variable<DateTime>(detectedTime);
    }
    map['detection_status'] = Variable<String>(detectionStatus);
    map['received_at'] = Variable<DateTime>(receivedAt);
    return map;
  }

  NotificationQueueCompanion toCompanion(bool nullToAbsent) {
    return NotificationQueueCompanion(
      id: Value(id),
      rawText: Value(rawText),
      sourceOrDestination: sourceOrDestination == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceOrDestination),
      detectedAmount: detectedAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(detectedAmount),
      detectedDirection: detectedDirection == null && nullToAbsent
          ? const Value.absent()
          : Value(detectedDirection),
      detectedTime: detectedTime == null && nullToAbsent
          ? const Value.absent()
          : Value(detectedTime),
      detectionStatus: Value(detectionStatus),
      receivedAt: Value(receivedAt),
    );
  }

  factory NotificationQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationQueueData(
      id: serializer.fromJson<int>(json['id']),
      rawText: serializer.fromJson<String>(json['rawText']),
      sourceOrDestination: serializer.fromJson<String?>(
        json['sourceOrDestination'],
      ),
      detectedAmount: serializer.fromJson<double?>(json['detectedAmount']),
      detectedDirection: serializer.fromJson<String?>(
        json['detectedDirection'],
      ),
      detectedTime: serializer.fromJson<DateTime?>(json['detectedTime']),
      detectionStatus: serializer.fromJson<String>(json['detectionStatus']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rawText': serializer.toJson<String>(rawText),
      'sourceOrDestination': serializer.toJson<String?>(sourceOrDestination),
      'detectedAmount': serializer.toJson<double?>(detectedAmount),
      'detectedDirection': serializer.toJson<String?>(detectedDirection),
      'detectedTime': serializer.toJson<DateTime?>(detectedTime),
      'detectionStatus': serializer.toJson<String>(detectionStatus),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
    };
  }

  NotificationQueueData copyWith({
    int? id,
    String? rawText,
    Value<String?> sourceOrDestination = const Value.absent(),
    Value<double?> detectedAmount = const Value.absent(),
    Value<String?> detectedDirection = const Value.absent(),
    Value<DateTime?> detectedTime = const Value.absent(),
    String? detectionStatus,
    DateTime? receivedAt,
  }) => NotificationQueueData(
    id: id ?? this.id,
    rawText: rawText ?? this.rawText,
    sourceOrDestination: sourceOrDestination.present
        ? sourceOrDestination.value
        : this.sourceOrDestination,
    detectedAmount: detectedAmount.present
        ? detectedAmount.value
        : this.detectedAmount,
    detectedDirection: detectedDirection.present
        ? detectedDirection.value
        : this.detectedDirection,
    detectedTime: detectedTime.present ? detectedTime.value : this.detectedTime,
    detectionStatus: detectionStatus ?? this.detectionStatus,
    receivedAt: receivedAt ?? this.receivedAt,
  );
  NotificationQueueData copyWithCompanion(NotificationQueueCompanion data) {
    return NotificationQueueData(
      id: data.id.present ? data.id.value : this.id,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      sourceOrDestination: data.sourceOrDestination.present
          ? data.sourceOrDestination.value
          : this.sourceOrDestination,
      detectedAmount: data.detectedAmount.present
          ? data.detectedAmount.value
          : this.detectedAmount,
      detectedDirection: data.detectedDirection.present
          ? data.detectedDirection.value
          : this.detectedDirection,
      detectedTime: data.detectedTime.present
          ? data.detectedTime.value
          : this.detectedTime,
      detectionStatus: data.detectionStatus.present
          ? data.detectionStatus.value
          : this.detectionStatus,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationQueueData(')
          ..write('id: $id, ')
          ..write('rawText: $rawText, ')
          ..write('sourceOrDestination: $sourceOrDestination, ')
          ..write('detectedAmount: $detectedAmount, ')
          ..write('detectedDirection: $detectedDirection, ')
          ..write('detectedTime: $detectedTime, ')
          ..write('detectionStatus: $detectionStatus, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rawText,
    sourceOrDestination,
    detectedAmount,
    detectedDirection,
    detectedTime,
    detectionStatus,
    receivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationQueueData &&
          other.id == this.id &&
          other.rawText == this.rawText &&
          other.sourceOrDestination == this.sourceOrDestination &&
          other.detectedAmount == this.detectedAmount &&
          other.detectedDirection == this.detectedDirection &&
          other.detectedTime == this.detectedTime &&
          other.detectionStatus == this.detectionStatus &&
          other.receivedAt == this.receivedAt);
}

class NotificationQueueCompanion
    extends UpdateCompanion<NotificationQueueData> {
  final Value<int> id;
  final Value<String> rawText;
  final Value<String?> sourceOrDestination;
  final Value<double?> detectedAmount;
  final Value<String?> detectedDirection;
  final Value<DateTime?> detectedTime;
  final Value<String> detectionStatus;
  final Value<DateTime> receivedAt;
  const NotificationQueueCompanion({
    this.id = const Value.absent(),
    this.rawText = const Value.absent(),
    this.sourceOrDestination = const Value.absent(),
    this.detectedAmount = const Value.absent(),
    this.detectedDirection = const Value.absent(),
    this.detectedTime = const Value.absent(),
    this.detectionStatus = const Value.absent(),
    this.receivedAt = const Value.absent(),
  });
  NotificationQueueCompanion.insert({
    this.id = const Value.absent(),
    required String rawText,
    this.sourceOrDestination = const Value.absent(),
    this.detectedAmount = const Value.absent(),
    this.detectedDirection = const Value.absent(),
    this.detectedTime = const Value.absent(),
    this.detectionStatus = const Value.absent(),
    this.receivedAt = const Value.absent(),
  }) : rawText = Value(rawText);
  static Insertable<NotificationQueueData> custom({
    Expression<int>? id,
    Expression<String>? rawText,
    Expression<String>? sourceOrDestination,
    Expression<double>? detectedAmount,
    Expression<String>? detectedDirection,
    Expression<DateTime>? detectedTime,
    Expression<String>? detectionStatus,
    Expression<DateTime>? receivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawText != null) 'raw_text': rawText,
      if (sourceOrDestination != null)
        'source_or_destination': sourceOrDestination,
      if (detectedAmount != null) 'detected_amount': detectedAmount,
      if (detectedDirection != null) 'detected_direction': detectedDirection,
      if (detectedTime != null) 'detected_time': detectedTime,
      if (detectionStatus != null) 'detection_status': detectionStatus,
      if (receivedAt != null) 'received_at': receivedAt,
    });
  }

  NotificationQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? rawText,
    Value<String?>? sourceOrDestination,
    Value<double?>? detectedAmount,
    Value<String?>? detectedDirection,
    Value<DateTime?>? detectedTime,
    Value<String>? detectionStatus,
    Value<DateTime>? receivedAt,
  }) {
    return NotificationQueueCompanion(
      id: id ?? this.id,
      rawText: rawText ?? this.rawText,
      sourceOrDestination: sourceOrDestination ?? this.sourceOrDestination,
      detectedAmount: detectedAmount ?? this.detectedAmount,
      detectedDirection: detectedDirection ?? this.detectedDirection,
      detectedTime: detectedTime ?? this.detectedTime,
      detectionStatus: detectionStatus ?? this.detectionStatus,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (sourceOrDestination.present) {
      map['source_or_destination'] = Variable<String>(
        sourceOrDestination.value,
      );
    }
    if (detectedAmount.present) {
      map['detected_amount'] = Variable<double>(detectedAmount.value);
    }
    if (detectedDirection.present) {
      map['detected_direction'] = Variable<String>(detectedDirection.value);
    }
    if (detectedTime.present) {
      map['detected_time'] = Variable<DateTime>(detectedTime.value);
    }
    if (detectionStatus.present) {
      map['detection_status'] = Variable<String>(detectionStatus.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationQueueCompanion(')
          ..write('id: $id, ')
          ..write('rawText: $rawText, ')
          ..write('sourceOrDestination: $sourceOrDestination, ')
          ..write('detectedAmount: $detectedAmount, ')
          ..write('detectedDirection: $detectedDirection, ')
          ..write('detectedTime: $detectedTime, ')
          ..write('detectionStatus: $detectionStatus, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $DebtsTable debts = $DebtsTable(this);
  late final $NotificationQueueTable notificationQueue =
      $NotificationQueueTable(this);
  late final TransactionsDao transactionsDao = TransactionsDao(
    this as AppDatabase,
  );
  late final DebtsDao debtsDao = DebtsDao(this as AppDatabase);
  late final NotificationQueueDao notificationQueueDao = NotificationQueueDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactions,
    debts,
    notificationQueue,
  ];
}

typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required String description,
      required double amount,
      required DateTime date,
      required String direction,
      required String source,
      Value<String> transactionKind,
      Value<String?> category,
      Value<String?> spendingType,
      Value<int?> linkedDebtId,
      Value<DateTime> createdAt,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<String> description,
      Value<double> amount,
      Value<DateTime> date,
      Value<String> direction,
      Value<String> source,
      Value<String> transactionKind,
      Value<String?> category,
      Value<String?> spendingType,
      Value<int?> linkedDebtId,
      Value<DateTime> createdAt,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionKind => $composableBuilder(
    column: $table.transactionKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spendingType => $composableBuilder(
    column: $table.spendingType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedDebtId => $composableBuilder(
    column: $table.linkedDebtId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionKind => $composableBuilder(
    column: $table.transactionKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spendingType => $composableBuilder(
    column: $table.spendingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedDebtId => $composableBuilder(
    column: $table.linkedDebtId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get transactionKind => $composableBuilder(
    column: $table.transactionKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get spendingType => $composableBuilder(
    column: $table.spendingType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get linkedDebtId => $composableBuilder(
    column: $table.linkedDebtId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> transactionKind = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> spendingType = const Value.absent(),
                Value<int?> linkedDebtId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                description: description,
                amount: amount,
                date: date,
                direction: direction,
                source: source,
                transactionKind: transactionKind,
                category: category,
                spendingType: spendingType,
                linkedDebtId: linkedDebtId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String description,
                required double amount,
                required DateTime date,
                required String direction,
                required String source,
                Value<String> transactionKind = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> spendingType = const Value.absent(),
                Value<int?> linkedDebtId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                description: description,
                amount: amount,
                date: date,
                direction: direction,
                source: source,
                transactionKind: transactionKind,
                category: category,
                spendingType: spendingType,
                linkedDebtId: linkedDebtId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$DebtsTableCreateCompanionBuilder =
    DebtsCompanion Function({
      Value<int> id,
      required String personName,
      required double originalAmount,
      required double remainingBalance,
      required String description,
      required DateTime dateCreated,
      required String type,
      required String status,
      Value<DateTime> createdAt,
    });
typedef $$DebtsTableUpdateCompanionBuilder =
    DebtsCompanion Function({
      Value<int> id,
      Value<String> personName,
      Value<double> originalAmount,
      Value<double> remainingBalance,
      Value<String> description,
      Value<DateTime> dateCreated,
      Value<String> type,
      Value<String> status,
      Value<DateTime> createdAt,
    });

class $$DebtsTableFilterComposer extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get remainingBalance => $composableBuilder(
    column: $table.remainingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DebtsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get remainingBalance => $composableBuilder(
    column: $table.remainingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get remainingBalance => $composableBuilder(
    column: $table.remainingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateCreated => $composableBuilder(
    column: $table.dateCreated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DebtsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtsTable,
          Debt,
          $$DebtsTableFilterComposer,
          $$DebtsTableOrderingComposer,
          $$DebtsTableAnnotationComposer,
          $$DebtsTableCreateCompanionBuilder,
          $$DebtsTableUpdateCompanionBuilder,
          (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
          Debt,
          PrefetchHooks Function()
        > {
  $$DebtsTableTableManager(_$AppDatabase db, $DebtsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> personName = const Value.absent(),
                Value<double> originalAmount = const Value.absent(),
                Value<double> remainingBalance = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> dateCreated = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DebtsCompanion(
                id: id,
                personName: personName,
                originalAmount: originalAmount,
                remainingBalance: remainingBalance,
                description: description,
                dateCreated: dateCreated,
                type: type,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String personName,
                required double originalAmount,
                required double remainingBalance,
                required String description,
                required DateTime dateCreated,
                required String type,
                required String status,
                Value<DateTime> createdAt = const Value.absent(),
              }) => DebtsCompanion.insert(
                id: id,
                personName: personName,
                originalAmount: originalAmount,
                remainingBalance: remainingBalance,
                description: description,
                dateCreated: dateCreated,
                type: type,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DebtsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtsTable,
      Debt,
      $$DebtsTableFilterComposer,
      $$DebtsTableOrderingComposer,
      $$DebtsTableAnnotationComposer,
      $$DebtsTableCreateCompanionBuilder,
      $$DebtsTableUpdateCompanionBuilder,
      (Debt, BaseReferences<_$AppDatabase, $DebtsTable, Debt>),
      Debt,
      PrefetchHooks Function()
    >;
typedef $$NotificationQueueTableCreateCompanionBuilder =
    NotificationQueueCompanion Function({
      Value<int> id,
      required String rawText,
      Value<String?> sourceOrDestination,
      Value<double?> detectedAmount,
      Value<String?> detectedDirection,
      Value<DateTime?> detectedTime,
      Value<String> detectionStatus,
      Value<DateTime> receivedAt,
    });
typedef $$NotificationQueueTableUpdateCompanionBuilder =
    NotificationQueueCompanion Function({
      Value<int> id,
      Value<String> rawText,
      Value<String?> sourceOrDestination,
      Value<double?> detectedAmount,
      Value<String?> detectedDirection,
      Value<DateTime?> detectedTime,
      Value<String> detectionStatus,
      Value<DateTime> receivedAt,
    });

class $$NotificationQueueTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationQueueTable> {
  $$NotificationQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceOrDestination => $composableBuilder(
    column: $table.sourceOrDestination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get detectedAmount => $composableBuilder(
    column: $table.detectedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detectedDirection => $composableBuilder(
    column: $table.detectedDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedTime => $composableBuilder(
    column: $table.detectedTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detectionStatus => $composableBuilder(
    column: $table.detectionStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationQueueTable> {
  $$NotificationQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceOrDestination => $composableBuilder(
    column: $table.sourceOrDestination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get detectedAmount => $composableBuilder(
    column: $table.detectedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detectedDirection => $composableBuilder(
    column: $table.detectedDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedTime => $composableBuilder(
    column: $table.detectedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detectionStatus => $composableBuilder(
    column: $table.detectionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationQueueTable> {
  $$NotificationQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get sourceOrDestination => $composableBuilder(
    column: $table.sourceOrDestination,
    builder: (column) => column,
  );

  GeneratedColumn<double> get detectedAmount => $composableBuilder(
    column: $table.detectedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detectedDirection => $composableBuilder(
    column: $table.detectedDirection,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectedTime => $composableBuilder(
    column: $table.detectedTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detectionStatus => $composableBuilder(
    column: $table.detectionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );
}

class $$NotificationQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationQueueTable,
          NotificationQueueData,
          $$NotificationQueueTableFilterComposer,
          $$NotificationQueueTableOrderingComposer,
          $$NotificationQueueTableAnnotationComposer,
          $$NotificationQueueTableCreateCompanionBuilder,
          $$NotificationQueueTableUpdateCompanionBuilder,
          (
            NotificationQueueData,
            BaseReferences<
              _$AppDatabase,
              $NotificationQueueTable,
              NotificationQueueData
            >,
          ),
          NotificationQueueData,
          PrefetchHooks Function()
        > {
  $$NotificationQueueTableTableManager(
    _$AppDatabase db,
    $NotificationQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationQueueTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<String?> sourceOrDestination = const Value.absent(),
                Value<double?> detectedAmount = const Value.absent(),
                Value<String?> detectedDirection = const Value.absent(),
                Value<DateTime?> detectedTime = const Value.absent(),
                Value<String> detectionStatus = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
              }) => NotificationQueueCompanion(
                id: id,
                rawText: rawText,
                sourceOrDestination: sourceOrDestination,
                detectedAmount: detectedAmount,
                detectedDirection: detectedDirection,
                detectedTime: detectedTime,
                detectionStatus: detectionStatus,
                receivedAt: receivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String rawText,
                Value<String?> sourceOrDestination = const Value.absent(),
                Value<double?> detectedAmount = const Value.absent(),
                Value<String?> detectedDirection = const Value.absent(),
                Value<DateTime?> detectedTime = const Value.absent(),
                Value<String> detectionStatus = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
              }) => NotificationQueueCompanion.insert(
                id: id,
                rawText: rawText,
                sourceOrDestination: sourceOrDestination,
                detectedAmount: detectedAmount,
                detectedDirection: detectedDirection,
                detectedTime: detectedTime,
                detectionStatus: detectionStatus,
                receivedAt: receivedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationQueueTable,
      NotificationQueueData,
      $$NotificationQueueTableFilterComposer,
      $$NotificationQueueTableOrderingComposer,
      $$NotificationQueueTableAnnotationComposer,
      $$NotificationQueueTableCreateCompanionBuilder,
      $$NotificationQueueTableUpdateCompanionBuilder,
      (
        NotificationQueueData,
        BaseReferences<
          _$AppDatabase,
          $NotificationQueueTable,
          NotificationQueueData
        >,
      ),
      NotificationQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db, _db.debts);
  $$NotificationQueueTableTableManager get notificationQueue =>
      $$NotificationQueueTableTableManager(_db, _db.notificationQueue);
}

mixin _$TransactionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TransactionsTable get transactions => attachedDatabase.transactions;
  TransactionsDaoManager get managers => TransactionsDaoManager(this);
}

class TransactionsDaoManager {
  final _$TransactionsDaoMixin _db;
  TransactionsDaoManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
}

mixin _$DebtsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DebtsTable get debts => attachedDatabase.debts;
  DebtsDaoManager get managers => DebtsDaoManager(this);
}

class DebtsDaoManager {
  final _$DebtsDaoMixin _db;
  DebtsDaoManager(this._db);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db.attachedDatabase, _db.debts);
}

mixin _$NotificationQueueDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotificationQueueTable get notificationQueue =>
      attachedDatabase.notificationQueue;
  NotificationQueueDaoManager get managers => NotificationQueueDaoManager(this);
}

class NotificationQueueDaoManager {
  final _$NotificationQueueDaoMixin _db;
  NotificationQueueDaoManager(this._db);
  $$NotificationQueueTableTableManager get notificationQueue =>
      $$NotificationQueueTableTableManager(
        _db.attachedDatabase,
        _db.notificationQueue,
      );
}

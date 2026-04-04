// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SshKeysTable extends SshKeys with TableInfo<$SshKeysTable, SshKey> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SshKeysTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<KeyType, String> keyType =
      GeneratedColumn<String>(
        'key_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<KeyType>($SshKeysTable.$converterkeyType);
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedPrivateKeyMeta =
      const VerificationMeta('encryptedPrivateKey');
  @override
  late final GeneratedColumn<String> encryptedPrivateKey =
      GeneratedColumn<String>(
        'encrypted_private_key',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 128),
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
    label,
    keyType,
    publicKey,
    encryptedPrivateKey,
    fingerprint,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ssh_keys';
  @override
  VerificationContext validateIntegrity(
    Insertable<SshKey> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('encrypted_private_key')) {
      context.handle(
        _encryptedPrivateKeyMeta,
        encryptedPrivateKey.isAcceptableOrUnknown(
          data['encrypted_private_key']!,
          _encryptedPrivateKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedPrivateKeyMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {fingerprint},
  ];
  @override
  SshKey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SshKey(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      keyType: $SshKeysTable.$converterkeyType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}key_type'],
        )!,
      ),
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      )!,
      encryptedPrivateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_private_key'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SshKeysTable createAlias(String alias) {
    return $SshKeysTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<KeyType, String, String> $converterkeyType =
      const EnumNameConverter<KeyType>(KeyType.values);
}

class SshKey extends DataClass implements Insertable<SshKey> {
  final int id;
  final String label;
  final KeyType keyType;
  final String publicKey;

  /// The private key is encrypted at rest via AES-256-GCM.
  final String encryptedPrivateKey;
  final String fingerprint;
  final DateTime createdAt;
  const SshKey({
    required this.id,
    required this.label,
    required this.keyType,
    required this.publicKey,
    required this.encryptedPrivateKey,
    required this.fingerprint,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    {
      map['key_type'] = Variable<String>(
        $SshKeysTable.$converterkeyType.toSql(keyType),
      );
    }
    map['public_key'] = Variable<String>(publicKey);
    map['encrypted_private_key'] = Variable<String>(encryptedPrivateKey);
    map['fingerprint'] = Variable<String>(fingerprint);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SshKeysCompanion toCompanion(bool nullToAbsent) {
    return SshKeysCompanion(
      id: Value(id),
      label: Value(label),
      keyType: Value(keyType),
      publicKey: Value(publicKey),
      encryptedPrivateKey: Value(encryptedPrivateKey),
      fingerprint: Value(fingerprint),
      createdAt: Value(createdAt),
    );
  }

  factory SshKey.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SshKey(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      keyType: $SshKeysTable.$converterkeyType.fromJson(
        serializer.fromJson<String>(json['keyType']),
      ),
      publicKey: serializer.fromJson<String>(json['publicKey']),
      encryptedPrivateKey: serializer.fromJson<String>(
        json['encryptedPrivateKey'],
      ),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'keyType': serializer.toJson<String>(
        $SshKeysTable.$converterkeyType.toJson(keyType),
      ),
      'publicKey': serializer.toJson<String>(publicKey),
      'encryptedPrivateKey': serializer.toJson<String>(encryptedPrivateKey),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SshKey copyWith({
    int? id,
    String? label,
    KeyType? keyType,
    String? publicKey,
    String? encryptedPrivateKey,
    String? fingerprint,
    DateTime? createdAt,
  }) => SshKey(
    id: id ?? this.id,
    label: label ?? this.label,
    keyType: keyType ?? this.keyType,
    publicKey: publicKey ?? this.publicKey,
    encryptedPrivateKey: encryptedPrivateKey ?? this.encryptedPrivateKey,
    fingerprint: fingerprint ?? this.fingerprint,
    createdAt: createdAt ?? this.createdAt,
  );
  SshKey copyWithCompanion(SshKeysCompanion data) {
    return SshKey(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      keyType: data.keyType.present ? data.keyType.value : this.keyType,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      encryptedPrivateKey: data.encryptedPrivateKey.present
          ? data.encryptedPrivateKey.value
          : this.encryptedPrivateKey,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SshKey(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('keyType: $keyType, ')
          ..write('publicKey: $publicKey, ')
          ..write('encryptedPrivateKey: $encryptedPrivateKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    keyType,
    publicKey,
    encryptedPrivateKey,
    fingerprint,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SshKey &&
          other.id == this.id &&
          other.label == this.label &&
          other.keyType == this.keyType &&
          other.publicKey == this.publicKey &&
          other.encryptedPrivateKey == this.encryptedPrivateKey &&
          other.fingerprint == this.fingerprint &&
          other.createdAt == this.createdAt);
}

class SshKeysCompanion extends UpdateCompanion<SshKey> {
  final Value<int> id;
  final Value<String> label;
  final Value<KeyType> keyType;
  final Value<String> publicKey;
  final Value<String> encryptedPrivateKey;
  final Value<String> fingerprint;
  final Value<DateTime> createdAt;
  const SshKeysCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.keyType = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.encryptedPrivateKey = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SshKeysCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required KeyType keyType,
    required String publicKey,
    required String encryptedPrivateKey,
    required String fingerprint,
    this.createdAt = const Value.absent(),
  }) : label = Value(label),
       keyType = Value(keyType),
       publicKey = Value(publicKey),
       encryptedPrivateKey = Value(encryptedPrivateKey),
       fingerprint = Value(fingerprint);
  static Insertable<SshKey> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? keyType,
    Expression<String>? publicKey,
    Expression<String>? encryptedPrivateKey,
    Expression<String>? fingerprint,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (keyType != null) 'key_type': keyType,
      if (publicKey != null) 'public_key': publicKey,
      if (encryptedPrivateKey != null)
        'encrypted_private_key': encryptedPrivateKey,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SshKeysCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<KeyType>? keyType,
    Value<String>? publicKey,
    Value<String>? encryptedPrivateKey,
    Value<String>? fingerprint,
    Value<DateTime>? createdAt,
  }) {
    return SshKeysCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      keyType: keyType ?? this.keyType,
      publicKey: publicKey ?? this.publicKey,
      encryptedPrivateKey: encryptedPrivateKey ?? this.encryptedPrivateKey,
      fingerprint: fingerprint ?? this.fingerprint,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (keyType.present) {
      map['key_type'] = Variable<String>(
        $SshKeysTable.$converterkeyType.toSql(keyType.value),
      );
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (encryptedPrivateKey.present) {
      map['encrypted_private_key'] = Variable<String>(
        encryptedPrivateKey.value,
      );
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SshKeysCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('keyType: $keyType, ')
          ..write('publicKey: $publicKey, ')
          ..write('encryptedPrivateKey: $encryptedPrivateKey, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ServerCollectionsTable extends ServerCollections
    with TableInfo<$ServerCollectionsTable, ServerCollection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServerCollectionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 4,
      maxTextLength: 9,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'server_collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServerCollection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {name},
  ];
  @override
  ServerCollection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServerCollection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ServerCollectionsTable createAlias(String alias) {
    return $ServerCollectionsTable(attachedDatabase, alias);
  }
}

class ServerCollection extends DataClass
    implements Insertable<ServerCollection> {
  final int id;
  final String name;
  final String? color;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ServerCollection({
    required this.id,
    required this.name,
    this.color,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ServerCollectionsCompanion toCompanion(bool nullToAbsent) {
    return ServerCollectionsCompanion(
      id: Value(id),
      name: Value(name),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ServerCollection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServerCollection(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String?>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String?>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ServerCollection copyWith({
    int? id,
    String? name,
    Value<String?> color = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ServerCollection(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color.present ? color.value : this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ServerCollection copyWithCompanion(ServerCollectionsCompanion data) {
    return ServerCollection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerCollection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, color, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerCollection &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ServerCollectionsCompanion extends UpdateCompanion<ServerCollection> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> color;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ServerCollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ServerCollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ServerCollection> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ServerCollectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? color,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ServerCollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServerCollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ServersTable extends Servers with TableInfo<$ServersTable, Server> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(22),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 128,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AuthType, String> authType =
      GeneratedColumn<String>(
        'auth_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(AuthType.password.name),
      ).withConverter<AuthType>($ServersTable.$converterauthType);
  static const VerificationMeta _encryptedPasswordMeta = const VerificationMeta(
    'encryptedPassword',
  );
  @override
  late final GeneratedColumn<String> encryptedPassword =
      GeneratedColumn<String>(
        'encrypted_password',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sshKeyIdMeta = const VerificationMeta(
    'sshKeyId',
  );
  @override
  late final GeneratedColumn<int> sshKeyId = GeneratedColumn<int>(
    'ssh_key_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ssh_keys (id)',
    ),
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES server_collections (id)',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    host,
    port,
    username,
    authType,
    encryptedPassword,
    sshKeyId,
    collectionId,
    sortOrder,
    isFavorite,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'servers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Server> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('encrypted_password')) {
      context.handle(
        _encryptedPasswordMeta,
        encryptedPassword.isAcceptableOrUnknown(
          data['encrypted_password']!,
          _encryptedPasswordMeta,
        ),
      );
    }
    if (data.containsKey('ssh_key_id')) {
      context.handle(
        _sshKeyIdMeta,
        sshKeyId.isAcceptableOrUnknown(data['ssh_key_id']!, _sshKeyIdMeta),
      );
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Server map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Server(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      authType: $ServersTable.$converterauthType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}auth_type'],
        )!,
      ),
      encryptedPassword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_password'],
      ),
      sshKeyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ssh_key_id'],
      ),
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ServersTable createAlias(String alias) {
    return $ServersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AuthType, String, String> $converterauthType =
      const EnumNameConverter<AuthType>(AuthType.values);
}

class Server extends DataClass implements Insertable<Server> {
  final int id;
  final String label;
  final String host;
  final int port;
  final String username;
  final AuthType authType;
  final String? encryptedPassword;
  final int? sshKeyId;
  final int? collectionId;
  final int sortOrder;
  final bool isFavorite;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Server({
    required this.id,
    required this.label,
    required this.host,
    required this.port,
    required this.username,
    required this.authType,
    this.encryptedPassword,
    this.sshKeyId,
    this.collectionId,
    required this.sortOrder,
    required this.isFavorite,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['host'] = Variable<String>(host);
    map['port'] = Variable<int>(port);
    map['username'] = Variable<String>(username);
    {
      map['auth_type'] = Variable<String>(
        $ServersTable.$converterauthType.toSql(authType),
      );
    }
    if (!nullToAbsent || encryptedPassword != null) {
      map['encrypted_password'] = Variable<String>(encryptedPassword);
    }
    if (!nullToAbsent || sshKeyId != null) {
      map['ssh_key_id'] = Variable<int>(sshKeyId);
    }
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<int>(collectionId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ServersCompanion toCompanion(bool nullToAbsent) {
    return ServersCompanion(
      id: Value(id),
      label: Value(label),
      host: Value(host),
      port: Value(port),
      username: Value(username),
      authType: Value(authType),
      encryptedPassword: encryptedPassword == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedPassword),
      sshKeyId: sshKeyId == null && nullToAbsent
          ? const Value.absent()
          : Value(sshKeyId),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      sortOrder: Value(sortOrder),
      isFavorite: Value(isFavorite),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Server.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Server(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      host: serializer.fromJson<String>(json['host']),
      port: serializer.fromJson<int>(json['port']),
      username: serializer.fromJson<String>(json['username']),
      authType: $ServersTable.$converterauthType.fromJson(
        serializer.fromJson<String>(json['authType']),
      ),
      encryptedPassword: serializer.fromJson<String?>(
        json['encryptedPassword'],
      ),
      sshKeyId: serializer.fromJson<int?>(json['sshKeyId']),
      collectionId: serializer.fromJson<int?>(json['collectionId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'host': serializer.toJson<String>(host),
      'port': serializer.toJson<int>(port),
      'username': serializer.toJson<String>(username),
      'authType': serializer.toJson<String>(
        $ServersTable.$converterauthType.toJson(authType),
      ),
      'encryptedPassword': serializer.toJson<String?>(encryptedPassword),
      'sshKeyId': serializer.toJson<int?>(sshKeyId),
      'collectionId': serializer.toJson<int?>(collectionId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Server copyWith({
    int? id,
    String? label,
    String? host,
    int? port,
    String? username,
    AuthType? authType,
    Value<String?> encryptedPassword = const Value.absent(),
    Value<int?> sshKeyId = const Value.absent(),
    Value<int?> collectionId = const Value.absent(),
    int? sortOrder,
    bool? isFavorite,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Server(
    id: id ?? this.id,
    label: label ?? this.label,
    host: host ?? this.host,
    port: port ?? this.port,
    username: username ?? this.username,
    authType: authType ?? this.authType,
    encryptedPassword: encryptedPassword.present
        ? encryptedPassword.value
        : this.encryptedPassword,
    sshKeyId: sshKeyId.present ? sshKeyId.value : this.sshKeyId,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    sortOrder: sortOrder ?? this.sortOrder,
    isFavorite: isFavorite ?? this.isFavorite,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Server copyWithCompanion(ServersCompanion data) {
    return Server(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      host: data.host.present ? data.host.value : this.host,
      port: data.port.present ? data.port.value : this.port,
      username: data.username.present ? data.username.value : this.username,
      authType: data.authType.present ? data.authType.value : this.authType,
      encryptedPassword: data.encryptedPassword.present
          ? data.encryptedPassword.value
          : this.encryptedPassword,
      sshKeyId: data.sshKeyId.present ? data.sshKeyId.value : this.sshKeyId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Server(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('username: $username, ')
          ..write('authType: $authType, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('sshKeyId: $sshKeyId, ')
          ..write('collectionId: $collectionId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    host,
    port,
    username,
    authType,
    encryptedPassword,
    sshKeyId,
    collectionId,
    sortOrder,
    isFavorite,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Server &&
          other.id == this.id &&
          other.label == this.label &&
          other.host == this.host &&
          other.port == this.port &&
          other.username == this.username &&
          other.authType == this.authType &&
          other.encryptedPassword == this.encryptedPassword &&
          other.sshKeyId == this.sshKeyId &&
          other.collectionId == this.collectionId &&
          other.sortOrder == this.sortOrder &&
          other.isFavorite == this.isFavorite &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ServersCompanion extends UpdateCompanion<Server> {
  final Value<int> id;
  final Value<String> label;
  final Value<String> host;
  final Value<int> port;
  final Value<String> username;
  final Value<AuthType> authType;
  final Value<String?> encryptedPassword;
  final Value<int?> sshKeyId;
  final Value<int?> collectionId;
  final Value<int> sortOrder;
  final Value<bool> isFavorite;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ServersCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.host = const Value.absent(),
    this.port = const Value.absent(),
    this.username = const Value.absent(),
    this.authType = const Value.absent(),
    this.encryptedPassword = const Value.absent(),
    this.sshKeyId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ServersCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required String host,
    this.port = const Value.absent(),
    required String username,
    this.authType = const Value.absent(),
    this.encryptedPassword = const Value.absent(),
    this.sshKeyId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : label = Value(label),
       host = Value(host),
       username = Value(username);
  static Insertable<Server> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? host,
    Expression<int>? port,
    Expression<String>? username,
    Expression<String>? authType,
    Expression<String>? encryptedPassword,
    Expression<int>? sshKeyId,
    Expression<int>? collectionId,
    Expression<int>? sortOrder,
    Expression<bool>? isFavorite,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (username != null) 'username': username,
      if (authType != null) 'auth_type': authType,
      if (encryptedPassword != null) 'encrypted_password': encryptedPassword,
      if (sshKeyId != null) 'ssh_key_id': sshKeyId,
      if (collectionId != null) 'collection_id': collectionId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ServersCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String>? host,
    Value<int>? port,
    Value<String>? username,
    Value<AuthType>? authType,
    Value<String?>? encryptedPassword,
    Value<int?>? sshKeyId,
    Value<int?>? collectionId,
    Value<int>? sortOrder,
    Value<bool>? isFavorite,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ServersCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      authType: authType ?? this.authType,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      sshKeyId: sshKeyId ?? this.sshKeyId,
      collectionId: collectionId ?? this.collectionId,
      sortOrder: sortOrder ?? this.sortOrder,
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (authType.present) {
      map['auth_type'] = Variable<String>(
        $ServersTable.$converterauthType.toSql(authType.value),
      );
    }
    if (encryptedPassword.present) {
      map['encrypted_password'] = Variable<String>(encryptedPassword.value);
    }
    if (sshKeyId.present) {
      map['ssh_key_id'] = Variable<int>(sshKeyId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServersCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('username: $username, ')
          ..write('authType: $authType, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('sshKeyId: $sshKeyId, ')
          ..write('collectionId: $collectionId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $KnownHostsTable extends KnownHosts
    with TableInfo<$KnownHostsTable, KnownHost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KnownHostsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(22),
  );
  static const VerificationMeta _keyTypeMeta = const VerificationMeta(
    'keyType',
  );
  @override
  late final GeneratedColumn<String> keyType = GeneratedColumn<String>(
    'key_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostKeyFingerprintMeta =
      const VerificationMeta('hostKeyFingerprint');
  @override
  late final GeneratedColumn<String> hostKeyFingerprint =
      GeneratedColumn<String>(
        'host_key_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _firstSeenMeta = const VerificationMeta(
    'firstSeen',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeen = GeneratedColumn<DateTime>(
    'first_seen',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeen = GeneratedColumn<DateTime>(
    'last_seen',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    host,
    port,
    keyType,
    hostKeyFingerprint,
    firstSeen,
    lastSeen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'known_hosts';
  @override
  VerificationContext validateIntegrity(
    Insertable<KnownHost> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    }
    if (data.containsKey('key_type')) {
      context.handle(
        _keyTypeMeta,
        keyType.isAcceptableOrUnknown(data['key_type']!, _keyTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_keyTypeMeta);
    }
    if (data.containsKey('host_key_fingerprint')) {
      context.handle(
        _hostKeyFingerprintMeta,
        hostKeyFingerprint.isAcceptableOrUnknown(
          data['host_key_fingerprint']!,
          _hostKeyFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hostKeyFingerprintMeta);
    }
    if (data.containsKey('first_seen')) {
      context.handle(
        _firstSeenMeta,
        firstSeen.isAcceptableOrUnknown(data['first_seen']!, _firstSeenMeta),
      );
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {host, port, keyType},
  ];
  @override
  KnownHost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KnownHost(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      keyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_type'],
      )!,
      hostKeyFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host_key_fingerprint'],
      )!,
      firstSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen'],
      )!,
    );
  }

  @override
  $KnownHostsTable createAlias(String alias) {
    return $KnownHostsTable(attachedDatabase, alias);
  }
}

class KnownHost extends DataClass implements Insertable<KnownHost> {
  final int id;
  final String host;
  final int port;
  final String keyType;
  final String hostKeyFingerprint;
  final DateTime firstSeen;
  final DateTime lastSeen;
  const KnownHost({
    required this.id,
    required this.host,
    required this.port,
    required this.keyType,
    required this.hostKeyFingerprint,
    required this.firstSeen,
    required this.lastSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['host'] = Variable<String>(host);
    map['port'] = Variable<int>(port);
    map['key_type'] = Variable<String>(keyType);
    map['host_key_fingerprint'] = Variable<String>(hostKeyFingerprint);
    map['first_seen'] = Variable<DateTime>(firstSeen);
    map['last_seen'] = Variable<DateTime>(lastSeen);
    return map;
  }

  KnownHostsCompanion toCompanion(bool nullToAbsent) {
    return KnownHostsCompanion(
      id: Value(id),
      host: Value(host),
      port: Value(port),
      keyType: Value(keyType),
      hostKeyFingerprint: Value(hostKeyFingerprint),
      firstSeen: Value(firstSeen),
      lastSeen: Value(lastSeen),
    );
  }

  factory KnownHost.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KnownHost(
      id: serializer.fromJson<int>(json['id']),
      host: serializer.fromJson<String>(json['host']),
      port: serializer.fromJson<int>(json['port']),
      keyType: serializer.fromJson<String>(json['keyType']),
      hostKeyFingerprint: serializer.fromJson<String>(
        json['hostKeyFingerprint'],
      ),
      firstSeen: serializer.fromJson<DateTime>(json['firstSeen']),
      lastSeen: serializer.fromJson<DateTime>(json['lastSeen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'host': serializer.toJson<String>(host),
      'port': serializer.toJson<int>(port),
      'keyType': serializer.toJson<String>(keyType),
      'hostKeyFingerprint': serializer.toJson<String>(hostKeyFingerprint),
      'firstSeen': serializer.toJson<DateTime>(firstSeen),
      'lastSeen': serializer.toJson<DateTime>(lastSeen),
    };
  }

  KnownHost copyWith({
    int? id,
    String? host,
    int? port,
    String? keyType,
    String? hostKeyFingerprint,
    DateTime? firstSeen,
    DateTime? lastSeen,
  }) => KnownHost(
    id: id ?? this.id,
    host: host ?? this.host,
    port: port ?? this.port,
    keyType: keyType ?? this.keyType,
    hostKeyFingerprint: hostKeyFingerprint ?? this.hostKeyFingerprint,
    firstSeen: firstSeen ?? this.firstSeen,
    lastSeen: lastSeen ?? this.lastSeen,
  );
  KnownHost copyWithCompanion(KnownHostsCompanion data) {
    return KnownHost(
      id: data.id.present ? data.id.value : this.id,
      host: data.host.present ? data.host.value : this.host,
      port: data.port.present ? data.port.value : this.port,
      keyType: data.keyType.present ? data.keyType.value : this.keyType,
      hostKeyFingerprint: data.hostKeyFingerprint.present
          ? data.hostKeyFingerprint.value
          : this.hostKeyFingerprint,
      firstSeen: data.firstSeen.present ? data.firstSeen.value : this.firstSeen,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KnownHost(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('keyType: $keyType, ')
          ..write('hostKeyFingerprint: $hostKeyFingerprint, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    host,
    port,
    keyType,
    hostKeyFingerprint,
    firstSeen,
    lastSeen,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KnownHost &&
          other.id == this.id &&
          other.host == this.host &&
          other.port == this.port &&
          other.keyType == this.keyType &&
          other.hostKeyFingerprint == this.hostKeyFingerprint &&
          other.firstSeen == this.firstSeen &&
          other.lastSeen == this.lastSeen);
}

class KnownHostsCompanion extends UpdateCompanion<KnownHost> {
  final Value<int> id;
  final Value<String> host;
  final Value<int> port;
  final Value<String> keyType;
  final Value<String> hostKeyFingerprint;
  final Value<DateTime> firstSeen;
  final Value<DateTime> lastSeen;
  const KnownHostsCompanion({
    this.id = const Value.absent(),
    this.host = const Value.absent(),
    this.port = const Value.absent(),
    this.keyType = const Value.absent(),
    this.hostKeyFingerprint = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.lastSeen = const Value.absent(),
  });
  KnownHostsCompanion.insert({
    this.id = const Value.absent(),
    required String host,
    this.port = const Value.absent(),
    required String keyType,
    required String hostKeyFingerprint,
    this.firstSeen = const Value.absent(),
    this.lastSeen = const Value.absent(),
  }) : host = Value(host),
       keyType = Value(keyType),
       hostKeyFingerprint = Value(hostKeyFingerprint);
  static Insertable<KnownHost> custom({
    Expression<int>? id,
    Expression<String>? host,
    Expression<int>? port,
    Expression<String>? keyType,
    Expression<String>? hostKeyFingerprint,
    Expression<DateTime>? firstSeen,
    Expression<DateTime>? lastSeen,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (keyType != null) 'key_type': keyType,
      if (hostKeyFingerprint != null)
        'host_key_fingerprint': hostKeyFingerprint,
      if (firstSeen != null) 'first_seen': firstSeen,
      if (lastSeen != null) 'last_seen': lastSeen,
    });
  }

  KnownHostsCompanion copyWith({
    Value<int>? id,
    Value<String>? host,
    Value<int>? port,
    Value<String>? keyType,
    Value<String>? hostKeyFingerprint,
    Value<DateTime>? firstSeen,
    Value<DateTime>? lastSeen,
  }) {
    return KnownHostsCompanion(
      id: id ?? this.id,
      host: host ?? this.host,
      port: port ?? this.port,
      keyType: keyType ?? this.keyType,
      hostKeyFingerprint: hostKeyFingerprint ?? this.hostKeyFingerprint,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (keyType.present) {
      map['key_type'] = Variable<String>(keyType.value);
    }
    if (hostKeyFingerprint.present) {
      map['host_key_fingerprint'] = Variable<String>(hostKeyFingerprint.value);
    }
    if (firstSeen.present) {
      map['first_seen'] = Variable<DateTime>(firstSeen.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KnownHostsCompanion(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('keyType: $keyType, ')
          ..write('hostKeyFingerprint: $hostKeyFingerprint, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen')
          ..write(')'))
        .toString();
  }
}

class $ConnectionHistoryTable extends ConnectionHistory
    with TableInfo<$ConnectionHistoryTable, ConnectionHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConnectionHistoryTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES servers (id)',
    ),
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 128,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _connectedAtMeta = const VerificationMeta(
    'connectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> connectedAt = GeneratedColumn<DateTime>(
    'connected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _disconnectedAtMeta = const VerificationMeta(
    'disconnectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> disconnectedAt =
      GeneratedColumn<DateTime>(
        'disconnected_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _wasSuccessfulMeta = const VerificationMeta(
    'wasSuccessful',
  );
  @override
  late final GeneratedColumn<bool> wasSuccessful = GeneratedColumn<bool>(
    'was_successful',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_successful" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    host,
    port,
    username,
    connectedAt,
    disconnectedAt,
    wasSuccessful,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'connection_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConnectionHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    } else if (isInserting) {
      context.missing(_portMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('connected_at')) {
      context.handle(
        _connectedAtMeta,
        connectedAt.isAcceptableOrUnknown(
          data['connected_at']!,
          _connectedAtMeta,
        ),
      );
    }
    if (data.containsKey('disconnected_at')) {
      context.handle(
        _disconnectedAtMeta,
        disconnectedAt.isAcceptableOrUnknown(
          data['disconnected_at']!,
          _disconnectedAtMeta,
        ),
      );
    }
    if (data.containsKey('was_successful')) {
      context.handle(
        _wasSuccessfulMeta,
        wasSuccessful.isAcceptableOrUnknown(
          data['was_successful']!,
          _wasSuccessfulMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConnectionHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConnectionHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      connectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}connected_at'],
      )!,
      disconnectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}disconnected_at'],
      ),
      wasSuccessful: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_successful'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $ConnectionHistoryTable createAlias(String alias) {
    return $ConnectionHistoryTable(attachedDatabase, alias);
  }
}

class ConnectionHistoryData extends DataClass
    implements Insertable<ConnectionHistoryData> {
  final int id;
  final int? serverId;
  final String host;
  final int port;
  final String username;
  final DateTime connectedAt;
  final DateTime? disconnectedAt;
  final bool wasSuccessful;
  final String? errorMessage;
  const ConnectionHistoryData({
    required this.id,
    this.serverId,
    required this.host,
    required this.port,
    required this.username,
    required this.connectedAt,
    this.disconnectedAt,
    required this.wasSuccessful,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['host'] = Variable<String>(host);
    map['port'] = Variable<int>(port);
    map['username'] = Variable<String>(username);
    map['connected_at'] = Variable<DateTime>(connectedAt);
    if (!nullToAbsent || disconnectedAt != null) {
      map['disconnected_at'] = Variable<DateTime>(disconnectedAt);
    }
    map['was_successful'] = Variable<bool>(wasSuccessful);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  ConnectionHistoryCompanion toCompanion(bool nullToAbsent) {
    return ConnectionHistoryCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      host: Value(host),
      port: Value(port),
      username: Value(username),
      connectedAt: Value(connectedAt),
      disconnectedAt: disconnectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(disconnectedAt),
      wasSuccessful: Value(wasSuccessful),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory ConnectionHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConnectionHistoryData(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      host: serializer.fromJson<String>(json['host']),
      port: serializer.fromJson<int>(json['port']),
      username: serializer.fromJson<String>(json['username']),
      connectedAt: serializer.fromJson<DateTime>(json['connectedAt']),
      disconnectedAt: serializer.fromJson<DateTime?>(json['disconnectedAt']),
      wasSuccessful: serializer.fromJson<bool>(json['wasSuccessful']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'host': serializer.toJson<String>(host),
      'port': serializer.toJson<int>(port),
      'username': serializer.toJson<String>(username),
      'connectedAt': serializer.toJson<DateTime>(connectedAt),
      'disconnectedAt': serializer.toJson<DateTime?>(disconnectedAt),
      'wasSuccessful': serializer.toJson<bool>(wasSuccessful),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  ConnectionHistoryData copyWith({
    int? id,
    Value<int?> serverId = const Value.absent(),
    String? host,
    int? port,
    String? username,
    DateTime? connectedAt,
    Value<DateTime?> disconnectedAt = const Value.absent(),
    bool? wasSuccessful,
    Value<String?> errorMessage = const Value.absent(),
  }) => ConnectionHistoryData(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    host: host ?? this.host,
    port: port ?? this.port,
    username: username ?? this.username,
    connectedAt: connectedAt ?? this.connectedAt,
    disconnectedAt: disconnectedAt.present
        ? disconnectedAt.value
        : this.disconnectedAt,
    wasSuccessful: wasSuccessful ?? this.wasSuccessful,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  ConnectionHistoryData copyWithCompanion(ConnectionHistoryCompanion data) {
    return ConnectionHistoryData(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      host: data.host.present ? data.host.value : this.host,
      port: data.port.present ? data.port.value : this.port,
      username: data.username.present ? data.username.value : this.username,
      connectedAt: data.connectedAt.present
          ? data.connectedAt.value
          : this.connectedAt,
      disconnectedAt: data.disconnectedAt.present
          ? data.disconnectedAt.value
          : this.disconnectedAt,
      wasSuccessful: data.wasSuccessful.present
          ? data.wasSuccessful.value
          : this.wasSuccessful,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionHistoryData(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('username: $username, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('disconnectedAt: $disconnectedAt, ')
          ..write('wasSuccessful: $wasSuccessful, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    host,
    port,
    username,
    connectedAt,
    disconnectedAt,
    wasSuccessful,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConnectionHistoryData &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.host == this.host &&
          other.port == this.port &&
          other.username == this.username &&
          other.connectedAt == this.connectedAt &&
          other.disconnectedAt == this.disconnectedAt &&
          other.wasSuccessful == this.wasSuccessful &&
          other.errorMessage == this.errorMessage);
}

class ConnectionHistoryCompanion
    extends UpdateCompanion<ConnectionHistoryData> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<String> host;
  final Value<int> port;
  final Value<String> username;
  final Value<DateTime> connectedAt;
  final Value<DateTime?> disconnectedAt;
  final Value<bool> wasSuccessful;
  final Value<String?> errorMessage;
  const ConnectionHistoryCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.host = const Value.absent(),
    this.port = const Value.absent(),
    this.username = const Value.absent(),
    this.connectedAt = const Value.absent(),
    this.disconnectedAt = const Value.absent(),
    this.wasSuccessful = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  ConnectionHistoryCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String host,
    required int port,
    required String username,
    this.connectedAt = const Value.absent(),
    this.disconnectedAt = const Value.absent(),
    this.wasSuccessful = const Value.absent(),
    this.errorMessage = const Value.absent(),
  }) : host = Value(host),
       port = Value(port),
       username = Value(username);
  static Insertable<ConnectionHistoryData> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<String>? host,
    Expression<int>? port,
    Expression<String>? username,
    Expression<DateTime>? connectedAt,
    Expression<DateTime>? disconnectedAt,
    Expression<bool>? wasSuccessful,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (username != null) 'username': username,
      if (connectedAt != null) 'connected_at': connectedAt,
      if (disconnectedAt != null) 'disconnected_at': disconnectedAt,
      if (wasSuccessful != null) 'was_successful': wasSuccessful,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  ConnectionHistoryCompanion copyWith({
    Value<int>? id,
    Value<int?>? serverId,
    Value<String>? host,
    Value<int>? port,
    Value<String>? username,
    Value<DateTime>? connectedAt,
    Value<DateTime?>? disconnectedAt,
    Value<bool>? wasSuccessful,
    Value<String?>? errorMessage,
  }) {
    return ConnectionHistoryCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      connectedAt: connectedAt ?? this.connectedAt,
      disconnectedAt: disconnectedAt ?? this.disconnectedAt,
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (connectedAt.present) {
      map['connected_at'] = Variable<DateTime>(connectedAt.value);
    }
    if (disconnectedAt.present) {
      map['disconnected_at'] = Variable<DateTime>(disconnectedAt.value);
    }
    if (wasSuccessful.present) {
      map['was_successful'] = Variable<bool>(wasSuccessful.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionHistoryCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('username: $username, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('disconnectedAt: $disconnectedAt, ')
          ..write('wasSuccessful: $wasSuccessful, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SshKeysTable sshKeys = $SshKeysTable(this);
  late final $ServerCollectionsTable serverCollections =
      $ServerCollectionsTable(this);
  late final $ServersTable servers = $ServersTable(this);
  late final $KnownHostsTable knownHosts = $KnownHostsTable(this);
  late final $ConnectionHistoryTable connectionHistory =
      $ConnectionHistoryTable(this);
  late final ServerDao serverDao = ServerDao(this as AppDatabase);
  late final CollectionDao collectionDao = CollectionDao(this as AppDatabase);
  late final KeyDao keyDao = KeyDao(this as AppDatabase);
  late final KnownHostDao knownHostDao = KnownHostDao(this as AppDatabase);
  late final ConnectionHistoryDao connectionHistoryDao = ConnectionHistoryDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sshKeys,
    serverCollections,
    servers,
    knownHosts,
    connectionHistory,
  ];
}

typedef $$SshKeysTableCreateCompanionBuilder =
    SshKeysCompanion Function({
      Value<int> id,
      required String label,
      required KeyType keyType,
      required String publicKey,
      required String encryptedPrivateKey,
      required String fingerprint,
      Value<DateTime> createdAt,
    });
typedef $$SshKeysTableUpdateCompanionBuilder =
    SshKeysCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<KeyType> keyType,
      Value<String> publicKey,
      Value<String> encryptedPrivateKey,
      Value<String> fingerprint,
      Value<DateTime> createdAt,
    });

final class $$SshKeysTableReferences
    extends BaseReferences<_$AppDatabase, $SshKeysTable, SshKey> {
  $$SshKeysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ServersTable, List<Server>> _serversRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.servers,
    aliasName: $_aliasNameGenerator(db.sshKeys.id, db.servers.sshKeyId),
  );

  $$ServersTableProcessedTableManager get serversRefs {
    final manager = $$ServersTableTableManager(
      $_db,
      $_db.servers,
    ).filter((f) => f.sshKeyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_serversRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SshKeysTableFilterComposer
    extends Composer<_$AppDatabase, $SshKeysTable> {
  $$SshKeysTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<KeyType, KeyType, String> get keyType =>
      $composableBuilder(
        column: $table.keyType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedPrivateKey => $composableBuilder(
    column: $table.encryptedPrivateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> serversRefs(
    Expression<bool> Function($$ServersTableFilterComposer f) f,
  ) {
    final $$ServersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.servers,
      getReferencedColumn: (t) => t.sshKeyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServersTableFilterComposer(
            $db: $db,
            $table: $db.servers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SshKeysTableOrderingComposer
    extends Composer<_$AppDatabase, $SshKeysTable> {
  $$SshKeysTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyType => $composableBuilder(
    column: $table.keyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPrivateKey => $composableBuilder(
    column: $table.encryptedPrivateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SshKeysTableAnnotationComposer
    extends Composer<_$AppDatabase, $SshKeysTable> {
  $$SshKeysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumnWithTypeConverter<KeyType, String> get keyType =>
      $composableBuilder(column: $table.keyType, builder: (column) => column);

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get encryptedPrivateKey => $composableBuilder(
    column: $table.encryptedPrivateKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> serversRefs<T extends Object>(
    Expression<T> Function($$ServersTableAnnotationComposer a) f,
  ) {
    final $$ServersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.servers,
      getReferencedColumn: (t) => t.sshKeyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServersTableAnnotationComposer(
            $db: $db,
            $table: $db.servers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SshKeysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SshKeysTable,
          SshKey,
          $$SshKeysTableFilterComposer,
          $$SshKeysTableOrderingComposer,
          $$SshKeysTableAnnotationComposer,
          $$SshKeysTableCreateCompanionBuilder,
          $$SshKeysTableUpdateCompanionBuilder,
          (SshKey, $$SshKeysTableReferences),
          SshKey,
          PrefetchHooks Function({bool serversRefs})
        > {
  $$SshKeysTableTableManager(_$AppDatabase db, $SshKeysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SshKeysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SshKeysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SshKeysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<KeyType> keyType = const Value.absent(),
                Value<String> publicKey = const Value.absent(),
                Value<String> encryptedPrivateKey = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SshKeysCompanion(
                id: id,
                label: label,
                keyType: keyType,
                publicKey: publicKey,
                encryptedPrivateKey: encryptedPrivateKey,
                fingerprint: fingerprint,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required KeyType keyType,
                required String publicKey,
                required String encryptedPrivateKey,
                required String fingerprint,
                Value<DateTime> createdAt = const Value.absent(),
              }) => SshKeysCompanion.insert(
                id: id,
                label: label,
                keyType: keyType,
                publicKey: publicKey,
                encryptedPrivateKey: encryptedPrivateKey,
                fingerprint: fingerprint,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SshKeysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({serversRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (serversRefs) db.servers],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (serversRefs)
                    await $_getPrefetchedData<SshKey, $SshKeysTable, Server>(
                      currentTable: table,
                      referencedTable: $$SshKeysTableReferences
                          ._serversRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SshKeysTableReferences(db, table, p0).serversRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sshKeyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SshKeysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SshKeysTable,
      SshKey,
      $$SshKeysTableFilterComposer,
      $$SshKeysTableOrderingComposer,
      $$SshKeysTableAnnotationComposer,
      $$SshKeysTableCreateCompanionBuilder,
      $$SshKeysTableUpdateCompanionBuilder,
      (SshKey, $$SshKeysTableReferences),
      SshKey,
      PrefetchHooks Function({bool serversRefs})
    >;
typedef $$ServerCollectionsTableCreateCompanionBuilder =
    ServerCollectionsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> color,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ServerCollectionsTableUpdateCompanionBuilder =
    ServerCollectionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> color,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ServerCollectionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ServerCollectionsTable,
          ServerCollection
        > {
  $$ServerCollectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ServersTable, List<Server>> _serversRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.servers,
    aliasName: $_aliasNameGenerator(
      db.serverCollections.id,
      db.servers.collectionId,
    ),
  );

  $$ServersTableProcessedTableManager get serversRefs {
    final manager = $$ServersTableTableManager(
      $_db,
      $_db.servers,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_serversRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ServerCollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $ServerCollectionsTable> {
  $$ServerCollectionsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> serversRefs(
    Expression<bool> Function($$ServersTableFilterComposer f) f,
  ) {
    final $$ServersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.servers,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServersTableFilterComposer(
            $db: $db,
            $table: $db.servers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServerCollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServerCollectionsTable> {
  $$ServerCollectionsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServerCollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServerCollectionsTable> {
  $$ServerCollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> serversRefs<T extends Object>(
    Expression<T> Function($$ServersTableAnnotationComposer a) f,
  ) {
    final $$ServersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.servers,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServersTableAnnotationComposer(
            $db: $db,
            $table: $db.servers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServerCollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServerCollectionsTable,
          ServerCollection,
          $$ServerCollectionsTableFilterComposer,
          $$ServerCollectionsTableOrderingComposer,
          $$ServerCollectionsTableAnnotationComposer,
          $$ServerCollectionsTableCreateCompanionBuilder,
          $$ServerCollectionsTableUpdateCompanionBuilder,
          (ServerCollection, $$ServerCollectionsTableReferences),
          ServerCollection,
          PrefetchHooks Function({bool serversRefs})
        > {
  $$ServerCollectionsTableTableManager(
    _$AppDatabase db,
    $ServerCollectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServerCollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServerCollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServerCollectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ServerCollectionsCompanion(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ServerCollectionsCompanion.insert(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ServerCollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({serversRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (serversRefs) db.servers],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (serversRefs)
                    await $_getPrefetchedData<
                      ServerCollection,
                      $ServerCollectionsTable,
                      Server
                    >(
                      currentTable: table,
                      referencedTable: $$ServerCollectionsTableReferences
                          ._serversRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ServerCollectionsTableReferences(
                            db,
                            table,
                            p0,
                          ).serversRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.collectionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ServerCollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServerCollectionsTable,
      ServerCollection,
      $$ServerCollectionsTableFilterComposer,
      $$ServerCollectionsTableOrderingComposer,
      $$ServerCollectionsTableAnnotationComposer,
      $$ServerCollectionsTableCreateCompanionBuilder,
      $$ServerCollectionsTableUpdateCompanionBuilder,
      (ServerCollection, $$ServerCollectionsTableReferences),
      ServerCollection,
      PrefetchHooks Function({bool serversRefs})
    >;
typedef $$ServersTableCreateCompanionBuilder =
    ServersCompanion Function({
      Value<int> id,
      required String label,
      required String host,
      Value<int> port,
      required String username,
      Value<AuthType> authType,
      Value<String?> encryptedPassword,
      Value<int?> sshKeyId,
      Value<int?> collectionId,
      Value<int> sortOrder,
      Value<bool> isFavorite,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ServersTableUpdateCompanionBuilder =
    ServersCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<String> host,
      Value<int> port,
      Value<String> username,
      Value<AuthType> authType,
      Value<String?> encryptedPassword,
      Value<int?> sshKeyId,
      Value<int?> collectionId,
      Value<int> sortOrder,
      Value<bool> isFavorite,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ServersTableReferences
    extends BaseReferences<_$AppDatabase, $ServersTable, Server> {
  $$ServersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SshKeysTable _sshKeyIdTable(_$AppDatabase db) => db.sshKeys
      .createAlias($_aliasNameGenerator(db.servers.sshKeyId, db.sshKeys.id));

  $$SshKeysTableProcessedTableManager? get sshKeyId {
    final $_column = $_itemColumn<int>('ssh_key_id');
    if ($_column == null) return null;
    final manager = $$SshKeysTableTableManager(
      $_db,
      $_db.sshKeys,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sshKeyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ServerCollectionsTable _collectionIdTable(_$AppDatabase db) =>
      db.serverCollections.createAlias(
        $_aliasNameGenerator(db.servers.collectionId, db.serverCollections.id),
      );

  $$ServerCollectionsTableProcessedTableManager? get collectionId {
    final $_column = $_itemColumn<int>('collection_id');
    if ($_column == null) return null;
    final manager = $$ServerCollectionsTableTableManager(
      $_db,
      $_db.serverCollections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ConnectionHistoryTable,
    List<ConnectionHistoryData>
  >
  _connectionHistoryRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.connectionHistory,
        aliasName: $_aliasNameGenerator(
          db.servers.id,
          db.connectionHistory.serverId,
        ),
      );

  $$ConnectionHistoryTableProcessedTableManager get connectionHistoryRefs {
    final manager = $$ConnectionHistoryTableTableManager(
      $_db,
      $_db.connectionHistory,
    ).filter((f) => f.serverId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _connectionHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ServersTableFilterComposer
    extends Composer<_$AppDatabase, $ServersTable> {
  $$ServersTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AuthType, AuthType, String> get authType =>
      $composableBuilder(
        column: $table.authType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SshKeysTableFilterComposer get sshKeyId {
    final $$SshKeysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sshKeyId,
      referencedTable: $db.sshKeys,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SshKeysTableFilterComposer(
            $db: $db,
            $table: $db.sshKeys,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ServerCollectionsTableFilterComposer get collectionId {
    final $$ServerCollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.serverCollections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServerCollectionsTableFilterComposer(
            $db: $db,
            $table: $db.serverCollections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> connectionHistoryRefs(
    Expression<bool> Function($$ConnectionHistoryTableFilterComposer f) f,
  ) {
    final $$ConnectionHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.connectionHistory,
      getReferencedColumn: (t) => t.serverId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionHistoryTableFilterComposer(
            $db: $db,
            $table: $db.connectionHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServersTableOrderingComposer
    extends Composer<_$AppDatabase, $ServersTable> {
  $$ServersTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SshKeysTableOrderingComposer get sshKeyId {
    final $$SshKeysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sshKeyId,
      referencedTable: $db.sshKeys,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SshKeysTableOrderingComposer(
            $db: $db,
            $table: $db.sshKeys,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ServerCollectionsTableOrderingComposer get collectionId {
    final $$ServerCollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.serverCollections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServerCollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.serverCollections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServersTable> {
  $$ServersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AuthType, String> get authType =>
      $composableBuilder(column: $table.authType, builder: (column) => column);

  GeneratedColumn<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SshKeysTableAnnotationComposer get sshKeyId {
    final $$SshKeysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sshKeyId,
      referencedTable: $db.sshKeys,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SshKeysTableAnnotationComposer(
            $db: $db,
            $table: $db.sshKeys,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ServerCollectionsTableAnnotationComposer get collectionId {
    final $$ServerCollectionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.collectionId,
          referencedTable: $db.serverCollections,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ServerCollectionsTableAnnotationComposer(
                $db: $db,
                $table: $db.serverCollections,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> connectionHistoryRefs<T extends Object>(
    Expression<T> Function($$ConnectionHistoryTableAnnotationComposer a) f,
  ) {
    final $$ConnectionHistoryTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.connectionHistory,
          getReferencedColumn: (t) => t.serverId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ConnectionHistoryTableAnnotationComposer(
                $db: $db,
                $table: $db.connectionHistory,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ServersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServersTable,
          Server,
          $$ServersTableFilterComposer,
          $$ServersTableOrderingComposer,
          $$ServersTableAnnotationComposer,
          $$ServersTableCreateCompanionBuilder,
          $$ServersTableUpdateCompanionBuilder,
          (Server, $$ServersTableReferences),
          Server,
          PrefetchHooks Function({
            bool sshKeyId,
            bool collectionId,
            bool connectionHistoryRefs,
          })
        > {
  $$ServersTableTableManager(_$AppDatabase db, $ServersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<AuthType> authType = const Value.absent(),
                Value<String?> encryptedPassword = const Value.absent(),
                Value<int?> sshKeyId = const Value.absent(),
                Value<int?> collectionId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ServersCompanion(
                id: id,
                label: label,
                host: host,
                port: port,
                username: username,
                authType: authType,
                encryptedPassword: encryptedPassword,
                sshKeyId: sshKeyId,
                collectionId: collectionId,
                sortOrder: sortOrder,
                isFavorite: isFavorite,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required String host,
                Value<int> port = const Value.absent(),
                required String username,
                Value<AuthType> authType = const Value.absent(),
                Value<String?> encryptedPassword = const Value.absent(),
                Value<int?> sshKeyId = const Value.absent(),
                Value<int?> collectionId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ServersCompanion.insert(
                id: id,
                label: label,
                host: host,
                port: port,
                username: username,
                authType: authType,
                encryptedPassword: encryptedPassword,
                sshKeyId: sshKeyId,
                collectionId: collectionId,
                sortOrder: sortOrder,
                isFavorite: isFavorite,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ServersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sshKeyId = false,
                collectionId = false,
                connectionHistoryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (connectionHistoryRefs) db.connectionHistory,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sshKeyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sshKeyId,
                                    referencedTable: $$ServersTableReferences
                                        ._sshKeyIdTable(db),
                                    referencedColumn: $$ServersTableReferences
                                        ._sshKeyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (collectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.collectionId,
                                    referencedTable: $$ServersTableReferences
                                        ._collectionIdTable(db),
                                    referencedColumn: $$ServersTableReferences
                                        ._collectionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (connectionHistoryRefs)
                        await $_getPrefetchedData<
                          Server,
                          $ServersTable,
                          ConnectionHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$ServersTableReferences
                              ._connectionHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ServersTableReferences(
                                db,
                                table,
                                p0,
                              ).connectionHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.serverId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ServersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServersTable,
      Server,
      $$ServersTableFilterComposer,
      $$ServersTableOrderingComposer,
      $$ServersTableAnnotationComposer,
      $$ServersTableCreateCompanionBuilder,
      $$ServersTableUpdateCompanionBuilder,
      (Server, $$ServersTableReferences),
      Server,
      PrefetchHooks Function({
        bool sshKeyId,
        bool collectionId,
        bool connectionHistoryRefs,
      })
    >;
typedef $$KnownHostsTableCreateCompanionBuilder =
    KnownHostsCompanion Function({
      Value<int> id,
      required String host,
      Value<int> port,
      required String keyType,
      required String hostKeyFingerprint,
      Value<DateTime> firstSeen,
      Value<DateTime> lastSeen,
    });
typedef $$KnownHostsTableUpdateCompanionBuilder =
    KnownHostsCompanion Function({
      Value<int> id,
      Value<String> host,
      Value<int> port,
      Value<String> keyType,
      Value<String> hostKeyFingerprint,
      Value<DateTime> firstSeen,
      Value<DateTime> lastSeen,
    });

class $$KnownHostsTableFilterComposer
    extends Composer<_$AppDatabase, $KnownHostsTable> {
  $$KnownHostsTableFilterComposer({
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

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyType => $composableBuilder(
    column: $table.keyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostKeyFingerprint => $composableBuilder(
    column: $table.hostKeyFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KnownHostsTableOrderingComposer
    extends Composer<_$AppDatabase, $KnownHostsTable> {
  $$KnownHostsTableOrderingComposer({
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

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyType => $composableBuilder(
    column: $table.keyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostKeyFingerprint => $composableBuilder(
    column: $table.hostKeyFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KnownHostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $KnownHostsTable> {
  $$KnownHostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get keyType =>
      $composableBuilder(column: $table.keyType, builder: (column) => column);

  GeneratedColumn<String> get hostKeyFingerprint => $composableBuilder(
    column: $table.hostKeyFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstSeen =>
      $composableBuilder(column: $table.firstSeen, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);
}

class $$KnownHostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KnownHostsTable,
          KnownHost,
          $$KnownHostsTableFilterComposer,
          $$KnownHostsTableOrderingComposer,
          $$KnownHostsTableAnnotationComposer,
          $$KnownHostsTableCreateCompanionBuilder,
          $$KnownHostsTableUpdateCompanionBuilder,
          (
            KnownHost,
            BaseReferences<_$AppDatabase, $KnownHostsTable, KnownHost>,
          ),
          KnownHost,
          PrefetchHooks Function()
        > {
  $$KnownHostsTableTableManager(_$AppDatabase db, $KnownHostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KnownHostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KnownHostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KnownHostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<String> keyType = const Value.absent(),
                Value<String> hostKeyFingerprint = const Value.absent(),
                Value<DateTime> firstSeen = const Value.absent(),
                Value<DateTime> lastSeen = const Value.absent(),
              }) => KnownHostsCompanion(
                id: id,
                host: host,
                port: port,
                keyType: keyType,
                hostKeyFingerprint: hostKeyFingerprint,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String host,
                Value<int> port = const Value.absent(),
                required String keyType,
                required String hostKeyFingerprint,
                Value<DateTime> firstSeen = const Value.absent(),
                Value<DateTime> lastSeen = const Value.absent(),
              }) => KnownHostsCompanion.insert(
                id: id,
                host: host,
                port: port,
                keyType: keyType,
                hostKeyFingerprint: hostKeyFingerprint,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KnownHostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KnownHostsTable,
      KnownHost,
      $$KnownHostsTableFilterComposer,
      $$KnownHostsTableOrderingComposer,
      $$KnownHostsTableAnnotationComposer,
      $$KnownHostsTableCreateCompanionBuilder,
      $$KnownHostsTableUpdateCompanionBuilder,
      (KnownHost, BaseReferences<_$AppDatabase, $KnownHostsTable, KnownHost>),
      KnownHost,
      PrefetchHooks Function()
    >;
typedef $$ConnectionHistoryTableCreateCompanionBuilder =
    ConnectionHistoryCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      required String host,
      required int port,
      required String username,
      Value<DateTime> connectedAt,
      Value<DateTime?> disconnectedAt,
      Value<bool> wasSuccessful,
      Value<String?> errorMessage,
    });
typedef $$ConnectionHistoryTableUpdateCompanionBuilder =
    ConnectionHistoryCompanion Function({
      Value<int> id,
      Value<int?> serverId,
      Value<String> host,
      Value<int> port,
      Value<String> username,
      Value<DateTime> connectedAt,
      Value<DateTime?> disconnectedAt,
      Value<bool> wasSuccessful,
      Value<String?> errorMessage,
    });

final class $$ConnectionHistoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ConnectionHistoryTable,
          ConnectionHistoryData
        > {
  $$ConnectionHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ServersTable _serverIdTable(_$AppDatabase db) =>
      db.servers.createAlias(
        $_aliasNameGenerator(db.connectionHistory.serverId, db.servers.id),
      );

  $$ServersTableProcessedTableManager? get serverId {
    final $_column = $_itemColumn<int>('server_id');
    if ($_column == null) return null;
    final manager = $$ServersTableTableManager(
      $_db,
      $_db.servers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_serverIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConnectionHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ConnectionHistoryTable> {
  $$ConnectionHistoryTableFilterComposer({
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

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get disconnectedAt => $composableBuilder(
    column: $table.disconnectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasSuccessful => $composableBuilder(
    column: $table.wasSuccessful,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  $$ServersTableFilterComposer get serverId {
    final $$ServersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverId,
      referencedTable: $db.servers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServersTableFilterComposer(
            $db: $db,
            $table: $db.servers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConnectionHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ConnectionHistoryTable> {
  $$ConnectionHistoryTableOrderingComposer({
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

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get disconnectedAt => $composableBuilder(
    column: $table.disconnectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasSuccessful => $composableBuilder(
    column: $table.wasSuccessful,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  $$ServersTableOrderingComposer get serverId {
    final $$ServersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverId,
      referencedTable: $db.servers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServersTableOrderingComposer(
            $db: $db,
            $table: $db.servers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConnectionHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConnectionHistoryTable> {
  $$ConnectionHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get disconnectedAt => $composableBuilder(
    column: $table.disconnectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasSuccessful => $composableBuilder(
    column: $table.wasSuccessful,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  $$ServersTableAnnotationComposer get serverId {
    final $$ServersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serverId,
      referencedTable: $db.servers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServersTableAnnotationComposer(
            $db: $db,
            $table: $db.servers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConnectionHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConnectionHistoryTable,
          ConnectionHistoryData,
          $$ConnectionHistoryTableFilterComposer,
          $$ConnectionHistoryTableOrderingComposer,
          $$ConnectionHistoryTableAnnotationComposer,
          $$ConnectionHistoryTableCreateCompanionBuilder,
          $$ConnectionHistoryTableUpdateCompanionBuilder,
          (ConnectionHistoryData, $$ConnectionHistoryTableReferences),
          ConnectionHistoryData,
          PrefetchHooks Function({bool serverId})
        > {
  $$ConnectionHistoryTableTableManager(
    _$AppDatabase db,
    $ConnectionHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConnectionHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConnectionHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConnectionHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<DateTime> connectedAt = const Value.absent(),
                Value<DateTime?> disconnectedAt = const Value.absent(),
                Value<bool> wasSuccessful = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => ConnectionHistoryCompanion(
                id: id,
                serverId: serverId,
                host: host,
                port: port,
                username: username,
                connectedAt: connectedAt,
                disconnectedAt: disconnectedAt,
                wasSuccessful: wasSuccessful,
                errorMessage: errorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required String host,
                required int port,
                required String username,
                Value<DateTime> connectedAt = const Value.absent(),
                Value<DateTime?> disconnectedAt = const Value.absent(),
                Value<bool> wasSuccessful = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => ConnectionHistoryCompanion.insert(
                id: id,
                serverId: serverId,
                host: host,
                port: port,
                username: username,
                connectedAt: connectedAt,
                disconnectedAt: disconnectedAt,
                wasSuccessful: wasSuccessful,
                errorMessage: errorMessage,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConnectionHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({serverId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (serverId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.serverId,
                                referencedTable:
                                    $$ConnectionHistoryTableReferences
                                        ._serverIdTable(db),
                                referencedColumn:
                                    $$ConnectionHistoryTableReferences
                                        ._serverIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ConnectionHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConnectionHistoryTable,
      ConnectionHistoryData,
      $$ConnectionHistoryTableFilterComposer,
      $$ConnectionHistoryTableOrderingComposer,
      $$ConnectionHistoryTableAnnotationComposer,
      $$ConnectionHistoryTableCreateCompanionBuilder,
      $$ConnectionHistoryTableUpdateCompanionBuilder,
      (ConnectionHistoryData, $$ConnectionHistoryTableReferences),
      ConnectionHistoryData,
      PrefetchHooks Function({bool serverId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SshKeysTableTableManager get sshKeys =>
      $$SshKeysTableTableManager(_db, _db.sshKeys);
  $$ServerCollectionsTableTableManager get serverCollections =>
      $$ServerCollectionsTableTableManager(_db, _db.serverCollections);
  $$ServersTableTableManager get servers =>
      $$ServersTableTableManager(_db, _db.servers);
  $$KnownHostsTableTableManager get knownHosts =>
      $$KnownHostsTableTableManager(_db, _db.knownHosts);
  $$ConnectionHistoryTableTableManager get connectionHistory =>
      $$ConnectionHistoryTableTableManager(_db, _db.connectionHistory);
}

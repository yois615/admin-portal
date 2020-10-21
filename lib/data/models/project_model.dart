import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/utils/formatting.dart';
import 'package:invoiceninja_flutter/utils/strings.dart';

part 'project_model.g.dart';

abstract class ProjectListResponse
    implements Built<ProjectListResponse, ProjectListResponseBuilder> {
  factory ProjectListResponse([void updates(ProjectListResponseBuilder b)]) =
      _$ProjectListResponse;

  ProjectListResponse._();

  @override
  @memoized
  int get hashCode;

  BuiltList<ProjectEntity> get data;

  static Serializer<ProjectListResponse> get serializer =>
      _$projectListResponseSerializer;
}

abstract class ProjectItemResponse
    implements Built<ProjectItemResponse, ProjectItemResponseBuilder> {
  factory ProjectItemResponse([void updates(ProjectItemResponseBuilder b)]) =
      _$ProjectItemResponse;

  ProjectItemResponse._();

  @override
  @memoized
  int get hashCode;

  ProjectEntity get data;

  static Serializer<ProjectItemResponse> get serializer =>
      _$projectItemResponseSerializer;
}

class ProjectFields {
  static const String number = 'number';
  static const String name = 'name';
  static const String clientId = 'client_id';
  static const String client = 'client';
  static const String taskRate = 'task_rate';
  static const String dueDate = 'due_date';
  static const String privateNotes = 'private_notes';
  static const String publicNotes = 'public_notes';
  static const String budgetedHours = 'budgeted_hours';
  static const String customValue1 = 'custom1';
  static const String customValue2 = 'custom2';
  static const String customValue3 = 'custom3';
  static const String customValue4 = 'custom4';
  static const String updatedAt = 'updated_at';
  static const String archivedAt = 'archived_at';
  static const String isDeleted = 'is_deleted';
  static const String documents = 'documents';
}

abstract class ProjectEntity extends Object
    with BaseEntity, SelectableEntity, BelongsToClient
    implements Built<ProjectEntity, ProjectEntityBuilder> {
  factory ProjectEntity({String id, AppState state}) {
    return _$ProjectEntity._(
      id: id ?? BaseEntity.nextId,
      number: '',
      isChanged: false,
      name: '',
      clientId: '',
      taskRate: 0.0,
      dueDate: '',
      privateNotes: '',
      publicNotes: '',
      budgetedHours: 0.0,
      customValue1: '',
      customValue2: '',
      customValue3: '',
      customValue4: '',
      updatedAt: 0,
      archivedAt: 0,
      isDeleted: false,
      createdUserId: '',
      createdAt: 0,
      assignedUserId: '',
      documents: BuiltList<DocumentEntity>(),
    );
  }

  ProjectEntity._();

  @override
  @memoized
  int get hashCode;

  ProjectEntity get clone => rebuild((b) => b
    ..id = BaseEntity.nextId
    ..isChanged = false
    ..isDeleted = false);

  @override
  EntityType get entityType {
    return EntityType.project;
  }

  String get name;

  @override
  @BuiltValueField(wireName: 'client_id')
  String get clientId;

  @BuiltValueField(wireName: 'task_rate')
  double get taskRate;

  @BuiltValueField(wireName: 'due_date')
  String get dueDate;

  @BuiltValueField(wireName: 'private_notes')
  String get privateNotes;

  @BuiltValueField(wireName: 'public_notes')
  String get publicNotes;

  @BuiltValueField(wireName: 'budgeted_hours')
  double get budgetedHours;

  @BuiltValueField(wireName: 'custom_value1')
  String get customValue1;

  @BuiltValueField(wireName: 'custom_value2')
  String get customValue2;

  @BuiltValueField(wireName: 'custom_value3')
  String get customValue3;

  @BuiltValueField(wireName: 'custom_value4')
  String get customValue4;

  @nullable // TODO remove this
  String get number;

  BuiltList<DocumentEntity> get documents;

  @override
  List<EntityAction> getActions(
      {UserCompanyEntity userCompany,
      ClientEntity client,
      bool includeEdit = false,
      bool multiselect = false}) {
    final actions = <EntityAction>[];

    if (!multiselect) {
      if (!isDeleted) {
        if (includeEdit && userCompany.canEditEntity(this)) {
          actions.add(EntityAction.edit);
        }

        if (isActive && client?.isActive == true) {
          if (userCompany.canCreate(EntityType.invoice)) {
            actions.add(EntityAction.newInvoice);
          }
          if (userCompany.canCreate(EntityType.recurringInvoice)) {
            actions.add(EntityAction.newRecurringInvoice);
          }
          if (userCompany.canCreate(EntityType.quote)) {
            actions.add(EntityAction.newQuote);
          }
          if (userCompany.canCreate(EntityType.credit)) {
            actions.add(EntityAction.newCredit);
          }
          if (userCompany.canCreate(EntityType.task)) {
            actions.add(EntityAction.newTask);
          }
          if (userCompany.canCreate(EntityType.expense)) {
            actions.add(EntityAction.newExpense);
          }
        }
      }

      if (userCompany.canCreate(EntityType.project)) {
        actions.add(EntityAction.clone);
      }
    }

    if (actions.isNotEmpty) {
      actions.add(null);
    }

    return actions..addAll(super.getActions(userCompany: userCompany));
  }

  int compareTo(
      ProjectEntity project,
      String sortField,
      bool sortAscending,
      BuiltMap<String, UserEntity> userMap,
      BuiltMap<String, ClientEntity> clientMap) {
    int response = 0;
    final ProjectEntity projectA = sortAscending ? this : project;
    final ProjectEntity projectB = sortAscending ? project : this;

    switch (sortField) {
      case ProjectFields.name:
        response =
            projectA.name.toLowerCase().compareTo(projectB.name.toLowerCase());
        break;
      case ProjectFields.taskRate:
        response = projectA.taskRate.compareTo(projectB.taskRate);
        break;
      case ProjectFields.client:
        final clientA = clientMap[projectA.clientId] ?? ClientEntity();
        final clientB = clientMap[projectB.clientId] ?? ClientEntity();
        response = clientA.listDisplayName
            .toLowerCase()
            .compareTo(clientB.listDisplayName.toLowerCase());
        break;
      case ProjectFields.dueDate:
        response = projectA.dueDate.compareTo(projectB.dueDate);
        break;
      case ProjectFields.privateNotes:
        response = projectA.privateNotes.compareTo(projectB.privateNotes);
        break;
      case ProjectFields.publicNotes:
        response = projectA.publicNotes.compareTo(projectB.publicNotes);
        break;
      case ProjectFields.budgetedHours:
        response = projectA.budgetedHours.compareTo(projectB.budgetedHours);
        break;
      case EntityFields.state:
        final stateA =
            EntityState.valueOf(projectA.entityState) ?? EntityState.active;
        final stateB =
            EntityState.valueOf(projectB.entityState) ?? EntityState.active;
        response =
            stateA.name.toLowerCase().compareTo(stateB.name.toLowerCase());
        break;
      case EntityFields.createdAt:
        response = projectA.createdAt.compareTo(projectB.createdAt);
        break;
      case ProjectFields.archivedAt:
        response = projectA.archivedAt.compareTo(projectB.archivedAt);
        break;
      case ProjectFields.updatedAt:
        response = projectA.updatedAt.compareTo(projectB.updatedAt);
        break;
      case EntityFields.assignedTo:
        final userA = userMap[projectA.assignedUserId] ?? UserEntity();
        final userB = userMap[projectB.assignedUserId] ?? UserEntity();
        response = userA.listDisplayName
            .toLowerCase()
            .compareTo(userB.listDisplayName.toLowerCase());
        break;
      case EntityFields.createdBy:
        final userA = userMap[projectA.createdUserId] ?? UserEntity();
        final userB = userMap[projectB.createdUserId] ?? UserEntity();
        response = userA.listDisplayName
            .toLowerCase()
            .compareTo(userB.listDisplayName.toLowerCase());
        break;
      case ProjectFields.documents:
        response =
            projectA.documents.length.compareTo(projectB.documents.length);
        break;
      default:
        print('## ERROR: sort by project.$sortField is not implemented');
        break;
    }

    return response;
  }

  @override
  bool matchesFilter(String filter) {
    return matchesStrings(
      haystacks: [
        name,
        customValue1,
        customValue2,
        customValue3,
        customValue4,
      ],
      needle: filter,
    );
  }

  @override
  String matchesFilterValue(String filter) {
    return matchesStringsValue(
      haystacks: [
        customValue1,
        customValue2,
        customValue3,
        customValue4,
      ],
      needle: filter,
    );
  }

  @override
  String get listDisplayName {
    return name;
  }

  @override
  double get listDisplayAmount => null;

  bool get hasClient => clientId != null && clientId.isNotEmpty;

  @override
  FormatNumberType get listDisplayAmountType => FormatNumberType.money;

  static Serializer<ProjectEntity> get serializer => _$projectEntitySerializer;
}

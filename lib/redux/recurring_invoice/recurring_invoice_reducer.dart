import 'package:redux/redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/company/company_actions.dart';
import 'package:invoiceninja_flutter/redux/ui/entity_ui_state.dart';
import 'package:invoiceninja_flutter/redux/recurring_invoice/recurring_invoice_actions.dart';
import 'package:invoiceninja_flutter/redux/ui/list_ui_state.dart';
import 'package:invoiceninja_flutter/redux/recurring_invoice/recurring_invoice_state.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';

EntityUIState recurringInvoiceUIReducer(
    RecurringInvoiceUIState state, dynamic action) {
  return state.rebuild((b) => b
    ..listUIState
        .replace(recurringInvoiceListReducer(state.listUIState, action))
    ..editing.replace(editingReducer(state.editing, action))
    ..editingItemIndex = editingItemIndexReducer(state.editingItemIndex, action)
    ..selectedId = selectedIdReducer(state.selectedId, action));
}

final editingItemIndexReducer = combineReducers<int>([
  TypedReducer<int, EditRecurringInvoice>((index, action) => action.itemIndex),
  TypedReducer<int, EditRecurringInvoiceItem>(
      (index, action) => action.itemIndex),
]);

Reducer<String> dropdownFilterReducer = combineReducers([
  TypedReducer<String, FilterRecurringInvoiceDropdown>(
      filterRecurringInvoiceDropdownReducer),
]);

String filterRecurringInvoiceDropdownReducer(
    String dropdownFilter, FilterRecurringInvoiceDropdown action) {
  return action.filter;
}

Reducer<String> selectedIdReducer = combineReducers([
  TypedReducer<String, ViewRecurringInvoice>(
      (selectedId, action) => action.recurringInvoiceId),
  TypedReducer<String, AddRecurringInvoiceSuccess>(
      (selectedId, action) => action.recurringInvoice.id),
  TypedReducer<String, ShowEmailRecurringInvoice>(
      (selectedId, action) => action.invoice.id),
  TypedReducer<String, SelectCompany>(
      (selectedId, action) => action.clearSelection ? '' : selectedId),
  TypedReducer<String, DeleteRecurringInvoicesSuccess>(
      (selectedId, action) => ''),
  TypedReducer<String, ArchiveRecurringInvoicesSuccess>(
      (selectedId, action) => ''),
  TypedReducer<String, ClearEntityFilter>((selectedId, action) => ''),
  TypedReducer<String, ClearEntitySelection>((selectedId, action) =>
      action.entityType == EntityType.recurringInvoice ? '' : selectedId),
  TypedReducer<String, FilterByEntity>(
      (selectedId, action) => action.clearSelection
          ? ''
          : action.entityType == EntityType.recurringInvoice
              ? action.entityId
              : selectedId),
]);

final editingReducer = combineReducers<InvoiceEntity>([
  TypedReducer<InvoiceEntity, SaveRecurringInvoiceSuccess>(_updateEditing),
  TypedReducer<InvoiceEntity, AddRecurringInvoiceSuccess>(_updateEditing),
  TypedReducer<InvoiceEntity, EditRecurringInvoice>(_updateEditing),
  TypedReducer<InvoiceEntity, UpdateRecurringInvoice>(
      (recurringInvoice, action) {
    return action.recurringInvoice.rebuild((b) => b..isChanged = true);
  }),
  TypedReducer<InvoiceEntity, AddRecurringInvoiceItem>(
      (recurringInvoice, action) {
    return recurringInvoice.rebuild((b) => b..isChanged = true);
  }),
  TypedReducer<InvoiceEntity, DeleteRecurringInvoiceItem>(
      (recurringInvoice, action) {
    return recurringInvoice.rebuild((b) => b..isChanged = true);
  }),
  TypedReducer<InvoiceEntity, UpdateRecurringInvoiceItem>(
      (recurringInvoice, action) {
    return recurringInvoice.rebuild((b) => b..isChanged = true);
  }),
  TypedReducer<InvoiceEntity, UpdateRecurringInvoiceClient>(
      (recurringInvoice, action) {
    final client = action.client;
    return recurringInvoice.rebuild((b) => b
      ..isChanged = true
      ..clientId = client?.id ?? ''
      ..projectId = (recurringInvoice.clientId ?? '').isEmpty ||
              recurringInvoice.clientId == client?.id
          ? recurringInvoice.projectId
          : ''
      ..invitations.replace((client?.contacts ?? <ContactEntity>[])
          .where((contact) => contact.sendEmail)
          .map((contact) => InvitationEntity(contactId: contact.id))
          .toList()));
  }),
  TypedReducer<InvoiceEntity, RestoreRecurringInvoicesSuccess>(
      (recurringInvoices, action) {
    return action.recurringInvoices[0];
  }),
  TypedReducer<InvoiceEntity, ArchiveRecurringInvoicesSuccess>(
      (recurringInvoices, action) {
    return action.recurringInvoices[0];
  }),
  TypedReducer<InvoiceEntity, DeleteRecurringInvoicesSuccess>(
      (recurringInvoices, action) {
    return action.recurringInvoices[0];
  }),
  TypedReducer<InvoiceEntity, AddRecurringInvoiceItem>(
      _addRecurringInvoiceItem),
  TypedReducer<InvoiceEntity, AddRecurringInvoiceItems>(
      _addRecurringInvoiceItems),
  TypedReducer<InvoiceEntity, DeleteRecurringInvoiceItem>(
      _removeRecurringInvoiceItem),
  TypedReducer<InvoiceEntity, UpdateRecurringInvoiceItem>(
      _updateRecurringInvoiceItem),
  TypedReducer<InvoiceEntity, DiscardChanges>(_clearEditing),
  TypedReducer<InvoiceEntity, AddRecurringInvoiceContact>(
      (recurringInvoice, action) {
    return recurringInvoice.rebuild((b) => b
      ..invitations.add(
          action.invitation ?? InvitationEntity(contactId: action.contact.id)));
  }),
  TypedReducer<InvoiceEntity, RemoveRecurringInvoiceContact>(
      (recurringInvoice, action) {
    return recurringInvoice
        .rebuild((b) => b..invitations.remove(action.invitation));
  }),
]);

InvoiceEntity _clearEditing(InvoiceEntity recurringInvoice, dynamic action) {
  return InvoiceEntity();
}

InvoiceEntity _updateEditing(InvoiceEntity recurringInvoice, dynamic action) {
  return action.recurringInvoice;
}

InvoiceEntity _addRecurringInvoiceItem(
    InvoiceEntity recurringInvoice, AddRecurringInvoiceItem action) {
  final item = action.invoiceItem ?? InvoiceItemEntity();
  return recurringInvoice.rebuild((b) => b
    ..hasTasks = b.hasTasks || item.isTask
    ..hasExpenses = b.hasExpenses || item.isExpense
    ..lineItems.add(item));
}

InvoiceEntity _addRecurringInvoiceItems(
    InvoiceEntity recurringInvoice, AddRecurringInvoiceItems action) {
  return recurringInvoice.rebuild((b) => b
    ..hasTasks = action.items.where((item) => item.isTask).isNotEmpty
    ..hasExpenses = action.items.where((item) => item.isExpense).isNotEmpty
    ..lineItems.addAll(action.items));
}

InvoiceEntity _removeRecurringInvoiceItem(
    InvoiceEntity recurringInvoice, DeleteRecurringInvoiceItem action) {
  if (recurringInvoice.lineItems.length <= action.index) {
    return recurringInvoice;
  }
  return recurringInvoice.rebuild((b) => b..lineItems.removeAt(action.index));
}

InvoiceEntity _updateRecurringInvoiceItem(
    InvoiceEntity recurringInvoice, UpdateRecurringInvoiceItem action) {
  if (recurringInvoice.lineItems.length <= action.index) {
    return recurringInvoice;
  }
  return recurringInvoice
      .rebuild((b) => b..lineItems[action.index] = action.item);
}

final recurringInvoiceListReducer = combineReducers<ListUIState>([
  TypedReducer<ListUIState, SortRecurringInvoices>(_sortRecurringInvoices),
  TypedReducer<ListUIState, FilterRecurringInvoicesByState>(
      _filterRecurringInvoicesByState),
  TypedReducer<ListUIState, FilterRecurringInvoicesByStatus>(
      _filterRecurringInvoicesByStatus),
  TypedReducer<ListUIState, FilterRecurringInvoices>(_filterRecurringInvoices),
  TypedReducer<ListUIState, FilterRecurringInvoicesByCustom1>(
      _filterRecurringInvoicesByCustom1),
  TypedReducer<ListUIState, FilterRecurringInvoicesByCustom2>(
      _filterRecurringInvoicesByCustom2),
  TypedReducer<ListUIState, FilterRecurringInvoicesByCustom3>(
      _filterRecurringInvoicesByCustom3),
  TypedReducer<ListUIState, FilterRecurringInvoicesByCustom4>(
      _filterRecurringInvoicesByCustom4),
  TypedReducer<ListUIState, StartRecurringInvoiceMultiselect>(
      _startListMultiselect),
  TypedReducer<ListUIState, AddToRecurringInvoiceMultiselect>(
      _addToListMultiselect),
  TypedReducer<ListUIState, RemoveFromRecurringInvoiceMultiselect>(
      _removeFromListMultiselect),
  TypedReducer<ListUIState, ClearRecurringInvoiceMultiselect>(
      _clearListMultiselect),
]);

ListUIState _filterRecurringInvoicesByCustom1(
    ListUIState recurringInvoiceListState,
    FilterRecurringInvoicesByCustom1 action) {
  if (recurringInvoiceListState.custom1Filters.contains(action.value)) {
    return recurringInvoiceListState
        .rebuild((b) => b..custom1Filters.remove(action.value));
  } else {
    return recurringInvoiceListState
        .rebuild((b) => b..custom1Filters.add(action.value));
  }
}

ListUIState _filterRecurringInvoicesByCustom2(
    ListUIState recurringInvoiceListState,
    FilterRecurringInvoicesByCustom2 action) {
  if (recurringInvoiceListState.custom2Filters.contains(action.value)) {
    return recurringInvoiceListState
        .rebuild((b) => b..custom2Filters.remove(action.value));
  } else {
    return recurringInvoiceListState
        .rebuild((b) => b..custom2Filters.add(action.value));
  }
}

ListUIState _filterRecurringInvoicesByCustom3(
    ListUIState recurringInvoiceListState,
    FilterRecurringInvoicesByCustom3 action) {
  if (recurringInvoiceListState.custom3Filters.contains(action.value)) {
    return recurringInvoiceListState
        .rebuild((b) => b..custom3Filters.remove(action.value));
  } else {
    return recurringInvoiceListState
        .rebuild((b) => b..custom3Filters.add(action.value));
  }
}

ListUIState _filterRecurringInvoicesByCustom4(
    ListUIState recurringInvoiceListState,
    FilterRecurringInvoicesByCustom4 action) {
  if (recurringInvoiceListState.custom4Filters.contains(action.value)) {
    return recurringInvoiceListState
        .rebuild((b) => b..custom4Filters.remove(action.value));
  } else {
    return recurringInvoiceListState
        .rebuild((b) => b..custom4Filters.add(action.value));
  }
}

ListUIState _filterRecurringInvoicesByState(
    ListUIState recurringInvoiceListState,
    FilterRecurringInvoicesByState action) {
  if (recurringInvoiceListState.stateFilters.contains(action.state)) {
    return recurringInvoiceListState
        .rebuild((b) => b..stateFilters.remove(action.state));
  } else {
    return recurringInvoiceListState
        .rebuild((b) => b..stateFilters.add(action.state));
  }
}

ListUIState _filterRecurringInvoicesByStatus(
    ListUIState recurringInvoiceListState,
    FilterRecurringInvoicesByStatus action) {
  if (recurringInvoiceListState.statusFilters.contains(action.status)) {
    return recurringInvoiceListState
        .rebuild((b) => b..statusFilters.remove(action.status));
  } else {
    return recurringInvoiceListState
        .rebuild((b) => b..statusFilters.add(action.status));
  }
}

ListUIState _filterRecurringInvoices(
    ListUIState recurringInvoiceListState, FilterRecurringInvoices action) {
  return recurringInvoiceListState.rebuild((b) => b
    ..filter = action.filter
    ..filterClearedAt = action.filter == null
        ? DateTime.now().millisecondsSinceEpoch
        : recurringInvoiceListState.filterClearedAt);
}

ListUIState _sortRecurringInvoices(
    ListUIState recurringInvoiceListState, SortRecurringInvoices action) {
  return recurringInvoiceListState.rebuild((b) => b
    ..sortAscending = b.sortField != action.field || !b.sortAscending
    ..sortField = action.field);
}

ListUIState _startListMultiselect(ListUIState recurringInvoiceListState,
    StartRecurringInvoiceMultiselect action) {
  return recurringInvoiceListState
      .rebuild((b) => b..selectedIds = ListBuilder());
}

ListUIState _addToListMultiselect(ListUIState recurringInvoiceListState,
    AddToRecurringInvoiceMultiselect action) {
  return recurringInvoiceListState
      .rebuild((b) => b..selectedIds.add(action.entity.id));
}

ListUIState _removeFromListMultiselect(ListUIState recurringInvoiceListState,
    RemoveFromRecurringInvoiceMultiselect action) {
  return recurringInvoiceListState
      .rebuild((b) => b..selectedIds.remove(action.entity.id));
}

ListUIState _clearListMultiselect(ListUIState recurringInvoiceListState,
    ClearRecurringInvoiceMultiselect action) {
  return recurringInvoiceListState.rebuild((b) => b..selectedIds = null);
}

final recurringInvoicesReducer = combineReducers<RecurringInvoiceState>([
  TypedReducer<RecurringInvoiceState, SaveRecurringInvoiceSuccess>(
      _updateRecurringInvoice),
  TypedReducer<RecurringInvoiceState, AddRecurringInvoiceSuccess>(
      _addRecurringInvoice),
  TypedReducer<RecurringInvoiceState, LoadRecurringInvoicesSuccess>(
      _setLoadedRecurringInvoices),
  TypedReducer<RecurringInvoiceState, LoadCompanySuccess>(_setLoadedCompany),
  TypedReducer<RecurringInvoiceState, LoadRecurringInvoiceSuccess>(
      _updateRecurringInvoice),
  TypedReducer<RecurringInvoiceState, EmailRecurringInvoiceSuccess>(
      _emailRecurringInvoiceSuccess),
  TypedReducer<RecurringInvoiceState, StartRecurringInvoicesSuccess>(
      _startRecurringInvoicesSuccess),
  TypedReducer<RecurringInvoiceState, StopRecurringInvoicesSuccess>(
      _stopRecurringInvoicesSuccess),
  TypedReducer<RecurringInvoiceState, ArchiveRecurringInvoicesSuccess>(
      _archiveRecurringInvoiceSuccess),
  TypedReducer<RecurringInvoiceState, DeleteRecurringInvoicesSuccess>(
      _deleteRecurringInvoiceSuccess),
  TypedReducer<RecurringInvoiceState, RestoreRecurringInvoicesSuccess>(
      _restoreRecurringInvoiceSuccess),
]);

RecurringInvoiceState _archiveRecurringInvoiceSuccess(
    RecurringInvoiceState recurringInvoiceState,
    ArchiveRecurringInvoicesSuccess action) {
  return recurringInvoiceState.rebuild((b) {
    for (final recurringInvoice in action.recurringInvoices) {
      b.map[recurringInvoice.id] = recurringInvoice;
    }
  });
}

RecurringInvoiceState _deleteRecurringInvoiceSuccess(
    RecurringInvoiceState recurringInvoiceState,
    DeleteRecurringInvoicesSuccess action) {
  return recurringInvoiceState.rebuild((b) {
    for (final recurringInvoice in action.recurringInvoices) {
      b.map[recurringInvoice.id] = recurringInvoice;
    }
  });
}

RecurringInvoiceState _emailRecurringInvoiceSuccess(
    RecurringInvoiceState recurringInvoiceState,
    EmailRecurringInvoiceSuccess action) {
  return recurringInvoiceState
      .rebuild((b) => b..map[action.invoice.id] = action.invoice);
}

RecurringInvoiceState _restoreRecurringInvoiceSuccess(
    RecurringInvoiceState recurringInvoiceState,
    RestoreRecurringInvoicesSuccess action) {
  return recurringInvoiceState.rebuild((b) {
    for (final recurringInvoice in action.recurringInvoices) {
      b.map[recurringInvoice.id] = recurringInvoice;
    }
  });
}

RecurringInvoiceState _startRecurringInvoicesSuccess(
    RecurringInvoiceState recurringInvoiceState,
    StartRecurringInvoicesSuccess action) {
  return recurringInvoiceState.rebuild((b) {
    for (final recurringInvoice in action.invoices) {
      b.map[recurringInvoice.id] = recurringInvoice;
    }
  });
}

RecurringInvoiceState _stopRecurringInvoicesSuccess(
    RecurringInvoiceState recurringInvoiceState,
    StopRecurringInvoicesSuccess action) {
  return recurringInvoiceState.rebuild((b) {
    for (final recurringInvoice in action.invoices) {
      b.map[recurringInvoice.id] = recurringInvoice;
    }
  });
}

RecurringInvoiceState _addRecurringInvoice(
    RecurringInvoiceState recurringInvoiceState,
    AddRecurringInvoiceSuccess action) {
  return recurringInvoiceState.rebuild((b) => b
    ..map[action.recurringInvoice.id] = action.recurringInvoice
    ..list.add(action.recurringInvoice.id));
}

RecurringInvoiceState _updateRecurringInvoice(
    RecurringInvoiceState recurringInvoiceState, dynamic action) {
  final InvoiceEntity recurringInvoice = action.recurringInvoice;
  return recurringInvoiceState.rebuild((b) => b
    ..map[action.recurringInvoice.id] = recurringInvoice
        .rebuild((b) => b..loadedAt = DateTime.now().millisecondsSinceEpoch));
}

RecurringInvoiceState _setLoadedRecurringInvoices(
        RecurringInvoiceState recurringInvoiceState,
        LoadRecurringInvoicesSuccess action) =>
    recurringInvoiceState.loadRecurringInvoices(action.recurringInvoices);

RecurringInvoiceState _setLoadedCompany(
    RecurringInvoiceState recurringInvoiceState, LoadCompanySuccess action) {
  final company = action.userCompany.company;
  return recurringInvoiceState.loadRecurringInvoices(company.recurringInvoices);
}

// Shared lists strings. Use lang 'fr' or 'en'.

import 'package:nousdeux/domain/entities/shared_list_entity.dart';
import 'package:nousdeux/core/l10n/l10n.dart';

String listsTitle(String lang) => l10nFor(lang).listsTitle;
String listsSubtitle(String lang, String partnerName) =>
    l10nFor(lang).listsSubtitle(partnerName);
String listsSeeAll(String lang) => l10nFor(lang).listsSeeAll;
String listsNew(String lang) => l10nFor(lang).listsNew;
String listsEmptyTitle(String lang) => l10nFor(lang).listsEmptyTitle;
String listsEmptyBody(String lang) => l10nFor(lang).listsEmptyBody;

/// "4 à prendre sur 9", "Tout est fait", "Vide".
String listsCounts(String lang, int open, int total) {
  final l = l10nFor(lang);
  if (total == 0) return l.listsCountsEmpty;
  if (open == 0) return l.listsCountsAllDone;
  return l.listsCounts(open, total);
}

String listsNameLabel(String lang) => l10nFor(lang).listsNameLabel;
String listsNameHint(String lang) => l10nFor(lang).listsNameHint;
String listsIconLabel(String lang) => l10nFor(lang).listsIconLabel;
String listsCreate(String lang) => l10nFor(lang).listsCreate;
String listsRename(String lang) => l10nFor(lang).listsRename;
String listsDelete(String lang) => l10nFor(lang).listsDelete;
String listsDeleteConfirm(String lang, String name) =>
    l10nFor(lang).listsDeleteConfirm(name);
String listsCancel(String lang) => l10nFor(lang).listsCancel;
String listsSave(String lang) => l10nFor(lang).listsSave;
String listsOptions(String lang) => l10nFor(lang).listsOptions;
String listsBack(String lang) => l10nFor(lang).listsBack;

String listsAddLabel(String lang) => l10nFor(lang).listsAddLabel;
String listsAddHint(String lang) => l10nFor(lang).listsAddHint;
String listsAddButton(String lang) => l10nFor(lang).listsAddButton;
String listsChecked(String lang, int n) => l10nFor(lang).listsChecked(n);
String listsClearChecked(String lang) => l10nFor(lang).listsClearChecked;
String listsAddedByMe(String lang) => l10nFor(lang).listsAddedByMe;
String listsAddedBy(String lang, String name) =>
    l10nFor(lang).listsAddedBy(name);
String listsItemDeleted(String lang, String text) =>
    l10nFor(lang).listsItemDeleted(text);
String listsUndo(String lang) => l10nFor(lang).listsUndo;
String listsDeleteItem(String lang) => l10nFor(lang).listsDeleteItem;
String listsGoneTitle(String lang) => l10nFor(lang).listsGoneTitle;
String listsGoneBody(String lang) => l10nFor(lang).listsGoneBody;
String listsAll(String lang) => l10nFor(lang).listsAll;
String listsEmptyListBody(String lang) => l10nFor(lang).listsEmptyListBody;
String listsError(String lang) => l10nFor(lang).listsError;
String listsIconName(String lang, ListIcon icon) =>
    l10nFor(lang).listsIconName(icon.name);

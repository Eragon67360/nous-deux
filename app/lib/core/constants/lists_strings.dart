// Shared lists strings. Use lang 'fr' or 'en'.

import 'package:nousdeux/domain/entities/shared_list_entity.dart';

String listsTitle(String lang) => lang == 'fr' ? 'Listes' : 'Lists';
String listsSubtitle(String lang, String partnerName) => lang == 'fr'
    ? 'Partagées avec $partnerName, en direct.'
    : 'Shared with $partnerName, live.';
String listsSeeAll(String lang) => lang == 'fr' ? 'Tout voir' : 'See all';
String listsNew(String lang) => lang == 'fr' ? 'Nouvelle liste' : 'New list';
String listsEmptyTitle(String lang) =>
    lang == 'fr' ? 'Pas encore de liste' : 'No lists yet';
String listsEmptyBody(String lang) => lang == 'fr'
    ? 'Courses, choses à faire, idées de week-end : ce que vous ajoutez apparaît aussi chez votre partenaire.'
    : "Groceries, to-dos, weekend ideas: whatever you add shows up on your partner's phone too.";

/// "4 à prendre sur 9", "Tout est fait", "Vide".
String listsCounts(String lang, int open, int total) {
  if (total == 0) return lang == 'fr' ? 'Vide' : 'Empty';
  if (open == 0) return lang == 'fr' ? 'Tout est fait' : 'All done';
  return lang == 'fr' ? '$open à faire sur $total' : '$open left of $total';
}

String listsNameLabel(String lang) =>
    lang == 'fr' ? 'Nom de la liste' : 'List name';
String listsNameHint(String lang) => lang == 'fr' ? 'Courses' : 'Groceries';
String listsIconLabel(String lang) => lang == 'fr' ? 'Icône' : 'Icon';
String listsCreate(String lang) => lang == 'fr' ? 'Créer' : 'Create';
String listsRename(String lang) => lang == 'fr' ? 'Renommer' : 'Rename';
String listsDelete(String lang) =>
    lang == 'fr' ? 'Supprimer la liste' : 'Delete list';
String listsDeleteConfirm(String lang, String name) => lang == 'fr'
    ? '« $name » et tous ses éléments seront supprimés pour vous deux.'
    : '"$name" and all its items will be deleted for both of you.';
String listsCancel(String lang) => lang == 'fr' ? 'Annuler' : 'Cancel';
String listsSave(String lang) => lang == 'fr' ? 'Enregistrer' : 'Save';
String listsOptions(String lang) =>
    lang == 'fr' ? 'Options de la liste' : 'List options';
String listsBack(String lang) => lang == 'fr' ? 'Retour' : 'Back';

String listsAddLabel(String lang) =>
    lang == 'fr' ? 'Ajouter un élément' : 'Add an item';
String listsAddHint(String lang) =>
    lang == 'fr' ? "Lait d'avoine, pain…" : 'Oat milk, bread…';
String listsAddButton(String lang) => lang == 'fr' ? 'Ajouter' : 'Add';
String listsChecked(String lang, int n) =>
    lang == 'fr' ? 'Cochés ($n)' : 'Ticked ($n)';
String listsClearChecked(String lang) =>
    lang == 'fr' ? 'Tout effacer' : 'Clear all';
String listsAddedByMe(String lang) =>
    lang == 'fr' ? 'Ajouté par vous' : 'Added by you';
String listsAddedBy(String lang, String name) =>
    lang == 'fr' ? 'Ajouté par $name' : 'Added by $name';
String listsItemDeleted(String lang, String text) =>
    lang == 'fr' ? '« $text » supprimé.' : '"$text" deleted.';
String listsUndo(String lang) => lang == 'fr' ? 'Annuler' : 'Undo';
String listsDeleteItem(String lang) => lang == 'fr' ? 'Supprimer' : 'Delete';
String listsGoneTitle(String lang) =>
    lang == 'fr' ? "Cette liste n'existe plus" : 'This list is gone';
String listsGoneBody(String lang) => lang == 'fr'
    ? "Elle a sans doute été supprimée sur l'autre téléphone."
    : 'It was probably deleted on the other phone.';
String listsAll(String lang) =>
    lang == 'fr' ? 'Toutes les listes' : 'All lists';
String listsEmptyListBody(String lang) => lang == 'fr'
    ? 'Ajoutez le premier élément ci-dessus.'
    : 'Add the first item above.';
String listsError(String lang) => lang == 'fr'
    ? "Ça n'a pas marché. Réessayez."
    : "That didn't work. Try again.";
String listsIconName(String lang, ListIcon icon) => switch (icon) {
  ListIcon.list => lang == 'fr' ? 'Liste' : 'List',
  ListIcon.cart => lang == 'fr' ? 'Courses' : 'Shopping',
  ListIcon.star => lang == 'fr' ? 'Envies' : 'Wishes',
  ListIcon.home => lang == 'fr' ? 'Maison' : 'Home',
  ListIcon.gift => lang == 'fr' ? 'Cadeaux' : 'Gifts',
};

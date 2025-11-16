/// A mixin that defines the contract for items that have a name and ID.
/// 
/// This allows dialogs and other UI components to work with any item
/// that has these properties, such as Entry subclasses and Product.
mixin NamedItem {
  /// The unique identifier of the item.
  String? get id;

  /// The display name of the item.
  String get name;
}


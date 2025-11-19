# Tasks

## Selected

- [x] Support editing products
- [x] Fix bug in nutrition calculation on product entry detail screen: nutrition is multiplied by quantity, but that quantity may not be in grams (e.g. it might be "1 pieces"), in which case it still needs to be multiplied by the unit's weight in grams as well.
- [x] Support updating product version on product entry detail screen
- [x] Check if we can refactor anything to improve code quality and sustainability
- [ ] Support editing product consumption entries
- [ ] Replace products list with a search UI, likely using Algolia
- [ ] Implement Recipe creation with product ingredients
- [ ] Support using recipes as ingredients in other recipes
- [x] Implement Journal FAB to quickly log a product or recipe
- [ ] Expand nutrition data to include vitamins and minerals
- [ ] Add user auth and route guard
- [ ] Add onboarding flow and route guard

## Backlog

- [ ] Add a unique key to the ProductVersion.units, and use that key to lookup the unit in the ProductEntry.unit field instead of the name.
- [ ] Update journal screen to show nested entries in some way
- [ ] Add support for logging measurements (e.g., weight, body fat) as a new Entry type
- [ ] Implement Journal date picker to view past dates
- [ ] Add recents and/or frequents to the products view
- [ ] Allow expansion of the journal entries to show nested entries
- [ ] Add categories/tags to refine the search in the products view
- [ ] Add a way to mark products as favorites and make those easily accessible
- [ ] Implement GoRouter errorBuilder for routing errors
- [ ] Implement type-safe routing using `go_router_builder`
- [ ] Create a `Weight` class to handle conversions from grams to other units (mg, μg) for display purposes, and use that class in the `Ingredient` model.
- [ ] Show daily nutrition dashboard with the totals for the day progress towards the target calories and macros
- [ ] Support marking a day as "complete" (because sometimes i only track half the things, and those days should probably be ignored for certain analyses)
- [ ] remember last quantity used for a product and pre-fill it in the log product entry dialog (just like how i remember the last sets and reps for an exercise in vim)
- [ ] support duplicating a journal entry, defaulting its date/time to now. makes it easy to log a recent entry again
- [ ] Implement optional local notificaation reminder to mark a day as complete
- [ ] Add USDA API as a products source
- [ ] Support opting in and out of product sources
- [ ] Support opting in to other users as product sources
- [ ] Graphs and trends for calories, macros, expenditure, etc.
- [ ] Configurable target calories and macros for the day
- [ ] Consider displaying an "outdated" flag on product entry list items, keeping in mind that this would require two additional queries for each list item
- [ ] support turning a group entry into a recipe entry, creating a new recipe with the products as ingredients and the group entry name as the recipe name
- [ ] support turning a consumption entry into a product entry, creating a new product with the consumption entry name as the product name

## Done

- [x] Show consumed nutrition on product entry detail screen
- [x] Create product entry detail screen
- [x] Update journal screen to support rendering group entries
- [x] update journal screen to only show root entries
- [x] Implement Group Entry to group any log entries (e.g., several products to make a meal)
- [x] Support deleting product consumption entries
- [x] Make product units optional, and always support grams as the default unit
- [x] Implement product consumptions feature
- [x] Refactor `AddProductScreen` with `flutter_form_builder`
- [x] Move `ProductDetailScreen` to its own file

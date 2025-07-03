# Tasks

## Selected

- [x] Make product units optional, and always support grams as the default unit
- [x] Support deleting product consumption entries
- [ ] Implement Group Entry to group any log entries (e.g., several products to make a meal)
- [ ] Update journal screen to support rendering group entries
- [ ] update journal screen to only show root entries
- [ ] Update journal screen to somehow show nested entries
- [ ] Create product entry detail screen
- [ ] Support editing products
- [ ] Support editing product consumption entries
- [ ] Replace products list with a search UI, likely using Algolia
- [ ] Implement Recipe creation with product ingredients
- [ ] Support using recipes as ingredients in other recipes
- [ ] Implement Journal FAB to quickly log a product or recipe
- [ ] Expand nutrition data to include vitamins and minerals
- [ ] Add user auth and route guard
- [ ] Add onboarding flow and route guard

## Backlog

- [ ] Implement Journal date picker to view past dates
- [ ] Add recents and/or frequents to the products view
- [ ] Add categories/tags to refine the search in the products view
- [ ] Add a way to mark products as favorites and make those easily accessible
- [ ] Implement GoRouter errorBuilder for routing errors
- [ ] Implement type-safe routing using `go_router_builder`
- [ ] Create a `Weight` class to handle conversions from grams to other units (mg, μg) for display purposes, and use that class in the `Ingredient` model.
- [ ] Show an totals overview of the journal entries for a given date
- [ ] Support marking a day as "complete"
- [ ] Implement optional local notificaation reminder to mark a day as complete
- [ ] Add USDA API as a products source
- [ ] Support opting in and out of product sources
- [ ] Support opting in to other users as product sources

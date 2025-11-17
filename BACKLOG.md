# Backlog

## Epic 1: Search in 1st Party Database When Creating an Entry

### Overview

When creating a journal entry, allow users to search their existing products or scan a barcode to find a product. This improves the entry creation flow by eliminating the need to navigate to a product detail screen first.

**Current State:**

- Users navigate to a product detail screen
- Click a button to log a product entry
- Currently requires knowing which product to log beforehand
- Products are stored at: `users/{userId}/products/{productId}`

### Stories

#### Story 1.1: Product Search Screen for Entry Creation

**Requirements:**

- User wants to create a journal entry but doesn't know which product to use
- User should be able to search their existing products by name
- User should be able to select a product from search results
- After selection, proceed to entry creation (quantity/unit selection)

**Planned Changes:**

1. **Create Product Search Screen**

   - File: `lib/features/journal/screens/product_search_screen.dart` (new)
   - Search input field
   - Results list showing user's products
   - Tap product → navigate to entry creation flow

2. **Update Product Repository**

   - Add `searchProducts(String query, String userId)` method
   - Query `users/{userId}/products` where name contains query
   - Return matching products
   - **Note:** Using user-specific query for Epic 1. Will refactor to collection group in Epic 4 when cross-owner search is needed.

3. **Update Entry Creation Flow**
   - Add "Search Products" option to journal screen (FloatingActionButton or menu)
   - Navigate to product search screen
   - After product selection, show quantity/unit selection dialog
   - Create entry with selected product

**Dependencies:** None

---

#### Story 1.2: Barcode Scanning for Entry Creation & UPC Field

**Requirements:**

- User wants to create a journal entry by scanning a product barcode
- If product exists in user's database, proceed to entry creation
- If product doesn't exist, show message and offer to create product
- Product model should support UPC field for barcode tracking
- Product creation/edit/detail screens should display and allow editing UPC field

**Planned Changes:**

1. **Add Barcode Scanner Package**

   - Add `mobile_scanner` or `barcode_scan` to `pubspec.yaml`
   - **Dependency:** `mobile_scanner: ^5.0.0` or `barcode_scan: ^x.x.x`

2. **Create Barcode Scanner Service**

   - File: `lib/core/services/barcode_scanner_service.dart` (new)
   - Handles camera integration
   - Returns barcode string (UPC/EAN)

3. **Create Barcode Scanner Screen**

   - File: `lib/core/screens/barcode_scanner_screen.dart` (new)
   - Camera view with barcode detection overlay
   - Returns barcode to caller

4. **Update Product Model**

   - Add `upc` field (optional String) to Product model
   - Update `toMap`, `fromSnapshot`, `copyWith` methods
   - **Database Schema Change:** `users/{userId}/products/{productId}` now includes optional `upc` field

5. **Update Product Repository**

   - Add `getProductByBarcode(String barcode, String userId)` method
   - Query `users/{userId}/products` where `upc = barcode`
   - Return product if found, null otherwise

6. **Update Product Creation Screen**

   - File: `lib/features/products/screens/add_product_screen.dart`
   - Add UPC field to form
   - Add "Scan Barcode" button to pre-fill UPC field
   - Navigate to barcode scanner, get barcode, pre-fill UPC field

7. **Update Product Edit Screen**

   - File: `lib/features/products/screens/edit_product_screen.dart`
   - Add UPC field to form
   - Allow editing UPC field

8. **Update Product Detail Screen**

   - File: `lib/features/products/screens/product_detail_screen.dart`
   - Display UPC field if present

9. **Update Entry Creation Flow**
   - Add "Scan Barcode" option to journal screen
   - Navigate to barcode scanner
   - After scanning, look up product by UPC
   - If found: proceed to entry creation
   - If not found: show message "Product not found. Create it?" → navigate to product creation with UPC pre-filled

**Dependencies:** Requires Story 1.1 (product search infrastructure)

**Open Questions:**

- Which barcode package: `mobile_scanner` vs `barcode_scan` - which is better maintained?

---

## Epic 2: Search in 3rd Party Database When Creating a Product

### Overview

When creating a product, allow users to import product data from Open Food Facts by searching for a product name or scanning a barcode. This eliminates the need to manually enter all nutritional information.

**Current State:**

- Users navigate to `/products/add`
- Manually enter all product information (name, nutrition, units)
- No way to import from external sources

**Architecture Note:**

- Third-party data sources like Open Food Facts will eventually be represented as Organization models (see Epic 3)
- Sync scripts (bots) are just utilities that write to organization accounts
- No need to model bots in the database

### Stories

#### Story 2.1: Open Food Facts Integration

**Requirements:**

- User wants to import product data from Open Food Facts when creating a product
- User can search Open Food Facts by product name
- User can look up product by barcode (reusing barcode scanner from Epic 1)
- Imported data should be editable before saving
- Product should be saved to user's collection with `upc` field set

**Planned Changes:**

1. **Add HTTP Package** (if not already present)

   - Add `http: ^1.1.0` to `pubspec.yaml`

2. **Create Open Food Facts Service**

   - File: `lib/core/services/open_food_facts_service.dart` (new)
   - Methods:
     - `getProductByBarcode(String barcode)` - Fetch product by UPC/EAN
     - `searchProducts(String query)` - Search products by name
   - Converts Open Food Facts format to our Product model
   - Handles API errors and rate limiting
   - **API:** https://world.openfoodfacts.org/api/v2/

3. **Create Product Import Screen**

   - File: `lib/features/products/screens/product_import_screen.dart` (new)
   - Shows product data from Open Food Facts
   - Allows editing before saving
   - Shows source indicator (e.g., "From Open Food Facts")
   - Save button (saves to user's collection with `upc` field)

4. **Update Product Creation Screen**

   - Add "Import from Open Food Facts" option
   - Two flows:
     - **By Barcode:** Scan barcode (reuse scanner from Epic 1) → look up in Open Food Facts → show import screen
     - **By Search:** Search Open Food Facts → select product → show import screen

5. **Update Product Repository**
   - Add `importProductFromApi(Product product, String userId)` method
   - Saves product to user's collection
   - Sets `upc` field if available

**Dependencies:** Requires Epic 1, Story 1.2 (barcode scanning and UPC field)

**Open Questions:**

- Should we implement client-side rate limiting for API calls?
- How to handle offline scenarios? (Show cached results only?)

---

## Epic 3: Organizations

### Overview

Support for organizations that can own products. Users can belong to organizations and create products under them. Similar to GitHub's model where users can create repos under their personal account or under an organization.

**Architecture Notes:**

- **Users** (`users/{userId}`) - Can own products, recipes, and journal entries
- **Organizations** (`organizations/{orgId}`) - Can own products and recipes (NOT journal entries)
- Products/recipes are stored in the owner's subcollection, so owner is implicit from path
- No need for `ownerType` or `ownerId` fields in Product model - owner is determined by collection path
- Third-party data sources (like Open Food Facts, USDA) can be represented as Organization models
- Sync scripts (bots) are just utilities that write to organization accounts

### Stories

#### Story 3.1: Organization Model & Basic CRUD

**Requirements:**

- Users should be able to create organizations
- Organizations should have a name
- Users should be able to view their organizations

**Planned Changes:**

1. **Create Organization Model**

   - File: `lib/core/models/organization.dart` (new)
   - Fields: id, name, createdBy, timestamps
   - Extends Document
   - Implements `toMap`, `fromSnapshot`, `copyWith`
   - **Database Schema:** New collection `organizations/{orgId}`
     ```dart
     {
       id: string,
       name: string,
       createdBy: string, // User who created the organization
       createdAt: timestamp,
       updatedAt: timestamp,
     }
     ```

2. **Create Organization Repository**

   - File: `lib/core/data/organization_repository.dart` (new)
   - Methods:
     - `createOrganization(String name)`
     - `getOrganization(String orgId)`
     - `updateOrganization(String orgId, {String? name})`
     - `deleteOrganization(String orgId)`
     - `getUserOrganizations(String userId)` - Query `organizations` collection group where user is member

3. **Create Organization Screens**
   - File: `lib/features/organizations/screens/organizations_screen.dart` (new)
   - List of user's organizations
   - Create organization button
   - File: `lib/features/organizations/screens/create_organization_screen.dart` (new)
   - Form to create organization

**Dependencies:** None

**Security Rules:**

```javascript
// Organizations: Public read, creator can update/delete
match /organizations/{orgId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null;
  allow update, delete: if request.auth != null &&
    request.auth.uid == resource.data.createdBy;
}
```

---

#### Story 3.2: Organization Members & Permissions

**Requirements:**

- Users should be able to add members to organizations
- Members should have roles (owner, admin, member)
- Users with appropriate roles should be able to manage members

**Planned Changes:**

1. **Create OrganizationMember Model**

   - File: `lib/core/models/organization_member.dart` (new)
   - Fields: userId, role, joinedAt
   - Enum: `OrganizationRole { owner, admin, member }`
   - **Database Schema:** New subcollection `organizations/{orgId}/members/{userId}`
     ```dart
     {
       userId: string,
       role: 'owner' | 'admin' | 'member', // Permission levels
       joinedAt: timestamp,
     }
     ```

2. **Update Organization Repository**

   - Add methods:
     - `addMember(String orgId, String userId, OrganizationRole role)`
     - `removeMember(String orgId, String userId)`
     - `getOrganizationMembers(String orgId)`
     - `canUserManageOrganization(String userId, String orgId)` - Check permissions
     - `getUserOrganizations(String userId)` - Query `members` collection group where `userId = userId`, then get organizations

3. **Create Member Management Screen**
   - File: `lib/features/organizations/screens/organization_members_screen.dart` (new)
   - List of members with roles
   - Add member button
   - Remove member (if user has permission)

**Dependencies:** Requires Story 3.1 (organization model)

**Security Rules:**

```javascript
// Organization members: Read if member, write if owner/admin
match /organizations/{orgId}/members/{userId} {
  allow read: if request.auth != null &&
    exists(/databases/$(database)/documents/organizations/$(orgId)/members/$(request.auth.uid));
  allow write: if request.auth != null &&
    (request.auth.uid == resource.data.userId ||
     get(/databases/$(database)/documents/organizations/$(orgId)/members/$(request.auth.uid)).data.role in ['owner', 'admin']);
}
```

---

#### Story 3.3: Organization Products

**Requirements:**

- Organizations should be able to own products
- Users with appropriate permissions should be able to create products for organizations
- Products should be stored in organization's collection
- When creating a product, user should be able to choose owner (personal account or organization)

**Planned Changes:**

1. **Update Product Repository**

   - Add `ownerType` parameter to methods: `'user' | 'organization'`
   - Add `ownerId` parameter to methods
   - Methods should route to correct collection:
     - If `ownerType == 'user'`: `users/{ownerId}/products`
     - If `ownerType == 'organization'`: `organizations/{ownerId}/products`
   - Update methods: `createProduct`, `getProduct`, `getProductsStream`, `searchProducts`, etc.
   - Add permission checks for organization products

2. **Update Product Creation Screen**

   - Add owner selector: "My Products" or select organization
   - Similar to GitHub's "Create repository under..." dropdown
   - Check permissions before allowing creation
   - Pass `ownerType` and `ownerId` to repository

3. **Update Product Model**

   - No changes needed - model works for both users and organizations
   - Owner is implicit from collection path

4. **Database Schema**
   - New collection: `organizations/{orgId}/products/{productId}`
     ```dart
     {
       // Same structure as user products
       createdBy: string,
       createdAt: timestamp,
       updatedAt: timestamp,
       name: string,
       latestVersion: integer,
       upc?: string, // If imported via barcode
     }
     ```
   - Owner is implicit from collection path (no `ownerType` or `ownerId` fields needed)

**Dependencies:** Requires Story 3.2 (organization members & permissions)

**Security Rules:**

```javascript
// Organization products: Read if member, write if member
match /organizations/{orgId}/products/{productId} {
  allow read: if request.auth != null &&
    exists(/databases/$(database)/documents/organizations/$(orgId)/members/$(request.auth.uid));
  allow create, update, delete: if request.auth != null &&
    exists(/databases/$(database)/documents/organizations/$(orgId)/members/$(request.auth.uid));
}
```

---

## Epic 4: Subscriptions

### Overview

Users can subscribe to organizations and other users to see their products. This enables content sharing and discovery.

**Architecture Notes:**

- Firestore collection groups allow querying across all collections with the same name
- Can use `products` collection group to search across user + organization products
- Already using `entries` collection group for similar purpose
- Owner is implicit from collection path - no need for `ownerType` or `ownerId` fields in Product model

### Stories

#### Story 4.1: Subscription Model & Repository

**Requirements:**

- Users should be able to subscribe to organizations
- Users should be able to subscribe to other users
- Users should be able to unsubscribe
- System should track which owners a user is subscribed to

**Planned Changes:**

1. **Create Subscription Model**

   - File: `lib/core/models/subscription.dart` (new)
   - Fields: ownerType ('user' | 'organization'), ownerId, enabled, subscribedAt
   - **Database Schema:** New collection `subscriptions/{userId}/sources/{ownerId}`
     ```dart
     {
       ownerType: 'user' | 'organization',
       ownerId: string,
       enabled: boolean,
       subscribedAt: Timestamp,
     }
     ```

2. **Create Subscription Repository**
   - File: `lib/core/data/subscription_repository.dart` (new)
   - Methods:
     - `subscribeToOwner(String userId, String ownerType, String ownerId)`
     - `unsubscribeFromOwner(String userId, String ownerType, String ownerId)`
     - `getUserSubscriptions(String userId)`
     - `isSubscribed(String userId, String ownerType, String ownerId)`

**Dependencies:** Requires Epic 3 (organizations)

**Security Rules:**

```javascript
// Subscriptions: Users manage their own
match /subscriptions/{userId}/sources/{ownerId} {
  allow read, write: if request.auth != null &&
    request.auth.uid == userId;
}
```

---

#### Story 4.2: Cross-Owner Product Search

**Requirements:**

- Users should be able to search products across their own products + subscribed owners
- Search should use Firestore collection group queries
- Results should indicate source (user's own vs. organization vs. other user)

**Planned Changes:**

1. **Update Product Repository**

   - Refactor `searchProducts` to use collection group query
   - Add `searchAllProducts(String query, String userId)` method
   - Use collection group query: `firestore.collectionGroup('products')`
   - Filter by:
     - User's own products: `users/{userId}/products`
     - Subscribed organizations: Check subscription list
     - Subscribed users: Check subscription list
   - Return results with source indicator (ownerType, ownerId)

2. **Update Product Search Screen** (from Epic 1, Story 1.1)

   - Show source indicator for each result
   - "Your Products" vs. organization name vs. user name
   - Allow filtering by source

3. **Update Entry Creation Flow**
   - When creating entry, search across user's products + subscribed owners
   - User can select product from any source

**Dependencies:** Requires Story 4.1 (subscription model) and Epic 1, Story 1.1 (product search)

**Open Questions:**

- Do we need to create composite indexes for collection group queries? (Firestore will prompt if needed)

---

#### Story 4.3: Subscription Management UI

**Requirements:**

- Users should be able to view their subscriptions
- Users should be able to discover public organizations and users
- Users should be able to subscribe/unsubscribe from owners

**Planned Changes:**

1. **Create Subscriptions Screen**

   - File: `lib/features/subscriptions/screens/subscriptions_screen.dart` (new)
   - List of subscribed owners (organizations + users)
   - Toggle to enable/disable subscription
   - Unsubscribe button

2. **Create Owner Discovery Screen**

   - File: `lib/features/subscriptions/screens/discover_owners_screen.dart` (new)
   - List of public organizations and users
   - Subscribe button for each
   - Search/filter functionality

3. **Update Organization Screens**

   - Add "Subscribe" button to organization detail screens
   - Show subscription status

4. **Update User Profile Screens** (if they exist)
   - Add "Subscribe" button to public user profiles
   - Show subscription status

**Dependencies:** Requires Story 4.1 (subscription model)

**Open Questions:**

- How do users discover public organizations? (Search, recommendations, categories?)
- Should we add a "public" flag to user profiles for discoverability?

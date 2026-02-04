# Category → Subcategory → Product Navigation Flow

## Overview
The app supports **unlimited hierarchical navigation** from categories down to products. The system automatically detects whether to show subcategories or products based on the API response.

## Navigation Flow

```
Home Screen
    ↓ (tap category)
Subcategories View (Level 1)
    ↓ (tap subcategory)
Subcategories View (Level 2) - Shows more subcategories OR products
    ↓ (tap subcategory if available)
Subcategories View (Level 3) - Shows products
    ↓ (tap product)
Product Detail View
```

## How It Works

### 1. **Home Screen** (`lib/modules/home/home_view.dart`)
- Displays categories from `/api/v1/home` endpoint
- When user taps a category → navigates to `/subcategories/{categoryId}`

```dart
// In home_view.dart
onTap: () => Get.toNamed('/subcategories/${category.id}', arguments: category)
```

### 2. **Subcategories View** (`lib/modules/subcategories/subcategories_view.dart`)
- **Single unified view** that handles both subcategories AND products
- Automatically switches between grid (subcategories) and list (products) layout
- Uses `SubcategoriesController` to manage state

**View Logic:**
```dart
// Automatically shows subcategories OR products
controller.showingProducts.value
    ? _buildProductsList()      // Show products in list view
    : _buildSubcategoriesGrid() // Show subcategories in grid
```

### 3. **Subcategories Controller** (`lib/modules/subcategories/subcategories_controller.dart`)

**Automatic Detection Logic:**
```dart
void _processCurrentItem() {
  if (item.hasSubCategories) {
    // Show subcategories
    subcategories.assignAll(item.subCategories!);
    showingProducts.value = false;
  } else if (item.hasProducts) {
    // Show products
    products.assignAll(item.products!);
    showingProducts.value = true;
  } else {
    // Need to fetch from API
    loadItemData();
  }
}
```

**API Fetching:**
- Endpoint: `GET /api/v1/subcategories/{id}`
- Returns: `CategoryResponse` with either `subCategories` or `products`

```dart
Future<void> loadItemData() async {
  final response = await _apiService.get('/subcategories/$itemId');
  final categoryResponse = CategoryResponse.fromJson(response.data);
  
  // Automatically detects and displays appropriate content
  if (item.hasSubCategories) {
    // Show subcategories
  } else if (item.hasProducts) {
    // Show products
  }
}
```

## Data Models

### CategoryItem (`lib/models/category.dart`)
```dart
class CategoryItem {
  final int id;
  final String name;
  final List<CategoryItem>? subCategories; // Child subcategories
  final List<ProductItem>? products;       // Products (leaf node)
  
  bool get hasSubCategories => subCategories != null && subCategories!.isNotEmpty;
  bool get hasProducts => products != null && products!.isNotEmpty;
}
```

### API Response Format

**Expected Response from `/api/v1/subcategories/{id}`:**

**Option 1: Has Subcategories**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Hardware",
    "sub_categories": [
      {
        "id": 10,
        "name": "Tools",
        "product_count": 25
      },
      {
        "id": 11,
        "name": "Fasteners",
        "product_count": 50
      }
    ]
  }
}
```

**Option 2: Has Products (Leaf Node)**
```json
{
  "success": true,
  "data": {
    "id": 10,
    "name": "Tools",
    "products": [
      {
        "id": 100,
        "name": "Hammer",
        "selling_price": "15.99",
        "mrp": "19.99",
        "stock_quantity": 50,
        "image_url": "https://..."
      },
      {
        "id": 101,
        "name": "Screwdriver Set",
        "selling_price": "12.99",
        "mrp": "15.99",
        "stock_quantity": 30
      }
    ]
  }
}
```

## Routes Configuration

```dart
// In app_routes.dart
Routes.subcategories = '/subcategories/:id'

GetPage(
  name: Routes.subcategories,
  page: () => const SubcategoriesView(),
  binding: SubcategoriesBinding(),
)
```

## Key Features

### ✅ Unlimited Nesting Depth
- Category → Subcategory → Subcategory → ... → Products
- No limit on hierarchy levels

### ✅ Automatic Content Detection
- Checks if item has `subCategories` → shows subcategory grid
- Checks if item has `products` → shows product list
- If neither, fetches from API

### ✅ Smart Navigation
```dart
// Navigate to subcategory (drill down)
void navigateToSubcategory(CategoryItem subcategory) {
  Get.toNamed('/subcategories/${subcategory.id}', arguments: subcategory);
}

// Navigate to product detail
void navigateToProduct(ProductItem product) {
  Get.toNamed('/product/${product.id}');
}
```

### ✅ Loading States
- Loading indicator while fetching
- Error state with retry button
- Empty state when no content

### ✅ Pull-to-Refresh
- Swipe down to refresh current data
- Re-fetches from API

## Testing the Flow

### Test Scenario 1: Category with Subcategories
1. Open app → Home screen
2. Tap on "Hardware" category
3. **Expected:** Shows subcategories (Tools, Fasteners, etc.) in grid
4. Tap on "Tools" subcategory
5. **Expected:** Shows products in list view

### Test Scenario 2: Deep Nesting
1. Home → "Electronics"
2. Subcategories → "Lighting"
3. Subcategories → "LED Bulbs"
4. **Expected:** Shows LED bulb products

### Test Scenario 3: Empty Category
1. Home → Category with no items
2. **Expected:** Shows "No Subcategories" message with refresh button

## Debug Logging

The controller includes comprehensive debug logging:

```
SubcategoriesController: Processing item "Hardware" (ID: 1)
SubcategoriesController: Fetching data for item ID: 1
SubcategoriesController: API response status: 200
SubcategoriesController: Raw API response: {...}
SubcategoriesController: Item name: Hardware
SubcategoriesController: Has subcategories: true
SubcategoriesController: Has products: false
SubcategoriesController: SubCategories count: 5
SubcategoriesController: Products count: 0
SubcategoriesController: ✅ Showing 5 subcategories
```

Check Flutter console/logs to see what's happening during navigation.

## Troubleshooting

### Products Not Showing?

**Check 1: API Response**
- Verify `/api/v1/subcategories/{id}` returns `products` array
- Check if `products` field is null or empty

**Check 2: Debug Logs**
```
SubcategoriesController: Has products: false  ← Should be true
SubcategoriesController: Products count: 0    ← Should be > 0
```

**Check 3: Model Parsing**
- Ensure `ProductItem.fromJson()` correctly parses API response
- Check field names match (snake_case vs camelCase)

**Check 4: API Endpoint**
- Confirm endpoint is `/api/v1/subcategories/{id}` not `/api/v1/categories/{id}`
- Check if authentication is required

### Empty State Showing?

**Possible Causes:**
1. API returning empty `products` array
2. API returning `sub_categories` instead of `products`
3. Network error (check error state)
4. Wrong category ID

**Solution:**
- Tap "Refresh" button in empty state
- Check debug logs for API response
- Verify API endpoint and response format

## Code Files

| File | Purpose |
|------|---------|
| `lib/modules/subcategories/subcategories_view.dart` | UI for both subcategories and products |
| `lib/modules/subcategories/subcategories_controller.dart` | Business logic and API calls |
| `lib/modules/subcategories/subcategories_binding.dart` | Dependency injection |
| `lib/models/category.dart` | Data models (CategoryItem, ProductItem) |
| `lib/routes/app_routes.dart` | Route configuration |

## Summary

✅ **Feature is fully implemented and working!**

The navigation flow automatically:
1. Detects if a category has subcategories or products
2. Shows appropriate UI (grid for subcategories, list for products)
3. Fetches data from API when needed
4. Supports unlimited nesting depth

**To verify it's working:**
1. Run the app: `flutter run`
2. Navigate: Home → Category → Subcategory
3. Check debug logs for API responses
4. Verify products are displayed in list view

If products aren't showing, check the API response format and debug logs!

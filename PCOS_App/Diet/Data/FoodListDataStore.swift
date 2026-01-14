//
//  FoodListDataStore.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import Foundation

class FoodListdataStore {
    
    static var shared = FoodListdataStore()
    private let userDefaults = UserDefaults.standard
    private let foodItemsKey = "savedFoodItems"
    private init() {}
    
    // MARK: - Save Food Items
    func saveFoodItems(_ items: [FoodItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            userDefaults.set(encoded, forKey: foodItemsKey)
        }
    }
    
    // MARK: - Load Food Items
    func loadFoodItems() -> [FoodItem] {
        guard let data = userDefaults.data(forKey: foodItemsKey),
              let items = try? JSONDecoder().decode([FoodItem].self, from: data) else {
            return getDefaultFoodItems()
        }
        return items
    }
    
    // MARK: - Add Food Item
    func addFoodItem(_ item: FoodItem) {
        var items = loadFoodItems()
        items.append(item)
        saveFoodItems(items)
    }
    
    // MARK: - Delete Food Item
    func deleteFoodItem(withId id: String) {
        var items = loadFoodItems()
//        items.removeAll { $0.id == id }
        saveFoodItems(items)
    }
    
    // MARK: - Search Food Items
    func searchFoodItems(query: String) -> [FoodItem] {
        let items = loadFoodItems()
        if query.isEmpty {
            return items
        }
        return items.filter { $0.name.lowercased().contains(query.lowercased()) }
    }
    
    // MARK: - Default Food Items (for first time use)
    private func getDefaultFoodItems() -> [FoodItem] {
        return [
            FoodItem(name: "Chicken Breast", calories: 165, servingSize: 100, protein: 31, carbs: 0, fat: 3.6, desc: "Lean protein source, skinless and boneless.", ingredients: [
                Ingredient(id: UUID(), name: "Chicken breast", quantity: 100, protein: 31, carbs: 0, fats: 3.6, fibre: 0, tags: [])
            ]),
            FoodItem(name: "Brown Rice", calories: 112, servingSize: 100, protein: 2.6, carbs: 24, fat: 0.9, desc: "Whole grain rice rich in fiber and minerals.", ingredients: [
                Ingredient(id: UUID(), name: "Brown rice", quantity: 100, protein: 2.6, carbs: 24, fats: 0.9, fibre: 1.8, tags: [])
            ]),
            FoodItem(name: "Broccoli", calories: 34, servingSize: 100, protein: 2.8, carbs: 7, fat: 0.4, desc: "Cruciferous vegetable high in vitamins and fiber.", ingredients: [
                Ingredient(id: UUID(), name: "Broccoli", quantity: 100, protein: 2.8, carbs: 7, fats: 0.4, fibre: 2.6, tags: [])
            ]),
            FoodItem(name: "Salmon", calories: 208, servingSize: 100, protein: 20, carbs: 0, fat: 13, desc: "Fatty fish rich in omega-3 fatty acids.", ingredients: [
                Ingredient(id: UUID(), name: "Salmon fillet", quantity: 100, protein: 20, carbs: 0, fats: 13, fibre: 0, tags: [])
            ]),
            FoodItem(name: "Sweet Potato", calories: 86, servingSize: 100, protein: 1.6, carbs: 20, fat: 0.1, desc: "Starchy root vegetable with beta-carotene.", ingredients: [
                Ingredient(id: UUID(), name: "Sweet potato", quantity: 100, protein: 1.6, carbs: 20, fats: 0.1, fibre: 3, tags: [])
            ]),
            FoodItem(name: "Eggs", calories: 155, servingSize: 1, unit: "unit", protein: 13, carbs: 1.1, fat: 11, desc: "Whole eggs, a complete protein source.", ingredients: [
                Ingredient(id: UUID(), name: "Eggs", quantity: 100, protein: 13, carbs: 1.1, fats: 11, fibre: 0, tags: [])
            ]),
            FoodItem(name: "Avocado", calories: 160, servingSize: 100, protein: 2, carbs: 9, fat: 15, desc: "Creamy fruit high in healthy fats and fiber.", ingredients: [
                Ingredient(id: UUID(), name: "Avocado", quantity: 100, protein: 2, carbs: 9, fats: 15, fibre: 7, tags: [])
            ]),
            FoodItem(name: "Almonds", calories: 579, servingSize: 100, protein: 21, carbs: 22, fat: 50, desc: "Nutrient-dense nuts rich in healthy fats.", ingredients: [
                Ingredient(id: UUID(), name: "Almonds", quantity: 100, protein: 21, carbs: 22, fats: 50, fibre: 12.5, tags: [])
            ]),
            FoodItem(name: "Greek Yogurt", calories: 59, servingSize: 100, protein: 10, carbs: 3.6, fat: 0.4, desc: "Strained yogurt, high in protein and calcium.", ingredients: [
                Ingredient(id: UUID(), name: "Greek Yogurt", quantity: 100, protein: 10, carbs: 3.6, fats: 0.4, fibre: 0, tags: [])
            ]),
            FoodItem(name: "Banana", calories: 89, servingSize: 100, protein: 1.1, carbs: 23, fat: 0.3, desc: "Sweet fruit rich in potassium and carbs.", ingredients: [
                Ingredient(id: UUID(), name: "Banana", quantity: 100, protein: 1.1, carbs: 23, fats: 0.3, fibre: 2.6, tags: [])
            ]),
            FoodItem(name: "Oatmeal", calories: 68, servingSize: 100, protein: 2.4, carbs: 12, fat: 1.4, desc: "Whole grain oats, a good source of fiber.", ingredients: [
                Ingredient(id: UUID(), name: "Rolled oats", quantity: 100, protein: 13, carbs: 67, fats: 7, fibre: 10, tags: [])
            ]),
            FoodItem(name: "Apple", calories: 52, servingSize: 1, unit: "unit", protein: 0.3, carbs: 14, fat: 0.2, desc: "Crisp fruit with soluble fiber (pectin).", ingredients: [
                Ingredient(id: UUID(), name: "Apple", quantity: 100, protein: 0.3, carbs: 14, fats: 0.2, fibre: 2.4, tags: [])
            ]),
            FoodItem(name: "Dry Fruit & Fresh Fruit Smoothie", calories: 220, image: "smoothie", servingSize: 250, unit: "ml", protein: 6, carbs: 32, fat: 8, desc: "A glass of smoothie blended with mixed dry fruits and fresh fruits.", ingredients: [
                Ingredient(id: UUID(), name: "Milk", quantity: 150, protein: 5, carbs: 7, fats: 4, fibre: 0, tags: []),
                Ingredient(id: UUID(), name: "Banana", quantity: 80, protein: 0.9, carbs: 18, fats: 0.2, fibre: 2, tags: []),
                Ingredient(id: UUID(), name: "Almonds", quantity: 20, protein: 4.2, carbs: 4.4, fats: 10, fibre: 2.5, tags: []),
                Ingredient(id: UUID(), name: "Dates", quantity: 20, protein: 0.3, carbs: 15, fats: 0.1, fibre: 1.6, tags: []),
                Ingredient(id: UUID(), name: "Apple", quantity: 50, protein: 0.15, carbs: 7, fats: 0.05, fibre: 1.2, tags: [])
            ])
        ]
    }
}

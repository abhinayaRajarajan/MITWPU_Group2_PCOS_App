import Foundation

struct IndianFoodTool {

    /// Search for specific Indian foods and their nutritional impact on PCOS.
    func search(query: String, focus: String? = nil) -> String {
        let focusStr = focus.map { " with focus on \($0)" } ?? ""
        let queryLower = query.lowercased()
        
        let isVeg = queryLower.contains("veg")
        let isHair = queryLower.contains("hair")
        let isCheat = queryLower.contains("cheat") || queryLower.contains("fast food") || queryLower.contains("junk") || queryLower.contains("street") || queryLower.contains("pizza") || queryLower.contains("burger") || queryLower.contains("sweet") || queryLower.contains("chocolate")
        let isBreakfast = queryLower.contains("breakfast") || queryLower.contains("morning")
        
        if isVeg {
            return """
            Indian PCOS-friendly veg foods for '\(query)'\(focusStr):
            • Sabzi (Non-starchy veggies) - Bhindi (Eggplant), Lauki (Okra), Karela (Bottle Gourd), Palak (Spinach), Methi (Fenugreek leaves), Cabbage.
            • Paneer (Cottage Cheese) - Good vegetarian protein, balances blood sugar.
            • Dals / Lentils (Moong, Masoor) - Excellent source of fiber and plant protein.
            • Seeds - Alsi (Flaxseeds), Chia seeds, Pumpkin seeds for hormone regulation.
            • Nuts - Almonds, Walnuts for healthy fats.
            """
        }
        
        if isHair {
            return """
            Indian PCOS-friendly foods for hair health:
            • Curry Leaves (Kadi Patta) - Prevents premature greying and hair thinning.
            • Amla (Indian Gooseberry) - High vitamin C, reduces inflammation and androgen levels.
            • Flaxseeds (Alsi) - Balances hormones, reduces DHT which causes PCOS hair loss.
            • Nuts (Walnuts, Almonds) - Rich in nutrients for hair follicles.
            • High Protein (Paneer, Eggs, Dal) - Essential for hair keratin.
            """
        }
        
        if isCheat {
            return """
            Smart PCOS "Cheat Meal" Strategies & Fast Food alternatives for '\(query)'\(focusStr):
            • Keep the portions moderate. Have what you crave, but pair it with protein or fiber!
            • If craving street food: Try grilled chicken tikka, paneer tikka, or homemade chaat with lots of dahi and roasted chana.
            • If craving sweets: Dark chocolate (70%+ cocoa), dates, or fruit with nut butter (almond/peanut butter) to prevent insulin spikes.
            • If craving pizza/burgers: Eat a small salad or protein-rich starter *before* the cheat meal to flatten the glucose curve.
            • Drink apple cider vinegar in water before the meal or take a brief 10-minute walk after eating to reduce the insulin impact.
            """
        }
        
        if isBreakfast {
            return """
            Indian PCOS-friendly Breakfast options:
            • Moong Dal Chilla or Besan Chilla with veggies - High protein.
            • Eggs (Omelette/Bhurji) with palak and onions - Superior protein and healthy fats.
            • Poha with peanuts and lots of veggies - Moderate carbs, good healthy fats.
            • Paneer paratha (with multigrain/ragi flour) - Keeps you full longer.
            """
        }
        
        return """
        Indian PCOS-friendly foods for '\(query)'\(focusStr):
        • Moong Dal Chilla — High protein (12g), Low-GI, gut-friendly
        • Ragi Roti — High fibre, low-GI, insulin-balancing
        • Dahi with ground Alsi (flaxseed) — Probiotic + omega-3, DHT-reducing
        • Palak Dal — Iron + protein, anti-inflammatory
        • Rajma — Low-GI (GI 28), high inositol, hormone-supportive
        *Note to AI: If the user asks for something else, recommend OTHER Indian foods that fit their query instead of explicitly using the ones from this fallback list.*
        """
    }
}

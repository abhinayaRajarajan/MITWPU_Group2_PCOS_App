import Foundation

struct IndianFoodTool {

    /// Search for specific Indian foods and their nutritional impact on PCOS.
    func search(query: String, focus: String? = nil) -> String {
        let focusStr = focus.map { " with focus on \($0)" } ?? ""
        return """
        Indian PCOS-friendly foods for '\(query)'\(focusStr):
        • Moong Dal Chilla — High protein (12g), Low-GI, gut-friendly
        • Ragi Roti — High fibre, low-GI, insulin-balancing
        • Dahi with ground Alsi (flaxseed) — Probiotic + omega-3, DHT-reducing
        • Palak Dal — Iron + protein, anti-inflammatory
        • Rajma — Low-GI (GI 28), high inositol, hormone-supportive
        """
    }
}

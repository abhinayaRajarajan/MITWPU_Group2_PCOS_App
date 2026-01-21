
//
//  ProfileService.swift
//  PCOS_App
//
//  Created by SDC-USER on 21/01/26.
//

import Foundation

class ProfileService {
    // Singleton instance - only one ProfileService exists in the app
    static let shared = ProfileService()
    
    // Private init to prevent creating multiple instances
    private init() {}
    
    // Key for UserDefaults storage
    private let profileKey = "savedUserProfile"
    
    // Get saved profile from storage
    func getProfile() -> ProfileModel? {
        guard let data = UserDefaults.standard.data(forKey: profileKey) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(ProfileModel.self, from: data)
    }
    
    // Save profile to storage
    func setProfile(to profile: ProfileModel) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(profile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
            print("✅ Profile saved successfully!")
        } else {
            print("❌ Failed to save profile")
        }
    }
    
    // Delete profile from storage (optional - if you need this feature)
    func deleteProfile() {
        UserDefaults.standard.removeObject(forKey: profileKey)
        print("🗑️ Profile deleted")
    }
}

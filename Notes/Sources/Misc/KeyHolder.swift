import Foundation

struct KeyHolder {
  
  enum KeyType: String { case email, password, token }
  
  // MARK: Get
  static func get(_ key: KeyType) -> String? {
    let keychainQuery: [CFString : Any] = [
      kSecClass : kSecClassGenericPassword,
      kSecAttrService : key.rawValue,
      kSecReturnData: kCFBooleanTrue as Any,
      kSecMatchLimitOne: kSecMatchLimitOne
    ]

    var dataTypeRef: AnyObject?
    SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
    
    guard let data = dataTypeRef as? Data else { return nil }

    return String(data: data, encoding: .utf8)
  }
  
  // MARK: Update
  static func update(_ value: String, for key: KeyType) {
    guard let data = value.data(using: .utf8) else { return }
    
    let keychainQuery: [CFString : Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: key.rawValue,
      kSecValueData: data
    ]
    
    SecItemDelete(keychainQuery as CFDictionary)
    SecItemAdd(keychainQuery as CFDictionary, nil)
  }
  
  // MARK: Remove
  static func remove(_ value: String, for key: KeyType) {
    let keychainQuery: [CFString : Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: key.rawValue
    ]
    
    SecItemDelete(keychainQuery as CFDictionary)
  }
}

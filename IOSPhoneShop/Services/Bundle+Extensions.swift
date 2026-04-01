/* Bundle+Extensions.swift */
import Foundation

extension Bundle {
    var baseURL: String {
        return object(forInfoDictionaryKey: "BaseURL") as? String ?? "localhost:8080"
    }
}

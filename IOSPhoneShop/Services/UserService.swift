/* UserService.swift */
import Foundation

@MainActor
class UserService {
    static let shared = UserService()
    private let baseURL = "http://\(Bundle.main.baseURL)"
    
    func decode(jwtToken jwt: String) -> [String: Any] {
        let segments = jwt.components(separatedBy: ".")
        guard segments.count > 1,
              let payloadData = decodeBase64(segments[1]),
              let payload = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any] else {
            return [:]
        }
        return payload
    }
    
    private func decodeBase64(_ str: String) -> Data? {
        var base64 = str
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let length = Double(base64.lengthOfBytes(using: .utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = Int(requiredLength - length)
        if paddingLength > 0 {
            let padding = String(repeating: "=", count: paddingLength)
            base64 += padding
        }
        return Data(base64Encoded: base64)
    }
    
    func getNameFromStoredToken() -> String? {
        guard let token = UserDefaults.standard.string(forKey: "userToken") else {
            return nil
        }
        let payload = decode(jwtToken: token)
        
        if let name = payload["name"] as? String {
            UserDefaults.standard.set(name, forKey: "userName")
            return name
        } else if let userName = payload["username"] as? String {
            UserDefaults.standard.set(userName, forKey: "userName")
            return userName
        }
        
        return nil
    }
    
    func getUserIdFromToken() -> Int {
        guard let token = UserDefaults.standard.string(forKey: "userToken") else { return 0 }
        let payload = decode(jwtToken: token)
        
        if let subValue = payload["sub"] {
            if let idInt = subValue as? Int { return idInt }
            if let idString = subValue as? String { return Int(idString) ?? 0 }
        }
        return 0
    }
    
    func login(loginData: LoginRequest, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(self.baseURL)/users/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Task {
            do {
                request.httpBody = try JSONEncoder().encode(loginData)
                let (data, _) = try await URLSession.shared.data(for: request)
                
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                let token = loginResponse.token
                let payload = self.decode(jwtToken: token)
                
                if let extractedName = payload["name"] as? String {
                    UserDefaults.standard.set(extractedName, forKey: "userName")
                }
                
                if let subValue = payload["sub"] {
                    let userId: Int
                    if let idInt = subValue as? Int {
                        userId = idInt
                    } else if let idString = subValue as? String {
                        userId = Int(idString) ?? 0
                    } else {
                        userId = 0
                    }
                    UserDefaults.standard.set(userId, forKey: "userId")
                }
                
                let role = payload["role"] as? String ?? "USER"
                UserDefaults.standard.set(token, forKey: "userToken")
                UserDefaults.standard.set(role, forKey: "userRole")
                
                completion(token)
            } catch {
                completion(nil)
            }
        }
    }

    func fetchAndSaveUserInfo() async {
        guard let url = URL(string: "\(self.baseURL)/users") else { return }
        
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let fetchedName = json["name"] as? String ?? json["username"] as? String ?? ""
                
                if !fetchedName.isEmpty {
                    UserDefaults.standard.set(fetchedName, forKey: "userName")
                }
            }
        } catch {
        }
    }
    
    func withdrawUser(requestData: WithdrawRequest, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(self.baseURL)/users/withdraw") else { return }
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        Task {
            do {
                request.httpBody = try JSONEncoder().encode(requestData)
                let (_, response) = try await URLSession.shared.data(for: request)
                let success = (response as? HTTPURLResponse)?.statusCode == 200
                
                if success {
                    self.clearUserData()
                }
                completion(success)
            } catch {
                completion(false)
            }
        }
    }
    
    func registerUser(signupData: SignupRequest, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(self.baseURL)/users/signup") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Task {
            do {
                request.httpBody = try JSONEncoder().encode(signupData)
                let (_, response) = try await URLSession.shared.data(for: request)
                let success = (response as? HTTPURLResponse)?.statusCode == 201 || (response as? HTTPURLResponse)?.statusCode == 200
                
                completion(success)
            } catch {
                completion(false)
            }
        }
    }
    
    func updateUserInfo(updateData: UpdateUserRequest, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(self.baseURL)/users/update") else { return }
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        Task {
            do {
                request.httpBody = try JSONEncoder().encode(updateData)
                let (_, response) = try await URLSession.shared.data(for: request)
                
                let success = (response as? HTTPURLResponse)?.statusCode == 200
                if success {
                    UserDefaults.standard.set(updateData.name, forKey: "userName")
                }
                completion(success)
            } catch {
                completion(false)
            }
        }
    }
    
    func resetPassword(name: String, email: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/password/reset") else { return }
        
        let body: [String: String] = ["name": name, "email": email]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(nil)
                return
            }
            
            if let tempPassword = String(data: data, encoding: .utf8) {
                completion(tempPassword)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    private func clearUserData() {
        ["userToken", "userName", "userEmail", "userId", "userRole"].forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
    }
}

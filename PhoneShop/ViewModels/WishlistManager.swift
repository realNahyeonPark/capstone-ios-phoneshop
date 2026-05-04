import SwiftUI

class FavoritesManager: ObservableObject {
    var objectWillChange: ObservableObjectPublisher
    
    @Published var wishedProducts: Set<Int> = [] // 찜한 상품의 ID 세트
    
    // 찜 여부 확인
    func isWished(product: Product) -> Bool {
        return wishedProducts.contains(product.id)
    }
    
    // 찜하기 토글 (백엔드 연결)
    func toggleWish(product: Product) {
        if isWished(product: product) {
            // 💡 찜 해제 로직 (필요 시 DELETE API 연결)
            // 현재는 추가 기능 위주이므로 로컬에서 제거만 하거나 별도 삭제 API 호출
            removeFromFavorites(phoneId: product.id)
        } else {
            // 💡 찜 추가 (작성하신 FavoriteService 사용)
            FavoriteService.shared.addToFavorites(phoneId: product.id) { success in
                if success {
                    DispatchQueue.main.async {
                        self.wishedProducts.insert(product.id)
                        print("✅ 서버에 찜 추가 완료: \(product.name)")
                    }
                } else {
                    print("❌ 찜 추가 실패")
                }
            }
        }
    }
    
    // (선택) 찜 제거 API가 있다면 연결
    private func removeFromFavorites(phoneId: Int) {
        // 우선 로컬에서만 제거 예시
        self.wishedProducts.remove(phoneId)
        print("🗑️ 찜 제거됨 (로컬)")
    }
}

//
//  FilterChip.swift
//  IOSPhoneShop
//
//  Created by nh on 2/12/26.
//


// ✅ SearchResultView 구조체 밖(파일 하단)에 추가하세요.
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                // 선택되었을 때는 파란색, 아니면 연한 회색 배경
                .background(isSelected ? Color.blue : Color(.systemGray6))
                // 선택되었을 때는 흰색, 아니면 기본 글자색
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}
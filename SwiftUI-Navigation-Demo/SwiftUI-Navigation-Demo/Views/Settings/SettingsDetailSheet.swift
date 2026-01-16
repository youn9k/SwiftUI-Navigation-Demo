import SwiftUI

struct SettingsDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var autoSave = true
    @State private var cacheSize = 50.0
    @State private var dataSync = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("자동 저장", isOn: $autoSave)
                    Toggle("데이터 동기화", isOn: $dataSync)
                } header: {
                    Text("고급 옵션")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("캐시 크기: \(Int(cacheSize))MB")
                            .font(.subheadline)

                        Slider(value: $cacheSize, in: 0...100, step: 10)
                    }
                } header: {
                    Text("저장소")
                }

                Section {
                    Button("캐시 지우기") {
                        // 캐시 지우기 로직
                    }

                    Button(role: .destructive) {
                        // 모든 데이터 삭제 로직
                    } label: {
                        Text("모든 데이터 삭제")
                    }
                } header: {
                    Text("데이터 관리")
                }
            }
            .navigationTitle("고급 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsDetailSheet()
}

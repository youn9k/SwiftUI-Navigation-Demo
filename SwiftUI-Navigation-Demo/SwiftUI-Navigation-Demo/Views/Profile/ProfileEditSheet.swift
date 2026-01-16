import SwiftUI

struct ProfileEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = "홍길동"
    @State private var email = "hong@example.com"
    @State private var phone = "010-1234-5678"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("이름", text: $name)
                    TextField("이메일", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("전화번호", text: $phone)
                        .keyboardType(.phonePad)
                } header: {
                    Text("기본 정보")
                }

                Section {
                    Button("저장") {
                        // 저장 로직
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle("프로필 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileEditSheet()
}

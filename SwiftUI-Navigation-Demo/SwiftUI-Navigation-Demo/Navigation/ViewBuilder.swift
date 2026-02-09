import SwiftUI

/// Navigation 모듈이 제공하는 뷰 생성 프로토콜
/// App 모듈이 이 프로토콜을 구현하여 Feature View를 생성
public protocol ViewBuilder {
    // Root Views (탭 진입점)
    func makeHomeView(navigate: @escaping (Destination) -> Void) -> AnyView
    func makeProfileView(navigate: @escaping (Destination) -> Void) -> AnyView
    func makeSettingsView(navigate: @escaping (Destination) -> Void) -> AnyView

    // Push Destinations
    func makeView(for destination: PushDestination, navigate: @escaping (Destination) -> Void) -> AnyView

    // Sheet Destinations
    func makeView(for destination: SheetDestination, navigate: @escaping (Destination) -> Void) -> AnyView

    // FullScreen Destinations
    func makeView(for destination: FullScreenDestination, navigate: @escaping (Destination) -> Void) -> AnyView
}

import SwiftUI

struct LogoView: View {
    let size: CGFloat

    var body: some View {
        Group {
            if let logo = loadLogo() {
                Image(nsImage: logo)
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .fill(Color(nsColor: .windowBackgroundColor))
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
    }

    private func loadLogo() -> NSImage? {
        if let url = Bundle.module.url(forResource: "AppIcon", withExtension: "png") {
            return NSImage(contentsOf: url)
        }
        return nil
    }
}

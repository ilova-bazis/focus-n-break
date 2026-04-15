import SwiftUI

struct MainWindowView: View {
    var body: some View {
        MenuPopoverView(showCloseButton: false)
            .frame(minWidth: 320, idealWidth: 360)
    }
}

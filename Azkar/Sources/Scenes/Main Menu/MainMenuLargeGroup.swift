// ASCollectionView. Created by Apptek Studios 2019

import SwiftUI

struct MainMenuLargeGroupViewModel: Equatable, Identifiable {
    var id: String { category.title }
    let category: ZikrCategory
    let title: String
    let animationName: String
    let animationSpeed: Double
}

struct MainMenuLargeGroup: View {

    let viewModel: MainMenuLargeGroupViewModel

	var body: some View {
        VStack(alignment: .center, spacing: 0) {
            LottieView(
                name: viewModel.animationName,
                loopMode: .loop,
                contentMode: .scaleAspectFit,
                speed: CGFloat(viewModel.animationSpeed)
            )
            .frame(width: 60, height: 60)
            .padding(8)

            Text(viewModel.title)
                .font(Font.system(.body, design: .rounded))
				.bold()
				.multilineTextAlignment(.leading)
				.foregroundColor(Color.secondaryText)
                .padding(8)
                .layoutPriority(1)
		}
		.padding()
	}
}

struct GroupLarge_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
            MainMenuLargeGroup(
                viewModel: MainMenuLargeGroupViewModel(
                    category: .morning,
                    title: "Test",
                    animationName: "sun",
                    animationSpeed: 1
                )
            )
		}
        .previewLayout(.fixed(width: 200, height: 150))
	}
}

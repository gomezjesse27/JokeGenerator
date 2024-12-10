import SwiftUI

struct HistoryView: View {
    @State var history: [String] // Passed jokes history
    @Environment(\.dismiss) var dismiss // To close the view if needed

    var body: some View {
        NavigationView {
            VStack {
                Text("Joke History")
                    .font(.largeTitle.bold())
                    .padding()

                if history.isEmpty {
                    Text("No jokes in history yet!")
                        .foregroundColor(.gray)
                        .font(.title2)
                        .padding()
                } else {
                    List {
                        ForEach(history, id: \.self) { joke in
                            Text(joke)
                                .padding()
                                .multilineTextAlignment(.leading)
                        }
                    }
                }

                Spacer()

                // Clear History Button
                Button(action: clearHistory) {
                    Text("Clear History")
                        .font(.title2.bold())
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: .gray, radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    // Function to clear the history
    private func clearHistory() {
        history.removeAll()
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(history: ["Why don't scientists trust atoms? Because they make up everything!", "Another joke here."])
    }
}

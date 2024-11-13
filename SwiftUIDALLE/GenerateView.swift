//
//  GenerateView.swift
//  SwiftUIDALLE
//
//  Created by Yael Javier Zamora Moreno on 13/11/24.
//

import SwiftUI

final class ViewModel: ObservableObject {
    private let urlSession: URLSession
    @Published var imageURL: URL?
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func generateImage(withText text: String) async {
        guard let url = URL(string: "https://api.openai.com/v1/images/generations") else {
            return
        }
        
        var urlRequest = URLRequest(url: url) // 1
        
        urlRequest.httpMethod = "POST"         // 2
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type") // 3
        urlRequest.addValue("Bearer TODO", forHTTPHeaderField: "Authorization") // 4
        
        let dictionary: [String : Any] = [ // 5
            "n": 1,
            "size": "1024x1024",
            "prompt": text
        ]
        
        urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: dictionary, options: []) // 6
        
        do {
            let (data, _) = try await urlSession.data(for: urlRequest) // 1
            let model = try JSONDecoder().decode(ModelResponse.self, from: data) // 2
            DispatchQueue.main.async {
                guard let firstModel = model.data.first else {
                    return
                }
                self.imageURL = URL(string: firstModel.url)
            }
        } catch {
            print(error.localizedDescription) // 4
        }
    }
}

struct GenerateView: View {
    @State var text = "Two astronauts exploring the dark, cavernous interior of a huge derelict spacecraft, digital art"
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Text("Hello, Welcome to my App")
            
            AsyncImage(url: viewModel.imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                VStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                }
                .frame(width: 300, height: 300)
            }
            
            Form {
                TextField(
                    "Escribe lo que quieres",
                    text: $text,
                    axis: .vertical
                ).lineLimit(10).lineSpacing(5)
                
                Button("Generate Image") {
                    Task {
                        await viewModel.generateImage(withText: text)
                    }
                }
            }
        }
    }
}

#Preview {
    GenerateView()
}

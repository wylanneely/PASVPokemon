//
//  ContentView.swift
//  PokemonSwiftUI
//
//  Created by Wylan L Neely on 1/24/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var searchText = ""
    @State private var pokemon: Pokemon? = nil
    
    @State private var errorMessage: String? = nil
    @State private var isLoading = false

    var body: some View {
        HStack {
            
            
            TextField("Search Pokemon", text: $searchText) // Textfield needs a binding state object that reflects the UI and The code bound together
                .textFieldStyle(.automatic)
                .foregroundColor(Color.cyan)
                .padding(.leading, 20.0)
            
            
            Button(action: {
                fetchPokemon(for: searchText)
            }) {
                Label("Search", systemImage: "magnifyingglass")
                    .labelStyle(.iconOnly)
                    .padding()
                    .foregroundColor(Color.cyan.opacity(0.8))
                }
                .padding(.trailing,5.0)
            }
            .background(Color.yellow)
            .cornerRadius(16)
            .padding(.horizontal, 20.0)
            .padding(.top, 10)
        
        
        Group {
            if isLoading { // if loading run this block of code
                
                ProgressView("Fetching Pokemon...")
                    .padding()
                
            } else if let pokemon = pokemon { // if a pokemon exists run this
                
                
                PokemonView(pokemon: pokemon)

                
                
                
            } else if let error = errorMessage { // if there isnt a pokemon run an error message
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Please Search for a Pokemon")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        
        
   }
    
    
    //MARK: Functions
    private func fetchPokemon(for pokemonName: String) {
        guard !pokemonName.isEmpty else {
            errorMessage = "Enter Pokemon Name"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedPokemon = try await NetworkController.fetchPokemon(pokemonName.lowercased())
                
                await MainActor.run {
                    isLoading = false
                    pokemon = fetchedPokemon
                }
                
            } catch {
                
                await MainActor.run {
                    errorMessage = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

struct PokemonView: View {
    
    let pokemon: Pokemon
    
    var body: some View {
        VStack{
            AsyncImage(url: pokemon.imageURLs.last) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 140, maxHeight: 140)
                    
                case .failure:
                    EmptyView()
                @unknown default:
                    EmptyView()
                }
                
            }
            HStack {
                Text(pokemon.name.capitalized)
                    .font(.largeTitle)
                    .padding()
                ForEach(pokemon.types, id:\.self) { poketype in
                    Text(poketype)
                        .padding(.trailing, 20)
                }
               // Text(pokemon.types.first ?? "no abilities")
            }
            .background(Color.yellow)
            .cornerRadius(14)

            ForEach(pokemon.abilities, id:\.self) { ability in
                Text(ability)
                    .background(Color.yellow)
                    .font(.title)
                    .cornerRadius(12)
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mint)
    }
}

#Preview {
    ContentView()
}

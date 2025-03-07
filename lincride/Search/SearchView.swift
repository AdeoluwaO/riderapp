//
//  SearchView.swift
//  lincride
//
//  Created by Adeoluwa on 25/02/2025.
//

import SwiftUI
import MapKit

struct SearchView: View {
    let viewModel: SearchViewViewModel
    @State var mapScreenViewModel: MapView.ViewModel
//    @State private var viewModel = SearchViewViewModel()
    @FocusState private var isFocused: Bool
    
    @Environment(\.managedObjectContext) var context
    
    var body: some View {
        
        VStack {
            // Search bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass") // Search icon
                        .foregroundColor(.gray)
                    
                    TextField("Search Maps", text: $mapScreenViewModel.searchQuery)
                        .focused($isFocused)
                        .autocorrectionDisabled(true)
                        .onChange(of: isFocused) { oldValue, newValue in
                            withAnimation {
                                viewModel.isEditing = newValue
                            }
                        }
                    Image(systemName: "multiply.circle") // clear icon
                        .foregroundColor(.gray)
                        .onTapGesture {
                            mapScreenViewModel.searchQuery = ""
                            
                        }
                }
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                
                if isFocused {
                    Button("Cancel") {
                        withAnimation {
                            isFocused   = false
                            mapScreenViewModel.searchQuery = ""
                            mapScreenViewModel.showSearchModal = false
                        }
                    }
                    .foregroundColor(.blue)
                    .transition(.move(edge: .trailing))
                }
            }
            .padding()
            // Suggestion searches
            if viewModel.isEditing {
                
                if mapScreenViewModel.isLoadingLocation {
                    LoadingView()
                }
                
                if mapScreenViewModel.searchSuggestions.isEmpty && !$mapScreenViewModel.searchQuery.wrappedValue.isEmpty && !mapScreenViewModel.isLoadingLocation {
                    VStack(spacing: 10) {
                        Spacer()
                        Image(systemName: "multiply.circle")
                            .font(.system(size: 30))
                            .foregroundColor(.red)
                        
                        Text("No location found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                        
                    }
                } else {
                    List {
                        Section(header: Text(mapScreenViewModel.searchSuggestions.isEmpty ? "" : "Suggestions").foregroundColor(.gray)) {
                            ForEach(mapScreenViewModel.searchSuggestions, id: \.id) { suggestion in
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                    Text(suggestion.address).onTapGesture {
                                        mapScreenViewModel.search(for: suggestion.address)
                                        mapScreenViewModel.showSearchModal = false
                                        mapScreenViewModel.searchQuery = suggestion.address
                                    }
                                    Spacer()
                                    Image(systemName: suggestion.isSelected ? "bookmark.fill" : "bookmark")
                                        .foregroundColor(.gray).onTapGesture {
                                            if let index = mapScreenViewModel.searchSuggestions.firstIndex(where: { $0.id == suggestion.id }) {
                                                if !mapScreenViewModel.searchSuggestions[index].isSelected { // Check before toggling
                                                    viewModel.savedSuggestedLocation(mapScreenViewModel.searchSuggestions[index])
                                                }
                                                mapScreenViewModel.searchSuggestions[index].isSelected.toggle() // Toggle after checking
                                            }
                                            
                                        }
                                    
                                    Spacer().frame(width: 10)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation {
                isFocused = true
            }
        }.onDisappear {
            if(!viewModel.savedLocations.isEmpty) {
                viewModel.savedLocations.forEach { location in
                    let _ = SavedLocation(name: "Place", address: location.address, locationId: location.id, timestamp: Date(), context: context)
                    PersistenceController.shared.save()
                }
                
            }
        }
    }
}

//#Preview {
//    @State var search = ""
//    SearchView(searchText: $search, suggestions: [String]()) {
//    } onCancel: {
//
//    } onTapSuggestion: { suggestion in
//        print("SUGGESTION: \(suggestion)")
//    }
//
//}

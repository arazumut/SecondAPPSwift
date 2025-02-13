import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var selectedTab: Int = 0
    @State private var userName: String = ""
    @State private var bio: String = ""
    @State private var showWelcomeMessage: Bool = false
    @State private var profileImage: Image? = Image(systemName: "person.crop.circle.fill")
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var selectedLanguage: String = "Türkçe"
    @State private var showPasswordPrompt: Bool = false
    @State private var enteredPassword: String = ""
    @State private var isPasswordCorrect: Bool = false

    let languages = ["Türkçe", "English", "Español"]
    let motivationMessages = [
        "Bugün harika bir gün olacak! 🌟",
        "Başarı, küçük adımlarla gelir. 👣",
        "Hayallerinin peşinden git! 🚀",
        "Gülümse, çünkü sen değerlisin! 😊",
        "Her gün yeni bir başlangıçtır! 🌅"
    ]
    
    struct ImagePicker: UIViewControllerRepresentable {
        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker

            init(parent: ImagePicker) {
                self.parent = parent
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let uiImage = info[.originalImage] as? UIImage {
                    parent.image = uiImage
                }
                parent.presentationMode.wrappedValue.dismiss()
            }
        }

        @Environment(\.presentationMode) var presentationMode
        @Binding var image: UIImage?

        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }

        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: isDarkMode ? [Color.black, Color.gray] : [Color.blue, Color.purple]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                // Home Page
                VStack {
                    Text("Ana Sayfa")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    Text(motivationMessages.randomElement()!)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(15)
                        .padding(.horizontal, 40)
                        .animation(.easeInOut, value: motivationMessages)

                    Spacer()

                    Image(systemName: "house.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        )
                        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)

                    Spacer()

                    Button(action: {
                        withAnimation(.spring()) {
                            showWelcomeMessage.toggle()
                        }
                    }) {
                        Text(showWelcomeMessage ? "Mesajı Gizle" : "Hoşgeldiniz Mesajı Göster")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .cornerRadius(15)
                            .padding(.horizontal, 40)
                    }

                    if showWelcomeMessage {
                        Text("Merhaba, \(userName.isEmpty ? "Ziyaretçi" : userName)!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(20)
                            .padding(.horizontal, 40)
                            .transition(.opacity.combined(with: .slide))
                    }

                    Spacer()
                }
                .padding()
                .tag(0)

                // Profile Page
                VStack(spacing: 20) {
                    Text("Profil")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    profileImage?
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 10)

                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Text("Profil Fotoğrafını Değiştir")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                    }

                    TextField("Adınızı Girin", text: $userName)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .padding(.horizontal, 50)

                    TextField("Biyografinizi Girin", text: $bio)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .padding(.horizontal, 50)

                    if !userName.isEmpty {
                        Text("Merhaba, \(userName)!")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(20)
                            .padding(.horizontal, 40)
                            .transition(.move(edge: .bottom))
                    }

                    Spacer()
                }
                .padding()
                .tag(1)
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: $inputImage)
                }

                // Settings Page
                VStack(spacing: 20) {
                    Text("Ayarlar")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    Toggle(isOn: $isDarkMode) {
                        Text("Karanlık Mod")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal, 40)

                    Picker("Dil Seçin", selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) { language in
                            Text(language).tag(language)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 40)

                    Button("Şifre Gir") {
                        showPasswordPrompt = true
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(15)

                    Spacer()
                }
                .padding()
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Bilgi"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
        }
        .sheet(isPresented: $showPasswordPrompt) {
            PasswordPrompt(isPasswordCorrect: $isPasswordCorrect)
        }
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
    }
}

struct PasswordPrompt: View {
    @Binding var isPasswordCorrect: Bool
    @State private var password: String = ""

    var body: some View {
        VStack {
            SecureField("Şifre Girin", text: $password)
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(20)
                .padding(.horizontal, 50)
        }
    }
}

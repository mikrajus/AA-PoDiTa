<div align="center">
  <img src="assets/images/logo.png" alt="AA-PoDiTa Logo" width="120" />
  
  # AA-PoDiTa (Posyandu Digital Terpadu)
  
  **Aman Datanya, Aman Anaknya** <br>
  *A comprehensive digital solution for Posyandu cadres and health workers to monitor, analyze, and manage toddler nutritional status effectively.*

  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](https://firebase.google.com/)
</div>

---

## 📖 Overview

**AA-PoDiTa** (Posyandu Digital Terpadu Bayi Balita) is an innovative mobile application designed to modernize the workflow of Posyandu (Integrated Healthcare Center) in Indonesia. By digitizing health records, the app enables Posyandu cadres and head health workers to actively prevent and monitor stunting in toddlers.

This application replaces the manual tracking system with a robust digital platform, offering real-time Z-Score calculations (based on WHO Growth Standards), automated graphical analysis, and secure medical history tracking.

## ✨ Key Features

- **Automated Z-Score Calculation:** Instantly calculates the nutritional status of toddlers based on World Health Organization (WHO) standards.
- **Interactive Growth Charts:** Visualizes weight and height progress over time to quickly identify stunting risks.
- **Digital KIA Book:** A digital version of the Maternal and Child Health (KIA) book, securely storing medical histories and complaints.
- **Dual Role System:** Dedicated interfaces and distinct functionalities for Posyandu Cadres (Data Entry) and Health Workers/Puskesmas Heads (Monitoring & Analysis).
- **Excel Report Export:** Generate and export comprehensive medical records and growth data into Excel files with a single tap.
- **Responsive UI/UX:** Built with a modern, glassmorphism-inspired design to ensure a smooth and premium user experience.

## 📸 Screenshots
<div align="center">
  <img width="350" height="700" alt="image" src="https://github.com/user-attachments/assets/fa015678-06e0-4179-9c7f-ed240229a2d4" />
  <img width="350" height="700" alt="image" src="https://github.com/user-attachments/assets/45ee4624-6882-48ba-a6e7-6700f5ad462c" />
  <img width="350" height="700" alt="image" src="https://github.com/user-attachments/assets/ed76f810-f344-41bc-b28f-8606cb3be4ab" />
  <img width="350" height="700" alt="image" src="https://github.com/user-attachments/assets/a1e8d6bb-165f-44e3-b180-5e15ec052e8f" />
  <img width="350" height="700" alt="image" src="https://github.com/user-attachments/assets/a7c6402e-c026-4770-8d41-8731ef5891a8" />
  <img width="350" height="700" alt="image" src="https://github.com/user-attachments/assets/1d4c3978-5542-450c-aabf-ebd164b06fea" />
</div>

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Backend/Auth:** Firebase Authentication & Cloud Firestore
- **Local Storage:** Shared Preferences
- **Data Export:** Syncfusion Flutter XlsIO
- **Fonts & Icons:** Google Fonts (Poppins), FontAwesome

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.x or higher)
- [Dart SDK](https://dart.dev/get-dart)
- IDE (VS Code, Android Studio, etc.)
- A Firebase Project (for Auth & Firestore)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/AA-PoDiTa.git
   cd AA-PoDiTa
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Create a project on [Firebase Console](https://console.firebase.google.com/).
   - Add an Android App with the package name `com.yourcompany.aa_podita` (or modify `android/app/build.gradle` to match yours).
   - Download the `google-services.json` file and place it in the `android/app/` directory.
   - Enable **Email/Password Authentication** and **Firestore Database**.

4. **Run the application:**
   ```bash
   flutter run
   ```

## 🏗️ Architecture & Security

- **Role-Based Access Control (RBAC):** Users must be registered by a system administrator into the `username_pool` collection before they can create a Firebase Auth account, ensuring strict access control.
- **Data Privacy:** Sensitive child health data is secured within Firestore rules and only accessible to authorized healthcare personnel.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/yourusername/AA-PoDiTa/issues).

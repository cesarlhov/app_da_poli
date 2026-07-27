// No topo do arquivo, garanta que o plugin do google-services está sendo aplicado
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // <<< GARANTA QUE ESTA LINHA EXISTA
}

// ... (outras configurações como 'android', 'defaultConfig', etc.)

// No final do arquivo, dentro do bloco dependencies { ... }
dependencies {
    // ... (outras dependências que já possam existir)

    // Adicione a Bill of Materials (BOM) do Firebase
    implementation(platform("com.google.firebase:firebase-bom:33.1.1"))

    // Adicione as dependências do Firebase que você precisa (sem especificar versões)
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-analytics")
    
    // Suporte ao Multidex
    implementation("androidx.multidex:multidex:2.0.1")
}
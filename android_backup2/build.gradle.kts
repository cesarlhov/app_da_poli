plugins {
    // Define as versões dos plugins principais para todo o projeto
    id("com.android.application") version "8.2.1" apply false
    id("org.jetbrains.kotlin.android") version "1.8.20" apply false
    id("com.google.gms.google-services") version "4.3.15" apply false
}

// Esta parte força todos os submódulos a usar a mesma versão do Kotlin,
// resolvendo o erro de "Duplicate class".
subprojects {
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin" && requested.name.startsWith("kotlin-stdlib")) {
                useVersion("1.8.20")
            }
        }
    }
}
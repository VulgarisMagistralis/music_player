import java.util.Properties
import java.io.FileInputStream
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}
dependencies {
    implementation("androidx.media:media:1.7.0")
    implementation("androidx.legacy:legacy-support-v4:1.0.0")
    // Android For Cars (Automotive OS)
    implementation("androidx.car.app:app:1.7.0")
    implementation("androidx.car.app:app-automotive:1.7.0")
}

android {
    namespace = "com.cenkt.music_player"
    compileSdk = 36
    ndkVersion = "28.2.13676358"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.cenkt.music_player"
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    signingConfigs {
        create("release") {
            storeFile = file("release.keystore")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = System.getenv("KEY_ALIAS")
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
    // ──────────────────────────────────────────────────────────
    //  PRODUCT FLAVORS
    // ──────────────────────────────────────────────────────────
    flavorDimensions += "car"

    productFlavors {
        // ----- Android Auto (Google Play Auto) -----
        create("auto") {
            dimension = "car"
            // No automotive‑OS hardware feature – keep Google‑Auto metadata only.
            // Anything you need specifically for the Auto flavor can be added here
            // (e.g., versionNameSuffix = "-auto").
        }

        // ----- Android Automotive OS (stand‑alone) -----
        create("automotive") {
            dimension = "car"
            // The automotive feature is added via the flavor‑specific manifest,
            // not here. You can still customize version codes, resources, etc.
        }
    }

    // ──────────────────────────────────────────────────────────
    //  Source‑set layout – tell Gradle where the flavor manifests live
    // ──────────────────────────────────────────────────────────
    sourceSets {
        // Common code / resources (already in src/main)
        getByName("main") {
            manifest.srcFile("src/main/AndroidManifest.xml")
        }

        // Auto flavor – merges src/auto/AndroidManifest.xml on top of main
        getByName("auto") {
            manifest.srcFile("src/auto/AndroidManifest.xml")
        }

        // Automotive flavor – merges src/automotive/AndroidManifest.xml on top of main
        getByName("automotive") {
            manifest.srcFile("src/automotive/AndroidManifest.xml")
        }
    }
}

flutter {
    source = "../.."
}

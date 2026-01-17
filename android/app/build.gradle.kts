plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // 🔥 Firebase
}

android {
    namespace = "com.example.test_app"

    // 🔥 REQUIRED FOR FIREBASE + ANDROID 13 NOTIFICATIONS
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.test_app"

        minSdk = flutter.minSdkVersion
        targetSdk = 34

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 🔥 REQUIRED FOR FIREBASE
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true 
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            // OK for testing; later you can add release signing
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // 🔥 REQUIRED FOR MULTIDEX
    implementation("androidx.multidex:multidex:2.0.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}

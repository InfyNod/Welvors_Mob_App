plugins {
    id("com.android.application")
    id("kotlin-android")
    
    // Yahan apply hona chahiye (bina version ke)
    id("com.google.gms.google-services") 
    
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
android {
    namespace = "com.infynod.welvors"
    
    // Yahan 36 kar dein taaki modern plugins successfully compile ho sakein
    compileSdk = 36 
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.infynod.welvors"
        minSdk = flutter.minSdkVersion
        
        // Isko 34 par hi lock rakhein taaki device runtime behavior change na ho
        targetSdk = 34 
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Required by flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}

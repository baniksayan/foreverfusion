plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.forever_fusion"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.forever_fusion"
        minSdk = 24 // ⬅️ Increased to 24 (Required for Flutter Stripe)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
        isMinifyEnabled = true  // ⬅️ Enable code shrinking (fixes error)
        isShrinkResources = true  // ⬅️ Shrink unused resources
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}

}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.stripe:stripe-android:20.48.3")
    implementation("androidx.appcompat:appcompat:1.6.1") // ⬅️ Added for better compatibility
    implementation("androidx.fragment:fragment-ktx:1.6.2") // ⬅️ Required for FlutterFragmentActivity
}

import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

val hasValidKeystore = keystorePropertiesFile.exists() && 
    keystoreProperties["storeFile"] != null && 
    file(keystoreProperties["storeFile"] as String).exists()
val splitPerAbi = project.findProperty("split-per-abi") == "true"

android {
    namespace = "com.degenk.boorusama"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.glack.boorusama"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        getByName("debug") {
            keyAlias = "androiddebugkey"
            keyPassword = "android"
            storeFile = rootProject.file("keystore/debug.jks")
            storePassword = "android"
        }

        create("release") {
            if (hasValidKeystore) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasValidKeystore)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
        }
    }

    flavorDimensions.add("boorusama")

    productFlavors {
        create("dev") {
            dimension = "boorusama"
            resValue("string", "app_name", "Boorusama Dev")
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }

        create("prod") {
            dimension = "boorusama"
            resValue("string", "app_name", "Boorusama")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

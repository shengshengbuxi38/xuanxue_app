pluginManagement {
    // 修正 local.properties 中的中文路径，避免 Gradle 编码错误
    val localPropsFile = file("local.properties")
    if (localPropsFile.exists()) {
        val props = java.util.Properties()
        localPropsFile.inputStream().use { props.load(it) }
        val raw = props.getProperty("flutter.sdk", "")
        // 检测是否包含非 ASCII 字符（中文路径）
        if (raw.any { it.code > 127 }) {
            props.setProperty("flutter.sdk", "C:\\flutter_sdk")
            localPropsFile.outputStream().use { props.store(it, null) }
        }
    }

    val flutterSdkPath = "C:\\flutter_sdk"

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/central") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")

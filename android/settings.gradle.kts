pluginManagement {
    // 本地中文路径修正（CI 环境由 Flutter 自动设置，不需要 local.properties）
    var flutterSdkPath = "C:\\flutter_sdk" // 默认值（仅本地 Windows 使用）
    val localPropsFile = file("local.properties")
    if (localPropsFile.exists()) {
        val props = java.util.Properties()
        localPropsFile.inputStream().use { props.load(it) }
        val raw = props.getProperty("flutter.sdk", "")
        if (raw.any { it.code > 127 }) {
            props.setProperty("flutter.sdk", "C:\\flutter_sdk")
            localPropsFile.outputStream().use { props.store(it, null) }
        }
        flutterSdkPath = props.getProperty("flutter.sdk") ?: flutterSdkPath
    }

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

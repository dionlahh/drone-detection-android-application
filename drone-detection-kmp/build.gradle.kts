@file:Suppress("UnstableApiUsage")

plugins {
    id("com.android.application") version "8.5.0" apply false
    id("com.android.library") version "8.5.0" apply false
    id("org.jetbrains.kotlin.multiplatform") version "1.9.24" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}


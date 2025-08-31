// In android/build.gradle.kts

plugins {
    // We only need to declare the google-services plugin here.
    // Flutter will handle the Android and Kotlin plugin versions automatically.
    id("com.google.gms.google-services") version "4.4.1" apply false
}

// The rest of your file remains exactly the same
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
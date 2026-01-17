// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    // 🔥 REQUIRED KOTLIN VERSION (STABLE FOR FIREBASE + NOTIFICATIONS)
    extra["kotlin_version"] = "1.9.22"

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // 🔥 GOOGLE SERVICES PLUGIN (FIREBASE)
        classpath("com.google.gms:google-services:4.4.4")
    }
}


allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 🔧 CUSTOM BUILD DIRECTORY (FLUTTER DEFAULT STRUCTURE)
val newBuildDir = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// 🔥 CLEAN TASK
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

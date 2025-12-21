allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }
    
    // Fix for plugins not specifying namespace (AGP 8+ requirement)
    plugins.withId("com.android.library") {
        val android = project.extensions.getByName("android") as com.android.build.gradle.LibraryExtension
        if (android.namespace == null) {
            android.namespace = "com.example.${project.name}"
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

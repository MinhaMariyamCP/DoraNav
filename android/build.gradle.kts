allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val rootBuildDir = rootProject.projectDir.parentFile.resolve("build")
allprojects {
    layout.buildDirectory.set(rootBuildDir.resolve(project.name))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootBuildDir)
}

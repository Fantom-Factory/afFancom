using build::BuildPod

class Build : BuildPod {
		
	new make() {
		podName = "afFancom"
		summary = "A Fantom / COM Automation bridge for the JVM Runtime"
		version = Version("1.0.4")
		
		meta = [
			"proj.name"		: "Fancom",	
			"repo.tags"		: "system",
			"repo.public"	: "true"
		]
	
		depends = [
			"sys 1.0"
		]

		srcDirs = [`test/`, `test/utils/`, `fan/`, `fan/internal.utils/`, `fan/internal/`]
		resDirs = [`doc/`, `res/jacob-1.17-M2/`]
		javaDirs = [`java/`]
	}
}

using build::BuildPod

class Build : BuildPod {
		
	new make() {
		podName = "afFancom"
		summary = "A Fantom / COM Automation bridge for the JVM Runtime"
		version = Version("1.0.5")
		
		meta = [
			"proj.name"		: "Fancom",	
			"repo.tags"		: "system",
			"repo.public"	: "false"
		]
	
		depends = [
			"sys 1.0"
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/internal.utils/`, `test/`, `test/utils/`]
		resDirs = [`doc/`, `res/jacob-1.17-M2/`]
		javaDirs = [`java/`]
	}
}

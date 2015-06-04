using build::BuildPod

class Build : BuildPod {
		
	new make() {
		podName = "afFancom"
		summary = "A Fantom / COM Automation bridge for the JVM Runtime"
		version = Version("1.0.5")
		
		meta	= [	"org.name"		: "Alien-Factory",
					"org.uri"		: "http://www.alienfactory.co.uk/",
					"proj.name"		: "AF-Fancom",
					"license.name"	: "BSD 2-Clause License",
					"repo.private"	: "true"	// EEK!
				  ]
		
		srcDirs = [`test/`, `test/utils/`, `fan/`, `fan/utils/`, `fan/internal/`]
		depends = ["sys 1.0"]
		javaDirs = [`java/`]
		resDirs = [`doc/`, `res/jacob-1.17-M2/`]

		docApi = true
		docSrc = true
	}
}

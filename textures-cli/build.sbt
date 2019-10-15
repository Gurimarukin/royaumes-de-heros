name := "textures-cli"
version := "1.0"

scalaVersion := "2.12.10"

scalaSource in Compile := baseDirectory.value / "src"
scalaSource in Test := baseDirectory.value / "test"

// mainClass in (Compile, run) := Some("texturescli.Main")

libraryDependencies ++= Seq(
  "com.sksamuel.scrimage" %% "scrimage-core" % "2.1.8",
  "org.scalatest" %% "scalatest" % "3.0.8" % Test
)

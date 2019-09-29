package texturescli

import java.io.File

import scala.util.Try

import com.sksamuel.scrimage.Image
import scala.util.Random

object Main extends App {

  makeTexture match {
    case Left(error) =>
      println(s"Error: $error")
      println()
      println("usage: run <folder from> <file to> <width> <height>")

    case Right(_) => println("Finished!")
  }

  def makeTexture: Either[String, Unit] =
    if (args.length == 4) {

      (Try(args(2).toInt).toEither, Try(args(3).toInt).toEither) match {
        case (Right(width), Right(height)) => makeTexture(args(0), args(1), width, height)
        case _                             => Left("width and height must be integers")
      }

    } else
      Left("2 arguments required")

  def makeTexture(from: String, to: String, width: Int, height: Int): Either[String, Unit] = {
    val d = new File(from)

    if (d.exists && d.isDirectory)
      for {
        image <- joinFiles(
          d.listFiles
            .filter((f: File) => f.isFile && f.getName.endsWith(".png"))
            .toSeq,
          width,
          height
        )
        _ <- outputFile(image, to)
      } yield ()
    else
      Left("directory not found: $from")
  }

  def joinFiles(files: Seq[File], width: Int, height: Int): Either[String, Image] = {
    val images = files.map(Image.fromFile).toList

    images match {
      case Nil => Left("no image found")

      case head :: tail =>
        val (w, h) = head.dimensions

        if (tail.forall(_.dimensions == head.dimensions)) {
          val initImg = Image(width * w, height * h).blank

          val res = Range(0, width).map(_ * w).foldLeft(initImg) { (acc, x) =>
            Range(0, height).map(_ * h).foldLeft(acc) { (acc, y) =>
              acc.overlay(randomElt(images), x, y)
            }
          }

          Right(res)
        } else Left("images must have the same dimensions")
    }
  }

  def randomElt[A](elts: Seq[A]): A = elts(Random.nextInt(elts.length))

  def outputFile(image: Image, to: String): Either[String, Unit] =
    Try(image.output(new File(to))).toEither match {
      case Left(e)  => Left(e.getMessage)
      case Right(_) => Right(())
    }

}

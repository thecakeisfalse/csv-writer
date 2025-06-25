import os
import sequtils, strutils, strformat
import random
import math

randomize()

type
  Person* = ref object of RootObj
    firstName*: string
    lastName*: string
    birthDate*: int64

  Director* = ref object of Person

  Teacher* = ref object of Person
    classNums*: seq[string]

  Student* = ref object of Person
    classNum*: string

  School* = ref object of RootObj
    director*: Director
    teachers*: seq[Teacher]
    students*: seq[Student]

proc getData(fileName: string): seq[string] =
  let file = open(fileName)
  result = file.readAll.splitLines.filterIt(it != "")
  file.close()

let
  maleNames = getData(getAppDir() / "src" / "male_names.txt")
  femaleNames = getData(getAppDir() / "src" / "female_names.txt")
  lastNames = getData(getAppDir() / "src" / "last_names.txt")
  classNumbers = @["1A", "1B", "2A", "2B", "3A", "3B", "4A", "4B", "5A", "5B"]
  firstNames = maleNames & femaleNames

proc genRandDate(
    d: HSlice = 1..28,
    m: HSlice = 1..12,
    y: HSlice = 1970..2000
  ): string =
  fmt"{rand(d):02}.{rand(m):02}.{rand(y)}"

proc genCSV(
    header: string = "",
    rows: seq[seq[string]] = @[@[""]],
    csvFileName: string = "default.csv"
  ) =
  let dir = splitFile(csvFileName).dir
  if not dirExists(dir):
    createDir(dir)

  let file = open(csvFileName, fmWrite)
  defer: file.close()

  if header != "":
    file.writeLine(header)

  rows.filterIt(it.len != 0)
    .apply(proc(it: seq[string]) = file.writeLine(it.join(",")))

proc genDirector(csvFileName: string) =
  let header = "firstName,lastName,birthDate"
  let firstName = sample(firstNames)
  let lastName = sample(lastNames)
  let birthDate = genRandDate(y = 1960..1980)

  genCSV(header, @[@[firstName, lastName, birthDate]], csvFileName)

proc genTeachers(csvFileName: string, rowsCount: int) =
  var rows: seq[seq[string]]
  let header = "firstName,lastName,birthDate,classNums"

  for i in 1..rowsCount:
    let firstName = sample(firstNames)
    let lastName = sample(lastNames)
    let birthDate = genRandDate(y = 1980..1995)
    let classes = toSeq(1..rand(1..5))
      .mapIt(sample(classNumbers))
      .deduplicate()
      .join(";")

    rows.add(@[firstName, lastName, birthDate, classes])

  genCSV(header, rows, csvFileName)

proc genStudents(csvFileName: string, rowsCount: int) =
  var rows: seq[seq[string]]
  let header = "firstName,lastName,birthDate,classNum"

  for i in 1..rowsCount:
    let firstName = sample(firstNames)
    let lastName = sample(lastNames)
    let birthDate = genRandDate(y = 2010..2018)
    let classNum = sample(classNumbers)

    rows.add(@[firstName, lastName, birthDate, classNum])

  genCSV(header, rows, csvFileName)

when isMainModule:
  var rowsCount = 0
  if paramCount() > 0:
    rowsCount = paramStr(1).parseInt
  else:
    stderr.writeLine("Nothing to write. Quit")
    quit()

  genDirector(
    getAppDir() / "data" / "school_director.csv"
  )

  genTeachers(
    getAppDir() / "data" / "school_teachers.csv",
    rowsCount
  )

  genStudents(
    getAppDir() / "data" / "school_students.csv",
    rowsCount * 20
  )


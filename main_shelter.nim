import os
import sequtils, strutils, strformat
import random
import math

randomize()

type
  Post* = enum
    NONE, Уборщик, Ветеринар, Менеджер, Директор

  Person* = ref object of RootObj
    name*: string
    birthDate*: int64

  Staff* = ref object of Person
    uid*: int
    post*: Post

  Pet* = ref object of RootObj
    name*: string
    age*: int

  Manager* = ref object of Person

  Shelter* = ref object of RootObj
    staff*: seq[Staff]
    pets*: seq[Pet]
    managers*: seq[Manager]

proc getData(fileName: string): seq[string] =
  let file = open(fileName)
  result = file.readAll.splitLines.filterIt(it != "")
  file.close()

let
  petNames = getData(getAppDir() / "src" / "pet_names.txt")
  maleNames = getData(getAppDir() / "src" / "male_names.txt")
  femaleNames = getData(getAppDir() / "src" / "female_names.txt")
  lastNames = getData(getAppDir() / "src" / "last_names.txt")
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

proc genStaff(csvFileName: string, rowsCount: int) =
  var rows: seq[seq[string]]
  let header = "name,birthDate,uid,post"

  for i in 1..rowsCount:
    let firstName = sample(firstNames)
    let lastName = sample(lastNames)
    let name = firstName & " " & lastName
    let birthDate = genRandDate()
    let uid = rand(1000..9999)
    let post = sample([Уборщик, Ветеринар, Менеджер,
        Директор])

    rows.add(@[name, birthDate, $uid, $post])

  genCSV(header, rows, csvFileName)

proc genPets(csvFileName: string, rowsCount: int) =
  var rows: seq[seq[string]]
  let header = "name,age"

  for i in 1..rowsCount:
    let name = sample(petNames)
    let age = rand(1..20)

    rows.add(@[name, $age])

  genCSV(header, rows, csvFileName)

proc genManagers(csvFileName: string, rowsCount: int) =
  var rows: seq[seq[string]]
  let header = "name,birthDate"

  for i in 1..rowsCount:
    let firstName = sample(firstNames)
    let lastName = sample(lastNames)
    let name = firstName & " " & lastName
    let birthDate = genRandDate()

    rows.add(@[name, birthDate])

  genCSV(header, rows, csvFileName)

when isMainModule:
  var rowsCount = 0
  if paramCount() > 0:
    rowsCount = paramStr(1).parseInt
  else:
    stderr.writeLine("Nothing to write. Quit")
    quit()

  genStaff(
    getAppDir() / "data" / "shelter_staff.csv",
    rowsCount
  )

  genPets(
    getAppDir() / "data" / "shelter_pets.csv",
    rowsCount * 10
  )

  genManagers(
    getAppDir() / "data" / "shelter_managers.csv",
    rowsCount div 5
  )


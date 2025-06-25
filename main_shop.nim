import os # папки, файлы, аргументы командной строки
import sequtils, strutils, strformat # работа со строками
import random # для генерации случайных чисел
import math

randomize() # Для рандомизации генератора

type
  Post* = enum
    NONE, Кассир, Уборщик, Консультант,
      Менеджер, Директор

  Staff* = ref object of RootObj
    firstName*: string
    lastName*: string
    birthDate*: int64
    post*: Post

  Good* = ref object of RootObj
    title*: string
    price*: float
    endDate*: int64
    discount*: float
    count*: int

  Cash* = ref object of RootObj
    number*: int
    free*: bool
    totalCash*: float

  Shop* = ref object of RootObj
    staff*: seq[Staff]
    goods*: seq[Good]
    cashes*: seq[Cash]

proc getData(fileName: string): seq[string] =
  ## Получает все не пустные строки из файла
  let file = open(fileName)
  result = file.readAll.splitLines.filterIt(it != "")
  file.close()

let
  petNames = getData(getAppDir() / "src" / "pet_names.txt")
  maleNames = getData(getAppDir() / "src" / "male_names.txt")
  femaleNames = getData(getAppDir() / "src" / "female_names.txt")
  lastNames = getData(getAppDir() / "src" / "last_names.txt")
  goodTitles = getData(getAppDir() / "src" / "good_titles.txt")
  firstNames = maleNames & femaleNames

proc genRandDate(
    d: HSlice = 1..28,
    m: HSlice = 1..12,
    y: HSlice = 1970..2000
  ): string =
  ## Возвращает строку даты на основе переданного диапазона значений
  ## По умолчанию, день: от 1 до 28
  ## месяц: от 1 до 12
  ## год: с 1970 по 2000
  ## Учтите, что для срока годности как минимум год должен быть другим.
  fmt"{rand(d):02}.{rand(m):02}.{rand(y)}"

proc genCSV(
    header: string = "",
    rows: seq[seq[string]] = @[@[""]],
    csvFileName: string = "default.csv"
  ) =
  ## Вносит заголовок и строки в csvFileName
  ## если значения не переданы, то должны использоваться значения по умолчанию

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
  ## Функция генерации сотрудников
  ##
  ## Для формирования CSV-заголовка используйте наименования атрибутов объекта Staff
  ## Для записи данных рекомендуется реализовать функцию genCSV и использовать
  ## её во всех трех генераторах

  var rows: seq[seq[string]]
  let header = "firstName,lastName,birthDate,post"

  for i in 1..rowsCount:
    let firstName = sample(firstNames)
    let lastName = sample(lastNames)
    let birthDate = genRandDate()
    let post = sample([Кассир, Уборщик, Консультант,
        Менеджер, Директор])

    rows.add(@[firstName, lastName, birthDate, $post])

  genCSV(header, rows, csvFileName)

proc genGoods(csvFileName: string, rowsCount: int) =
  ## Функция генерации товаров
  ##
  ## Для формирования CSV-заголовка используйте наименования атрибутов объекта Good
  ## Для записи данных рекомендуется реализовать функцию genCSV и использовать
  ## её во всех трех генераторах

  var rows: seq[seq[string]]
  let header = "title,price,endDate,discount,count"

  for i in 1..rowsCount:
    let title = sample(goodTitles)
    let price = round(rand(10.0..1000.0), 2)
    let endDate = genRandDate(y = 2025..2030)
    let discount = round(rand(0.0..0.5), 2)
    let count = rand(1..100)

    rows.add(@[title, $price, endDate, $discount, $count])

  genCSV(header, rows, csvFileName)


proc genCashes(csvFileName: string, rowsCount: int) =
  ## Функция генерации касс
  ##
  ## Для формирования CSV-заголовка используйте наименования атрибутов объекта Cash
  ## Для записи данных рекомендуется реализовать функцию genCSV и использовать
  ## её во всех трех генераторах

  var rows: seq[seq[string]]
  let header = "number,free,totalCash"

  for i in 1..rowsCount:
    let number = i
    let free = sample([true, false])
    let totalCash = round(rand(0.0..10000.0), 2)

    rows.add(@[$number, $free, $totalCash])

  genCSV(header, rows, csvFileName)


when isMainModule:
  var rowsCount = 0 # Сколько строк писать
  if paramCount() > 0: # Если передан аргумент командной строки
    rowsCount = paramStr(1).parseInt # Присваиваем новое значение
  else:
    stderr.writeLine("Nothing to write. Quit") # Ошибка
    quit() # Завершаем работу
  genStaff( # Генерируем сотрудников
    getAppDir() / "data" / "shop_staff.csv",
    rowsCount
  )
  genGoods( # Генерируем товары
    getAppDir() / "data" / "shop_goods.csv",
    rowsCount * 10 # в 10 раз больше
  )
  genCashes( # Генерируем кассы
    getAppDir() / "data" / "shop_cashes.csv",
    rowsCount div 10 # в 10 раз меньше
  )


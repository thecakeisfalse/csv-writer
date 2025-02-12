import os  # папки, файлы, аргументы командной строки
import sequtils, strutils, strformat  # работа со строками
import random  # для генерации случайных чисел

randomize()  # Для рандомизации генератора

type
  Post = enum  # Возьмите вашу заготовку из задачи types_2
    NONE,      # Либо подключите её сюда напрямую, используя import

proc getData(fileName: string): seq[string] =
  ## Получает все не пустные строки из файла
  let file = open(fileName)
  result = file.readAll.splitLines.filterIt(it != "")
  file.close()

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

proc genStaff(csvFileName: string, rowsCount: int) =
  ## Функция генерации сотрудников
  ## 
  ## Для формирования CSV-заголовка используйте наименования атрибутов объекта Staff
  ## Для записи данных рекомендуется реализовать функцию genCSV и использовать
  ## её во всех трех генераторах

proc genGoods(csvFileName: string, rowsCount: int) =
  ## Функция генерации товаров
  ## 
  ## Для формирования CSV-заголовка используйте наименования атрибутов объекта Good
  ## Для записи данных рекомендуется реализовать функцию genCSV и использовать
  ## её во всех трех генераторах

proc genCashes(csvFileName: string, rowsCount: int) =
  ## Функция генерации касс
  ## 
  ## Для формирования CSV-заголовка используйте наименования атрибутов объекта Cash
  ## Для записи данных рекомендуется реализовать функцию genCSV и использовать
  ## её во всех трех генераторах

when isMainModule:
  var rowsCount = 0  # Сколько строк писать
  if paramCount() > 0:  # Если передан аргумент командной строки
    rowsCount = paramStr(1).parseInt  # Присваиваем новое значение
  else:
    stderr.writeLine("Nothing to write. Quit")  # Ошибка
    quit()  # Завершаем работу
  genStaff(  # Генерируем сотрудников
    getAppDir() / "data" / "shop_staff.csv",
    rowsCount
  )
  genGoods(  # Генерируем товары
    getAppDir() / "data" / "shop_goods.csv",
    rowsCount * 10  # в 10 раз больше
  )
  genCashes(  # Генерируем кассы
    getAppDir() / "data" / "shop_cashes.csv",
    rowsCount div 10  # в 10 раз меньше
  )
           
# import db_postgres
import streams
import strutils

var strm = newFileStream("./sqls/account.sql", fmRead)
var line = ""
var lines = ""
if not isNil(strm):
  while strm.readLine(line):
    lines &= line
    if line.endsWith(";"):
      echo lines
      lines = ""
  strm.close()



# let db = open("localhost", "user", "password", "dbname")
# db.close()
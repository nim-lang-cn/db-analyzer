import os, streams
import json #, xmlParser, yaml
import types


proc parseConfigXml(filename: string)
proc parseConfigJson(filename: string): Analysis
proc parseConfigYaml(filename: string)


proc parseConfigureFile(filename: string): Analysis = 
  let (_, _, ext) = splitFile(filename)
  case ext: 
  of ".xml":
    parseConfigXml(filename)
  of ".json":
    result = parseConfigJson(filename)
  of ".yaml":
    parseConfigYaml(filename)

proc parseConfigXml(filename: string) = 
  discard
  
proc parseConfigJson(filename: string): Analysis = 
  let s = open(filename, fmRead)
  let jsonNode = parseJson(s.readAll)
  let node = jsonNode["analysis"]
  let rootDir = node["rootDir"]
  let quality = node["quality"]
  let schemas = node["schemas"]["schema"]
  let table = node["tables"]["table"]
  let index = node["indexes"]["index"]
  let actions = node["actions"]
  let name = actions["@name"]
  let action = actions["action"]


  var analysis = new Analysis
  var 
    schema: seq[Schema] = @[]
    idx: seq[Index] = @[]
  analysis.rootDir = rootDir.getStr
  analysis.quality = quality.getStr
  for s in index.getElems:
    idx.add(s.getStr)
  # 待修复
  if idx.len != 0:
    analysis.indexes = idx 
  else:
    analysis.indexes = @[index.getStr]

  for s in schemas.getElems:
    schema.add(s.getStr)
  analysis.schemas = schema
  analysis.tables = initTable(table["@count"].getStr, 
                              table["@name"].getStr, 
                              table["@description"].getStr,  
                              table["query"].getStr)

  var way_seq: seq[Way] = @[]
  for w in action.getElems:
    way_seq.add(initWay(w["@name"].getStr, 
                w["@description"].getStr, w["query"].getStr))

  analysis.actions = initAction(name.getStr, way_seq)
  s.close()
  return analysis

proc parseConfigYaml(filename: string) =
  discard

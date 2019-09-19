import os, streams
import json, parseXml


import types

proc parseConfigXml(filename: string): Analysis 
proc parseConfigJson(filename: string): Analysis
proc parseConfigYaml(filename: string)


let filename = "test.xml"
var s = newFileStream(filename, fmRead)
if s == nil: quit("cannot open the file " & filename)


proc parseAction(xd: var XmlParser): Way = 
  var 
    name: string
    description: string
    query: string
  # name
  xd.next
  if xd.attrkey == "name":
    name =  xd.attrValue
    # description
    xd.next
  if xd.attrkey == "description":
    description = xd.attrValue
  # >
    xd.next
  # query
    xd.next
  # data
  if xd.elementName == "query":
    xd.next
    query = xd.charData
  # query end
    xd.next
  # action end
  xd.next
  # next action
  xd.next
  result = initWay(name=name, description=description, query=query)

proc parseSchema(xd: var XmlParser): Schema = 
  # data
  xd.next
  result = xd.charData
  # schema end
  xd.next
  # next schema
  xd.next
  
proc parseTable(xd: var XmlParser): Table = 
  var 
    count: string
    name: string
    description: string
    query: string

    
  xd.next
  if xd.attrKey == "count":
    count = xd.attrValue
    xd.next
  if xd.attrKey == "name":
    name = xd.attrValue
    xd.next
  if xd.attrKey == "description":
    description = xd.attrValue
    xd.next
    xd.next
  
  if xd.kind == xmlElementStart and xd.elementName == "query":
    xd.next
    query = xd.charData
    # query end
    xd.next
    # table end
    xd.next
  xd.next
  return initTable(count, name, description, query)

proc parseIndex(xd: var XmlParser): Index = 
  # data
  xd.next
  result = xd.charData
  # index end
  xd.next
  # next index
  xd.next

proc parseConfigureFile(filename: string): Analysis = 
  let (_, _, ext) = splitFile(filename)
  case ext: 
  of ".xml":
    result = parseConfigXml(filename)
  of ".json":
    result = parseConfigJson(filename)
  of ".yaml":
    parseConfigYaml(filename)

proc parseConfigXml(filename: string): Analysis = 
  var 
    xmlNode: XmlParser
    analysis = new Analysis

  open(xmlNode, s, filename)

  while true: 
    case xmlNode.kind
    of xmlElementStart: 
      case xmlNode.elementName:
      of "rootDir":
        # get rootDir no attr
        xmlNode.next
        analysis.rootDir = xmlNode.charData
      of "quality":
        # get quality no attr
        xmlNode.next
        analysis.quality = xmlNode.charData
      of "schemas":
        var schema: seq[string] = @[]
        # schema
        xmlNode.next
        while xmlNode.elementName == "schema":
          schema.add(xmlNode.parseSchema)
        analysis.schemas = schema
  
      of "indexes":
        var idx: seq[string] = @[]
        # index
        xmlNode.next
        while xmlNode.elementName == "index":
          idx.add(xmlNode.parseIndex)
        analysis.indexes = idx
      
      xmlNode.next
    of xmlElementOpen:
      while xmlNode.elementName == "table":
        analysis.tables = parseTable(xmlNode)


      if xmlNode.elementName == "actions":
        var 
          name: string
          actionSeq: seq[Way] 
        # actions attr
        xmlNode.next
        name = xmlNode.attrValue
        # >
        xmlNode.next
        # action <
        xmlNode.next
        while xmlNode.elementName == "action":
          actionSeq.add(xmlNode.parseAction)
        analysis.actions = initAction(name=name, actions=actionSeq)
          
      xmlNode.next
    of xmlElementEnd:
      xmlNode.next
    of xmlPI: 
      xmlNode.next
    of xmlEOf: 
      break
    of xmlError:
      echo xmlNode.errorMsg
      xmlNode.next
    else:
      xmlNode.next
  result = analysis


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


when isMainModule:
  # define analysis
  let a1 = parseConfigXml(filename="test.xml")
  let a2 = parseConfigJson(filename="test.json")


  echo a1.rootDir == a2.rootDir
  echo a1.quality == a2.quality
  echo a1.schemas == a2.schemas
  # echo "a1: ", a1.schemas, "\na2: ", a2.schemas
  echo "a1: ", a1.actions
  echo "a2: ", a2.actions
  echo "a1: ", a1.tables, "\na2: ", a2.tables

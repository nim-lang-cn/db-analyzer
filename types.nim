import strformat

type  
  Schema* = string
  Index* = string
  RootDir* = string
  Quality* = string
  Table* = ref object
    count: string         # 数量
    name: string          # 用户
    description: string   # 事件描述
    query: string         # 请求
  Way* = ref object
    name: string          # 用户
    description: string   # 事件描述
    query: string         # 请求
  Action* = ref object
    name: string          # 用户名
    actions: seq[Way]     # 执行的操作
  Analysis* = ref object  # 各节点内容
    rootDir*: RootDir     # 生成的 csv 文件和散点图片所保存的目录
    quality*: Quality     # 每个查询语句执行次数，比如查询 1000 次
    schemas*: seq[Schema] # 表的 Schema 定义文件，里面定义了 CREATE TABLE 脚本，用来创建表
    tables*: Table        # INSERT SQL 语句组，用于 “批量插入大量数据”。提供 count 指示插入多少行
    indexes*: seq[Index]       # INDEX SQL 语句组，用于 “批量创建索引”
    actions*: Action      # SQL 语句组，用于 “运行查询语句（EXPLAIN）”

proc initTable*(count: string, name: string, 
          description: string, query: string): Table = 
  Table(count: count, name: name, description: description,query: query)

proc initWay*(name: string, description: string, query: string): Way =
  Way(name: name, description:description, query: query)

proc initAction*(name: string, actions: seq[Way]): Action =
  Action(name: name, actions: actions)

proc `$`*(x: Table): string = 
  fmt"Table({x.count}, {x.name}, {x.description}, {x.query})"

proc `$`*(x: Way): string =
  fmt"Way({x.name}, {x.description}, {x.query})"

proc `$`*(x: Action): string = 
  fmt"Analysis({x.name}, {x.actions})"

proc `$`*(x: Analysis): string =
  fmt"Action({x.rootDir}, {x.quality}, {x.schemas}, {x.tables}, {x.indexes}, {x.actions})"

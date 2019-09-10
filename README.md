DB Analyzer
============

DBAnalyzer 帮助自动化数据库的基准测试过程，生成具有表现力的日志和图表。

过程
----

1. 提供一个 XML 配置文件（或者支持多行 SQL 文本的文件），配置数据表的定义和分析语句

2. 运行程序，执行分析过程：

   - 连接到数据库，运行 schemas 脚本
   - 执行 inserts 批量插入数据
   - 执行 actions 查询（没有索引）（使用 `EXPLAIN` 查询）
   - 执行 indexes 批量创建索引
   - 执行 actions 查询（有索引）（使用 `EXPLAIN` 查询）
   - 将返回结果保存成 csv 文件（格式：x,y - x 表示次数，y 表示查询时间） 

   具体过程如下：

    ```md
    Starting analysis, quality 1000 ...
    (schema) sqls/account.sql
    (schema) sqls/qa.sql
    (table)  users 10000 ...
             inserted rows 1000, cost 375ms 
             inserted rows 2000, cost 592ms
             inserted rows 3000, cost 874ms
             inserted rows 4000, cost 1457ms
             inserted rows 5000, cost 1698ms
             inserted rows 6000, cost 1923ms
             inserted rows 7000, cost 2216ms
             inserted rows 8000, cost 2840ms
             inserted rows 9000, cost 3077ms
             inserted rows 10000, cost 3305ms 
    (action) account.username.username-1 <non-index> ...
    (action) account.username.username-1-limit <non-index> ...
    (action) account.username.username-10000 <non-index> ...
    (action) account.username.username-10000-limit <non-index> ...
    (index)  CREATE UNIQUE INDEX index_users_on_username on account.users (username)
    (action) account.username.username-1 <index> ...
    (action) account.username.username-1-limit <index> ...
    (action) account.username.username-10000 <index> ...
    (action) account.username.username-10000-limit <index> ...
    Completed analysis.
    ```

3. 运行程序，执行成像过程

   > 读取 2 生成的 csv 文件，生成 png 图片

以下是伪代码：

```nim
parseXMLFile()

prepareSchemas()
prepareTables()
analyze(false)
prepareIndexes()
analyze(true)

execChartPlotter()
```

XML 配置
---------

- schemas 数据表的 Schema 定义文件，里面定义了 `CREATE TABLE` 脚本
- inserts 插入数据表的一组 SQL 语句，并且提供 count 指示插入多少航
- indexes 创建数据表索引的一组 SQL 语句
- actions 用于分析的一组查询 SQL 语句，比如 `EXPLAIN ANALYZE SELECT * FROM users WHERE username = 'username100'`

以下是一个例子：

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>

<analysis>
  <rootDir>analyzes</rootDir>
  <quality>1000</quality>

  <schemas>
    <schema>sqls/account.sql</schema>
    <schema>sqls/qa.sql</schema>
  </schemas>

  <tables>
    <table count="100000" name="users" description="insert into users">
      <query>
        INSERT INTO users (
          username, 
          password, 
          phone
        ) VALUES ( 
          concat('username', {i}),
          concat('password', {i}),
          concat('phone', {i})
        )
      </query>
    </table>
  </tables>

  <indexes>
    <index>
      CREATE UNIQUE INDEX index_users_on_username on account.users (username)
    </index>
  </indexes>

  <task name="username">
    <action name="username-1" description="Analyze username 1">
      <query>
        SELECT * FROM account.users WHERE username = 'username_1'
      </query>
    </action>

    <action name="username-1-limit" description="Analyze username 1 limit 1">
      <query>
        SELECT * FROM account.users WHERE username = 'username_1' LIMIT 1
      </query>
    </action>

    <action name="username-10000" description="Analyze username 10000">
      <query>
        SELECT * FROM account.users WHERE username = 'username_10000'
      </query>
    </action>

    <action name="username-10000-limit" description="Analyze username 10000 limit 1">
      <query>
        SELECT * FROM account.users WHERE username = 'username_10000' LIMIT 1
      </query>
    </action>
  </task>
</analysis>
```

分析结果
-------

actions 由一组查询语句组成。比如 `EXPLAIN SELECT * FROM account.users WHERE username = 'username_10000' LIMIT 1`，每一条语句运行 1000 次（支持 XML 配置更佳）。1 到 1000 表示次数 x，返回查询时间 y。将这 1000 条结果保存成 csv 文件，例如：

```csv
x,y
1,9.135
2,8.944
3,8.922
4,8.937
5,10.58
6,9.72
7,11.731
8,9.119
9,8.946
10,9.012
11,8.946
12,8.96
13,8.943
14,8.93
15,8.95
```

图表
----

使用一个图表软件包，把 csv 文件读取出来，然后转换成一个图片。如果可以的话，把所有的 csv 数据合并打印到一张图上。

![](https://github.com/nim-lang-cn/db-analyzer/blob/master/aggregate.svg)

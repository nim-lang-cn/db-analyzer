DB Analyzer
============

DBAnalyzer 能够帮助你自动化数据库的基准测试过程，生成具有表现力的日志和图表。DBAnalyzer 的目标是成为一个灵活配置的、支持多种文件格式的、插件化的自动化测试工具。

```md
+---------------------+
|      Configure      |
+---------------------+
           |
           V
+---------------------+
|    Exec Analisis    |
+---------------------+
           |
           V
+---------------------+
| Output Chart Images |
+---------------------+
```

**Status：version 0.1.0 is developing ...**

## README.md 说明

当前处于开发初期，为了便于新成员的参与，README 描述项目的设定和一些约定。当项目进入成熟阶段，README 的内容移动到一个专用的文档。

以下内容详细描述了本项目的主要设定和约定。

## 1. 执行过程

程序的执行过程主要由 3 步组成：读取配置、执行分析、执行成像。以下内容描述了程序的具体执行过程：

1. 读取一个配置文件，提取数据表的定义和要分析的查询语句

   > 关于配置文件的说明，参看下面

2. 运行程序，执行分析过程：

   - 连接到数据库，运行 schemas 脚本，创建数据库表
   - 执行 inserts 批量插入大量数据，提供一个可测试的数据环境
   - 执行 actions 运行查询语句（使用 `EXPLAIN` 分析查询时间）（没有索引）
   - 执行 indexes 批量创建索引，提供一个可测试的索引环境
   - 执行 actions 运行查询语句（使用 `EXPLAIN` 分析查询时间）（有索引）
   - 将返回结果保存成 csv 文件（格式：x,y -- x 表示查询次数，y 表示查询时间） 

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
    (action) users.username.username-1 <non-index> ...
    (action) users.username.username-1-limit <non-index> ...
    (action) users.username.username-10000 <non-index> ...
    (action) users.username.username-10000-limit <non-index> ...
    (index)  CREATE UNIQUE INDEX index_users_on_username on users (username)
    (action) users.username.username-1 <index> ...
    (action) users.username.username-1-limit <index> ...
    (action) users.username.username-10000 <index> ...
    (action) users.username.username-10000-limit <index> ...
    Completed analysis.
    ```

3. 运行程序，执行成像过程

   > 读取 2 生成的 csv 文件，生成 png | svg | jpg | ... 图片
   
   ![](https://github.com/nim-lang-cn/db-analyzer/blob/master/aggregate.svg)

以下是程序执行的伪代码：

```nim
parseConfigureFile()

prepareSchemas()
prepareTables()
analyze(indexed = false)
prepareIndexes()
analyze(indexed = true)

execChartPlotter()
```

以下是程序执行的图示：

```md
+-----------------------------------------------------------+
| parseConfigureFile - 读取配置文件，提取数据表定义和待分析语句    |
+-----------------------------------------------------------+
                            |
                            V
+-----------------------------------------------------------+
| prepareSchemas     - 连接到数据库，执行数据表定义的 schema 脚本 |
+-----------------------------------------------------------+
                            |
                            V
+-----------------------------------------------------------+
| prepareTables      - 批量插入大量数据，提供一个可测试的数据环境  |
+-----------------------------------------------------------+
                            |
                            V
+-----------------------------------------------------------+
| analyze            - 运行查询语句（`EXPLAIN`）（Non-Index）  |
+-----------------------------------------------------------+
                            |
                            V
+-----------------------------------------------------------+
| prepareIndexes     - 批量创建索引，提供一个可测试的索引环境      |
+-----------------------------------------------------------+
                            |
                            V
+-----------------------------------------------------------+
| analyze            - 再次运行查询语句（`EXPLAIN`）（Index）   |
+-----------------------------------------------------------+
                            |
                            V
+-----------------------------------------------------------+
| execChartPlotter   - 将以上过程产生的 csv 文件转换成散点图片    |
+-----------------------------------------------------------+
```

## 2. 配置文件

项目支持多种格式的配置文件，比如 json、yaml、xml、... XML 格式是其中的一个选项。下面以 XML 格式说明配置文件至少包含的属性：

组件|描述
---|----
`rootDir` | 生成的 csv 文件和散点图片所保存的目录
`quality` | 每个查询语句执行次数，比如查询 1000 次
`schemas` | 表的 Schema 定义文件，里面定义了 `CREATE TABLE` 脚本，用来创建表
`tables` | INSERT SQL 语句组，用于 “批量插入大量数据”。提供 `count` 指示插入多少行
`indexes` | INDEX SQL 语句组，用于 “批量创建索引”
`actions` | SQL 语句组，用于 “运行查询语句（`EXPLAIN`）” 

### 2.1. XML 配置例子

以下是一个 XML 格式的例子：

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>

<analysis>
  <rootDir>analyzes/</rootDir>
  <quality>1000</quality>

  <schemas>
    <schema>sqls/account.sql</schema>
    <schema>sqls/qa.sql</schema>
  </schemas>

  <tables>
    <table count="10000" name="users" description="insert into users">
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
      CREATE UNIQUE INDEX index_users_on_username on users (username)
    </index>
  </indexes>

  <actions name="username">
    <action name="username-1" description="Analyze username 1">
      <query>
        SELECT * FROM users WHERE username = 'username1'
      </query>
    </action>

    <action name="username-1-limit" description="Analyze username 1 limit 1">
      <query>
        SELECT * FROM users WHERE username = 'username1' LIMIT 1
      </query>
    </action>

    <action name="username-10000" description="Analyze username 10000">
      <query>
        SELECT * FROM users WHERE username = 'username10000'
      </query>
    </action>

    <action name="username-10000-limit" description="Analyze username 10000 limit 1">
      <query>
        SELECT * FROM users WHERE username = 'username10000' LIMIT 1
      </query>
    </action>
  </actions>
</analysis>
```

### 2.2. `<schemas>`

`<schemas>` 由一组 `<schema>` 组成，每个 `<schema>` 表示一个 SQL 脚本文件，可以创建一组数据库表。

以下是一个 sqls/account.sql schema 的例子（本例子使用 PostgreSQL SQL 语句，项目应该支持多种数据库）：

```sql
DROP SCHEMA IF EXISTS account CASCADE;
CREATE SCHEMA account;

CREATE TYPE  account.gender AS ENUM(
  'UNKNOWN', 'FEMALE', 'MALE'
);

CREATE TABLE account.users (
  id            serial          NOT NULL PRIMARY KEY,
  username      varchar(255)    NOT NULL,
  password      char(64)        NOT NULL,
  phone         varchar(255)    NOT NULL,
  email         varchar(255)    DEFAULT NULL,
  gender        account.gender  NOT NULL DEFAULT 'UNKNOWN',
  created_date  timestamp       NOT NULL,
  is_active     boolean         NOT NULL DEFAULT TRUE
);
```

以下是一个 sqls/qa.sql schema 的例子（本例子使用 PostgreSQL SQL 语句，项目应该支持多种数据库）：

```sql
DROP SCHEMA IF EXISTS qa CASCADE;
CREATE SCHEMA qa;

CREATE TABLE qa.tags (
  id                serial        NOT NULL PRIMARY KEY,
  name              varchar(255)  NOT NULL,
  question_count    int           NOT NULL
);

CREATE TABLE qa.questions (
  id                serial        NOT NULL PRIMARY KEY,
  title             varchar(255)  NOT NULL,
  content           text          NOT NULL DEFAULT '',
  created_user_id   int           NOT NULL, 
  created_username  varchar(255)  NOT NULL,
  created_date      timestamp     NOT NULL DEFAULT now(),
  is_closed         boolean       NOT NULL DEFAULT FALSE
);

CREATE TABLE qa.question_tags (
  question_id       int           NOT NULL,
  tag_id            int           NOT NULL, 
  PRIMARY KEY (question_id, tag_id) 
);
```

### 2.3 `<tables>`

`<tables>` 由一组 `<table>` 组成，每个 `<table>` 表示一个 INSERT SQL 语句，指定为哪一个数据表插入样本数据。

通常，（供测试的）样本数据有很多行，比如　`10000` 行。`<table>` 提供 `count` 指定循环次数。还应该提供动态参数，以使得数据更加随机。INSERT SQL 支持 `{i}` 获取当前循环次数。

### 2.4 `<indexes>`

`<indexes>` 由一组 `<index>` 组成，每个 `<index>` 表示一个 CREATE INDEX SQL 语句，指定创建的索引。

### 2.5 `<actions>`

`<actions>` 由一组 `<action>` 组成，每个 `<action>` 表示一个 SELECT SQL 语句，指定要分析的查询。程序在运行过程中，自动添加 `EXPLAIN` 分析关键字，提取查询的时间和性能信息。比如 `EXPLAIN SELECT * FROM users WHERE username = 'username10000' LIMIT 1`。

###

## 3. 分析结果

执行分析时，每一条查询语句运行多次，比如，运行 1000 次。1 到 1000 表示查询次数 `x`，返回查询时间 `y`。将这 1000 条结果保存成 csv 文件，例如：

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
...
```

## 4. 散点图片

在上面的过程会产生大量的 csv 文件（分析结果）。使用一个 chart 软件包，把 csv 文件读取出来，然后转换成一个图片。如果可以的话，把所有的 csv 数据合并打印到一张图上，成为一个区间散点图：

![](https://github.com/nim-lang-cn/db-analyzer/blob/master/aggregate.svg)

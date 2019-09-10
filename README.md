DB Analyzer
============

DBAnalyzer 帮助自动化你的数据库基准测试过程，为你生成具有表现力的日志和图表。

过程
----

1. 提供一个 XML 配置文件，配置数据表格定义和分析语句

2. 运行程序，执行分析：

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

3. 运行程序，读取 2 生成的 csv 文件，生成 png 图片

XML 配置
---------

- schemas 数据表的 Schema 定义文件，里面定义了 `CREATE TABLE` 脚本
- inserts 插入数据表的一组 SQL 语句，并且提供 count 指示插入多少航
- indexes 创建数据表索引的一组 SQL 语句
- actions 用于分析的一组查询 SQL 语句，比如 `EXPLAIN ANALYZE SELECT * FROM users WHERE username = 'username100'`

![](https://github.com/nim-lang-cn/db-analyzer/blob/master/aggregate.svg)

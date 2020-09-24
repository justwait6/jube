local DbManager = class("DbManager")

local sqlite3 = require("lsqlite3")

local _db, _vm

function DbManager:ctor()
    self:initialize()
end

function DbManager:initialize()
end

function DbManager:openDb()
   	local dbFilePath = device.writablePath..'test.db'
    local isExist = cc.FileUtils:getInstance():isFileExist(dbFilePath)

    if not _db then
        print('[SQLite] DB Open')
        _db = sqlite3.open(dbFilePath)
    end
    if isExist then
        print('[SQLite] DB File already exists')
    else
        print('[SQLite] DB File not exist, created it')
        --初始化表结构
        self:initDb()
    end
end

function DbManager:closeDb()
    if _db then
        print('[SQLite] DB Close')
    	_db:close()
        _db = nil
    end
end

function DbManager:isTableExist(tableName, callback)
    local isExist = false

    self:openDb()
    local stmt = _db:prepare([[
        SELECT count(*) FROM sqlite_master WHERE type='table' and name=$tableName;
    ]]) --前导声明
    stmt:bind_names({tableName = tableName})
    for row in stmt:nrows() do
        isExist = row and row['count(*)'] > 0
        self:closeDb()
        break
    end

    if callback then callback(isExist) end
end

function DbManager:dropTable(tableName, callback)
    self:openDb()
    local t_drop_template = [=[
        DROP TABLE $tableName;
    ]=]

    local t_drop_sql = string.gsub(t_drop_template, '$tableName', tableName)

    local ret = _db:exec(t_drop_sql)
    if ret == sqlite3.OK then
        print("[SQLite] drop table " .. tableName .. " success!")
        if callback then callback(true) end
    else
        self:showError()
        if callback then callback(false) end
    end
end

function DbManager:executeSql(sql, callback)
    self:openDb()

    local stmt = _db:prepare(sql) --前导声明
    self:showError()
    if stmt then
        local ret = stmt:step()
        if ret == sqlite3.DONE then
            if callback then callback(true) end
        else
            self:showError()
            if callback then callback(false) end
        end
    end
end

function DbManager:executeTransaction(sql, callback)
	self:openDb()

	local ret = _db:exec(sql)
	self:showError()
	if ret == sqlite3.DONE then
		if callback then callback(true) end
	else
			self:showError()
			if callback then callback(false) end
	end
end

function DbManager:showError()
    print("[SQLite] " .. _db:errmsg())
end

function DbManager:getDbVersion()
    return sqlite3.version()
end

function DbManager:initDb()
    -- Demo表DDL语句
    local t_demo_sql =
    [=[
        CREATE TABLE numbers(num1,num2,str);
        INSERT INTO numbers VALUES(1,11,"ABC");
        INSERT INTO numbers VALUES(2,22,"DEF");
        INSERT INTO numbers VALUES(3,33,"UVW");
        INSERT INTO numbers VALUES(4,44,"XYZ");
        SELECT * FROM numbers;
    ]=]

    local showrow = function(udata,cols,values,names)
        assert(udata == 't_demo_create')

        print('[SQLite] %s rows %s', udata,table.concat( values, "-"))

        return 0
    end

    _db:exec(t_demo_sql, showrow, 't_demo_create')
end

function DbManager:query(sql, sql_tag, callback)
    self:openDb()

    print("[SQLite] start query:\n" .. sql)
    local data = {}

    local showrow = function(udata,cols,values,names)
        assert(udata == sql_tag)
        table.insert(data, clone(values))
        return 0
    end

    local ret = _db:exec(sql, showrow, sql_tag)
    if ret ~= sqlite3.OK then
        self:showError()
    else
        if callback then callback(data) end
    end
end

--[[test]]
function DbManager:test()
    local width = 78
    local function line(pref, suff)  --格式化函数
        pref = pref or ''
        suff = suff or ''
        local len = width - 2 - string.len(pref) - string.len(suff)
        cclog(pref .. string.rep('_', len) .. suff)
    end

    local db, vm
    local assert_, assert = assert, function (test)
        if (not test) then
            error(db:errmsg(), 2)
        end
    end

    -- os.remove('test.db')
    db = sqlite3.open('test.db')

    line(nil, 'db:exec')
    db:exec('CREATE TABLE t(a, b)')

    line(nil, 'prepare')
    vm = db:prepare('insert into t values(?, :bork)')
    assert(vm, db:errmsg())
    assert(vm:bind_parameter_count() == 2)
    assert(vm:bind_values(2, 4) == sqlite3.OK)
    assert(vm:step() == sqlite3.DONE)
    assert(vm:reset() == sqlite3.OK)
    assert(vm:bind_names{ 'pork', bork = 'nono' } == sqlite3.OK)
    assert(vm:step() == sqlite3.DONE)
    assert(vm:reset() == sqlite3.OK)
    assert(vm:bind_names{ bork = 'sisi' } == sqlite3.OK)
    assert(vm:step() == sqlite3.DONE)
    assert(vm:reset() == sqlite3.OK)
    assert(vm:bind_names{ 1 } == sqlite3.OK)
    assert(vm:step() == sqlite3.DONE)
    assert(vm:finalize() == sqlite3.OK)

    line("select * from t", 'db:exec')

    -- assert(db:exec('select * from t', function (ud, ncols, values, names)
    --     cclog(table.unpack(values))
    --     return sqlite3.OK
    -- end) == sqlite3.OK)

    db:exec('select * from t', function (ud, ncols, values, names)
        cclog(
            table.concat(
                  { unpack(values)}
                )
        )

        return sqlite3.OK
    end)

    line("select * from t", 'db:prepare')

    vm = db:prepare('select * from t')
    assert(vm, db:errmsg())
    cclog(vm:get_unames())
    while (vm:step() == sqlite3.ROW) do
        cclog(vm:get_uvalues())
    end
    assert(vm:finalize() == sqlite3.OK)

    line('udf', 'scalar')

    local function do_query(sql)
        local r
        local vm = db:prepare(sql)
        assert(vm, db:errmsg())
        cclog('====================================')
        cclog(vm:get_unames())
        cclog('------------------------------------')
        r = vm:step()
        while (r == sqlite3.ROW) do
            cclog(vm:get_uvalues())
            r = vm:step()
        end
        assert(r == sqlite3.DONE)
        assert(vm:finalize() == sqlite3.OK)
        cclog('====================================')
    end

    local function udf1_scalar(ctx, v)
        local ud = ctx:user_data()
        ud.r = (ud.r or '') .. tostring(v)
        ctx:result_text(ud.r)
    end

    db:create_function('udf1', 1, udf1_scalar, { })
    do_query('select udf1(a) from t')


    line('udf', 'aggregate')

    local function udf2_aggregate(ctx, ...)
        local ud = ctx:get_aggregate_data()
        if (not ud) then
            ud = {}
            ctx:set_aggregate_data(ud)
        end
        ud.r = (ud.r or 0) + 2
    end

    local function udf2_aggregate_finalize(ctx, v)
        local ud = ctx:get_aggregate_data()
        ctx:result_number(ud and ud.r or 0)
    end

    db:create_aggregate('udf2', 1, udf2_aggregate, udf2_aggregate_finalize, { })
    do_query('select udf2(a) from t')

    line(nil, "db:close")

    local filePath = cc.FileUtils:getInstance():fullPathForFilename('test.db')
    cclog('path: '..filePath)

    assert(db:close() == sqlite3.OK)
end

function DbManager:test2()
    _db = sqlite3.open('test.db')
    cclog('[SQLite] db:exec')
    _db:exec('CREATE TABLE t(a, b)')

    cclog('[SQLite] prepare')
    _vm = _db:prepare('insert into t values(?, :bork)')
    assert(_vm, _db:errmsg())
    assert(_vm:bind_parameter_count() == 2)
    assert(_vm:bind_values(2, 4) == sqlite3.OK)
    assert(_vm:step() == sqlite3.DONE)
    assert(_vm:reset() == sqlite3.OK)
    assert(_vm:bind_names{ 'pork', bork = 'nono' } == sqlite3.OK)
    assert(_vm:step() == sqlite3.DONE)
    assert(_vm:reset() == sqlite3.OK)
    assert(_vm:bind_names{ bork = 'sisi' } == sqlite3.OK)
    assert(_vm:step() == sqlite3.DONE)
    assert(_vm:reset() == sqlite3.OK)
    assert(_vm:bind_names{ 1 } == sqlite3.OK)
    assert(_vm:step() == sqlite3.DONE)
    assert(_vm:finalize() == sqlite3.OK)

    cclog("[SQLite] select * from t")

    -- assert(_db:exec('select * from t', 
    --     function (ud, ncols, values, names)
    --         cclog(table.unpack(values))
    --         return sqlite3.OK
    --     end) == sqlite3.OK
    -- )

    local ret = _db:exec('select * from t', 
            function (ud, ncols, values, names)
                cclog('[SQLite] ' .. table.unpack(values))
                return sqlite3.OK
            end)

end

--[[test 3]]
function DbManager:test3()

end

--[[聚合函数]]
function DbManager:aggregate()
    assert( _db:exec "CREATE TABLE test (col1, col2)" )
    assert( _db:exec "INSERT INTO test VALUES (1, 2)" )
    assert( _db:exec "INSERT INTO test VALUES (2, 4)" )
    assert( _db:exec "INSERT INTO test VALUES (3, 6)" )
    assert( _db:exec "INSERT INTO test VALUES (4, 8)" )
    assert( _db:exec "INSERT INTO test VALUES (5, 10)" )

    do
        local square_error_sum = 0

        local function step(ctx, a, b)
          local error        = a - b
          local square_error = error * error
          square_error_sum   = square_error_sum + square_error
        end

        local function final(ctx)
          ctx:result_number( square_error_sum / ctx:aggregate_count() )
        end

        assert( _db:create_aggregate("my_stats", 2, step, final) )
    end

    for my_stats in _db:urows("SELECT my_stats(col1, col2) FROM test")
    do 
        cclog("my_stats:%d", my_stats) 
    end
end

--[[CRUD]]
function DbManager:crudTest()
   local db = sqlite3.open_memory() --开辟内存数据库

   db:exec[[ CREATE TABLE test (id INTEGER PRIMARY KEY, content) ]] --执行DDL语句

   local stmt = db:prepare[[ INSERT INTO test VALUES (:key, :value) ]] --前导声明

   stmt:bind_names({  
                        key = 1,
                        value = "Hello World"    
                   }) --参数绑定

   -- step()
   -- This is the top-level implementation of sqlite3_step().  Call
   -- sqlite3Step() to do most of the work.  If a schema error occurs,
   -- call sqlite3Reprepare() and try again.
   stmt:step()  --执行
   stmt:reset()  --重置
   stmt:bind_names({  key = 2,  value = "Hello Lua"      } ) 
   stmt:step()
   stmt:reset()
   stmt:bind_names({  key = 3,  value = "Hello Sqlite3"  })
   stmt:step()
   stmt:finalize()

   for row in db:nrows("SELECT * FROM test") do
      cclog("%d, %s", row.id, row.content)
   end 
end

--[[statement]]
function DbManager:statement()
    local db = sqlite3.open_memory()

    db:exec[[
      CREATE TABLE test (
        id        INTEGER PRIMARY KEY,
        content   VARCHAR
      );
    ]]

    local insert_stmt = assert( db:prepare("INSERT INTO test VALUES (NULL, ?)") )

    local function insert(data)  --封装一个insert函数
      insert_stmt:bind_values(data)
      insert_stmt:step()
      insert_stmt:reset()
    end

    local select_stmt = assert( db:prepare("SELECT * FROM test") )

    local function select()  --封装一个查询函数
      for row in select_stmt:nrows() do
        cclog("%d, %s",row.id, row.content)
      end
    end

    insert("Hello World")
    cclog("First:")
    select()

    insert("Hello Lua")
    cclog("Second:")
    select()

    insert("Hello Sqlite3")
    cclog("Third:")
    select()
end

--[[tracing]]
function DbManager:tracing()
    local db = sqlite3.open_memory()

    db:trace( function(ud, sql)
      cclog("[Sqlite Trace]: %s", sql)
    end )

    db:exec[=[
      CREATE TABLE test ( id INTEGER PRIMARY KEY, content VARCHAR );

      INSERT INTO test VALUES (NULL, 'Hello World');
      INSERT INTO test VALUES (NULL, 'Hello Lua');
      INSERT INTO test VALUES (NULL, 'Hello Sqlite3');
    ]=]

    for row in db:rows("SELECT * FROM test") do
      cclog(row.content)
    end
end

--[[batch sql str]]
--批处理
function DbManager:batchsql()

    local db = sqlite3.open_memory()

    local sql=[=[
          CREATE TABLE numbers(num1,num2,str);
          INSERT INTO numbers VALUES(1,11,"ABC");
          INSERT INTO numbers VALUES(2,22,"DEF");
          INSERT INTO numbers VALUES(3,33,"UVW");
          INSERT INTO numbers VALUES(4,44,"XYZ");
          SELECT * FROM numbers;
        ]=]
    local showrow = function(udata,cols,values,names)
        assert(udata=='test_udata')

        for i=1,cols do
           cclog('%s |-> %s',names[i],values[i]) 
        end

        return 0
    end
    db:exec(sql,showrow,'test_udata')
end

--[[update hook]]
--表事件监听   eg:有在一张表插入数据，则读取更新数据
function DbManager:updateHook()
    local db = sqlite3.open_memory()

    local optbl = { 
                [sqlite3.UPDATE] = "UPDATE";
                [sqlite3.INSERT] = "INSERT";
                [sqlite3.DELETE] = "DELETE"
            }

    setmetatable(optbl,
        {
            __index=function(t,n) 
                return string.format("Unknown op %d",n) 
            end
        })

    local udtbl = {0, 0, 0}

    db:update_hook( function(ud, op, dname, tname, rowid)
      cclog("Sqlite Update Hook: %s,%s,%s,%d", optbl[op], dname, tname, rowid)
    end, udtbl)

    db:exec[[
      CREATE TABLE test ( id INTEGER PRIMARY KEY, content VARCHAR );

      INSERT INTO test VALUES (NULL, 'Hello World');
      INSERT INTO test VALUES (NULL, 'Hello Lua');
      INSERT INTO test VALUES (NULL, 'Hello Sqlite3');
      UPDATE test SET content = 'Hello Again World' WHERE id = 1;
      DELETE FROM test WHERE id = 2;
    ]]

    for row in db:nrows("SELECT * FROM test") do
       cclog('%d %s', row.id, row.content)
    end
end

function DbManager.getInstance()
    if not DbManager.singleInstance then
        DbManager.singleInstance = DbManager.new()
    end
    return DbManager.singleInstance
end

return DbManager

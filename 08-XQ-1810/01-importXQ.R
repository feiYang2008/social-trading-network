library(mongolite)
# ���ű����ڽ����ݴ�MongoDB�е��롣ע�⣬���ļ�ֻ���ڵ�������һ��ץȡ�����ݡ�������ݵ���������01-update����ɵ�, 02-filter���ڽ�������޶ȵ�����

# ����xq_user_info (22 s)----
system.time({
    r.user.info <- mongo(collection = 'xq_user_info', db = 'XQ-1810', url = "mongodb://localhost:27018")$find(field = '{"_id":0}') %>% setDT
    r.user.info <- r.user.info[, .(user.id = id, screen.name = screen_name, gender = gender, province = province, city = city, verified.type = verified_type, verified = verified, verified.realname = verified_realname, verified.description = verified_description, fans.count = followers_count, follow.count = friends_count, stock.count = stocks_count, cube.count = cube_count, status.count = status_count, donate.count = donate_count, st.color = st_color, step = step, status = status, allow.all.stock = allow_all_stock, domain = domain, type = type, url = url, description = description, last.status.id = last_status_id)]

    # ���user.id�ظ�����ôȡlast.status.id��ģ������µ�
    r.user.info.1810 <- r.user.info[order(user.id, - last.status.id)][, .SD[1], keyby = .(user.id)]

    # �½� lastcrawl ����������Ϊ 1806
    r.user.info.1810[, ":="(lastcrawl = 1810)]

    setkey(r.user.info.1810, user.id)
    sv(r.user.info.1810)
})

# ����xq_user_info_weibo (0.5 s)----
system.time({
    r.user.info.weibo <- mongo(collection = 'xq_user_info_weibo', db = 'XQ-1810', url = "mongodb://localhost:27018")$find(field = '{"_id":0}') %>% setDT
    r.user.info.weibo.1810 <- r.user.info.weibo[, .(user.id = user_id, weibo.id = weibo_id)]
    r.user.info.weibo.1810[, uniqueN(user.id)] == nrow(r.user.info.weibo) # ��֤ÿ��user.idֻռһ��

    # ���� lastcrawl = 1806
    r.user.info.weibo.1810[, ":="(lastcrawl = 1810)]
    sv(r.user.info.weibo.1810)
})

# ����xq_user_follow (20 s)----
library(mongolite)
system.time({
    r.user.follow <- mongo(collection = 'xq_user_follow', db = 'XQ-1810', url = "mongodb://localhost:27018")$find(field = '{"_id":0}') %>% setDT
    # Ϊ lastcrawl �趨ֵΪ 1810
    r.user.follow <- r.user.follow[, .(user.id = user_id, follow = follow, lastcrawl = 1810)]
    # ����ͬһ�� user.id �����кܶ�page�������Ҫ��һ��user.id���������follow�ϲ�
    r.user.follow.1810 <- r.user.follow[, .(follow = list(unlist(follow)), lastcrawl = lastcrawl[1]), keyby = user.id]
    sv(r.user.follow.1810)
})

# ����xq_user_fans (20 s)----
system.time({
    r.user.fans <- mongo(collection = 'xq_user_fans', db = 'XQ-1810', url = "mongodb://localhost:27018")$find(field = '{"_id":0}') %>% setDT
    r.user.fans <- r.user.fans[, .(user.id = user_id, fans.count = count, anonymous.fans.count = anonymous_count, fans = fans)]

    # ����ͬһ�� user.id �����кܶ�page�������Ҫ��һ��user.id���������fans�ϲ�
    r.user.fans.1810 <- r.user.fans[, .(fans.count = fans.count[1], anonymous.fans.count = anonymous.fans.count[1], fans = list(unlist(fans))), keyby = user.id]

    # ����lastcrawl = 1810
    r.user.fans.1810[, lastcrawl := 1810]

    sv(r.user.fans.1810)
})

# ����xq_user_cmt ----
library(mongolite)
conn <- mongo(collection = 'xq_user_cmt', db = 'XQ-1810', url = "mongodb://localhost:27018")
iter <- conn$iterate(query = '{}', field = '{"_id":0, "statuses.id":1, "statuses.user_id":1, "statuses.title":1, "statuses.created_at":1, "statuses.commentId":1, "statuses.retweet_count":1, "statuses.reply_count":1, "statuses.retweet_status_id":1, "statuses.text":1, "statuses.source":1}')

system.time({
r.user.cmt.1810 <- data.table()
iter.count <- 0
while (!is.null(res <- iter$batch(size = 1e5))) {
    chunk <- lapply(res, `[[`, 1) %>% lapply(rbindlist, use.names = T, fill = T) %>% rbindlist(use.name = T, fill = T)
    iter.count <- iter.count + 1
    cat(iter.count, '\n')
    r.user.cmt.1810 <- rbindlist(list(r.user.cmt.1810, chunk), use.names = T, fill = T)
}
}) # 18.2 min @1e5

r.user.cmt.1810 <- r.user.cmt.1810[, .(id, user.id = user_id, title, created.at = as.POSIXct(created_at / 1000, origin = "1970-01-01", tz = "GMT"), comment.id = commentId, retweet.status.id = retweet_status_id, text, source)]

# ���� lastcrawl = 1810
r.user.cmt.1810[, ":="(lastcrawl = 1810)]

sv(r.user.cmt.1810, T) # 5.33 min

# ����xq_user_stock ----
# ���� mongodb ���������´��룬����flatten�������������� r_user_stock
# ~= 5 min
#db.getCollection('xq_user_stock').aggregate([
#{"$project":{"count":1, "isPublic":1, "stocks":1, "user_id":1}},
#{"$unwind":"$stocks"},
#{"$project":{"_id":0, "user_id":"$user_id", "count":1, "isPublic":1, "code":"$stocks.code", "comment":{"$ifNull":["$stocks.comment", ""]}, 
#"sellPrice":"$stocks.sellPrice", "buyPrice":"$stocks.buyPrice", "portfolioIds":"$stocks.portfolioIds",
#"createAt":"$stocks.createAt", "targetPercent":"$stocks.targetPercent", "isNotice":"$stocks.isNotice",
#"stockName":{"$ifNull":["$stocks.stockName",""]}, 
#"exchange":{"$ifNull":["$stocks.exchange",""]},
#"stockType":{"$ifNull":["$stocks.stockType",""]}}},
#{"$out":"r_user_stock"}
#], {"allowDiskUse":true})

# Ȼ���ٰ�flatten������ݼ� (r_user_stock) ����R
library(mongolite)
conn <- mongo(collection = 'r_user_stock', db = 'XQ-1810', url = "mongodb://localhost:27018")
iter <- conn$iterate(field = '{"_id":0}')
r.user.stock.1810 <- data.table()

system.time({
    iter.count <- 0
    while (!is.null(res <- iter$batch(size = 1e6))) {
        chunk <- rbindlist(res, use.names = T, fill = T)
        r.user.stock.1810 <- rbindlist(list(r.user.stock.1810, chunk), use.names = T, fill = T)
        iter.count <- iter.count + 1
        cat(iter.count, '\n')
    }
}) # 6min@1e6 (batch.size = 1e6 �� 1e7Ҫ�죬��Ϊ1e7��ű��ڴ�)

# ���� lastcrawl������Ϊ 1810
r.user.stock.1810[, ":="(lastcrawl = 1810)]
setnames(r.user.stock.1810, c("isPublic", "user_id"), c("is.public", "user.id"))
setkey(r.user.stock.1810, user.id)
sv(r.user.stock.1810) # 54s

# ����xq_cube_info ----
conn <- mongo(collection = 'xq_cube_info', db = 'XQ-1810', url = "mongodb://localhost:27018")
# �Ȱѳ�Ƕ��dict��������б���������
r.cube.info <- conn$find(query = '{}', field = '{"_id":0, "last_rebalancing":0, "view_rebalancing":0, "owner":0, "last_success_rebalancing":0, "sell_rebalancing":0, "performance":0}') %>% setDT()
rm(conn)
# Ȼ����һ�޳�û�õı�����ѡ����Ҫ�ı���������r.cube.info
# .........��ʡ�Լ�������Ƿ����õĴ��������У�
r.cube.info.1810 <- r.cube.info[, .(cube.type = cube_type,
    cube.symbol = symbol,
    cube.name = name,
    owner.id = owner_id,
    market = market,
    create.date = ymd(created_date_format),
    close.date = ymd(close_date),
    fans.count = follower_count,
    net.value = net_value,
    rank.percent = rank_percent,
    annual.ret = annualized_gain_rate,
    monthly.ret = monthly_gain,
    weekly.ret = weekly_gain,
    daily.ret = daily_gain,
    bb.rate = bb_rate,
    listed.flag = listed_flag,
    update.date = updated_at,
    style.name = style[[3]], style.degree = style[[4]],
    tag = tag, tid = tid, aid = aid,
    description = description)]
# Ϊcube.info����lastcrawl=1810
r.cube.info.1810[, lastcrawl := 1810]
# Ϊcube.info����key = cube_symbol
r.cube.info.1810 <- unique(r.cube.info.1810, by = "cube.symbol")
setkey(r.cube.info.1810, cube.symbol)
sv(r.cube.info.1810)

# ����xq_cube_ret ----
# ʹ��iterate/batch��ʽ���룬��ʱ��Ϊfind������1/10����
# �ⲽ�ǳ����ڴ棬��˱�������ڴ棬����mongodb service��
library(mongolite)
conn <- mongo(collection = 'xq_cube_ret', db = 'XQ-1810', url = "mongodb://localhost:27018")
system.time({
    iter <- conn$iterate(query = '{}', field = '{"_id":0, "percent":0, "time":0}')
    r.cube.ret <- data.table()
    iter.count <- 0
    while (!is.null(res <- iter$batch(size = 1e7))) {
        chunk <- rbindlist(res, use.names = T, fill = T)
        r.cube.ret <- rbindlist(list(r.cube.ret, chunk), fill = T, use.names = T)
        iter.count <- iter.count + 1
        cat(iter.count, '\n')
    }
    rm(iter, chunk, iter.count)
}) # 50 min @ size = 1e7
r.cube.ret <- unique(r.cube.ret, by = c("cube_symbol", "date"))

# ��cube.ret���к��ڴ������������͡�set key��sv��
# ���� lastcrawl = 1810
r.cube.ret[, ":="(date = fast_strptime(date, "%Y-%m-%d", lt = F) %>% as.Date(), lastcrawl = 1810)]
setnames(r.cube.ret, names(r.cube.ret), str_replace(names(r.cube.ret), "_", "."))
setkey(r.cube.ret, cube.symbol, date)
r.cube.ret.1810 <- r.cube.ret
sv(r.cube.ret.1810) # 6.6 min

# ����xq_cube_rb ----
# ʹ��MRO 3.4.4���������⣬ʹ��MRO 3.5.0��û����
# ������mongodb���������³��򣬰����е�null field���޳���recursively��
# ~= 1 h
#const remove = (data) => {
#for (let key in data) {
#const val = data[key];
#if (val == null) {
#delete data[key];
#} else if (Array.isArray(val)) {
#val.forEach((v) => {
#remove(v);
#});
#}
#}
#return data;
#}

#db.getCollection('xq_cube_rb').find({}).forEach((data) => {
#data = remove(data);
#db.xq_cube_rb.save(data);
#})

system.time({
    library(mongolite)
    conn <- mongo(collection = 'xq_cube_rb', db = 'XQ-1810', url = "mongodb://localhost:27018")
    # cube.rb һ��������id���ֱ�Ϊ��id����top level���� ��id������ rebalancing_histories�ڵ��У�����rebalancing_id����Ҳ�� rebalancing_histories �ڵ��У������У�top level �� id �� reblancing_id ��һ���ġ����������ڵ���ʱѡ�� "id":0
    iter <- conn$iterate(field = '{"_id":0, "id":0, "holdings":0, "error_message":0, "error_status":0, "created_at":0, "updated_at":0, "prev_bebalancing_id":0, "new_buy_count":0, "diff":0, "exe_strategy":0, "rebalancing_histories.stock_label":0, "rebalancing_histories.created_at":0}')

    r.cube.rb.1810 <- data.table()
    while (!is.null(res <- iter$batch(size = 1e5))) {
        # res.nested ֻ������չ�������reblancing_histories�ڵ�
        res.nested <- lapply(res, `[[`, "rebalancing_histories") %>% lapply(rbindlist, use.names = T, fill = T) %>% rbindlist(use.names = T, fill = T, idcol = "rid")
        # chunk �������� rebalancing_histories ��������з�Ƕ�׽ڵ�
        chunk <- lapply(res, function(ele) { ele[["rebalancing_histories"]] <- NULL; ele }) %>% rbindlist(use.names = T, fill = T, idcol = "rid")
        # �ϲ�����
        chunk <- res.nested[chunk, on = .(rid), nomatch = 0]
        # �� chunk ���� r.cube.rb.1810
        r.cube.rb.1810 <- rbindlist(list(r.cube.rb.1810, chunk), use.names = T, fill = T)
    }
}) # 111 min

# ���ڴ���
setnames(r.cube.rb.1810, names(r.cube.rb.1810), str_replace_all(names(r.cube.rb.1810), "_", "."))
r.cube.rb.1810 <- r.cube.rb.1810[comment == '', comment := NA]
r.cube.rb.1810[, ":="(rid = NULL, target.weight = as.numeric(target.weight), prev.weight.adjusted = as.numeric(prev.weight.adjusted))
    ][, ":="(datetime = as.POSIXct(updated.at / 1000, origin = "1970-01-01"))
    ][, ":="(updated.at = NULL)] # �� UNIX ʱ���ת��Ϊ POSIXct
setnames(r.cube.rb.1810, "datetime", "created.at")

# ��ֵ��lastcrawl=1810
r.cube.rb.1810[, ":="(lastcrawl = 1810)]

# ֻ����status = "success" �Լ� category == "user_rebalancing" �Ĺ۲�
r.cube.rb.1810 <- r.cube.rb.1810[status == 'success' & category == "user_rebalancing"] # 56255548 -> 42386431
r.cube.rb.1810[, ":="(status = NULL, category = NULL, cube.id = NULL, error.code = NULL)]

setorder(r.cube.rb.1810, cube.symbol, - lastcrawl)
sv(r.cube.rb.1810)
# ���ű����ڽ���ץȡ�����ݺϲ�����������
# �������ݼ����� new ��׺��ԭ�����ݼ� old ��׺
# ����ִ�е������ǽ�2017-09�ϲ���2017-03
# ע�⣡��������ִ�к����ɵ����ݼ���r-�������ظ��Ĺ۲⣬������ 02-filter�н���ȥ��

# �ϲ�cube.info ----
# �������¾������ļ�
ld(r.cube.info.old, T)
r.cube.info.old <- r.cube.info
ld(r.cube.info.new, T)
r.cube.info.new <- r.cube.info
# ���¾������ļ������š�ƴ�ӣ�������ÿһ�εļ�¼
r.cube.info <- rbindlist(list(r.cube.info.old, r.cube.info.new), use.names = T, fill = T) %>% unique()
# ����symbol��update.date�����Ժ�Ҫ����ʱ��ֱ��r.cube.info[, .SD[.N], keyby = .(cube.symbol)] ���ɵ������µļ�¼
setorder(r.cube.info, cube.symbol, update.date)
sv(r.cube.info)

# �ϲ�cube.ret ----
# �������¾������ļ���������Ϊ������ old ��׺
ld(r.cube.ret.new, T)
r.cube.ret.new <- r.cube.ret
rm(r.cube.ret)
ld(r.cube.ret.old, T)
r.cube.ret.old <- r.cube.ret
rm(r.cube.ret)
# ���¾������ļ������š�ƴ�ӣ�������ÿһ�εļ�¼
r.cube.ret <- rbindlist(list(r.cube.ret.old, r.cube.ret.new), use.names = T, fill = T) %>% unique() # 821047320 -> 468837556

setkey(r.cube.ret, cube.symbol, date)
sv(r.cube.ret

# �ϲ�cube.rb ----
# �������¾������ļ���������Ϊ������ old ��׺
ld(r.cube.rb.new, T)
r.cube.rb.new <- r.cube.rb
rm(r.cube.rb)
ld(r.cube.rb.old, T)
r.cube.rb.old <- r.cube.rb
rm(r.cube.rb)
# ���¾������ļ������š�ƴ�ӣ�������ÿһ�εļ�¼
r.cube.rb <- rbindlist(list(r.cube.rb.old, r.cube.rb.new), use.names = T, fill = T) %>% unique()
sv(r.cube.rb)

# �ϲ�user.fans ----
# �������¾������ļ���������Ϊ������ old ��׺
ld(r.user.fans.new, T)
r.user.fans.new <- r.user.fans
rm(r.user.fans)
ld(r.user.fans.old, T)
r.user.fans.old <- r.user.fans
rm(r.user.fans)

# ���¾������ļ������š�ƴ�ӣ�������ÿһ�εļ�¼
r.user.fans <- rbindlist(list(r.user.fans.old, r.user.fans.new), use.names = T, fill = T)
# ��lastcrawlת���datetime
r.user.fans[lastcrawl >= 1e10, ":="(last = as.POSIXct(lastcrawl / 100, origin = "1970-01-01"))]
r.user.fans[lastcrawl <= 1e10, ":="(last = as.POSIXct(lastcrawl, origin = "1970-01-01"))]
r.user.fans[, ":="(lastcrawl = last)][, last := NULL]
# ����user.id��lastcrawl���� ���Ժ�Ҫ����ʱ��ֱ��r.user.fans[, .SD[.N], keyby = .(user.id)] ���ɵ������µļ�¼
setkey(r.user.fans, user.id, lastcrawl)
sv(r.user.fans)

# �ϲ�user.follow ----
# �������¾������ļ���������Ϊ������ old ��׺
ld(r.user.follow.new, T)
r.user.follow.new <- r.user.follow[, ":="(lastcrawl = as.Date("2017-10-01"))]
rm(r.user.follow)
ld(r.user.follow.old, T)
r.user.follow.old <- r.user.follow
rm(r.user.follow)
# ���¾������ļ������š�ƴ�ӣ�������ÿһ�εļ�¼
r.user.follow <- rbindlist(list(r.user.follow.old, r.user.follow.new), use.names = T, fill = T)
# ����user.id��lastcrawl���� ���Ժ�Ҫ����ʱ��ֱ��r.user.follow[, .SD[.N], keyby = .(user.id)] ���ɵ������µļ�¼
setkey(r.user.follow, user.id, lastcrawl)
sv(r.user.follow)

# �ϲ�user.info ----
# �������¾������ļ�
ld(r.user.info.old, T)
r.user.info.old <- r.user.info[, lastcrawl := as.Date("2017-03-20")]
ld(r.user.info.new, T)
r.user.info.new <- r.user.info[, lastcrawl := as.Date("2017-10-01")]
rm(r.user.info)
# ���¾������ļ������š�ƴ�ӣ�������ÿһ�εļ�¼
r.user.info <- rbindlist(list(r.user.info.old, r.user.info.new), use.names = T, fill = T)
# ����user.id��lastcrawl�����Ժ�Ҫ����ʱ��ֱ��dt[, .SD[.N], keyby = .(user.id, lastcrawl)] ���ɵ������µļ�¼
setorder(r.user.info, user.id, lastcrawl)
sv(r.user.info)

# �ϲ�user.info.weibo ----
# �������¾������ļ�
ld(r.user.info.weibo.old, T)
r.user.info.weibo.old <- r.user.info.weibo[, lastcrawl := as.Date("2017-03-20")]
ld(r.user.info.weibo.new, T)
r.user.info.weibo.new <- r.user.info.weibo[, lastcrawl := as.Date("2017-10-01")]
rm(r.user.info.weibo)
# ���¾������ļ������š�ƴ�ӣ�������ÿһ�εļ�¼
r.user.info.weibo <- rbindlist(list(r.user.info.weibo.old, r.user.info.weibo.new), use.names = T, fill = T) %>% unique()
# ����user.id��lastcrawl�����Ժ�Ҫ����ʱ��ֱ��dt[, .SD[.N], keyby = .(user.id, lastcrawl)] ���ɵ������µļ�¼
setorder(r.user.info.weibo, user.id, lastcrawl)
sv(r.user.info.weibo)

# �ϲ�user.stock ----
# �������¾������ļ�
ld(r.user.stock.old, T)
r.user.stock.old <- r.user.stock[, lastcrawl := as.Date("2017-03-20")]
ld(r.user.stock.new, T)
r.user.stock.new <- r.user.stock[, lastcrawl := as.Date("2017-10-01")]
rm(r.user.stock)
# ���¾������ļ������š�ƴ�ӣ�������ÿһ�εļ�¼
r.user.stock <- rbindlist(list(r.user.stock.old, r.user.stock.new), use.names = T, fill = T)
# ����user.id��lastcrawl�����Ժ�Ҫ����ʱ��ֱ��r.cube.stock[, .SD[.N], keyby = .(cube.symbol)] ���ɵ������µļ�¼
setorder(r.user.stock, user.id, lastcrawl)
sv(r.user.stock)
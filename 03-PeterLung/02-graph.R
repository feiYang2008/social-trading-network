# �������� edges�����ǻ�����2�飬�ֱ�Ϊ6��12����----
putLocalFile("f.user.nwk.Rdata")
putLocalFile("f.cu.Rdata")

ld(f.user.nwk)
ld(f.cu)
# ��������ʱ��edge list
system.time({
p.edges.6m <- f.user.nwk[year == 2017 & week == 1
    ][, .(source = user.id, target = nbr)
    ][!sapply(target, is.null)
    ][, .(target = unlist(target), period = "6m"), keyby = .(source)
    ][f.cu, on = .(target = cube.symbol), nomatch = 0
    ][, .(source = as.character(source), target = as.character(user.id), period)
    ] %>% unique()
}) #  2.51 / 3.57
# ��ʮ����ʱedge list
p.edges.12m <- f.user.nwk[year == 2017 & week == 30
    ][, .(source = user.id, target = nbr)
    ][!sapply(target, is.null)
    ][, .(target = unlist(target), period = "12m"), keyby = .(source)
    ][f.cu, on = .(target = cube.symbol), nomatch = 0
    ][, .(source = as.character(source), target = as.character(user.id), period)
    ] %>% unique()
# ����ȫ�����ܵ�edge list
system.time({
p.edges.all <- f.user.nwk[order(user.id, year, week)
    ][, .SD[.N], keyby = .(user.id)
    ][!sapply(nbr, is.null)
    ][, .(to = unlist(nbr), period = "all"), keyby = .(from = user.id)
    ][f.cu, on = .(to = cube.symbol), nomatch = 0
    ][, .(source = as.character(from), target = as.character(user.id), period)
    ] %>% unique()
p.edges <- rbindlist(list(p.edges.6m, p.edges.12m, p.edges.all), use.names = T)
})# / 

sv(p.edges)
rm(p.edges.12m, p.edges.6m, p.edges.all)

# ��������nodes ----
ld(f.sp.owner)
p.nodes <- p.edges[, .(id = unique(c(source, target)))
    ][, ":="(is.sp = ifelse(id %in% f.sp.owner$user.id, T, F))]
sv(p.nodes)

# ���nodes��edges ----
# ʣ�µĹ����ͽ��� Gephi �ˣ�
fwrite(p.nodes, "graph/nodes.csv")
fwrite(p.edges, "graph/edges.csv")

# ���� degree �� centrality�����ں���Ļع飨��Ȼ��ЩҲ������Gephi����ɣ����Ǵ�Gephi�е���̫�鷳�ˣ�
# �ȼ���centrality
system.time({
p.g.all <- graph_from_data_frame(p.edges[period == "all"], directed = T)
#sv(p.g.all)
cen.pr <- page.rank(p.g.all, directed = T)$vector
# cen.eigen <- eigen_centrality(p.g.all, directed = T) # eigen_centrality���������������޷�����
})

# �ټ���degree
system.time({
make_degree_tbl <- function(x, mode) {
    data.table(user.id = names(x), degree = x, degree.mode = mode)
}
degree.out <- degree(p.g.all, mode = "out")
degree.in <- degree(p.g.all, mode = "in")
degree.total <- degree(p.g.all, mode = "total")
# ��cen��degree�ϲ���һ������
degree <- rbindlist(list(
    make_degree_tbl(degree.out, "out"),
    make_degree_tbl(degree.in, "in"),
    make_degree_tbl(degree.total, "total")),
    use.names = T) %>% dcast(user.id ~ degree.mode, value.var = "degree")
p.cen <- data.table(user.id = names(cen.pr), cen= cen.pr)[degree, on = .(user.id)
    ][, .(user.id, cen, cen.scale = scale(cen), d.in = `in`, d.out = out, d.total = total)]
})

sv(p.cen)
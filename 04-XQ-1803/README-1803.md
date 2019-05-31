### 数据集 (.Rdata)

* r-prefix 前缀，不带mst，表示是1803抓取的原数据，没有与原来的数据做合并

* r-prefix前缀，带mst，是一直更新至1803的master数据集

* r-prefix中，只有 r.cube.rb 是去重过的！

* f-prefix是做过去重、清洗后的数据集。需要注意，f-prefix只对r.mst.1803做了最基本的清洗（限制条件最少），因此所有基于1803的实证研究都可以用 f-prefix。如果需要做特殊的清洗（例如存续期大于180天），则需要在实证研究自己的project中进一步清洗。

* * *

### 代码文件 (.R）
1. 01-importXQ.R
* 用于将数据从MongoDB中导入。注意，本文件只用于导入最新一次抓取的数据。与旧数据的整合是在01-update中完成的, 02-filter用于进行最低限度的清晰

2. 02-update.R
* 用于将新抓取的数据合并至旧数据中。
* 本次执行的任务是将1806合并至mst.1803
* 注意！本次任务执行后生成的数据集（r-）具有重复的观测，将会在 02-filter中进行去重

3. 03-filter.R
* 本脚本用于对 r-prefix.mst（截至1803）进行去重、清洗（例如剔除存续期小于阈值的cube），最终生成的 f-prefix 
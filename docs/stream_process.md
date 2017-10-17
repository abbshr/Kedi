Kedi 中的流处理由管道（pipeline）构成。

每个 pipeline 内部固有一个处理 **顺序**：

- source
- filter
- substitute
- store
- calculator
- probe
- destination

其中 source 和 destination 标识一个完整 pipeline 的始末，它们可以配置为多个，当有多个源和目的时，这些源或目的都被并列排列而非顺序排列，其他类型的边则按照配置的顺序依次排列。

基于 pipeline 的模型中，不同类型的边可以选择性配置，但在一个 pipeline 中至少存在一条边。
每个 pipeline 都可以赋一个不同的名字，从而允许被其他 pipeline 所引用：

```ru
#p1
pipeline :p1 do
  calc :means
end

#p2
name "p2"
from :pipeline, :name => "p1"
...

#p3
pipeline :p3 do
  from :mysql
  ...
  to :pipeline, :name => "p1"
end
```

如上所示的 pipeline 组合，我们可以借此将一个很长的流处理任务拆分成不同的子 pipeline，通过依赖引用完成他们之间的关联。

# example
以异常报警系统为例，我们可以用 Kedi DSL 描述一个报警监控场景：

我们开发的 Web 应用原型目前部署在一个性能比较差的机器上，但何时需要扩容及升级，且升级到什么程度我们尚不清楚，因此我们希望得知这个应用的接口访问频率、API 调用耗时、I/O 速度、CPU 利用率、内存消耗等等。此外，对于这个第一版的应用，我们还不知道在高负载情况下有哪些隐藏的 bug，但是我们的开发人员需要及时的知道它们。

这个 web 应用产生的用户访问数据和错误都被实时记录在 Elasticsearch 的 indices 里，我们可以从这里开始编写我们的处理内容，从而让这些数据自己说话，及时告诉我们系统的瓶颈，崩溃信息等等（当然这些只是 Kedi 应用领域的冰山一角）。

```ru
# file: p1.rule.rb

name "sources"
description "从 Elasticsearch 中取数据"

from :elasticsearch do
  hosts "192.168.5.19:7200", "192.168.5.20:9200"
  indices "our-web-app-access-record-*"

  # 每隔 10 秒拉取一次数据
  polling_interval "10second"

  # Elasticsearch 查询
  query :filter => { ... }, :both => { ... }, :range => { ... }
end

from :elasticsearch do
  hosts "192.168.5.19:7200", "192.168.5.20:9200"
  indices "our-web-app-error-*"

  polling_interval "4sec"
  query :range => { ... }
end
```

```ru
# file: p2.rule.rb

from :pipeline, :name => "sources"
select do |event|
  both(
    morethan(event.payload.),
    isnt(event.host, "dev")
  )
end

fulfilled do |event|
  inside(event.payload)
end

to :sms do |event|
  message "yyy"
end
```

```ru
# file: p3.rule.rb

name "calc"

from :pipeline, :name => "sources"
calc :count

fulfilled do |event|
  morethan(event.payload, 100)
end

to :http do |event|
  message "xxx"
  url "http://notify.internal/xxx"
end
```
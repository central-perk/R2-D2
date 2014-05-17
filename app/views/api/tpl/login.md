### 用户登陆日志

记录用户登陆信息

---

#### 数据提交接口

    {
        method: get,
        url: http://127.0.0.1:8001?_type=openLogin&timestamp=1400126353482&openID=12345&appID=1&token=134sdfaisodu
    }


需要提供三个参数：

- _type：日志类型, 此处为openLogin
- timestamp： 时间戳
- openID：用户ID

<a class="login create">提交测试数据</a>(正式环境下请勿提交)

#### 数据强制入库接口

    {
        method: post,
        url: http://127.0.0.1:8001/storage
    }

该接口为了演示入库效果，以及需要查看最新的数据。因此除此之外，不建议强制入库，使用该接口可能引起数据丢失。

<a class="login storage">文件数据强制入库</a>

#### 数据列表
<a class="login list">获取数据列表</a>

<div class="login_list"></div>



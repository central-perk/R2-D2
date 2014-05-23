### 用户登陆日志

准备：
+ 删除日志文件夹（/logs）中所有文件
+ 清空数据库表logmodels、logins、logfiles、auth

---

#### 创建日志模型
调用
```
{
    method：'post',
    url: '/logmodel'
    args：{
        type： 'login',
        attributes: [{
            key: 'openID',
            value: 'String'    
        }]
    }
}
```
> value可选的值: ['Boolean', 'String', 'Date', 'Number', 'Array', 'Object']

返回信息
```
{
    "status": 1,
    "message": "日志模型创建成功"
}
```

<a class="login create_model">创建日志模型</a>

#### 查看已创建的日志模型
调用
```
{
    method: 'get',
    url: '/logmodel'
}
```
返回信息
```
{
    "status": 1,
    "message": [
        "login"
    ]
}
```

<a class="login list_model">查看已创建的日志模型</a>

#### 获取授权
调用
```
{
    method: 'post',
    url: '/auth',
    args: {
        appName: '易传单'
    }
}
```
返回信息
```
{
    "status": 1,
    "message": {
        "appID": 1,
        "token": "a1d370b27868bc50d2fdfd5b9df21eb6"
    }
}
```

<a class="auth create_auth">获取授权</a>



#### 上传日志
```
{
    method: get,
    url: localhost/?type=login&ts=1400126353482&appID=1&token=a1d370b27868bc50d2fdfd5b9df21eb6&openID=123123
    url_params:{
        type: login,
        ts: 1400126353482,
        appID: 1,
        token: a1d370b27868bc50d2fdfd5b9df21eb6,
        openID: 123123
    }
}
```

<a class="login create_log">提交测试数据</a>
<div class="create_log_result"></div>


#### 数据列表
<a class="login list">获取数据列表</a>

<div class="login_list"></div>



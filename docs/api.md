1. [创建日志模型](#createDataModel)
2. [获取授权](#createAuth)
3. [上传日志数据](#uploadLog)

<h3 id="createAuth">获取授权</h3>
+ 调用

请求方式|接口
------|--- 
post|/auth

+ 请求参数

名称|类型|是否必须|默认值|描述
----|----|:------:|----|------|----
appName|String, 长度1～20|是| |应用名称

+ 返回参数

名称|类型|是否可能为空|描述
----|----|:------:|----
appID|Number|否|应用ID
token|String|否|令牌

+ 返回示例

```
{
    "status": 1,
    "message": {
        "appID": 1,
        "token": "a1d370b27868bc50d2fdfd5b9df21eb6"
    }
}
```

<h3 id="uploadLog">上传日志数据</h3>

+ 调用




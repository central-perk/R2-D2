# 日志服务器

### 功能描述

为易传单全线产品提供日志记录服务

### 代码语法
后端使用coffee编写


### 启动项目

- 启动 mongoDB
- 启动 redis
- sudo npm install
- sudo npm install pm2 (package.json 不需要写pm2配置)
- bower install
- gulp

### 发布至正式版
```
gulp build-pro
```

### 生产环境下启动：

```
pm2 start package.json
```

### 前端工具

 1. 使用webpack管理js代码依赖，打包发布js
 2. gulp构建和发布css

### 重启服务功能
必须以pm2方式启动服务才有效
 
    

#基础镜像
FROM registry:5000/base-openresty-1:1.13.6.1

#设置系统时区
ENV TZ Asia/Shanghai

#copy程序
RUN mkdir -p -m 777 /run/apigateway/logs 
COPY ./ /run/apigateway

#切换工作目录
WORKDIR /run/apigateway

#执行
CMD ["openresty","-g", "daemon off;master_process on;", "-p", ".", "-c", "conf/nginx.conf"]

FROM amazonlinux:latest
RUN amazon-linux-extras install -y epel >/dev/null && \
    yum install -y java-11-amazon-corretto-headless
    
RUN mkdir -p /opt/dms/app
ADD target/sp-supplier-service-0.0.1-SNAPSHOT.jar /opt/dms/app/application.jar
CMD ["java","-jar","/opt/dms/app/application.jar"]
EXPOSE 8083

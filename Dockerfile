FROM maven:3.9.4-amazoncorretto-20-al2023 as build

COPY . /app
WORKDIR /app
RUN mvn clean install

FROM amazoncorretto:11.0.20-al2023
RUN yum install -y net-tools
ARG JAR_FILE=/app/target/*.jar
COPY --from=build ${JAR_FILE} /app/app.jar
ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar /opt/opentelemetry-javaagent.jar
ENV JAVA_TOOL_OPTIONS=-javaagent:/opt/opentelemetry-javaagent.jar
#ADD https://github.com/aws-observability/aws-otel-java-instrumentation/releases/latest/download/aws-opentelemetry-agent.jar /opt/aws-opentelemetry-agent.jar
#ENV JAVA_TOOL_OPTIONS=-javaagent:/opt/aws-opentelemetry-agent.jar

ENV OTEL_RESOURCE_ATTRIBUTES "service.name=DemoApp"
#ENV OTEL_IMR_EXPORT_INTERVAL "5000"
ENV OTEL_SERVICE_NAME="DemoApp"
ENV OTEL_EXPORTER_OTLP_ENDPOINT "http://localhost:4318"

WORKDIR /app
ENTRYPOINT java -jar ${JAVA_OPTS} ${JAVA_TOOL_OPTIONS} app.jar

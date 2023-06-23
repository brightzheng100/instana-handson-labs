# Lab 3.6 – Configuration-based Instrumentation

## Step 1: Start up the Spring Boot app (again)

```sh
# The Git repository should have been cloned in Lab 2.2
# Refer to Lab 2.2 if you haven't done that
cd ~/springboot-swagger-jpa-stack

# Start up the app
nohup bash -c "mvn spring-boot:run" &> app.out & echo $! > app.pid

# Start up the load-gen
nohup bash -c "./load-gen.sh" &> load.out & echo $! > load.pid
```

## Step 4: Update the agent config by adding an new file

```sh
cat <<EOF | sudo tee /opt/instana/agent/etc/instana/configuration-springboot.yaml
com.instana.plugin.javatrace:
  instrumentation:
    sdk:
      targets:
        - match:
            type: class
            name: app.controller.StudentController
            method: findStudentById
          span:
            name: findStudentById
            type: ENTRY
            stackDepth: 0
            tags:
              - kind: argument
                name: student_id
                index: 0
        - match:
            type: class
            name: app.controller.StudentController
            method: createStudent
          span:
            name: createStudent
            type: ENTRY
            stackDepth: 0
            tags:
              - kind: argument
                name: student
                index: 0
EOF
```

## Key findings

### New instrumented endpoints

There will be two newly instrumented endpoints:
- `sdk.findStudentById`, replacing original `GET /api/v1/students/{id}`
- `sdk.createStudent`, replacing original `POST /api/v1/students`

By the way, the name like `sdk.findStudentById` can be further tuned as well in above yaml configuration.


### Tracing context will be enhanced

In all transactions in `sdk.findStudentById` endpoint, a new tag will be added.
For example, "student_id = 90001".

In all transactions in `` end point, a new tag will be added.
For example, "student = {student_id: 90001, student_nid: test, student_name: test}"


### Such tags can be used as filter for Smart Alert

Such tags, or officially under Call -> Tag, can be used as part of the filters, among Application, Service(s), and Endpoint(s).

By doing so, we can limit to some specific transactions of Application/Service(s)/Endpoint(s) for alerting.
For example: the student info with id as 90001 can be retrieved maximumly 500 times per 5 minutes, otherwise alert me.

# SREN System – Smart Recommendation using Emotion Recognition

SREN is a modular, Spring Boot–based backend capable of recognising user emotions and delivering personalised recommendations.  
It is composed of multiple Java microservices, a Spring Cloud Gateway, Eureka discovery, Config Server, a MySQL datastore, and a lightweight Python (Flask) inference stub.

---

## Architecture at a Glance

| Component | Purpose | Ports |
|-----------|---------|-------|
| `discovery-server` | Eureka registry for service discovery | `8761` |
| `config-server` | Centralised configuration delivery | `8888` |
| `api-gateway` | Spring Cloud Gateway entry point & routing | `8080` (public) |
| `auth-service` | JWT-based authentication (register/login) | `9001` |
| `emotion-service` | Consumes Python API to persist emotion snapshots | `9002` |
| `recommender-service` | Generates recommendations based on recent emotion | `9003` |
| `user-service` | Manages profile data and emotion history sync | `9004` |
| `notification-service` | Logs outbound notifications (email/SMS placeholder) | `9005` |
| `python-emotion` | Flask stub returning dummy emotion predictions | `5001` |
| `mysql` | Persistent storage backing all Java services | `3306` |

Services communicate using REST + Feign clients, authenticate through JWT, and register with Eureka. Configuration is pulled from the config server with fallback defaults included in each service’s `application.yml`.

---

## Prerequisites

1. **Java 17** (for local development outside Docker)  
2. **Maven 3.9+**  
3. **Docker & Docker Compose v2**  
4. **Python 3.10+** *(only if you intend to run the Flask service directly)*

Clone the repository and switch to the project root:

```bash
git clone <repo-url>
cd sren-system
```

---

## Configuration

- All runtime configuration defaults live in `config-server/src/main/resources/config`.  
- `.env` in the repository root controls Docker Compose variables (ports, database credentials, service URLs).  
- Each Spring Boot service reads configuration from Config Server via `spring.config.import=optional:configserver:http://${CONFIG_SERVER_HOST:config-server}:${CONFIG_SERVER_PORT:8888}`. Environment overrides can be supplied as container variables or JVM properties.

---

## Building Locally

### Java Microservices
```bash
cd backend
mvn clean package -DskipTests
```
Artifacts are produced under each service’s `target/` directory (e.g., `auth-service/target/auth-service-0.0.1-SNAPSHOT.jar`).

### Config & Discovery Servers
```bash
cd ../config-server
mvn clean package -DskipTests

cd ../discovery-server
mvn clean package -DskipTests
```

### Python Emotion Stub
The Flask app has no build step. Dependencies are captured in the Docker image. To run locally:
```bash
cd ml-models/recommendation-engine
pip install -r requirements.txt  # (if present) otherwise install flask, tensorflow, etc.
python app.py
```
> By default it listens on `0.0.0.0:5001` and exposes `/health`, `/predict`, `/analyze`.

---

## Running Everything with Docker Compose

From the project root:

```bash
docker compose --env-file .env up --build
```

This builds all Maven modules (inside containers), starts MySQL, discovery, config server, Python inference, every microservice, and the API gateway.

### Health Checks

| URL | Description |
|-----|-------------|
| `http://localhost:8761` | Eureka dashboard (should list all services as `UP`) |
| `http://localhost:8888/actuator/health` | Config server health |
| `http://localhost:8080/actuator/health` | API gateway health (requires actuator starter) |
| `http://localhost:5001/health` | Python emotion service health |

---

## End-to-End Smoke Flow

1. **Register & Login**
   ```bash
   curl -X POST http://localhost:8080/api/v1/auth/register \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"password123","fullName":"Test User"}'

   curl -X POST http://localhost:8080/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"password123"}'
   ```
   Both responses return a JWT (`token`) for subsequent authenticated calls (if you enable security on downstream services).

2. **Log an Emotion Snapshot**
   ```bash
   curl -X POST http://localhost:8080/api/v1/emotions/analyze \
     -H "Content-Type: application/json" \
     -d '{"userId":1,"imageData":"<base64>" ,"source":"curl"}'
   ```
   The gateway forwards the request to `emotion-service`, which calls the Python stub (`/analyze`) and persists the result in MySQL.

3. **Fetch Latest Emotion**
   ```bash
   curl http://localhost:8080/api/v1/emotions/1/latest
   ```

4. **Generate a Recommendation**
   ```bash
   curl -X POST http://localhost:8080/api/v1/recommendations \
     -H "Content-Type: application/json" \
     -d '{"userId":1}'
   ```
   This queries `emotion-service` for the latest emotion via Feign, derives a recommendation, stores it, and returns the payload via the gateway.

5. **Notification Example**
   ```bash
   curl -X POST http://localhost:8080/api/v1/notifications \
     -H "Content-Type: application/json" \
     -d '{"userId":1,"channel":"EMAIL","message":"Hello"}'
   ```
   The service logs the notification event (no real email/SMS integration yet).

6. **User Profile Sync**
   ```bash
   curl -X PUT http://localhost:8080/api/v1/users \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","fullName":"Test User","preferences":"news"}'
   ```
   ```bash
   curl http://localhost:8080/api/v1/users/1/emotions/sync
   ```
   The sync endpoint fetches the latest emotion snapshot and records it against the user profile history.

---

## Running Services Individually (Optional)

You can start components manually when iterating locally:

1. **MySQL**: `docker run --name mysql -e MYSQL_ROOT_PASSWORD=rootpwd -p 3306:3306 mysql:8.0`
2. **Discovery**: `java -jar discovery-server/target/discovery-server-0.0.1-SNAPSHOT.jar`
3. **Config**: `java -jar config-server/target/config-server-0.0.1-SNAPSHOT.jar`
4. **Python Service**: `python ml-models/recommendation-engine/app.py`
5. **Each Spring Boot service**: `java -jar backend/<service>/target/<service>-0.0.1-SNAPSHOT.jar`

Ensure you export the environment variables found in `.env` (e.g., `CONFIG_SERVER_HOST`, `DISCOVERY_HOST`, `MYSQL_HOST`, etc.) for the services you start outside Docker.

---

## Troubleshooting

- **Gateway 404 / 503**: verify the route starts with `/api/v1/...`. Ensure both discovery and config servers report healthy; the gateway depends on them during startup.
- **Python 404**: the Java service posts to `/analyze` with `imageUrl` or `imageData`. Update `ml-models/recommendation-engine/app.py` if you deploy a different model.
- **Database connectivity issues**: Confirm the MySQL container is healthy (`docker compose ps mysql`) and the JDBC URL matches `.env`.
- **Eureka registration missing**: Re-check `@EnableDiscoveryClient` annotations and `spring-cloud-starter-netflix-eureka-client` dependency entries in each service’s `pom.xml`.
- **Config fetch errors**: Ensure `config-server` has booted before any other service. In Docker, the compose file’s health checks already enforce this ordering.

---

## Next Steps

- Replace the Flask stub with a production-ready emotion model and adjust `PythonEmotionResponse` as needed.
- Implement real notification channels (email/SMS) in `notification-service`.
- Add integration tests or contract tests across microservices using WireMock/Testcontainers.
- Deploy to Kubernetes by translating the compose setup into Helm charts or Kustomize manifests.

---

## License

Project licensing is not defined in this repository. Add an appropriate license file if you intend to distribute or open source the work.


# Automed - Global Healthcare Delivery Automation Platform
.PHONY: help dev-up dev-down dev-logs dev-clean build test clean flutter-deps flutter-build flutter-test docker-build docker-push k8s-deploy k8s-delete helm-install helm-upgrade helm-uninstall performance-test security-scan integration-test setup-monitoring

# Default target
help:
	@echo "Automed - Global Healthcare Delivery Automation Platform"
	@echo ""
	@echo "🚀 Development Commands:"
	@echo "  dev-up              Start development environment"
	@echo "  dev-down            Stop development environment"
	@echo "  dev-logs            Show development logs"
	@echo "  dev-clean           Clean development environment"
	@echo "  setup-dev           Setup complete development environment"
	@echo ""
	@echo "🔨 Build & Test Commands:"
	@echo "  build               Build all services"
	@echo "  test                Run all tests"
	@echo "  integration-test    Run integration tests"
	@echo "  performance-test    Run performance tests"
	@echo "  security-scan       Run security scans"
	@echo "  clean               Clean build artifacts"
	@echo ""
	@echo "📱 Flutter Commands:"
	@echo "  flutter-deps        Get Flutter dependencies"
	@echo "  flutter-build       Build Flutter app"
	@echo "  flutter-test        Run Flutter tests"
	@echo "  flutter-analyze     Analyze Flutter code"
	@echo ""
	@echo "🐳 Docker Commands:"
	@echo "  docker-build        Build Docker images"
	@echo "  docker-push         Push Docker images"
	@echo "  docker-scan         Scan Docker images for vulnerabilities"
	@echo ""
	@echo "☸️  Kubernetes Commands:"
	@echo "  k8s-deploy          Deploy to Kubernetes"
	@echo "  k8s-delete          Delete from Kubernetes"
	@echo "  helm-install        Install with Helm"
	@echo "  helm-upgrade        Upgrade with Helm"
	@echo "  helm-uninstall      Uninstall with Helm"
	@echo ""
	@echo "📊 Monitoring Commands:"
	@echo "  setup-monitoring    Setup monitoring stack"
	@echo "  logs                View application logs"
	@echo "  metrics             View application metrics"
	@echo ""
	@echo "🔒 Security Commands:"
	@echo "  security-scan       Run comprehensive security scans"
	@echo "  dependency-check    Check for vulnerable dependencies"
	@echo "  container-scan      Scan container images"

# Development Environment
dev-up:
	docker-compose -f docker-compose.dev.yml up -d
	@echo "Development environment started!"
	@echo "Services available at:"
	@echo "  API Gateway: http://localhost:8080"
	@echo "  Eureka Server: http://localhost:8761"
	@echo "  Patient Service: http://localhost:8081"
	@echo "  Hospital Service: http://localhost:8082"
	@echo "  Consultation Service: http://localhost:8083"
	@echo "  Sync Service: http://localhost:8084"
	@echo "  AI Service: http://localhost:8085"
	@echo "  Clinical Decision Service: http://localhost:8086"
	@echo "  Workflow Automation Service: http://localhost:8087"
	@echo "  Telemedicine Service: http://localhost:8088"
	@echo "  Emergency Response Service: http://localhost:8089"
	@echo "  Kafka UI: http://localhost:8090"
	@echo "  Redis Commander: http://localhost:8091"
	@echo "  PgAdmin: http://localhost:8092"

dev-down:
	docker-compose -f docker-compose.dev.yml down

dev-logs:
	docker-compose -f docker-compose.dev.yml logs -f

dev-clean:
	docker-compose -f docker-compose.dev.yml down -v --remove-orphans
	docker system prune -f

# Build & Test
build:
	@echo "Building backend services..."
	cd backend/api-gateway && ./gradlew build
	cd backend/patient-service && ./gradlew build
	cd backend/hospital-service && ./gradlew build
	cd backend/consultation-service && ./gradlew build
	cd backend/sync-service && ./gradlew build
	cd backend/ai-service && ./gradlew build
	cd backend/clinical-decision-service && ./gradlew build
	cd backend/workflow-automation-service && ./gradlew build
	cd backend/telemedicine-service && ./gradlew build
	cd backend/emergency-response-service && ./gradlew build
	@echo "Building Flutter app..."
	cd frontend/automed_app && flutter build apk --release

test:
	@echo "Running backend tests..."
	cd backend/api-gateway && ./gradlew test
	cd backend/patient-service && ./gradlew test
	cd backend/hospital-service && ./gradlew test
	cd backend/consultation-service && ./gradlew test
	cd backend/sync-service && ./gradlew test
	cd backend/ai-service && ./gradlew test
	@echo "Running Flutter tests..."
	cd frontend/automed_app && flutter test

clean:
	@echo "Cleaning backend build artifacts..."
	cd backend/api-gateway && ./gradlew clean
	cd backend/patient-service && ./gradlew clean
	cd backend/hospital-service && ./gradlew clean
	cd backend/consultation-service && ./gradlew clean
	cd backend/sync-service && ./gradlew clean
	cd backend/ai-service && ./gradlew clean
	@echo "Cleaning Flutter build artifacts..."
	cd frontend/automed_app && flutter clean

# Flutter
flutter-deps:
	cd frontend/automed_app && flutter pub get
	cd frontend/automed_app && dart run build_runner build --delete-conflicting-outputs

flutter-build:
	cd frontend/automed_app && flutter build apk --release
	cd frontend/automed_app && flutter build web --release
	cd frontend/automed_app && flutter build windows --release

flutter-test:
	cd frontend/automed_app && flutter test
	cd frontend/automed_app && flutter test integration_test/

# Docker
docker-build:
	docker-compose build

docker-push:
	docker-compose push

# Kubernetes
k8s-deploy:
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/
	@echo "Deployed to Kubernetes!"

k8s-delete:
	kubectl delete -f k8s/
	@echo "Deleted from Kubernetes!"

# Database migrations
db-migrate:
	@echo "Running database migrations..."
	cd backend/patient-service && ./gradlew flywayMigrate
	cd backend/hospital-service && ./gradlew flywayMigrate
	cd backend/consultation-service && ./gradlew flywayMigrate

# Security scan
security-scan:
	@echo "Running security scans..."
	cd backend && ./gradlew dependencyCheckAnalyze
	cd frontend/automed_app && flutter pub deps --json | dart pub global run pana

# Performance test
perf-test:
	@echo "Running performance tests..."
	# Add performance testing commands here

# Setup development environment
setup-dev:
	@echo "Setting up development environment..."
	make flutter-deps
	make dev-up
	@echo "Development environment ready!"
# Flutte
r commands
flutter-analyze:
	cd frontend/automed_app && flutter analyze

# Docker security scanning
docker-scan:
	@echo "Scanning Docker images for vulnerabilities..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		-v $(PWD):/app aquasec/trivy image automed/api-gateway:latest
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		-v $(PWD):/app aquasec/trivy image automed/patient-service:latest

# Helm commands
helm-install:
	@echo "Installing Automed with Helm..."
	helm install automed ./helm/automed \
		--namespace automed \
		--create-namespace \
		--values ./helm/automed/values.yaml

helm-upgrade:
	@echo "Upgrading Automed with Helm..."
	helm upgrade automed ./helm/automed \
		--namespace automed \
		--values ./helm/automed/values.yaml

helm-uninstall:
	@echo "Uninstalling Automed..."
	helm uninstall automed --namespace automed

# Integration testing
integration-test:
	@echo "Running integration tests..."
	cd frontend/automed_app && flutter drive \
		--driver=test_driver/integration_test.dart \
		--target=integration_test/app_integration_test.dart

# Performance testing
performance-test:
	@echo "Running performance tests..."
	cd performance-tests && npm install
	cd performance-tests && artillery run load-test.yml --output report.json
	cd performance-tests && artillery report report.json --output report.html
	@echo "Performance test report generated: performance-tests/report.html"

# Security scanning
security-scan: dependency-check container-scan
	@echo "Running comprehensive security scan..."
	
dependency-check:
	@echo "Checking for vulnerable dependencies..."
	cd backend && ./gradlew dependencyCheckAnalyze
	cd frontend/automed_app && flutter pub deps --json | dart pub global run pana

container-scan:
	@echo "Scanning containers for vulnerabilities..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		-v $(PWD):/app aquasec/trivy fs --security-checks vuln,config .

# Monitoring setup
setup-monitoring:
	@echo "Setting up monitoring stack..."
	kubectl create namespace monitoring || true
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update
	helm install prometheus prometheus-community/kube-prometheus-stack \
		--namespace monitoring \
		--set grafana.adminPassword=admin123
	@echo "Monitoring stack installed!"
	@echo "Grafana: kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
	@echo "Prometheus: kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"

# Logging
logs:
	@echo "Viewing application logs..."
	kubectl logs -f deployment/api-gateway -n automed

# Metrics
metrics:
	@echo "Opening metrics dashboard..."
	kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 &
	@echo "Grafana available at: http://localhost:3000 (admin/admin123)"

# Advanced deployment
deploy-staging:
	@echo "Deploying to staging environment..."
	helm upgrade --install automed-staging ./helm/automed \
		--namespace automed-staging \
		--create-namespace \
		--values ./helm/automed/values-staging.yaml

deploy-production:
	@echo "Deploying to production environment..."
	helm upgrade --install automed-production ./helm/automed \
		--namespace automed-production \
		--create-namespace \
		--values ./helm/automed/values-production.yaml

# Backup and restore
backup:
	@echo "Creating backup..."
	kubectl create job --from=cronjob/automed-backup backup-$(shell date +%Y%m%d-%H%M%S) -n automed

restore:
	@echo "Restoring from backup..."
	@echo "Please specify backup file: make restore BACKUP_FILE=backup-20240101-120000"

# Load testing with different scenarios
load-test-light:
	cd performance-tests && artillery run load-test-light.yml

load-test-heavy:
	cd performance-tests && artillery run load-test-heavy.yml

stress-test:
	cd performance-tests && artillery run stress-test.yml

# Code quality
code-quality:
	@echo "Running code quality checks..."
	cd backend && ./gradlew sonarqube
	cd frontend/automed_app && flutter analyze --write=analysis_output.txt

# Documentation
docs-serve:
	@echo "Starting documentation server..."
	cd docs && python -m http.server 8000
	@echo "Documentation available at: http://localhost:8000"

docs-build:
	@echo "Building documentation..."
	cd docs && mkdocs build

# Environment management
env-create:
	@echo "Creating new environment..."
	@echo "Environment name: $(ENV_NAME)"
	kubectl create namespace automed-$(ENV_NAME)
	helm install automed-$(ENV_NAME) ./helm/automed \
		--namespace automed-$(ENV_NAME) \
		--values ./helm/automed/values-$(ENV_NAME).yaml

env-destroy:
	@echo "Destroying environment: $(ENV_NAME)"
	helm uninstall automed-$(ENV_NAME) --namespace automed-$(ENV_NAME)
	kubectl delete namespace automed-$(ENV_NAME)

# Health checks
health-check:
	@echo "Running health checks..."
	curl -f http://localhost:8080/health || echo "API Gateway: UNHEALTHY"
	curl -f http://localhost:8081/actuator/health || echo "Patient Service: UNHEALTHY"
	curl -f http://localhost:8082/actuator/health || echo "Hospital Service: UNHEALTHY"
	curl -f http://localhost:8083/actuator/health || echo "Consultation Service: UNHEALTHY"

# Complete setup for new developers
setup-complete: flutter-deps dev-up
	@echo "🎉 Complete setup finished!"
	@echo ""
	@echo "✅ Services started:"
	@echo "   - API Gateway: http://localhost:8080"
	@echo "   - Frontend: Run 'cd frontend/automed_app && flutter run'"
	@echo "   - Eureka: http://localhost:8761"
	@echo "   - Kafka UI: http://localhost:8090"
	@echo "   - Redis Commander: http://localhost:8091"
	@echo "   - PgAdmin: http://localhost:8092"
	@echo ""
	@echo "🚀 Ready to develop!"

# Cleanup everything
cleanup-all: dev-clean
	@echo "Cleaning up everything..."
	docker system prune -af --volumes
	docker network prune -f
	kubectl delete namespace automed automed-staging automed-production --ignore-not-found=true
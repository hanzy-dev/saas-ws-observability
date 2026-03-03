SHELL := /bin/sh

.PHONY: up down restart ps logs pull reset demo-traffic

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

ps:
	docker compose ps

logs:
	docker compose logs -f --tail=200

pull:
	docker compose pull

reset:
	docker compose down -v
	docker compose up -d

demo-traffic:
	docker run --rm --network saas-ws-observability_default curlimages/curl:8.7.1 \
		-sS http://hello-api:8080/ping >/dev/null
	docker run --rm --network saas-ws-observability_default curlimages/curl:8.7.1 \
		-sS -X POST http://hello-api:8080/echo \
		-H 'Content-Type: application/json' \
		-d '{"message":"hi"}' >/dev/null
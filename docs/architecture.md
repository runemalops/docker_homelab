# Arquitectura del homelab

Mapa de servicios actuales y del flujo de trabajo con `opencode`.
Fuente de verdad: `docker-compose.yml`, `services/*/docker-compose*.yml`,
`configs/traefik/` y los stacks de `ansible/` + `tofu/`.

## Servicios y publicación

```mermaid
flowchart TB
    subgraph INET["Internet"]
        USER["Clientes HTTPS<br/>(*.runemal.cloud)"]
        CF["Cloudflare Edge<br/>DNS + Zero Trust"]
    end

    USER -->|TLS| CF
    CF <-->|"tunnel QUIC (TUNNEL_TOKEN)"| CFD["cloudflared<br/>red: web"]

    CFD -->|"navidrome · jellyfin · bikerzone<br/>rutas retiradas → 404"| TR["traefik :80<br/>file provider"]
    CFD -->|"origen directo (LAN)"| LAN["192.168.1.99:3000/8000/8443<br/>192.168.1.99:8080 · 192.168.1.21:2368"]
    LAN -. "bikerzone-prod-nginx<br/>alias 'bikerzone'" .-> BFZ

    TR --> NAV["navidrome :4533"]
    TR --> JEL["jellyfin :8096"]
    TR --> BFZ["bikerzone-prod-nginx :80"]
    TR --> DASH["dashboard traefik<br/>api@internal"]

    subgraph HOST["Host homelab — docker compose (make start/ps/logs)"]
        direction TB

        subgraph NETW["Red homelab_network"]
            direction LR
            WEB["web: nginx:8081 · nextcloud:8444<br/>wordpress:8082"]
            UTIL["utilities: homepage:3001 · gitea:3002/2222<br/>vaultwarden:3003 · uptime-kuma:3004"]
            NETG["networking: pihole:8083 · wireguard:51820<br/>nginx-proxy-manager:8084"]
            MEDIA2["media: sonarr:8989 · radarr:7878<br/>qbittorrent:8085 · navidrome:4533 · jellyfin:8096"]
        end

        subgraph MON["Red monitoring_network"]
            PROM["prometheus:9090"] --> GRAF["grafana:3000"]
            NODE["node-exporter"] & CADV["cadvisor:8086"] --> PROM
        end

        subgraph DATA["Red databases_network / volúmenes"]
            PG["postgres:5432"] & RD["redis:6379"] & MA["mariadb:3306"]
        end

        VOL[("volúmenes nombrados<br/>*_data · *_config · prometheus_data")]
    end

    GRAF -. "scrape" .-> NETW
    WEB & UTIL -. "dependen de" .-> DATA
```

### Redes

| Red | Uso |
|---|---|
| `homelab_network` | backbone: casi todos los servicios |
| `web_network` | `traefik`, `cloudflared` y los backends publicados |
| `monitoring_network` | prometheus, grafana, node-exporter, cadvisor |
| `databases_network` / `networking_network` | aislamiento de DBs y de pihole/wireguard/NPM |

### Superficie publicada hoy

| Vía | Hostnames / rutas |
|---|---|
| `traefik` (file provider, `configs/traefik/dynamic/`) | `navidrome`, `jellyfin`, `bikerzone`, `traefik` dashboard |
| Túnel Cloudflare (origen directo LAN) | `www` (192.168.1.21:2368), `git`, `ci`, `crafty`, `bookheaven` (192.168.1.99) |
| Solo puertos LAN (sin proxy) | nginx, nextcloud, wordpress, sonarr, radarr, qbittorrent, gitea, vaultwarden, homepage, uptime-kuma, pihole, wireguard, NPM, prometheus, grafana, cadvisor |

## Cómo integra opencode el homelab

```mermaid
flowchart LR
    A["1 · Diagnóstico<br/>docker ps / logs<br/>docker compose config<br/>curl traefik y túnel"] --> B["2 · Edición infra-as-code<br/>docker-compose.yml + services/*<br/>configs/traefik · ansible/ · tofu/"]
    B --> C["3 · Validación<br/>docker compose config --quiet<br/>make start / make ps<br/>pytest · tofu plan"]
    C -->|"ok"| D["4 · Despliegue<br/>scripts/deploy.sh<br/>make deploy / update"]
    C -->|"error: vuelve a B"| B
    D --> E["5 · Documentación<br/>README · docs/architecture.md"]
    E --> A
    D -.->|aplica cambios| HOST["Stack en ejecución"]
    A -.->|lee estado| HOST
```

| Fase | Qué hace opencode | Punto de aplicación |
|---|---|---|
| Diagnóstico | `docker ps`, `docker logs`, `docker compose config`, `curl` contra traefik/túnel | localiza la causa raíz (p. ej. el schema roto de `jellyfin` que bloqueaba todo el stack) |
| Edición | modifica en un mismo flujo compose, Traefik, Ansible y OpenTofu | `docker-compose.yml`, `services/*`, `configs/traefik`, `ansible/`, `tofu/` |
| Validación | `make start/ps`, `tofu plan`, tests antes de aplicar | evita despliegues rotos y regresiones de red o puertos |
| Despliegue | `scripts/deploy.sh`, `make deploy/update` | reconstruye contenedores y redes de forma reproducible |
| Documentación | README, diagramas, resúmenes de Ansible | el mapa de servicios queda sincronizado con el código |

## Puntos pendientes

- `traefik` solo usa `file provider`: las labels `traefik.*` de los compose no tienen efecto, por eso el resto de servicios no está tras el proxy.
- `traefik` está únicamente en `web_network` y los backends viven en `homelab_network` → 502 hasta corregir la red.
- Quedan reglas residuales en la config remota del túnel (Zero Trust, token) de servicios ya retirados; devuelven 404 y hay que borrarlas desde el dashboard de Cloudflare.
- `www.runemal.cloud → 192.168.1.21:2368` no responde (origen caído).

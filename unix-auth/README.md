# uim-unix-auth-service

A POSIX/UNIX authentication management service implemented with **D** and **vibe.d**, aligned with **Clean** and **Hexagonal** architecture.

Features:

- Read and manipulate `passwd` and `shadow` sources (default `/etc/passwd` and `/etc/shadow`).
- Compare and create password hashes through libc `crypt`.
- Create compatible UNIX crypt salts for `sha512`, `sha256`, and `md5`.
- Expose both JSON HTTP controllers and MVC HTML pages.
- Runtime compatibility with Docker, Podman, Cloud Foundry, and Kubernetes.

## Architecture layout

```text
unix-auth/
├── dub.sdl
├── Dockerfile
├── Containerfile
├── manifest.yml
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── README.md
├── Readme.md
├── Nafv4.md
├── UML.md
└── source/
    ├── app.d
    └── uim/infrastructure/unix_auth_service/
        ├── domain/
        │   ├── entities/unix_user.d
        │   └── ports/
        │       ├── repositories/unix_auth_repository.d
        │       └── security/password_crypto.d
        ├── application/
        │   ├── dto/
        │   │   ├── create_user_command.d
        │   │   └── password_command.d
        │   └── usecases/
        │       ├── list_users.d
        │       ├── get_user.d
        │       ├── create_user.d
        │       ├── set_password.d
        │       ├── generate_hash.d
        │       └── verify_password.d
        └── infrastructure/
            ├── persistence/files/unix_auth_repository.d
            ├── security/crypt_password_crypto.d
            └── http/
                ├── controllers/
                │   ├── api_controller.d
                │   └── web_controller.d
                └── views/html_renderer.d
```

## HTTP JSON API

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/health` | Health check |
| `GET` | `/v1/unix/users` | List users from passwd + shadow |
| `GET` | `/v1/unix/users/<username>` | User detail |
| `POST` | `/v1/unix/users` | Create user + shadow hash |
| `POST` | `/v1/unix/users/<username>/password` | Set password hash in shadow |
| `POST` | `/v1/unix/hash` | Generate hash + salt with crypt |
| `POST` | `/v1/unix/verify` | Verify password against existing hash |

### Example payloads

Create user:

```json
{
  "username": "appsvc",
  "uid": 2100,
  "gid": 2100,
  "gecos": "Application Service",
  "homeDirectory": "/home/appsvc",
  "loginShell": "/bin/bash",
  "password": "secret123"
}
```

Set password:

```json
{
  "password": "newSecret",
  "algorithm": "sha512"
}
```

Generate hash:

```json
{
  "password": "myPassword",
  "algorithm": "sha256"
}
```

Verify password:

```json
{
  "password": "myPassword",
  "existingHash": "$6$5N8xk9a2Q7QfYlfZ$..."
}
```

## MVC HTML routes

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/` | User list page |
| `GET` | `/users` | User list page |
| `GET` | `/users/new` | Create user form |
| `POST` | `/users/new` | Submit create user form |
| `GET` | `/users/<username>` | User detail + password update form |
| `POST` | `/users/<username>/password` | Update password hash |
| `GET` | `/hash` | Hash generator page |
| `POST` | `/hash` | Generate hash from form |

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `PORT` | `8080` | HTTP listen port |
| `BIND_ADDRESS` | `0.0.0.0` | Bind address |
| `PASSWD_FILE` | `/etc/passwd` | Path to passwd data source |
| `SHADOW_FILE` | `/etc/shadow` | Path to shadow data source |

## Local run

```bash
cd unix-auth
dub run
```

For non-root development, use sandbox files:

```bash
cp /etc/passwd ./passwd.sample
cp /etc/shadow ./shadow.sample
PASSWD_FILE=./passwd.sample SHADOW_FILE=./shadow.sample dub run
```

## Docker

```bash
docker build -t uim-unix-auth-service .
docker run --rm -p 8080:8080 -e PASSWD_FILE=/data/passwd -e SHADOW_FILE=/data/shadow uim-unix-auth-service
```

## Podman

```bash
podman build -t uim-unix-auth-service .
podman run --rm -p 8080:8080 -e PASSWD_FILE=/data/passwd -e SHADOW_FILE=/data/shadow uim-unix-auth-service
```

## Cloud Foundry

```bash
cf push -f manifest.yml
```

## Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Security note

Manipulating real `/etc/shadow` requires elevated privileges and can lock out system users if malformed data is written. Prefer running this service against dedicated sandbox copies of passwd/shadow files except in controlled administration environments.

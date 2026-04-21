# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
# StyleHub-Project

## Docker

This project now includes a local Docker setup for development and demos.

1. Add your Stripe key to `.env` in the project root:

```env
STRIPE_SECRET_KEY=your_rotated_test_key
```

2. Build and start the app:

```bash
docker compose up --build
```

3. Open the app at:

```text
http://127.0.0.1:3000
```

Useful commands:

```bash
docker compose down
docker compose up
docker compose logs -f web
```

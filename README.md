# Decisive Team

<img src="public/icon.svg" width="33%"/>

Decisive Team is a group decision-making tool that uses a 3 step decision-making protocol:
1. Ask a question.
2. Gather options.
3. Decide through approval voting.

Learn more at [decisive.team](https://decisive.team).

## Development
Docker and Docker Compose are the only dependencies you need to have installed to run the app. For initial setup, first create a `.env` file for your environment variables.

```bash
cp .env.example .env
```

For development, you don't need to change any variables from `.env.example`. For production, you do.

Then use `setup.sh` to build the docker containers and initialize the database. You only need to run this once.

```bash
./scripts/setup.sh
```

To start the containers, run

```bash
./scripts/start.sh
```

To stop, run

```bash
./scripts/stop.sh
```

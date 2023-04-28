# Decisive Team

<img src="public/icon.svg" width="33%"/>

Decisive Team is a group decision-making tool that uses a 3 step decision-making protocol:
1. Ask a question.
2. Gather options.
3. Decide through approval voting.

Learn more at [decisive.team](https://decisive.team).

## Development
Docker and Docker Compose are the only dependencies you need to have installed to run the app. For initial setup, use `setup.sh`. This will build the docker containers and initialize the database. You only need to run this once.

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

# Decisive Team

This codebase now encompasses both [Decisive Team](https://decisive.team) and [Coordinated Team](https://coordinated.team).

### Decisive Team

<img src="public/decisive-icon.svg" width="20%"/>

Decisive Team is a group decision-making tool that uses a 3 step decision-making protocol:
1. Ask a question.
2. Gather options.
3. Decide through [acceptance voting](https://decisiveteam.substack.com/p/acceptance-voting).

Learn more at [decisive.team](https://decisive.team).

### Coordinated Team

<img src="public/coordinated-icon.svg" width="20%"/>

Coordinated Team is a group coordination tool based on the concept of reciprocal commitments.

Reciprocal commitments are commitments that are conditional on a critical mass of participants all making the same commitment.

Learn more at [coordinated.team](https://coordinated.team).


## Development
Docker and Docker Compose are the only dependencies you need to have installed to run the app. For initial setup, first create a `.env` file for your environment variables.

```bash
cp .env.example .env
```

For development, you probably won't need to change any variables from `.env.example`, unless you are using a remote dev environment like GitHub Codespaces, in which case you will need to set `HOSTNAME` to the correct domain. For production, you will need to change other variables also.

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

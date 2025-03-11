# Bookclicker Application

This guide covers the setup and deployment instructions for the BookClicker application, including steps to initialize the database schema from `structure.sql` and seed the database using Rails seeds.

## Prerequisites

Before proceeding, ensure you have the following installed on your system:

- Docker
- Docker Compose

## Setup

### 1. **Clone the Repository**

First, clone the repository to your local machine:

```sh
git clone https://github.com/behrk2/bookclicker.git
cd bookclicker
```

### 2. **Build the Docker Containers**

Build the Docker containers using Docker Compose:

```sh
docker-compose build
```

This command builds the images for your application and database based on the configurations defined in `docker-compose.yml`.

### 3. **Initialize the Database**

Start the containers. If the database container is being started for the first time, it will automatically load the `structure.sql` file to set up the database schema:

```sh
docker-compose up -d
```

The `-d` flag runs the containers in the background.

### 4. **Seed the Database**

To populate the database with initial data defined in `db/seeds.rb`, run the following command:

```sh
docker-compose exec app bundle exec rake db:seed
```

This command executes the Rails seeding task within the running application container.

## Running the Application

- To start the application (if not already running):

```sh
docker-compose up -d
```

- The application should now be accessible at `http://localhost:3000` (or another port if you've configured it differently in `docker-compose.yml`).

## Additional Commands

- To stop the containers:

```sh
docker-compose down
```

- To view the logs of the application container:

```sh
docker-compose logs app
```

- To enter the application container for debugging purposes:

```sh
docker-compose exec app /bin/bash
```

- To delete all of your Docker containers, images, and volumes:

```sh
docker-compose down -v --rmi all --remove-orphans
docker system prune -a --volumes
```

## Notes

- Remember to rebuild your Docker containers (`docker-compose build`) if you make changes to the Dockerfile or the application's dependencies.
- The database is only seeded once manually. If you need to reseed, repeat the seeding command.
- If you make a frontend UI change that requires a rebuild (e.g., updates to JavaScript, CSS, or other static assets), run the precompile command in the Docker container:

```sh
docker-compose exec app bundle exec rake assets:precompile
```

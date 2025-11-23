# Take Home Exercise

This repository contains a Jupyter notebook with exercises on cohort analysis and customer value forecasting.

## Prerequisites

- Docker
- Docker Compose

## Getting Started

### 1. Launch the Jupyter Notebook

Start the Jupyter environment using Docker Compose:

```bash
docker-compose up --build
```

This will:
- Build the Docker image with Python 3.11 and required dependencies
- Start a Jupyter notebook server
- Make the notebook accessible at `http://localhost:8888`

### 2. Access the Notebook

Open your web browser and navigate to:

```
http://localhost:8888
```

The notebook server runs without authentication for local development convenience.

### 3. Open the Exercise

In the Jupyter interface, click on `takehome.ipynb` to start working on the exercises.

### 4. Stop the Server

When you're done, stop the container:

```bash
docker-compose down
```

Or press `Ctrl+C` in the terminal where it's running.

## What's Included

- **takehome.ipynb** - Main exercise notebook covering:
  - Exercise 1: Payment data transformation to cohort format
  - Exercise 2: Applying predictions to cohort data
  - Exercise 3: Threshold application logic
  - Exercise 4: CVF cashflow calculations

## Dependencies

- pandas >= 2.0.0
- jupyter >= 1.0.0
- notebook >= 7.0.0

All dependencies are automatically installed in the Docker container.

run_test:
	@echo "\nRunning Tests\n"
	docker build -t pg_historical_tables .
	docker run -it --rm pg_historical_tables

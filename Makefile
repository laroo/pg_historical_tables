run_test:
	@echo "\nRunning Tests\n"
	docker build -t pg_historical_tables .
	docker run -it --rm pg_historical_tables /pg/test/run_tests.sh

performance_test:
	@echo "\nRunning Performance Test\n"
	docker build -t pg_historical_tables .
	docker run -it --rm pg_historical_tables /pg/test/run_performance_test.sh temporal_trigger_function.sql

performance_test_optimized:
	@echo "\nRunning Performance Test\n"
	docker build -t pg_historical_tables .
	docker run -it --rm pg_historical_tables /pg/test/run_performance_test.sh temporal_trigger_function_optimized.sql


performance_test_original:
	@echo "\nRunning Performance Test\n"
	docker build -t pg_historical_tables .
	docker run -it --rm pg_historical_tables /pg/test/run_performance_test.sh extension_temporal_tables


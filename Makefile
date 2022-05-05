run_test:
	docker build -t pg_historical_tables .
	docker run -it --rm pg_historical_tables /pg/test/run_tests.sh


run_performance_test_pg_historical_tables_debug:
	docker build -t pg_historical_tables .
	docker run -it --rm pg_historical_tables /pg/test/run_performance_test.sh pg_historical_tables_debug 


run_performance_test_pg_historical_tables_optimized:
	docker build -t pg_historical_tables .
	docker run -it --rm pg_historical_tables /pg/test/run_performance_test.sh pg_historical_tables_optimized 


performance_test_nearform_temporal_tables:
	docker build -t pg_historical_tables .
	docker run -it --rm pg_historical_tables /pg/test/run_performance_test.sh nearform_temporal_tables


performance_test_nearform_temporal_tables_nochecks:
	docker build -t pg_historical_tables .
	docker run -it --rm pg_historical_tables /pg/test/run_performance_test.sh nearform_temporal_tables_nochecks


performance_test_extension_temporal_tables:
	docker build -t pg_historical_tables .
	docker run -it --rm pg_historical_tables /pg/test/run_performance_test.sh extension_temporal_tables

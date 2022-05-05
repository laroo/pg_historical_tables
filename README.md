# pg_historical_tables

Hybrid temporal/historical tables for PostgreSQL (RDS compatible)

Based on https://github.com/nearform/temporal_tables


## Performance

| Extension                         | Insert      | Update       | Delete       |
|-----------------------------------|-------------|--------------|--------------|
| pg_historical_tables_debug        | 5261.510 ms | 47164.371 ms | 41445.687 ms |
| pg_historical_tables_optimized    | 4043.908 ms | 37492.552 ms | 45897.886 ms |
| nearform_temporal_tables          | 1715.725 ms | 13881.452 ms | 11543.187 ms |
| nearform_temporal_tables_nochecks |  398.140 ms |  4703.188 ms |  4944.596 ms |
| extension_temporal_tables         |   60.575 ms |   622.103 ms |   569.177 ms |

## License

Licensed under [MIT](./LICENSE).
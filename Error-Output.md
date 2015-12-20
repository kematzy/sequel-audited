# RESULTS OUTPUT

## 1) PostgreSQL test run - (reference)
### with `DB[:audit_log].model_pk` column as `:integer`

No problems, all tests pass.

```bash
06:37:50 [rerun] Sequel-audited restarted
Using DB=[postgres://kematzy@localhost/sequel-audited-test]
Run options: --seed 4729

# Running:

..S...................S..............S...........S...........S........

Finished in 0.816878s, 85.6921 runs/s, 157.9183 assertions/s.

70 runs, 129 assertions, 0 failures, 0 errors, 5 skips

You have skipped tests. Run with --verbose for details.

06:37:59 [rerun] Sequel-audited succeeded
```


## 2) PostgreSQL test run - (with errors)

### with `DB[:audit_log].model_pk` column as `:text`

```ruby
# only change in spec/spec_helper.rb
DB.create_table!(:audit_logs) do
  primary_key :id
  column :model_type,       :text
  column :model_pk,         :text  # NOTE! changed to :text from :integer
  <snip...>
```

The above change results in the following errors. (see below)

All the errors are related to the `one_to_many` code which on Postgres does not handle the conversion of '*integer*' value(s) into '*string*' value(s), or the reversed scenario.

If you look at the DB, the `DB[:audit_log]` table actually stores the values correctly as `:text`.

<br>

```bash
06:38:49 [rerun] Change detected: 1 modified: spec_helper.rb
06:38:49 [rerun] Sending signal TERM to 47135

06:38:50 [rerun] Sequel-audited restarted
Using DB=[postgres://kematzy@localhost/sequel-audited-test]
Run options: --seed 31090

# Running:

E...E.........E.......F.E.E.......SEE..F....EES.....SSS..E.......E.E..

Finished in 0.750242s, 93.3032 runs/s, 117.2954 assertions/s.

  1) Error:
configuration::without options passed::#audited_current_user_method#test_0002_should use the :current_user User:
Sequel::DatabaseError: PG::UndefinedFunction: ERROR:  operator does not exist: text = integer
LINE 1: ..._type" = 'Category') AND ("audit_logs"."model_pk" = 5)) ORDE...
                                                             ^
HINT:  No operator matches the given name and argument type(s). You might need to add explicit type casts.

    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `async_exec'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `block in execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/logging.rb:33:in `log_yield'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:147:in `check_disconnect_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:524:in `_execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block (2 levels) in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:545:in `check_database_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `block in synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/connection_pool/threaded.rb:103:in `hold'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:950:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:668:in `fetch_rows'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:831:in `with_sql_each'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `block in with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:890:in `_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/placeholder_literalizer.rb:138:in `all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2131:in `_load_associated_object_array'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2142:in `_load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2240:in `load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:1767:in `block in def_association_method'
    /Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:93:in `block (4 levels) in <class:SequelAuditedPluginTest>'


  2) Error:
with Custom user method#test_0001_should:
Sequel::DatabaseError: PG::UndefinedFunction: ERROR:  operator does not exist: text = integer
LINE 1: ...el_type" = 'Author') AND ("audit_logs"."model_pk" = 3)) ORDE...
                                                             ^
HINT:  No operator matches the given name and argument type(s). You might need to add explicit type casts.

    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `async_exec'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `block in execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/logging.rb:33:in `log_yield'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:147:in `check_disconnect_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:524:in `_execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block (2 levels) in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:545:in `check_database_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `block in synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/connection_pool/threaded.rb:103:in `hold'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:950:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:668:in `fetch_rows'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:831:in `with_sql_each'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `block in with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:890:in `_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/placeholder_literalizer.rb:138:in `all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2131:in `_load_associated_object_array'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2142:in `_load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2240:in `load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:1767:in `block in def_association_method'
    /Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:584:in `block (2 levels) in <class:SequelAuditedPluginTest>'


  3) Error:
An audited Model :Author::Instance Methods::Hooks::when destroying a record, triggering #.after_destroy#test_0001_should save an audited version with all values:
Sequel::DatabaseError: PG::UndefinedFunction: ERROR:  operator does not exist: text = integer
LINE 1: ..._type" = 'Category') AND ("audit_logs"."model_pk" = 18)) ORD...
                                                             ^
HINT:  No operator matches the given name and argument type(s). You might need to add explicit type casts.

    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `async_exec'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `block in execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/logging.rb:33:in `log_yield'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:147:in `check_disconnect_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:524:in `_execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block (2 levels) in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:545:in `check_database_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `block in synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/connection_pool/threaded.rb:103:in `hold'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:950:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:668:in `fetch_rows'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:831:in `with_sql_each'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `block in with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:890:in `_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/placeholder_literalizer.rb:138:in `all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2131:in `_load_associated_object_array'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2142:in `_load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2240:in `load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:1767:in `block in def_association_method'
    /Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:507:in `block (5 levels) in <class:SequelAuditedPluginTest>'


  4) Failure:
An audited Model :Author::Class Methods::#.audited_versions::without options#test_0002_should return an array of versions if one version have been created [/Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:318]:
Expected: 16
  Actual: "16"


  5) Error:
An audited Model :Author::Instance Methods::Hooks::when updating a record, triggering #.after_update#test_0001_should save an audited version with changes only:
Sequel::DatabaseError: PG::UndefinedFunction: ERROR:  operator does not exist: text = integer
LINE 1: ..._type" = 'Category') AND ("audit_logs"."model_pk" = 19)) ORD...
                                                             ^
HINT:  No operator matches the given name and argument type(s). You might need to add explicit type casts.

    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `async_exec'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `block in execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/logging.rb:33:in `log_yield'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:147:in `check_disconnect_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:524:in `_execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block (2 levels) in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:545:in `check_database_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `block in synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/connection_pool/threaded.rb:103:in `hold'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:950:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:668:in `fetch_rows'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:831:in `with_sql_each'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `block in with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:890:in `_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/placeholder_literalizer.rb:138:in `all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2131:in `_load_associated_object_array'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2142:in `_load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2240:in `load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:1767:in `block in def_association_method'
    /Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:487:in `block (5 levels) in <class:SequelAuditedPluginTest>'


  6) Error:
An audited Model :Author::Instance Methods::#.last_audited_at (aliased as: #.last_audited_on)#test_0002_should return the created_at time of the last version:
Sequel::DatabaseError: PG::UndefinedFunction: ERROR:  operator does not exist: text = integer
LINE 1: ...el_type" = 'Author') AND ("audit_logs"."model_pk" = 17)) ORD...
                                                             ^
HINT:  No operator matches the given name and argument type(s). You might need to add explicit type casts.

    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `async_exec'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `block in execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/logging.rb:33:in `log_yield'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:147:in `check_disconnect_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:524:in `_execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block (2 levels) in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:545:in `check_database_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `block in synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/connection_pool/threaded.rb:103:in `hold'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:950:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:668:in `fetch_rows'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:831:in `with_sql_each'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `block in with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:890:in `_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/placeholder_literalizer.rb:138:in `all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2131:in `_load_associated_object_array'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2142:in `_load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2240:in `load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:1767:in `block in def_association_method'
    /Users/kematzy/Desktop/sequel-audited/lib/sequel/plugins/audited.rb:235:in `last_audited_at'
    /Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:452:in `block (4 levels) in <class:SequelAuditedPluginTest>'


  7) Error:
An audited Model :Author::Class Methods::#.audited_versions::with options::(model_pk: ??)#test_0001_should return an empty array when given a model primary key without audits:
Sequel::DatabaseError: PG::UndefinedFunction: ERROR:  operator does not exist: text = integer
LINE 1: SELECT * FROM "audit_logs" WHERE (("model_pk" = 999) AND ("m...
                                                      ^
HINT:  No operator matches the given name and argument type(s). You might need to add explicit type casts.

    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `async_exec'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `block in execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/logging.rb:33:in `log_yield'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:147:in `check_disconnect_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:524:in `_execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block (2 levels) in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:545:in `check_database_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `block in synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/connection_pool/threaded.rb:103:in `hold'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:950:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:668:in `fetch_rows'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:137:in `each'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:45:in `block in all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:890:in `_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:45:in `all'
    /Users/kematzy/Desktop/sequel-audited/lib/sequel/plugins/audited.rb:175:in `audited_versions'
    /Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:363:in `block (6 levels) in <class:SequelAuditedPluginTest>'


  8) Error:
An audited Model :Author::Class Methods::#.audited_versions::with options::(model_pk: ??)#test_0002_should return found audits when given an audited primary key:
Sequel::DatabaseError: PG::UndefinedFunction: ERROR:  operator does not exist: text = integer
LINE 1: SELECT * FROM "audit_logs" WHERE (("model_pk" = 25) AND ("mo...
                                                      ^
HINT:  No operator matches the given name and argument type(s). You might need to add explicit type casts.

    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `async_exec'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `block in execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/logging.rb:33:in `log_yield'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:147:in `check_disconnect_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:524:in `_execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block (2 levels) in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:545:in `check_database_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `block in synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/connection_pool/threaded.rb:103:in `hold'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:950:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:668:in `fetch_rows'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:137:in `each'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:45:in `block in all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:890:in `_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:45:in `all'
    /Users/kematzy/Desktop/sequel-audited/lib/sequel/plugins/audited.rb:175:in `audited_versions'
    /Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:368:in `block (6 levels) in <class:SequelAuditedPluginTest>'


  9) Failure:
An audited Model :Author::Instance Methods::Hooks::when creating a record, triggering #.after_create#test_0001_should save an audited version [/Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:475]:
Expected: 28
  Actual: "28"


 10) Error:
An audited Model :Author::Class Methods::#.audited_versions?#test_0002_should return true if one version have been created:
Sequel::DatabaseError: PG::UndefinedFunction: ERROR:  operator does not exist: text = integer
LINE 1: ...el_type" = 'Author') AND ("audit_logs"."model_pk" = 26)) ORD...
                                                             ^
HINT:  No operator matches the given name and argument type(s). You might need to add explicit type casts.

    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `async_exec'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `block in execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/logging.rb:33:in `log_yield'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:147:in `check_disconnect_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:524:in `_execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block (2 levels) in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:545:in `check_database_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `block in synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/connection_pool/threaded.rb:103:in `hold'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:950:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:668:in `fetch_rows'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:831:in `with_sql_each'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `block in with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:890:in `_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/placeholder_literalizer.rb:138:in `all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2131:in `_load_associated_object_array'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2142:in `_load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2240:in `load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:1767:in `block in def_association_method'
    /Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:263:in `block (4 levels) in <class:SequelAuditedPluginTest>'


 11) Error:
An audited Model :Author::Class Methods::#.audited_versions?#test_0003_should return true if multiple versions have been created:
Sequel::DatabaseError: PG::UndefinedFunction: ERROR:  operator does not exist: text = integer
LINE 1: ...el_type" = 'Author') AND ("audit_logs"."model_pk" = 27)) ORD...
                                                             ^
HINT:  No operator matches the given name and argument type(s). You might need to add explicit type casts.

    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `async_exec'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `block in execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/logging.rb:33:in `log_yield'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:147:in `check_disconnect_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:524:in `_execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block (2 levels) in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:545:in `check_database_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `block in synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/connection_pool/threaded.rb:103:in `hold'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:950:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:668:in `fetch_rows'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:831:in `with_sql_each'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `block in with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:890:in `_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/placeholder_literalizer.rb:138:in `all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2131:in `_load_associated_object_array'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2142:in `_load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2240:in `load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:1767:in `block in def_association_method'
    /Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:271:in `block (4 levels) in <class:SequelAuditedPluginTest>'


 12) Error:
An audited Model :Author::Instance Methods::#.blame (aliased as: #.last_audited_by)#test_0002_should return the username of the last version:
Sequel::DatabaseError: PG::UndefinedFunction: ERROR:  operator does not exist: text = integer
LINE 1: ...el_type" = 'Author') AND ("audit_logs"."model_pk" = 36)) ORD...
                                                             ^
HINT:  No operator matches the given name and argument type(s). You might need to add explicit type casts.

    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `async_exec'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `block in execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/logging.rb:33:in `log_yield'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:147:in `check_disconnect_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:524:in `_execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block (2 levels) in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:545:in `check_database_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `block in synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/connection_pool/threaded.rb:103:in `hold'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:950:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:668:in `fetch_rows'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:831:in `with_sql_each'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `block in with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:890:in `_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/placeholder_literalizer.rb:138:in `all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2131:in `_load_associated_object_array'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2142:in `_load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2240:in `load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:1767:in `block in def_association_method'
    /Users/kematzy/Desktop/sequel-audited/lib/sequel/plugins/audited.rb:221:in `blame'
    /Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:437:in `block (4 levels) in <class:SequelAuditedPluginTest>'


 13) Error:
An audited Model :Author::should have associated versions#test_0003_should :
Sequel::DatabaseError: PG::UndefinedFunction: ERROR:  operator does not exist: text = integer
LINE 1: ...el_type" = 'Author') AND ("audit_logs"."model_pk" = 37)) ORD...
                                                             ^
HINT:  No operator matches the given name and argument type(s). You might need to add explicit type casts.

    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `async_exec'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `block in execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/logging.rb:33:in `log_yield'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:147:in `check_disconnect_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:524:in `_execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block (2 levels) in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:545:in `check_database_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `block in synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/connection_pool/threaded.rb:103:in `hold'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:950:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:668:in `fetch_rows'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:831:in `with_sql_each'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `block in with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:890:in `_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/placeholder_literalizer.rb:138:in `all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2131:in `_load_associated_object_array'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2142:in `_load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2240:in `load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:1767:in `block in def_association_method'
    /Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:551:in `block (3 levels) in <class:SequelAuditedPluginTest>'


 14) Error:
An audited Model :Author::should have associated versions#test_0002_should :
Sequel::DatabaseError: PG::UndefinedFunction: ERROR:  operator does not exist: text = integer
LINE 1: ...el_type" = 'Author') AND ("audit_logs"."model_pk" = 38)) ORD...
                                                             ^
HINT:  No operator matches the given name and argument type(s). You might need to add explicit type casts.

    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `async_exec'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `block in execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/logging.rb:33:in `log_yield'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:184:in `execute_query'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:147:in `check_disconnect_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:171:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:524:in `_execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block (2 levels) in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:545:in `check_database_errors'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `block in execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `block in synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/connection_pool/threaded.rb:103:in `hold'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/database/connecting.rb:249:in `synchronize'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:340:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:950:in `execute'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/adapters/postgres.rb:668:in `fetch_rows'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:831:in `with_sql_each'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `block in with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:890:in `_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/actions.rb:814:in `with_sql_all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/dataset/placeholder_literalizer.rb:138:in `all'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2131:in `_load_associated_object_array'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2142:in `_load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:2240:in `load_associated_objects'
    /Users/kematzy/.rbenv/versions/2.2.2/lib/ruby/gems/2.2.0/gems/sequel-4.29.0/lib/sequel/model/associations.rb:1767:in `block in def_association_method'
    /Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:541:in `block (3 levels) in <class:SequelAuditedPluginTest>'

70 runs, 88 assertions, 2 failures, 12 errors, 5 skips

You have skipped tests. Run with --verbose for details.
rake aborted!
```


## 3) SQLite3 tests run

### with `DB[:audit_log].model_pk` column as `:text`

The test failures are understandable and can be easily overcome.

```bash
06:46:25 [rerun] Change detected: 1 modified: .env.test
06:46:25 [rerun] Sending signal TERM to 48394

06:46:28 [rerun] Sequel-audited restarted
Using DB=[sqlite://spec/sequel-audited-test.db]    # NOTE! using SQLite3
Run options: --seed 5

# Running:

..F..S.......................S............S........SSF..F............F

Finished in 0.816422s, 85.7400 runs/s, 153.1071 assertions/s.

  1) Failure:
An audited Model :Author::Instance Methods::Hooks::when updating a record, triggering #.after_update#test_0001_should save an audited version with changes only [/Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:496]:
Expected: 5
  Actual: "5"


  2) Failure:
An audited Model :Author::Instance Methods::Hooks::when destroying a record, triggering #.after_destroy#test_0001_should save an audited version with all values [/Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:519]:
Expected: 35
  Actual: "35"


  3) Failure:
An audited Model :Author::Instance Methods::Hooks::when creating a record, triggering #.after_create#test_0001_should save an audited version [/Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:475]:
Expected: 36
  Actual: "36"


  4) Failure:
An audited Model :Author::Class Methods::#.audited_versions::without options#test_0002_should return an array of versions if one version have been created [/Users/kematzy/Desktop/sequel-audited/spec/sequel/plugins/audited_spec.rb:318]:
Expected: 38
  Actual: "38"

70 runs, 125 assertions, 4 failures, 0 errors, 5 skips

You have skipped tests. Run with --verbose for details.
rake aborted!
```

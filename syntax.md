```
rules_description ->
                    `rules` `:` (-rule_decription)+

rule_description ->
					          sources_declaration?
                    filter_directive?
                    inject_directive?
                    state_store_directive?
                    calculation_type_directive?
                    probe_directive
                    destinations_declaration?

sources_declaration ->
                      `from` `:` (-source_declaration)+

source_declaration ->
                      `name` `:` string
                      (`polling_interval` `:` time_literal)?
                      source_specified_options?

filter_directive ->
                    `select` `:` filter_clause

filter_clause -> filter_condition_literal | ruby_code_str

filter_condition_literal ->

inject_directive ->
                    `overwrite_with` `:` inject_clause

inject_clause -> attr_path | ruby_code_str

ruby_code_str -> string

attr_path -> array

state_store_directive ->
                          `use` `:` state_store_clause

state_store_clause ->
                      `store`: store_type
                      `sort_by` `:` (`event_time` | `birth_time`)
                      `enable_delay` `:` time_literal
                      store_specified_options?

store_type ->
              `window` | `rolling_list`
              | `ring`
              | `hash`

store_specified_options ->

calculation_type_directive ->
                              `for` `:` calculation_type_clause

calculation_type_clause ->
                            `count` | `rate`
                            | `means`
                            | `moving_average`
                            | `sum`
                            | `max` | `min` | other_math_ops

probe_directive ->
                    `if` `:` probe_clause

probe_clause ->
                judge_condition_literal | ruby_code_str

judge_condition_literal ->
                            | `only` `:` logical_literal
                            | `either` `:` logical_literal
                            | `both` `:` logical_literal
                            | `not` `:` logical_literal

logical_literal ->
                    `equal` `:` number_literal | string
                    | `morethan` `:` number_literal
                    | `lessthan` `:` number_literal
                    | `in` `:` range
                    | `similar` `:` regexp
                    | `is` `:` string
                    | `start_with` `:` string
                    | `end_with` `:` string
                    | `include` `:` string
                    | `length` `:` integer
                    | `nan` `:` boolean
                    | `infinity` `:` boolean

destinations_declaration ->
                            `to` `:` (-destination_declaration)+

destination_declaration ->
                            `name` `:` string
                            destination_specified_options?

destination_specified_options ->
```
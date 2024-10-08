create table merlin.span (
  span_id integer not null,

  dataset_id integer not null,
  parent_id integer null,

  start_offset interval not null,
  duration interval null,
  type text not null,
  attributes jsonb not null,


  constraint span_synthetic_key
    primary key (dataset_id, span_id)
)
partition by list (dataset_id);

comment on table merlin.span is e''
  'A temporal window of interest. A span may be refined by its children, providing additional information over '
  'more specific windows.';

comment on column merlin.span.span_id is e''
  'The id for this span.';
comment on column merlin.span.dataset_id is e''
  'The dataset this span is part of.';
comment on column merlin.span.parent_id is e''
  'The span this span refines.';
comment on column merlin.span.start_offset is e''
  'The offset from the dataset start at which this span begins.';
comment on column merlin.span.duration is e''
  'The amount of time this span extends for.';
comment on column merlin.span.type is e''
  'The type of span, implying the shape of its attributes.';
comment on column merlin.span.attributes is e''
  'A set of named values annotating this span as a whole.';

create function merlin.span_integrity_function()
  returns trigger
  security invoker
  language plpgsql as $$begin
  if not exists(select from merlin.dataset d where d.id = new.dataset_id for key share of d)
  then
    raise exception 'foreign key violation: there is no dataset with id %', new.dataset_id;
  end if;
  return new;
end$$;

comment on function merlin.span_integrity_function() is e''
  'Used to simulate a foreign key constraint between span and dataset, to avoid acquiring a lock on the'
  'dataset table when creating a new partition of span. This function checks that a corresponding dataset'
  'exists for every inserted or updated span. A trigger that calls this function is added separately to each'
  'new partition of span.';

create constraint trigger insert_update_span_trigger
  after insert or update on merlin.span
  for each row
execute function merlin.span_integrity_function();

create procedure merlin.span_add_foreign_key_to_partition(table_name varchar)
  security invoker
  language plpgsql as $$begin
  execute 'alter table ' || table_name || ' add constraint span_has_parent_span
    foreign key (dataset_id, parent_id)
    references ' || table_name || '
    on update cascade
    on delete cascade;';
end$$;

comment on procedure merlin.span_add_foreign_key_to_partition is e''
  'Creates a self-referencing foreign key on a particular partition of the span table. This should be called'
  'on every partition as soon as it is created';

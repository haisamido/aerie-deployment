create table merlin.constraint_specification(
  plan_id integer not null
    references merlin.plan
      on update cascade
      on delete cascade,
  constraint_id integer not null,
  constraint_revision integer, -- latest is NULL
  enabled boolean not null default true,

  constraint constraint_specification_pkey
    primary key (plan_id, constraint_id),
  constraint plan_spec_constraint_exists
    foreign key (constraint_id)
      references merlin.constraint_metadata(id)
      on update cascade
      on delete restrict,
  constraint plan_spec_constraint_definition_exists
    foreign key (constraint_id, constraint_revision)
      references merlin.constraint_definition(constraint_id, revision)
      on update cascade
      on delete restrict
);

comment on table merlin.constraint_specification is e''
'The set of constraints to be checked for a given plan.';
comment on column merlin.constraint_specification.plan_id is e''
'The plan which this specification is for. Half of the primary key.';
comment on column merlin.constraint_specification.constraint_id is e''
'The id of a specific constraint in the specification. Half of the primary key.';
comment on column merlin.constraint_specification.constraint_revision is e''
'The version of the constraint definition to use. Leave NULL to use the latest version.';
comment on column merlin.constraint_specification.enabled is e''
'Whether to run a given constraint. Defaults to TRUE.';

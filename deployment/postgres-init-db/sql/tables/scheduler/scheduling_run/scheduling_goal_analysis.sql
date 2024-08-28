create table scheduler.scheduling_goal_analysis (
  analysis_id integer not null,
  goal_id integer not null,
  goal_revision integer not null,
  satisfied boolean not null,

  constraint scheduling_goal_analysis_primary_key
    primary key (analysis_id, goal_id, goal_revision),
  constraint scheduling_goal_analysis_references_scheduling_request
    foreign key (analysis_id)
      references scheduler.scheduling_request (analysis_id)
      on update cascade
      on delete cascade,
  constraint scheduling_goal_analysis_references_scheduling_goal
    foreign key (goal_id, goal_revision)
      references scheduler.scheduling_goal_definition
      on update cascade
      on delete cascade
);

comment on table scheduler.scheduling_goal_analysis is e''
  'The analysis of single goal from a scheduling run.';
comment on column scheduler.scheduling_goal_analysis.analysis_id is e''
  'The associated analysis ID.';
comment on column scheduler.scheduling_goal_analysis.goal_id is e''
  'The associated goal ID.';
comment on column scheduler.scheduling_goal_analysis.goal_revision is e''
  'The associated version of the goal definition used.';
comment on column scheduler.scheduling_goal_analysis.satisfied is e''
  'Whether the associated goal was satisfied by the scheduling run.';

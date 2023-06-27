include "globals.mzn";

enum Teachers;
enum Days;
enum Slots;

int: num_teachers; % Number of teachers
int: num_slots; % Number of slots
int: max_lesson_duration;  % The maximum length of any lesson (in slots)
int: num_days; % Number of days
array[1..num_teachers] of 1..max_lesson_duration: lesson_durations; % The duration of teacher lessons
array[1..num_teachers] of 1..max_lesson_duration: lessons_per_week; % The duration of teacher lessons

array[1..num_teachers, 1..num_days] of set of 1..num_slots: teacher_availability; % The slots a teacher is available
array[1..num_teachers, 1..num_days] of var 0..num_slots: starting_slot; % The allocated starting slot
array[1..num_teachers, 1..num_days] of var 0..num_slots: last_slot; % The allocated ending slot
array[1..num_teachers, 1..num_days] of var Slots: starting_slot_nomi; % The allocated starting slot
array[1..num_teachers, 1..num_days] of var Slots: last_slot_nomi; % The allocated ending slot

%Assignments of slots
constraint
forall(i in 1..num_teachers) (
  forall(d in 1..num_days)(
       if teacher_availability[i, d] != {}  /\ starting_slot[i,d] != 0 /\ last_slot[i,d] != 0 then (last_slot[i, d] = starting_slot[i, d] + lesson_durations[i] - 1) \/ (last_slot[i,d] = 0 /\ starting_slot[i,d] = 0)  endif
));

constraint
forall(i in 1..num_teachers) (
  forall(d in 1..num_days)(
  if teacher_availability[i,d] = {} then (starting_slot[i,d]= 0 /\ last_slot[i,d]=0) endif));
  
  
%No overlapping constraint
constraint 
forall(i,j in 1..num_teachers where i < j) (
  forall(d in 1..num_days)(
     if teacher_availability[i, d] != {}  /\ starting_slot[i,d] != 0 /\ last_slot[i,d] != 0 then (no_overlap(starting_slot[i, d], lesson_durations[i], starting_slot[j, d], lesson_durations[j])) endif
 ));


constraint
forall(i in 1..num_teachers) (
forall(d in 1..num_days)(
starting_slot[i,d]= 0 <-> last_slot[i,d]=0));

%Starting slot and last slot must me in teacher availability
constraint 
forall(i in 1..num_teachers) (
forall(d in 1..num_days)(
      if teacher_availability[i, d] != {}  /\ starting_slot[i,d] != 0 /\ last_slot[i,d] != 0 then ( starting_slot[i, d] in teacher_availability[i, d] /\ last_slot[i, d] in teacher_availability[i, d]) endif
));


%A teacher can have a maximum amount of lessons in a week
constraint forall(i in 1..num_teachers)(
  sum(d in 1..num_days)(last_slot[i, d] > 0 /\ starting_slot[i,d] > 0) = lessons_per_week[i]
);


solve satisfy;

%Output constraint
constraint 
forall(i in 1..num_teachers) (
    forall(d in 1..num_days)(
        if starting_slot[i,d] != 0 then starting_slot_nomi[i,d] = Slots[starting_slot[i,d]] else starting_slot_nomi[i,d] = Slots[length(Slots)] endif /\ 
        if last_slot[i,d] != 0 then last_slot_nomi[i,d] = Slots[last_slot[i,d]] else last_slot_nomi[i,d] = Slots[length(Slots)] endif
    )
);


output[" DAYS   "]; output[show(Teachers[i]) ++ "    " | i in 1..length(Teachers)];
output["\n"];
output[show(d) ++ "-" ++ show(Days[d]) ++ ": " ++ show(starting_slot_nomi[..,d]) ++ " \n" ++ show(d) ++ "-" ++ show(Days[d]) ++ ": " ++ show(last_slot_nomi[..,d]) ++ "\n" | d in 1..num_days];
output["\n"];
output ["Starting:  ", show(starting_slot), "\n", "Endings:   ", show(last_slot), "\n", "Lessons:   ", show(lessons_per_week), "\n",  "Duration:  ", show(lesson_durations), "\n" ];

% no overlapping slots function
predicate no_overlap(var int:s1, int:d1, var int:s2, int:d2) = s1 + d1 <= s2 \/ s2 + d2 <= s1;



